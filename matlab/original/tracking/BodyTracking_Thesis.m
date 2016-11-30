% ------------------------------------------------------------------------
% Code to track a single fly (in multiple arenas) body position to have
% kinematic quantification of 2D-translation 
% in the 2-choice multiple-spot feeding assay of Veronica (Ribeiro lab)
% by Veronica Corrales-Carvajal, Teresa Montez, José Cruz and 
% Alex Gomez-Marin, Nov 2013
% ------------------------------------------------------------------------

clear
close all
format compact

videoPath = 'C:\Users\Public\Videos\Recordings Fly Tracker Prject\Exp 3\';
param.arenaThreshold=130;

Filenames={...
'0003A03R05Cam03P0WT-CantonS.avi';...
'0003A03R05Cam04P0WT-CantonS.avi';...
};

for lfilename=1:length(Filenames)
    filename = Filenames{lfilename};
    param.filename=filename;
    
    % data file (directly from video)
    VideoRaw=VideoReader([videoPath filename], 'Tag', 'My reader object');
    load('mask.mat');
    
    fps=VideoRaw.FrameRate;
    maxFrame=VideoRaw.NumberOfFrames;
    
    % select initial and final frames (and time coarsening, if necessary)
    iniFrame=1; %
    finalFrame=maxFrame;
    cgTime=1; % we do not skip frames
    param.Finalframe=finalFrame;
    param.cgTime=cgTime;
    
    param.frameH=VideoRaw.Height-15;
    param.frameWL=floor(VideoRaw.Width/3)-10;%Width of left arena
        
    % and where I will save all the position data
    frames2analyse=iniFrame:cgTime:finalFrame;
    FlytracksL=nan(length(frames2analyse),6);
         
    % JAC's code
    MAX_FRAME = 500;
    count = MAX_FRAME;
    % ----
    frameCount=0;
    for lframe=frames2analyse
        frameCount=frameCount+1;
        %% Reading frame %% --> JAC's code.
        if( count == MAX_FRAME )
            if (lframe+count-1)<finalFrame
                flymoviedataBatch = read(VideoRaw,...
                    [lframe lframe+count-1]);
                count = 1;
            else
                flymoviedataBatch=read(VideoRaw,[lframe finalFrame]);
                count=1;
            end
            
        end
        i500 = flymoviedataBatch(:,:,1,count);
        count = count + 1;
        
        %% Thresholding Fly %%
        clear flyData flyshape
        flyData = not(im2bw(i500, param.arenaThreshold/255)) * 255;
        flyshape=uint8(flyData).*mask;
        
        for arena=1%:3
            if arena==1
               yCrop=1; yCrop2=param.frameH; xCrop=1; xCrop2=param.frameWL;
            end
            %% crop it to the arena-of-interest reference frame
            i=flyshape(yCrop:yCrop2,xCrop:xCrop2);
            %% Extracting Blob properties
            % count objects and properties necessary
            [L,numobj] = bwlabel(i,8);
            regprops=regionprops(L,'Centroid','Area','Orientation',...
                'MajorAxisLength','MinorAxisLength');
            % and keep the largest dark-enough object, 
            % hoping in this case it is the fly
            bigobject1=find([regprops.Area]==max([regprops.Area]));
            Arees0=[regprops.Area];
            
            % and set a threshold in case the animal disappears, 
            % not to track a small dirt
            Athr=20; % NOTE: HEURISTIC VALUE 
            % (we do not need it if the fly does not ever leave the arena)
            if Arees0(bigobject1)>Athr
                bigobject=bigobject1(1);
                centr=regprops(bigobject).Centroid;
                % the lovely centroid locations
                xc=centr(1);
                yc=centr(2);
                or=regprops(bigobject).Orientation;
                MajAx=regprops(bigobject).MajorAxisLength;
                MinAx=regprops(bigobject).MinorAxisLength;
                A=regprops(bigobject).Area;
            else % we could skip if there is always a large enough fly
                xc=NaN; yc=NaN; xrh=NaN; yrh=NaN; xrt=NaN; yrt=NaN;
            end
            
            %% Saving all parameters in separate for each arena %%
            if arena==1
                FlytracksL(frameCount,:)=[xc yc or MajAx MinAx A];
            end
        end
    end
    save FlytracksL.mat FlytracksL param filename
end
% -------------------------------------------------------------------------
% final comments:
% note that the units of positions are in pixels
% -------------------------------------------------------------------------
%% To plot the fly shown in Figure 3.4 for a desired frame:
% Acquire the surrounding polygon in the desired frame using the following
% line when extracting centroid, area and other properties:
% Spolygon=regprops(bigobject).ConvexHull;
% And assuming that xc, yc, or and MajAx are the x and y positions,
% orientation and major axis length, respectively, for the desired frame.
nicebluecolor=[86 180 233]/255;
niceorangecolor=[230 159 0]/255;
flymoviedata=VideoRaw.read(desired_frame);
imshow(flymoviedata)
hold on
plot(Spolygon(:,1),Spolygon(:,2),'-','LineWidth',3,'Color',nicebluecolor)
Majoraxisbody(1,1)=xc-MajAx/2.3*cosd(or);
Majoraxisbody(2,1)=xc+MajAx/2.3*cosd(or);
Majoraxisbody(1,2)=yc+MajAx/2.3*sind(or);
Majoraxisbody(2,2)=yc-MajAx/2.3*sind(or);
plot(Majoraxisbody(:,1),Majoraxisbody(:,2),'-m','LineWidth',3,...
    'Color',niceorangecolor)
plot(Majoraxisbody(:,1),Majoraxisbody(:,2),'om','LineWidth',3,...
    'MarkerSize',7,...
    'MarkerFaceColor',niceorangecolor,'MarkerEdgeColor',niceorangecolor)
plot(xc,yc,'og','LineWidth',3,'MarkerSize',7,...
    'MarkerFaceColor',nicebluecolor,'MarkerEdgeColor',nicebluecolor)
