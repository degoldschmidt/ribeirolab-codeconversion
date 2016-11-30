%% Create pre-tracking file %%
format compact
close all
% clear all
% clc

load('mask.mat');
VideosFolder='F:\PROJECT INFO\Videos\Exp 0003\';

Filenames={...
'0003A02R02Cam03P0WT-CantonS.avi'...
};

arenaThreshold = 125; %180 Old. (New=205) Sets the threshold to differentiate the fly
scrsz = get(0,'ScreenSize');
    
    figure('Position',[100 50 scrsz(3)-150 scrsz(4)-150])
for lfile=1:length(Filenames)
    file=Filenames{lfile};
%     flymovie=VideoReader([VideosFolder file])%MovieObj;% 
% % %     flymovie=MovieObj;
%     numofframes=5;
%     frames=randi(flymovie.NumberOfFrames,numofframes,1);%1%
    frames=343377;
    
    nFrames = flymovie.NumberOfFrames;
    vidHeight = flymovie.Height-15;
    vidWidth = flymovie.Width;
    WidthLeft=floor( vidWidth/3)-10;
    WidthCentre=2*floor( vidWidth/3);
    
    clf
    lframecounter=1;
    for lframe=frames'
        
        display(['lframe: ' num2str(lframe)])
        
%         flymoviedata=flymovie.read(lframe);
        imshow(flymoviedata(1: vidHeight, WidthCentre: vidWidth));set(gcf,'Name','Raw frame')
        pause; savefig_withname(0,'300','png',DataSaving_dir_temp,Exp_num,Exp_letter,...
        'Thesis')
        clf
        imshow(uint8(flymoviedata(1: vidHeight, WidthCentre: vidWidth,1)).*mask(1: vidHeight, WidthCentre: vidWidth));set(gcf,'Name','Frame&mask')
        pause; savefig_withname(0,'300','png',DataSaving_dir_temp,Exp_num,Exp_letter,...
        'Thesis')
        %% Thresholding Fly %%
        flyData = not(im2bw(flymoviedata(:,:,1), arenaThreshold/255)) * 255;
        flyshape=uint8(flyData).*mask;%flyData=uint8(flyData).*mask;
%         clf
        imshow(flyshape(1: vidHeight, WidthCentre: vidWidth));set(gcf,'Name','Frame&Threshold')
        pause; savefig_withname(0,'300','png',DataSaving_dir_temp,Exp_num,Exp_letter,...
        'Thesis')
%     clf
        %Eliminating noise
%         SE=strel('disk',2);
%         flyshapethin=imerode(flyData,SE);
%         flyshape=imdilate(flyshapethin,SE);
        
        for arena=3%1:3
            arena
            if arena==1
                flyData1ar=flyshape(1: vidHeight,1:1: WidthLeft); % Delimits the Left Arena
                rawIm1ar=flymoviedata(1: vidHeight,1:1: WidthLeft);
                Xplus=0; % Left
            elseif arena==2
                flyData1ar=flyshape(1: vidHeight, WidthLeft: WidthCentre); %Centre
                rawIm1ar=flymoviedata(1: vidHeight, WidthLeft: WidthCentre);
                Xplus= WidthLeft-1; %Centre
            else
                flyData1ar=flyshape(1: vidHeight, WidthCentre: vidWidth); % Delimits the Right arena in the video
                rawIm1ar=flymoviedata(1: vidHeight, WidthCentre: vidWidth);
                Xplus= WidthCentre-1; %Right
            end
            
            
            
            
            %% Tracking
            fData= bwconncomp(flyData1ar,8);
            flytracks = regionprops(fData,{'Centroid','ConvexHull','Area','Orientation','MajorAxisLength'});
%             flytracks = regionprops(fData,rawIm1ar,{'Centroid','WeightedCentroid','ConvexHull','Area'}); % flytracks is a structure array
%             flytracks = regionprops(fData,{'Centroid','ConvexHull','Area'}); % flytracks is a structure array
            % which contains thresholded flies parameters. It has 3 components
            % correspoding to Left, Centre and Right flies.
            bigobject1=find([flytracks.Area]==max([flytracks.Area]));
            Arees0=[flytracks.Area];
            
            % and set a threshold in case the animal disappears, not to track a small dirt
            Athr=20;%20; % NOTE: HEURISTIC VALUE (we do not need it if the fly does not ever leave the arena)
            bluecol=[86 180 233]/255;%[0 114 178]/255;
            orangecol=[230 159 0]/255;
            if Arees0(bigobject1)>Athr
                bigobject=bigobject1(1);
                delta=30;
%                 subplot(numofframes,3,3*lframecounter-3+arena)
                display(['flytracks # of blobs: ' num2str(length(flytracks))])
            
                imshow(flymoviedata)%(floor(flytracks.Centroid(2))-20:floor(flytracks.Centroid(2))+20,...
                %                 floor(flytracks.Centroid(1))+Xplus-20:floor(flytracks.Centroid(1))+Xplus+20,1))
                axis([floor(flytracks(bigobject).Centroid(1))+Xplus-delta, floor(flytracks(bigobject).Centroid(1))+Xplus+delta,...
                    floor(flytracks(bigobject).Centroid(2))-delta, floor(flytracks(bigobject).Centroid(2))+delta])
                hold on
                plot(flytracks(bigobject).ConvexHull(:,1)+Xplus,flytracks(bigobject).ConvexHull(:,2),'-g','LineWidth',3,'Color',bluecol)
% %                 plot(flytracks(bigobject).WeightedCentroid(1)+Xplus,flytracks(bigobject).WeightedCentroid(2),'*m')
%                 plot(flytracks(bigobject).Centroid(1)+Xplus,flytracks(bigobject).Centroid(2),'*g')
               set(gcf,'Name','Fly&Centroid&Major Axis')
                %% Plotting major axis
               BodyLength=flytracks(bigobject).MajorAxisLength;
                Orientation=flytracks(bigobject).Orientation;
                Majoraxisbody(1,1)=flytracks(bigobject).Centroid(1)+Xplus-BodyLength/2.3*cosd(Orientation);
                Majoraxisbody(2,1)=flytracks(bigobject).Centroid(1)+Xplus+BodyLength/2.3*cosd(Orientation);
                Majoraxisbody(1,2)=flytracks(bigobject).Centroid(2)+BodyLength/2.3*sind(Orientation);
                Majoraxisbody(2,2)=flytracks(bigobject).Centroid(2)-BodyLength/2.3*sind(Orientation);
                plot(Majoraxisbody(:,1),Majoraxisbody(:,2),'-m','LineWidth',3,'Color',orangecol)
                plot(Majoraxisbody(:,1),Majoraxisbody(:,2),'om','LineWidth',3,'MarkerSize',7,...
                    'MarkerFaceColor',orangecol,'MarkerEdgeColor',orangecol)
                plot(flytracks(bigobject).Centroid(1)+Xplus,flytracks(bigobject).Centroid(2),'og',...
                    'LineWidth',3,'MarkerSize',7,'MarkerFaceColor',bluecol,'MarkerEdgeColor',bluecol)
                
            end
        end
        savefig_withname(0,'300','png',DataSaving_dir_temp,Exp_num,Exp_letter,...
        'Thesis')
%         suptitle(file)
        lframecounter=lframecounter+1;
        
    end
%     pause
%     clf
end
% close all