%% Create pre-tracking file %%
format compact
close all
% clear all
% clc

load('mask.mat');
VideosFolder='C:\Users\Vero\Documents\Videos\Experiments\';
%'H:\FLY TRACKER PROJECT\TRACKING AND VIDEO ANALYSIS\Videos\Exp 11\';
%'C:\Users\Public\Videos\Recordings Fly Tracker Prject\';%
%'D:\Videos\';%
%




Filenames={...
'0010A01R01CAM02P0w1118EX102.avi';...
};
arenaThreshold = 140; %180 Old. (New=205) Sets the threshold to differentiate the fly
scrsz = get(0,'ScreenSize');
    
    figure('Position',[100 50 scrsz(3)-150 scrsz(4)-150])
for lfile=1:length(Filenames)
    file=Filenames{lfile};
    flymovie=VideoReader([VideosFolder file])%MovieObj;% 
%     flymovie=MovieObj;
    numofframes=5;
    frames=randi(flymovie.NumberOfFrames,numofframes,1);%1%
    
    nFrames = flymovie.NumberOfFrames;
    vidHeight = flymovie.Height-15;
    vidWidth = flymovie.Width;
    WidthLeft=floor( vidWidth/3)-10;
    WidthCentre=2*floor( vidWidth/3);
    
   
    lframecounter=1;
    for lframe=frames'
        
        display(['lframe: ' num2str(lframe)])
        
        flymoviedata=flymovie.read(lframe);
        
        %% Thresholding Fly %%
        flyData = not(im2bw(flymoviedata(:,:,1), arenaThreshold/255)) * 255;
        flyshape=uint8(flyData).*mask;%flyData=uint8(flyData).*mask;
        
        %Eliminating noise
%         SE=strel('disk',2);
%         flyshapethin=imerode(flyData,SE);
%         flyshape=imdilate(flyshapethin,SE);
        
        for arena=1:3
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
            Athr=20; % NOTE: HEURISTIC VALUE (we do not need it if the fly does not ever leave the arena)
            if Arees0(bigobject1)>Athr
                bigobject=bigobject1(1);
                subplot(numofframes,3,3*lframecounter-3+arena)
                display(['flytracks # of blobs: ' num2str(length(flytracks))])
            
                imshow(flymoviedata)%(floor(flytracks.Centroid(2))-20:floor(flytracks.Centroid(2))+20,...
                %                 floor(flytracks.Centroid(1))+Xplus-20:floor(flytracks.Centroid(1))+Xplus+20,1))
                axis([floor(flytracks(bigobject).Centroid(1))+Xplus-15, floor(flytracks(bigobject).Centroid(1))+Xplus+15,...
                    floor(flytracks(bigobject).Centroid(2))-15, floor(flytracks(bigobject).Centroid(2))+15])
                hold on
                plot(flytracks(bigobject).ConvexHull(:,1)+Xplus,flytracks(bigobject).ConvexHull(:,2),'-g','LineWidth',2)
%                 plot(flytracks(bigobject).WeightedCentroid(1)+Xplus,flytracks(bigobject).WeightedCentroid(2),'*m')
                plot(flytracks(bigobject).Centroid(1)+Xplus,flytracks(bigobject).Centroid(2),'*g')
                
                %% Plotting major axis
%                BodyLength=flytracks.MajorAxisLength;
%                 Orientation=flytracks.Orientation;
%                 Majoraxisbody(1,1)=flytracks.Centroid(1)-BodyLength/2.3*cosd(Orientation);
%                 Majoraxisbody(2,1)=flytracks.Centroid(1)+BodyLength/2.3*cosd(Orientation);
%                 Majoraxisbody(1,2)=flytracks.Centroid(2)+BodyLength/2.3*sind(Orientation);
%                 Majoraxisbody(2,2)=flytracks.Centroid(2)-BodyLength/2.3*sind(Orientation);
%                 plot(Majoraxisbody(:,1),Majoraxisbody(:,2),'-m','LineWidth',3)
            end
        end
        lframecounter=lframecounter+1;
        
    end
    pause
    clf
end
close all