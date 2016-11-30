%% Detecting wich well is not a well (fly?) by using the median intensity
if plot_int_outliers==1
    figure
end
pixelvalues=nan(size(centers,1),1);
% intensity_all=nan(size(centers,1),1);
major_minor_ratio=nan(size(centers,1),1);
for lcircle=1:size(centers,1)
    %%% Define bounding box using radius
    r=radii(lcircle);
    wellbox=image_arena(floor(centers(lcircle,2)-r):floor(centers(lcircle,2)+r),...
        floor(centers(lcircle,1)-r):floor(centers(lcircle,1)+r));
    pixelvalues(lcircle)=median(median(wellbox));
    %%% Extract pixel values and Major/Minor Axes ratio
    level = graythresh(wellbox);
    BW = not(im2bw(wellbox,level))*255;
    [L,numobj] = bwlabel(BW,8);
    regprops=regionprops(L,wellbox,'Area','PixelValues','MajorAxisLength','MinorAxisLength');
    bigobject1=find([regprops.Area]==max([regprops.Area]));
    pixelvalues(lcircle)=median(regprops(bigobject1).PixelValues);
    major_minor_ratio(lcircle)=regprops(bigobject1).MajorAxisLength/regprops(bigobject1).MinorAxisLength;
    if plot_int_outliers==1
        subplot(3,size(centers,1),lcircle)
        imagesc(wellbox,[95 125])
        axis off
    end
end
%%% Calculate outliers in pixel values and Ma/Mi axes ratio
outlierup_pv= prctile(pixelvalues,75) + 1.5*(prctile(pixelvalues,75) - prctile(pixelvalues,25));
outlierdown_pv= prctile(pixelvalues,25) - 1.5*(prctile(pixelvalues,75) - prctile(pixelvalues,25));
outlierup_rat= prctile(major_minor_ratio,75) + 1.5*(prctile(major_minor_ratio,75) - prctile(major_minor_ratio,25));
outlierdown_rat= prctile(major_minor_ratio,25) - 1.5*(prctile(major_minor_ratio,75) - prctile(major_minor_ratio,25));

if plot_int_outliers==1
    subplot(3,size(centers,1),[size(centers,1)+1:2*size(centers,1)])
    hold on
    plot(pixelvalues,'ob')
    plot([1 lcircle],[outlierup_pv outlierup_pv],'--r')
    plot([1 lcircle],[outlierdown_pv outlierdown_pv],'--r')
    font_style([],'Well Nº','Median intensity of blob')
    
    subplot(3,size(centers,1),[2*size(centers,1)+1:3*size(centers,1)])
    hold on
    plot(major_minor_ratio,'ob')
    plot([1 lcircle],[outlierup_rat outlierup_rat],'--r')
    plot([1 lcircle],[outlierdown_rat outlierdown_rat],'--r')
    font_style([],'Well Nº','Major to Minor axis ratio')
end
%% Detecting fly: When both the pixel values and the Ma/Mi axes ratio are outliers
log_vector=(((pixelvalues>outlierup_pv)|(pixelvalues<outlierdown_pv))+...
    ((major_minor_ratio>outlierup_rat)|(major_minor_ratio<outlierdown_rat)))==2;
outlierwell=find(log_vector);
if sum(log_vector)==1
    %% Remove and continue with following steps
    centers=centers(~log_vector,:);
    radii=radii(~log_vector,:);
elseif sum(log_vector)==0
    %% Do nothing and continue with following steps
else
    %% Save arena in problems
    display({'WARNING: More than one intensity outlier';...
        ['Edge Threshold: ' num2str(edge_thr)];...
        ['Number of Circles: ' num2str(size(centers,1))]})
    ProblemArenas(DBentry)=1;
    if plot_problems==1
        figure,colormap('default'),
        imshow(image_arena);hold on;
        h = viscircles(centers,radii,'DrawBackgroundCircle',false);
    end
end
