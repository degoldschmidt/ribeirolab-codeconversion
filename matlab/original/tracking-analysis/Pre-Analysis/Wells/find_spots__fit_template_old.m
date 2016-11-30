%% Find Circles function in MATLAB
image_arena=(gray_image(AddCrop:param.frameH2-10,xCrop_ALL(larena,1)+AddCrop:xCrop_ALL(larena,2)-25));
[centers, radii] = imfindcircles(image_arena,[9 15],'ObjectPolarity','dark',...
    'Sensitivity',sensit_thr,'EdgeThreshold',edge_thr);%[9 15]
% h = viscircles(centers,radii,'DrawBackgroundCircle',false);

%% Creating Detected cell array
Detected{larena}=centers;%Spots for this arena detected ffrom image

if (size(centers,1)<=10)&&(size(centers,1)>=8)
    %% Calculating Center as mean
    Center_temp(larena,:)=mean(Detected{larena});
    
    %% Creating Template
    wellpos_temp=wellpositions;
    wellpos_temp2=wellpos_temp+...
        repmat(Center_temp(larena,:),size(wellpos_temp,1),1);
    Template{larena}=wellpos_temp2((Geometry_ALL(lfile,:)==1),:);%Spots template for this arena
    
    %% Calculating distances & Correcting numbering for detected
    Distances_temp=pdist2(Template{larena},Detected{larena});
    %%% Step 1: Find first which spot in template matches which spot in the
    %%% detected.
    MinDists=zeros(size(Detected{larena},1),1);
    MinIdxs=zeros(size(Detected{larena},1),1);
    for lcircle_Detected=1:size(Detected{larena},1)
        [MinDists(lcircle_Detected),MinIdxs(lcircle_Detected)]=min(Distances_temp(:,lcircle_Detected,:));
    end
    %%% Step 2: Rearrange Detected order, so when we calculate pdist2, we
    %%% care only about the diagonal.
    [~,sort_idx]=sort(MinIdxs);
    clear Detected_sort
    Detected_sort=Detected{larena}(sort_idx,:);
    Distances_temp=pdist2(Template{larena},Detected_sort);
    Detected{larena}=Detected_sort;
    %             %% Plot detected & template circles
    %             close all
    %             figure('Position',[2079,269,583,564],'Color','w')
    %             imagesc(image_arena);colormap(gray);
    %             xlim([xCrop_ALL(larena,1) xCrop_ALL(larena,2)]);axis off
    %             hold on
    %             plot_spot_detection
    
    
    %% Iteration to correct rotation and radius
    %%% Error in rotation and radius
    [TH_T1,R_T1]=cart2pol(Template{larena}(:,1),Template{larena}(:,2));%Polar coordinates of template
    [TH_D,R_D]=cart2pol(Detected{larena}(:,1),Detected{larena}(:,2));%Polar coordinates of detected
    %         Diff_R_TH=abs([TH_T-TH_D,R_T-R_D]);%Absolute difference in Theta and Rho
    
    close all
    figure('Position',[2221,353,2.5*560,620],'Color','w')
    ranges_rotation=-4:4;
    ranges_length=repmat(LengthInner_All(larena),1,length([-0.05:0.01:0.05]))-...
        LengthInner_All(larena)*[-0.05:0.01:0.05];
    Diff_Rot=zeros(length(ranges_rotation),1);
    Diff_Leng=zeros(length(ranges_length),1);
    
    %%% CHANGING INNER LENGTH
    llengthcounter=1;
    for llength=ranges_length
        %%% Re-calculate template for this value of rotation
        wellpos_temp=wellpositions(llength,DispAngle_All(larena));
        wellpos_temp2=wellpos_temp+...
            repmat(Center_temp(larena,:),size(wellpos_temp,1),1);
        Template{larena}=wellpos_temp2((Geometry_ALL(lfile,:)==1),:);%Spots template for this arena
        %%% Re-calculate differences on rotation
        [~,R_T]=cart2pol(Template{larena}(:,1),Template{larena}(:,2));
        %%% Plot wells
        subplot('Position',[0.07,0.1,0.4,0.8])
        axis off
        hold off
        plot_spot_detection
        
        
        %%% Plot differences with lengths
        subplot('Position',[0.55,0.55,0.4,0.4])
        hold on
        Diff_Leng(llengthcounter)=sum(abs(R_T-R_D));
        h1=plot(llength,Diff_Leng(llengthcounter),'or','MarkerFaceColor','r');
        
        pause(0.1)
        llengthcounter=llengthcounter+1;
    end
    legend([h1],{'Radius'})
    [~,lengthidx]=min(Diff_Leng);
    if length(lengthidx)==1
        LengthInner_All(larena)=ranges_length(lengthidx);
    else
        err('more than one min in inner length')
    end
    
    %%% CHANGING ROTATION
    lrotcounter=1;
    for lrot=ranges_rotation
        %%% Re-calculate template for this value of rotation
        wellpos_temp=wellpositions(LengthInner_All(larena),lrot);
        wellpos_temp2=wellpos_temp+...
            repmat(Center_temp(larena,:),size(wellpos_temp,1),1);
        Template{larena}=wellpos_temp2((Geometry_ALL(lfile,:)==1),:);%Spots template for this arena
        %%% Re-calculate differences on rotation
        [TH_T]=cart2pol(Template{larena}(:,1),Template{larena}(:,2));
        %%% Plot wells
        subplot('Position',[0.07,0.1,0.4,0.8])
        axis off
        plot_spot_detection
        
        
        %%% Plot differences with rotation
        subplot('Position',[0.55,0.1,0.4,0.4])
        hold on
        Diff_Rot(lrotcounter)=sum(abs(TH_T-TH_D));
        h2=plot(lrot,Diff_Rot(lrotcounter),'ob','MarkerFaceColor','b');
        
        pause(0.1)
        lrotcounter=lrotcounter+1;
    end
    legend([h2],{'Rotation'})
    [~,rotidx]=min(Diff_Rot);
    
    if length(rotidx)==1
        DispAngle_All(larena)=ranges_rotation(rotidx);
    else
        err('more than one min in rotation')
    end
    %%% Plotting the difference if the default parameters are used:
    subplot('Position',[0.55,0.55,0.4,0.4])
    plot(1.27*50,sum(abs(R_T1-R_D)),'om','MarkerFaceColor','m');
    subplot('Position',[0.55,0.1,0.4,0.4])
    plot(0,sum(abs(TH_T1-TH_D)),'om','MarkerFaceColor','m');
    
    %%% Plotting best fit
    %%% Re-calculate template for this value of rotation and inner
    %%% length
    wellpos_temp=wellpositions(LengthInner_All(larena),DispAngle_All(larena));
    wellpos_temp2=wellpos_temp+...
        repmat(Center_temp(larena,:),size(wellpos_temp,1),1);
    Template{larena}=wellpos_temp2((Geometry_ALL(lfile,:)==1),:);%Spots template for this arena
    % subplot('Position',[0.07,0.1,0.4,0.8])
    % hold off
    % plot(Center_temp(larena,1),Center_temp(larena,2),'or')
    % plot_spot_detection
    
    %% Transforming coordinates to have center in origin (reversed y)
    WellPositions_All(Geometry_ALL(lfile,:)==2,2*larena-1:2*larena)=...
        wellpos_temp2(Geometry_ALL(lfile,:)==2,:)-Center_temp(larena,:);
    
    WellPositions_All(Geometry_ALL(lfile,:)==1,2*larena-1:2*larena)=...
        Detected{larena}-Center_temp(larena,:);
    
    Center(larena,:)=Center_temp(larena,:)+[xCrop_ALL(larena,1)+AddCrop,AddCrop];
end