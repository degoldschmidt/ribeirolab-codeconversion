% -------------------------------------------------------------------------
% Code to track a single fly (in multiple arenas) head position to have
% kinematic quantification of 2D-translation plus heading (weight and front angles)
% in the 2-choice multiple-spot feeding assay of Veronica (Ribeiro lab)
%
% by Veronica Corrals and Alex Gomez-Marin, November 2013
%
% Main feature: it uses skeletonization of fly body shape and distance rule
% at its two endpoints to track head position dynamics. This, together with
% the centroid location, will allow to build heading angles, etc, afterwards.
% -------------------------------------------------------------------------

% start clean
clear
close all
format compact
% main folders
dataDir0='/Users/agomez/Desktop/rotransFly/videosFlyNew/';
% cd(dataDir0)
%dirOut=strcat(dataDir0,'animation/');
%mkdir(dirOut)


videoPath = 'C:\Users\Public\Videos\Recordings Fly Tracker Prject\Exp 3\';%
param.arenaThreshold=130;

Filenames={...
'0003A03R05Cam03P0WT-CantonS.avi';...
'0003A03R05Cam04P0WT-CantonS.avi';...
};

for lfilename=1:length(Filenames)
    filename = Filenames{lfilename};% '0003A01R04Cam04P0WT-CantonS.avi';
    param.filename=filename;
    
    % data file (directly from video)
    xyloObj=VideoReader([videoPath filename], 'Tag', 'My reader object');
    % xyloObj=mmreader('0003A01R02Cam04P0WT-CantonS.avi', 'Tag', 'My reader object');
    load('mask.mat');
    
    fps0=xyloObj.FrameRate;
    fps=floor(fps0+1);
    maxFrame=xyloObj.NumberOfFrames;
    frameW=xyloObj.Width;
    frameH=xyloObj.Height;
    
    % select initial and final frames (and time coarsening, if necessary)
    iniFrame=1; % or fps*50 %-> for instance, 50 seconds after video start (beware sync!)
    finalFrame=maxFrame;
    cgTime=1; % we do not skip frames, then
    param.Finalframe=finalFrame;
    param.cgTime=cgTime;
    
    param.frameH2=frameH-15;
    param.frameW2=frameW;
    param.frameWL=floor(frameW/3)-10;%Width of left arena
    param.frameWC=2*floor(frameW/3);%Width center arena
    
    frameCount=0;
    % and where I will save all the position data
    frames2analyse=iniFrame:cgTime:finalFrame;
    FlytracksNewL=nan(length(frames2analyse),6);
    FlytracksNewC=nan(length(frames2analyse),6);
    FlytracksNewR=nan(length(frames2analyse),6);
    
    % if we want to keep track of the time the main for loop took to process it all
    tic
    
    close all
    % figure,
    
    % beware with file, fileCOunt and k!
    
    % JAC's code
    MAX_FRAME = 500;
    count = MAX_FRAME;
    % ----
    for lframe=frames2analyse
        
        % To see the time or percentage running at the prompt
        %     lframe %% Below
        %file/fps % current time of processing in seconds
        %file/finalFile % ratio completed
        
        frameCount=frameCount+1;
        
        % % % % read frame, and thus image --> Vero's comment: Better use batch
        % % % % loading
        % % % ii=read(xyloObj,lframe);
        % % % i100=ii(:,:,1);
        %% Reading frame %% --> JAC's code. Be careful: This has to be modified if we skip frames!
        if( count == MAX_FRAME )
            if (lframe+count-1)<finalFrame
                flymoviedataBatch = read(xyloObj, [lframe lframe+count-1]);
                count = 1;
            else
                flymoviedataBatch=read(xyloObj,[lframe finalFrame]);
                count=1;
            end
            
        end
        i100 = flymoviedataBatch(:,:,1,count);
        count = count + 1;
        
        %% Thresholding Fly %%
        clear flyData flyshapethin flyshape
        flyData = not(im2bw(i100, param.arenaThreshold/255)) * 255;
        flyshape=uint8(flyData).*mask; %flyData=uint8(flyData).*mask; %to prevent dark sides outside the arena
        
        %% Eliminating noise
%         SE=strel('disk',2);
%         flyshapethin=imerode(flyData,SE);
%         flyshape=imdilate(flyshapethin,SE);
        
        
        for arenaside=1:3
            if arenaside==1
                yCrop=1; yCrop2=param.frameH2; xCrop=1; xCrop2=param.frameWL;
            elseif arenaside==2
                yCrop=1; yCrop2=param.frameH2; xCrop=param.frameWL; xCrop2=param.frameWC;
            else
                yCrop=1; yCrop2=param.frameH2; xCrop=param.frameWC; xCrop2=param.frameW2;
            end
            %% crop it to the arena-of-interest reference frame
            i=flyshape(yCrop:yCrop2,xCrop:xCrop2);
            
            i1=i100(yCrop:yCrop2,xCrop:xCrop2);% Raw cropped image to present to the
            % user for manual selection of 1st head and tail
            
            %% Extracting Blob properties
            % count objects and properties necessary
            [L,numobj] = bwlabel(i,8);
            regprops=regionprops(L,'Centroid','Area','Orientation','MajorAxisLength','MinorAxisLength');%,'Perimeter'
            % and keep the largest dark-enough object, hoping in this case it is the fly
            bigobject1=find([regprops.Area]==max([regprops.Area]));
            Arees0=[regprops.Area];
            
            % and set a threshold in case the animal disappears, not to track a small dirt
            Athr=20; % NOTE: HEURISTIC VALUE (we do not need it if the fly does not ever leave the arena)
            if Arees0(bigobject1)>Athr % this could be skipped if we are confident
                
                bigobject=bigobject1(1);
                centr=regprops(bigobject).Centroid;
                % the lovely centroid locations
                xc=centr(1);
                yc=centr(2);
                or=regprops(bigobject).Orientation;
                MajAx=regprops(bigobject).MajorAxisLength;
                MinAx=regprops(bigobject).MinorAxisLength;
                A=regprops(bigobject).Area;
                
%                 % else of the Arees0 condition
            else % we could skip if we are sure there is always a large enough fly
                xc=NaN;
                yc=NaN;
                xrh=NaN;
                yrh=NaN;
                xrt=NaN;
                yrt=NaN;
            end
            
            %% Saving all parameters in separate cells for each arena %%
            % Add current positions to the time vector
            % or just write it down like this in an array

            if arenaside==1
                FlytracksNewL(frameCount,:)=[xc yc or MajAx MinAx A];% xrh yrh xrt yrt];
                
            elseif arenaside==2
                FlytracksNewC(frameCount,:)=[xc yc or MajAx MinAx A];% xrh yrh xrt yrt];
                
            else
                FlytracksNewR(frameCount,:)=[xc yc or MajAx MinAx A];% xrh yrh xrt yrt];
                %% Processing Time info %%
                if 0==mod(lframe,100)
                    CurrentFrame=[lframe]
                    
                    display([filename(1:end-14) ', ' num2str(lframe/finalFrame*100) '% complete'])
                end
            end
            %% Saving Backup at 10000 frames %%
%             if 0==mod(lframe,10000)
%                 save(['tracking_10000_' filename(1:end-4) '-Left.mat'],'FlytracksNewL','param','filename')
%                 save(['tracking_10000_' filename(1:end-4) '-Centre.mat'],'FlytracksNewC','param','filename')
%                 save(['tracking_10000_' filename(1:end-4) '-Right.mat'],'FlytracksNewR','param','filename')
%             end
            
            % %---- see what is happening
            % %
            % % note difference between file and fileCount (beware)
            % %
            % xrct=[xrct FlytracksNew{fileCount}(1)];
            % yrct=[yrct FlytracksNew{fileCount}(2)];
            % xrht=[xrht FlytracksNew{fileCount}(3)];
            % yrht=[yrht FlytracksNew{fileCount}(4)];
            % xrtt=[xrtt FlytracksNew{fileCount}(5)];
            % yrtt=[yrtt FlytracksNew{fileCount}(6)];
            % %
            % %-----
            % kini=1;
            % k=fileCount;
            % %kini=iniFile;
            % %k=file;
            % %
            % hold on
            % xArrowLong=[xrct(k)  xrht(k)];
            % yArrowLong=[yrct(k) yrht(k)];
            % plot(xArrowLong,yArrowLong,'r','LineWidth',2);
            % %
            % xArrowLong2=[xrct(k)  xrtt(k)];
            % yArrowLong2=[yrct(k) yrtt(k)];
            % plot(xArrowLong2,yArrowLong2,'b','LineWidth',1);
            % %
            % plot(xrct(kini:k),yrct(kini:k),'.k','LineWidth',1)
            % plot(xrht(kini:k),yrht(kini:k),'.r','LineWidth',1)
            % plot(xrtt(kini:k),yrtt(kini:k),'.m','LineWidth',1)
            % %
            % plot(xrct(kini:k),yrct(kini:k),'-k','LineWidth',1)
            % %
            % xWin=xrct(k);
            % yWin=yrct(k);
            % dx=30;
            % dy=30;
            % axis equal
            % axis([xWin-dx xWin+dx yWin-dy yWin+dy])
            % hold off
            
            % that is all we need to do by now (we can deal with the kinematics in another code)
        end
    end
    toc;
    atoc=toc
    save(['C:\Users\Vero\Bonsai tracking\Exp 0003\TrackingBonsaiParams-' filename(1:end-4) '-Left.mat'],'FlytracksNewL','atoc','param','filename')
    save(['C:\Users\Vero\Bonsai tracking\Exp 0003\TrackingBonsaiParams-' filename(1:end-4) '-Centre.mat'],'FlytracksNewC','atoc','param','filename')
    save(['C:\Users\Vero\Bonsai tracking\Exp 0003\TrackingBonsaiParams-' filename(1:end-4) '-Right.mat'],'FlytracksNewR','atoc','param','filename')
    
    % save FlytracksNew.mat FlytracksNew
    % perhaps save other relevant info here too
    
    
    % save atoc.mat atoc
    
    % stop the time countercounter
    toc
end
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------



% -------------------------------------------------------------------------
% here we could add a visualization + correction tool


% -------------------------------------------------------------------------
%% more convenient way to deal with trajectories
% xrct=[];
% yrct=[];
% xrht=[];
% yrht=[];
% xrtt=[];
% yrtt=[];
% lastframe=2000%length(FlytracksNewC);
% for lframe=1:lastframe
%     xrct=[xrct FlytracksNewC(lframe,1)];
%     yrct=[yrct FlytracksNewC(lframe,2)];
%     xrht=[xrht FlytracksNewC(lframe,3)];
%     yrht=[yrht FlytracksNewC(lframe,4)];
%     xrtt=[xrtt FlytracksNewC(lframe,5)];
%     yrtt=[yrtt FlytracksNewC(lframe,6)];
% end
%
% % -------------------------------------------------------------------------
% % and now do some nice plotting
%
% close all
% figure,
% %imshow(i1)
% hold on
% inik=1;
% fink=lastframe-1% or instead a fixed time: fps*30;
% int=inik:fink;
% for k=inik:fink-1;%length(FlytracksNewC)
%     xArrowLong=[xrct(k)  xrht(k)];
%     yArrowLong=[yrct(k) yrht(k)];
%     plot(xArrowLong,yArrowLong,'r','LineWidth',1);
%     %plot_arrow(xrct(k),yrct(k),xrht(k),yrht(k),'linewidth',1,'color',[1 0 0],'facecolor',[1 0 0],'headwidth',0.25,'headheight',0.33);% x1,y1,x2,y2 [,options...] )
%     %plot_arrow(xrct(k),yrct(k),xrct(k+1),yrct(k+1),'linewidth',1,'color',[0 0 0],'facecolor',[0 0 0],'headwidth',0.25,'headheight',0.33);% x1,y1,x2,y2 [,options...] )
% end
% plot(xrct(int),yrct(int),'.k','LineWidth',1)
% plot(xrht(int),yrht(int),'.r','LineWidth',1)
% plot(xrct(int),yrct(int),'-k','LineWidth',1)
% %
% print('-f1','-depsc','trajectoryHC.eps');


% -------------------------------------------------------------------------
% final comments:
%
% note that the units of positions are in pixels
% we should thus callibrate the arena and convert the trajectories to mm
%
% note that in this assay it is key to correlate the motion of the fly with
% its position and orientation with respect to the food patches, thus we
% should make sure we can align both systems of reference to ultimately get
% what we want (i.e. the heading of the animal with respect to the food).


