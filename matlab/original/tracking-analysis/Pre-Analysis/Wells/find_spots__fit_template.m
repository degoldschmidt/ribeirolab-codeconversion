%% Find Circles function in MATLAB
image_arena=(gray_image(AddCrop:param.frameH2-10,xCrop_ALL(larena,1)+AddCrop:xCrop_ALL(larena,2)-25));

if edge_thr==0
    [centers, radii] = imfindcircles(image_arena,[9 15],'ObjectPolarity','dark',...
        'Sensitivity',sensit_thr,'EdgeThreshold',edge_thr);
else
    [centers, radii] = imfindcircles(image_arena,[9 15],'ObjectPolarity','dark',...
        'Sensitivity',sensit_thr);%[9 15]
    % h = viscircles(centers,radii,'DrawBackgroundCircle',false);
end


while ~((size(centers,1)>=8)&&(size(centers,1)<=10))
    display('Not 8-10 circles')
    if size(centers,1)<8
        if edge_thr~=0
            %% Change edge-threshold
            edge_thr=0;
            display(['Edge Thr changed to 0, Sens Thr = ' num2str(sensit_thr)])
            [centers, radii] = imfindcircles(image_arena,[9 15],'ObjectPolarity','dark',...
                'Sensitivity',sensit_thr,'EdgeThreshold',edge_thr);
            if plot_edgethr==1
                imshow(image_arena);hold on;
                h = viscircles(centers,radii,'DrawBackgroundCircle',false);
            end
        elseif sensit_thr<=0.95
            sensit_thr=sensit_thr+0.01;
            display(['Edge Thr = ' num2str(edge_thr) ', Increase Sens to ' num2str(sensit_thr)])
            [centers, radii] = imfindcircles(image_arena,[9 15],'ObjectPolarity','dark',...
                'Sensitivity',sensit_thr,'EdgeThreshold',edge_thr);
        elseif size(centers,1)==0
            display({'WARNING: Cannot detect yeast spots';...
                ['Edge Threshold: ' num2str(edge_thr)];...
                ['Sensitivity: ' num2str(sensit_thr)];...
                ['Number of Circles: ' num2str(size(centers,1))]})
            ProblemArenas(DBentry)=1;
            if plot_problems==1
                figure,colormap('default')
                imshow(image_arena);hold on;
                h = viscircles(centers,radii,'DrawBackgroundCircle',false);
            end
            break
        end
    else
        %% Change Sensitivity
        sensit_thr=sensit_thr-0.01;
        if edge_thr==0
            display(['Edge Thr = ' num2str(edge_thr) ', Decrease Sens to = ' num2str(sensit_thr)])
            [centers, radii] = imfindcircles(image_arena,[9 15],'ObjectPolarity','dark',...
                'Sensitivity',sensit_thr,'EdgeThreshold',edge_thr);
        else
            display(['Edge Thr = ' num2str(edge_thr) ', Decrease Sens to = ' num2str(sensit_thr)])
            [centers, radii] = imfindcircles(image_arena,[9 15],'ObjectPolarity','dark',...
                'Sensitivity',sensit_thr);
        end
    end
end
if size(centers,1)~=0
    display(['8-10: ' num2str(size(centers,1)) ' circles, ',...
        'Edge Thr = ' num2str(edge_thr) ', Sens Thr = ' num2str(sensit_thr)])
    %% Detecting wich well is not a well (fly?) by using the median intensity
    intensity_outliers
    %%
    if ProblemArenas(DBentry)==0;
        if size(centers,1)<10
            %% Detecting wells with abnormal radius
            outlierup= prctile(radii,75) + 1*(prctile(radii,75) - prctile(radii,25));
            outlierdown= prctile(radii,25) - 1*(prctile(radii,75) - prctile(radii,25));
            %%% Setting big radii to 1.7 mm and Smaller to 1.3 mm
            radii(radii>outlierup)=1.7/params.px2mm;
            radii(radii<outlierdown)=1.3/params.px2mm;
            if plot_rad_outliers==1
                figure
                hold on
                plot(radii,'ob')
                plot([1 lcircle],[outlierup outlierup],'--r')
                plot([1 lcircle],[outlierdown outlierdown],'--r')
                font_style([],'Well Nº','Median radius')
            end
            %% If detects the 9 yeast spots
            if size(centers,1)==9
                %% Creating Detected cell array
                Detected{larena}=centers;%Spots for this arena detected from image
                %% Center is mean
                Center_temp(larena,:)=mean(Detected{larena});
                %% Creating Template
                wellpos_temp=wellpositions;
                wellpos_temp2=wellpos_temp+...
                    repmat(Center_temp(larena,:),size(wellpos_temp,1),1);
                Template{larena}=wellpos_temp2((FlyDB(DBentry).Geometry==1),:);%Spots template for this arena
                %% Calculating distances & Correcting numbering for detected
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
                %% Correction of Inner Length and Rotation
                Iteration_Innerlength_Rotation
            elseif size(centers,1)>=7
                display('7 or 8')
                Case7_8=1;
                %             if plot_problems==1
                %                 figure,colormap('default'),
                %                 imshow(image_arena);hold on;
                %                 h = viscircles(centers,radii,'DrawBackgroundCircle',false);
                %             end
                %             error('7 or 8')
                %% Center Correction (Center cannot be mean)
                Iteration_Center
                %% Correction of Inner Length and Rotation
                Iteration_Innerlength_Rotation
            else
                display({'WARNING: Less than 7 spots found';...
                    ['Edge Threshold: ' num2str(edge_thr)];...
                    ['Number of Circles: ' num2str(size(centers,1))]})
                ProblemArenas(DBentry)=1;
                if plot_problems==1
                    figure,colormap('default'),
                    imshow(image_arena);hold on;
                    h = viscircles(centers,radii,'DrawBackgroundCircle',false);
                end
            end
        else
            sensit_thr=sensit_thr-0.01;
            display(['More than 10 after fly check: ' num2str(size(centers,1)) ' circles, ',...
                'Edge Thr = ' num2str(edge_thr) ', Sens Thr = ' num2str(sensit_thr)])
            
            find_spots__fit_template
        end
    end
end