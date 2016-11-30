%% Iteration to correct rotation and radius
%%% Error in rotation and radius
if Case7_8==1; Template{larena}=Template{larena}(sort(MinIdxs),:);end

[TH_T1,R_T1]=cart2pol(Template{larena}(:,1),Template{larena}(:,2));%Polar coordinates of template
[TH_D,R_D]=cart2pol(Detected{larena}(:,1),Detected{larena}(:,2));%Polar coordinates of detected
%         Diff_R_TH=abs([TH_T-TH_D,R_T-R_D]);%Absolute difference in Theta and Rho

if plot_innerl_rotation==1, figure('Position',[2221,353,2.5*560,620],'Color','w'); end
%% CHANGING INNER LENGTH
ranges_length=repmat(LengthInner_All(larena),1,length([-0.05:0.005:0.05]))-...
    LengthInner_All(larena)*[-0.05:0.005:0.05];
Diff_Leng=zeros(length(ranges_length),1);
Var_Leng=zeros(length(ranges_length),1);
llengthcounter=1;
for llength=ranges_length
    %%% Re-calculate template for this value of rotation
    wellpos_temp=wellpositions(llength,DispAngle_All(larena));
    wellpos_temp2=wellpos_temp+...
        repmat(Center_temp(larena,:),size(wellpos_temp,1),1);
    Template{larena}=wellpos_temp2((FlyDB(DBentry).Geometry==1),:);%Spots template for this arena
    if Case7_8==1; Template{larena}=Template{larena}(sort(MinIdxs),:);end
    %%% Re-calculate differences on rotation
    [~,R_T]=cart2pol(Template{larena}(:,1),Template{larena}(:,2));
    Diff_Leng(llengthcounter)=sum(abs(R_T-R_D));
    Var_Leng(llengthcounter)=var(R_T-R_D);
    if plot_innerl_rotation==1
        %%% Plot wells
        subplot('Position',[0.07,0.1,0.4,0.8])
        cla
        axis off
        hold off
        plot_spot_detection
        %%% Plot differences with lengths
        subplot('Position',[0.55,0.55,0.4,0.4])
        cla
        hold on
        h1=plot(ranges_length(1:llengthcounter),Diff_Leng(1:llengthcounter),...
            'or','MarkerFaceColor','r');
        pause(0.1)
    end
    llengthcounter=llengthcounter+1;
end
if plot_innerl_rotation==1,legend([h1],{'Radius'});end
%%% Select among the three minimum distances, that one with the minimum
%%% variance
[~,Diff_sort_idx]=sort(Diff_Leng);
[~,temp_leng_idx]=min(Var_Leng(Diff_sort_idx(1:3)));
lengthidx=Diff_sort_idx(temp_leng_idx);
if length(lengthidx)==1
    LengthInner_All(larena)=ranges_length(lengthidx);
else
    err('more than one min in inner length')
end
%% CHANGING ROTATION
ranges_rotation=-5:.5:5;
Diff_Rot=zeros(length(ranges_rotation),1);
Var_Rot=zeros(length(ranges_rotation),1);

lrotcounter=1;
for lrot=ranges_rotation
    %%% Re-calculate template for this value of rotation
    wellpos_temp=wellpositions(LengthInner_All(larena),lrot);
    wellpos_temp2=wellpos_temp+...
        repmat(Center_temp(larena,:),size(wellpos_temp,1),1);
    Template{larena}=wellpos_temp2((FlyDB(DBentry).Geometry==1),:);%Spots template for this arena
    if Case7_8==1; Template{larena}=Template{larena}(sort(MinIdxs),:);end
    %%% Re-calculate differences on rotation
    [TH_T]=cart2pol(Template{larena}(:,1),Template{larena}(:,2));
    Diff_Rot(lrotcounter)=sum(abs(TH_T-TH_D));
    
    if plot_innerl_rotation==1
        %%% Plot wells
        subplot('Position',[0.07,0.1,0.4,0.8])
        cla
        axis off
        plot_spot_detection
        %%% Plot differences with rotation
        subplot('Position',[0.55,0.1,0.4,0.4])
        cla
        hold on
        h2=plot(ranges_rotation(1:lrotcounter),Diff_Rot(1:lrotcounter),'ob','MarkerFaceColor','b');
        pause(0.1)
    end
    lrotcounter=lrotcounter+1;
end
if plot_innerl_rotation==1,legend([h2],{'Rotation'});end
%%% Select among the three minimum distances, that one with the minimum
%%% variance
[~,Diff_sort_idx]=sort(Diff_Rot);
[~,temp_rot_idx]=min(Var_Rot(Diff_sort_idx(1:3)));
rotidx=Diff_sort_idx(temp_rot_idx);
if length(rotidx)==1
    DispAngle_All(larena)=ranges_rotation(rotidx);
else
    err('more than one min in rotation')
end

if plot_innerl_rotation==1
    subplot('Position',[0.55,0.55,0.4,0.4])
    plot(1.27*50,sum(abs(R_T1-R_D)),'om','MarkerFaceColor','m');
    subplot('Position',[0.55,0.1,0.4,0.4])
    plot(0,sum(abs(TH_T1-TH_D)),'om','MarkerFaceColor','m');
end

%% Plotting best fit
%%% Re-calculate template for this value of rotation and inner
%%% length
wellpos_temp=wellpositions(LengthInner_All(larena),DispAngle_All(larena));
wellpos_temp2=wellpos_temp+...
    repmat(Center_temp(larena,:),size(wellpos_temp,1),1);
Template{larena}=wellpos_temp2((FlyDB(DBentry).Geometry==1),:);%Spots template for this arena

if plot_innerl_rotation==1
    subplot('Position',[0.07,0.1,0.4,0.8])
    hold off
    plot(Center_temp(larena,1),Center_temp(larena,2),'or')
    hold on
    plot_spot_detection
end

if Case7_8==1
    %%% When 7 or 8 are detected, the last positions of yeast will be the
    %%% detected + the template in the missing positions
    temp_yeast=nan(sum(FlyDB(DBentry).Geometry==1),2);
    temp_yeast(sort(MinIdxs),:)=Detected{larena};
    temp_yeast(isnan((temp_yeast(:,1))),:)=Template{larena}(isnan((temp_yeast(:,1))),:);
    Detected{larena}=temp_yeast;
    radii_temp=nan(sum(FlyDB(DBentry).Geometry==1),1);
    radii_temp(sort(MinIdxs))=radii;
    radii_temp(isnan(radii_temp))=repmat(median(radii),sum(isnan(radii_temp)),1);
    radii=radii_temp;
end
%% Transforming coordinates to have center in origin (reversed y)
%%% Save detected for yeast
WellPositions_All(FlyDB(DBentry).Geometry==1,2*larena-1:2*larena)=...
    Detected{larena}-repmat(Center_temp(larena,:),...
    sum(FlyDB(DBentry).Geometry==sec_subs),1);
Radii_All(FlyDB(DBentry).Geometry==1,larena)=radii;
%%% Save template for yeast
WellPositions_All2(FlyDB(DBentry).Geometry==1,2*larena-1:2*larena)=...
    wellpos_temp2(FlyDB(DBentry).Geometry==1,:)-repmat(Center_temp(larena,:),...
    sum(FlyDB(DBentry).Geometry==1),1);
Center(larena,:)=Center_temp(larena,:)+[xCrop_ALL(larena,1)+AddCrop,AddCrop];
%%% Save template for sucrose
WellPositions_All(FlyDB(DBentry).Geometry==sec_subs,2*larena-1:2*larena)=...
    wellpos_temp2(FlyDB(DBentry).Geometry==sec_subs,:)-repmat(Center_temp(larena,:),...
    sum(FlyDB(DBentry).Geometry==sec_subs),1);
Radii_All(FlyDB(DBentry).Geometry==sec_subs,larena)=...
    repmat(median(radii),sum(FlyDB(DBentry).Geometry==sec_subs),1);