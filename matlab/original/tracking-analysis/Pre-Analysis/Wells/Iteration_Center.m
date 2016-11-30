%% Center correction (Center cannot be mean)
%% Creating Detected cell array
Detected{larena}=centers;%Spots for this arena detected from image
%%% Starting point for iteration is center of image
C0x=size(image_arena,2)/2; C0y=size(image_arena,2)/2;
Center_temp(larena,:)=[C0x,C0y];
%%% Creating Template
wellpos_temp=wellpositions;
wellpos_temp2=wellpos_temp+...
    repmat(Center_temp(larena,:),size(wellpos_temp,1),1);
Template{larena}=wellpos_temp2((FlyDB(DBentry).Geometry==1),:);%Spots template for this arena
%%% Calculating distances & Correcting numbering for detected
Distances_temp=pdist2(Template{larena},Detected{larena});
%%% Step 1: Find first which spot in template matches which spot in the
%%% detected. Assumption: the closest one.
MinDists=zeros(size(Detected{larena},1),1);
MinIdxs=zeros(size(Detected{larena},1),1);
for lcircle_Detected=1:size(Detected{larena},1)
    [MinDists(lcircle_Detected),MinIdxs(lcircle_Detected)]=min(Distances_temp(:,lcircle_Detected,:));
end
[~,sort_idx]=sort(MinIdxs);
Detected{larena}=Detected{larena}(sort_idx,:);
Template{larena}=Template{larena}(sort(MinIdxs),:);
% %% Plotting numbers
% imshow(image_arena);hold on
% NOP=100;
% ColorDetected=[0 176 240]/255;
% for lcircle=1:size(Detected{larena},1)
%     text(Detected{larena}(lcircle,1)+15,Detected{larena}(lcircle,2),...
%         num2str(lcircle),'Color',ColorDetected)
%     hold on
%     [hc,xc,yc]=circle_(Detected{larena}(lcircle,:),radii(lcircle),NOP);
%     set(hc,'Color',[0.5 0.5 0.5])
%     patch(xc,yc,ColorDetected,'FaceAlpha',0.5,'EdgeAlpha',0)
% end
% %%% Plotting yeast spots from well postitions template
% ColorTemplate=[255 255 0]/255;
% for lcircle=1:size(Template{larena},1)
%     text(Template{larena}(lcircle,1)+15,Template{larena}(lcircle,2),...
%         num2str(lcircle),'Color',ColorTemplate)
%     [hc,xc2,yc2]=circle_(Template{larena}(lcircle,:),1.5/params.px2mm,NOP);
%     set(hc,'Color',[0.5 0.5 0.5])
%     patch(xc2,yc2,ColorTemplate,'FaceAlpha',0.5,'EdgeAlpha',0)
% end
%% Loop through possible centers
%%% Starting point for iteration is center of image. Iteration goes on an
%%% are define by delta
delta=30;
if plot_CenterXY==1, figure('Position',[2221,353,2.5*560,620],'Color','w'); end
%% CHANGING Center X
ranges_X=C0x-delta:C0x+delta;
Diff_Cent_X=zeros(length(ranges_X),1);
Var_Cent_X=zeros(length(ranges_X),1);
lcentcounter=1;
for lcentx=ranges_X
    %%% Re-calculate template for this value of rotation
    wellpos_temp2=wellpos_temp+...
        repmat([lcentx Center_temp(larena,2)],size(wellpos_temp,1),1);
    Template{larena}=wellpos_temp2((FlyDB(DBentry).Geometry==1),:);%Spots template for this arena
    Template{larena}=Template{larena}(sort(MinIdxs),:);
    %%% Re-calculate differences on rotation
    distances=sqrt(sum((Template{larena}-Detected{larena}).^2,2));
    Diff_Cent_X(lcentcounter)=sum(distances);
    Var_Cent_X(lcentcounter)=var(distances);
    if plot_CenterXY==1
        %%% Plot wells
        subplot('Position',[0.07,0.1,0.4,0.8])
        cla
        axis off
        plot_spot_detection
        %%% Plot differences with rotation
        subplot('Position',[0.55,0.55,0.4,0.4])
        cla
        hold on
        h2=plot(ranges_X(1:lcentcounter),Diff_Cent_X(1:lcentcounter),'ob','MarkerFaceColor','b');
        pause(0.01)
    end
    lcentcounter=lcentcounter+1;
end
if plot_CenterXY==1,legend([h2],{'Center X'});end

[~,Diff_sort_idx]=sort(Diff_Cent_X);
[~,temp_centX_idx]=min(Var_Cent_X(Diff_sort_idx(1:3)));
centX_idx=Diff_sort_idx(temp_centX_idx);
if length(centX_idx)==1
    Center_temp(larena,1)=ranges_X(centX_idx);
else
    error('more than one min in CenterX')
end

%% CHANGING Center Y
ranges_Y=C0y-delta:C0y+delta;
Diff_Cent_Y=zeros(length(ranges_Y),1);
Var_Cent_Y=zeros(length(ranges_Y),1);
lcentcounter=1;
for lcenty=ranges_Y
    %%% Re-calculate template for this value of rotation
    wellpos_temp2=wellpos_temp+...
        repmat([Center_temp(larena,1) lcenty],size(wellpos_temp,1),1);
    Template{larena}=wellpos_temp2((FlyDB(DBentry).Geometry==1),:);%Spots template for this arena
    Template{larena}=Template{larena}(sort(MinIdxs),:);
    %%% Re-calculate differences on rotation
    distances=sqrt(sum((Template{larena}-Detected{larena}).^2,2));
    Diff_Cent_Y(lcentcounter)=sum(distances);
    Var_Cent_Y(lcentcounter)=var(distances);
    if plot_CenterXY==1
        %%% Plot wells
        subplot('Position',[0.07,0.1,0.4,0.8])
        cla
        axis off
        plot_spot_detection
        %%% Plot differences with rotation
        subplot('Position',[0.55,0.1,0.4,0.4])
        cla
        hold on
        h2=plot(ranges_Y(1:lcentcounter),Diff_Cent_Y(1:lcentcounter),'ob','MarkerFaceColor','b');
        pause(0.01)
    end
    lcentcounter=lcentcounter+1;
end
if plot_CenterXY==1,legend([h2],{'Center Y'});end

[~,Diff_sort_idx]=sort(Diff_Cent_Y);
[~,temp_centY_idx]=min(Var_Cent_Y(Diff_sort_idx(1:3)));
centY_idx=Diff_sort_idx(temp_centY_idx);
if length(centY_idx)==1
    Center_temp(larena,2)=ranges_Y(centY_idx);
else
    error('more than one min in CenterY')
end

%%% Plotting best fit
%%% Re-calculate template for this value of rotation and inner
%%% length
wellpos_temp2=wellpos_temp+...
    repmat(Center_temp(larena,:),size(wellpos_temp,1),1);
Template{larena}=wellpos_temp2((FlyDB(DBentry).Geometry==1),:);%Spots template for this arena

if plot_CenterXY==1
    subplot('Position',[0.07,0.1,0.4,0.8])
    hold off
    plot(Center_temp(larena,1),Center_temp(larena,2),'or')
    plot_spot_detection
end
%% Visualizing iteration area
% close all
% figure
% for larena=1:3
%     subplot(1,3,larena)
%     image_arena=(gray_image(AddCrop:param.frameH2-10,xCrop_ALL(larena,1)+AddCrop:xCrop_ALL(larena,2)-25));
%     imshow(image_arena)
%     hold on
%     delta=30;
%     plot(size(image_arena,2)/2,size(image_arena,1)/2,'oy')
%     plot([size(image_arena,2)/2+delta,size(image_arena,2)/2+delta,...
%         size(image_arena,2)/2-delta,size(image_arena,2)/2-delta],...
%         [size(image_arena,1)/2+delta,size(image_arena,1)/2-delta,...
%         size(image_arena,1)/2+delta,size(image_arena,1)/2-delta],'*b')
% end