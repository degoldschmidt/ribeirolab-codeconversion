% -------------------------------------------------------------------------
% Code to track a single fly (in multiple arenas) head position to have
% kinematic quantification of 2D-translation plus heading (weight and front angles)
% in the 2-choice multiple-spot feeding assay of Veronica (Ribeiro lab)
%
% by Alex Gomez-Marin, November 2013
%
% Main feature: it uses skeletonization of fly body shape and distance rule
% at its two endpoints to track head position dynamics. This, together with
% the centroid location, will allow to build heading angles, etc, afterwards.
% -------------------------------------------------------------------------

% start clean
clear
close all

% main folders
dataDir0='/Users/agomez/Desktop/rotransFly/videosFlyNew/';
% cd(dataDir0)
%dirOut=strcat(dataDir0,'animation/');
%mkdir(dirOut)


videoPath = 'C:\Users\Vero\Documents\Videos\Experiments\';%'D:\Videos\';%
param.arenaThreshold=180;

Filenames={...
    '0003A01R02Cam04P0WT-CantonS.avi';...
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
    iniFrame=6600;%1; % or fps*50 %-> for instance, 50 seconds after video start (beware sync!)
    finalFrame=6620;%maxFrame;
    cgTime=1; % we do not skip frames, then
    param.Finalframe=finalFrame;
    param.cgTime=cgTime;
    % no need for brackground subtraction in this behavioral arena
    % (so no need to load the image here, but we could and it is easy to do)
    
    % cropping in 3 subparts, so that we analize each fly separately
    %
    % % manual cropping by clicking can be done like that
    % file=iniFile;
    % i0=read(xyloObj,file);
    % i00=i0(:,:,1);
    % figure,
    % imshow(i00)
    % display('Click up, down, left, right')
    % set(gca,'xtick',[],'ytick',[])
    % [xcc,ycc]=ginput(1);
    % yCrop=floor(ycc);
    % [xcc,ycc]=ginput(1);
    % yCrop2=floor(ycc);
    % [xcc,ycc]=ginput(1);
    % xCrop=floor(xcc);
    % [xcc,ycc]=ginput(1);
    % xCrop2=floor(xcc);
    %
    % % or automated (if arena's proportions unchanged) based on Vero's code
    % arenaside=1; % chose the subarena
    %
    % Note:
    %(to be expanded in a simple loop for all 3)
    %
    %
    param.frameH2=frameH-15;
    param.frameW2=frameW;
    param.frameWL=floor(frameW/3)-10;%Width of left arena
    param.frameWC=2*floor(frameW/3);%Width center arena
    
    
    % I do not think I need this (since we click the first frame -see below-):
    % % initializing empty variables
    % oxrh=0;
    % oyrh=0;
    % oxrt=10;
    % oyrt=10;
    %
    frameCount=0;
    % and where I will save all the position data
    frames2analyse=iniFrame:cgTime:finalFrame;
    FlytracksNewL=nan(length(frames2analyse),6);
    FlytracksNewC=nan(length(frames2analyse),6);
    FlytracksNewR=nan(length(frames2analyse),6);
    % and this, if we need
    xrct=[];
    yrct=[];
    xrht=[];
    yrht=[];
    xrtt=[];
    yrtt=[];
    
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
        flyData=uint8(flyData).*mask; %to prevent dark sides outside the arena
        
        %% Eliminating noise
        SE=strel('disk',2);
        flyshapethin=imerode(flyData,SE);
        flyshape=imdilate(flyshapethin,SE);
        
        
        for arenaside=3%1:3
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
            regprops=regionprops(L,'Centroid','Area');%,'Perimeter','Orientation','MajorAxisLength','MinorAxisLength');
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
                
                % finding the clean and single "blob" and its contour
                [rMain, cMain]=find(bwlabel(i)==bigobject);
                iL=zeros(size(i,1),size(i,2));
                for k=1:length(rMain)
                    iL(rMain(k),cMain(k))=1;
                end
                                
                % skeletonization of the blob: the main trick we chose to find 2 endpoints
                % that we will later identify as head and tail via a distance rule
                wskel=bwmorph(iL,'thin',Inf);
                
                % and the extremes of the skeleton will be the 2 endpoints we need
                skeleton=wskel;
                skeleton_indices=find(skeleton>0);
                [skeleton_y,skeleton_x]=ind2sub(size(skeleton),skeleton_indices);
                % Skeleton end points
                connect=zeros(1,length(skeleton_indices));
                for point=1:length(skeleton_indices)
                    i=skeleton_x(point);
                    j=skeleton_y(point);
                    connect(point)=length(find(skeleton_x>=i-1 & skeleton_x<=i+1 & skeleton_y>=j-1 & skeleton_y<=j+1));
                end
                endPoints=find(connect==2);
                
                % sometimes, depending on the animal posture geometry, spurs (branches, thus more than 2 endpoints)
                % can give us problems to tell head from tail(s), so we make sure we are in
                % the 2 case situation (although there will be no problems and we could even do it with 3 or more)
                if length(endPoints)==2
                    % % Initial guess
                    % xrh=skeleton_x(endPoints(2));
                    % yrh=skeleton_y(endPoints(2));
                    % xrt=skeleton_x(endPoints(1));
                    % yrt=skeleton_y(endPoints(1));
                    %
                    % the opposite, cause down I will flip them
                    xrh=skeleton_x(endPoints(1));
                    yrh=skeleton_y(endPoints(1));
                    xrt=skeleton_x(endPoints(2));
                    yrt=skeleton_y(endPoints(2));
                    %
                    % manual intervention for the 1st frame (we could think of more refined methods)
                    if lframe==iniFrame
                        display('Head-tail manual annotation:')
                        display('First, click close to head. Second, close to tail')
                        pause(1)
                        %keyboard
                        close all
                        % Show current image frame to classify
                        figure,
                        imshow(i1)
                        %imshow(wskel)
                        axis equal
                        %title(['File number:',int2str(file)],'Color','b')
                        colormap('gray')
                        axis equal
                        set(gca,'xtick',[],'ytick',[])
                        [xHead,yHead]=ginput(1);
                        oxrh=xHead;
                        oyrh=yHead;
                        [xTail,yTail]=ginput(1);
                        oxrt=xTail;
                        oyrt=yTail;
                        % setting up the "previous good head-tail as the actual, so OK"
                        close all
                        %
                        figure,
                        imshow(i1)
                        
                    end
                    %
                else % here we are conservative and decide to use the previous positions when spurs appear
                    display(['frame with 3 points: ' num2str(lframe)])
                    xrh=oxrh
                    yrh=oyrh
                    xrt=oxrt
                    yrt=oyrt
                    
                    %% Head %%
% BodyLength=bodytracks.MajorAxisLength;
%                 Orientation=bodytracks.Orientation;
%                 Majoraxisbody(1,1)=bodytracks.Centroid(1)-BodyLength/2.3*cosd(Orientation);
%                 Majoraxisbody(2,1)=bodytracks.Centroid(1)+BodyLength/2.3*cosd(Orientation);
%                 Majoraxisbody(1,2)=bodytracks.Centroid(2)+BodyLength/2.3*sind(Orientation);
%                 Majoraxisbody(2,2)=bodytracks.Centroid(2)-BodyLength/2.3*sind(Orientation);
% 
%                 T1=pdist2(Majoraxisbody(1,:),flytracks.Centroid);
%                 T2=pdist2(Majoraxisbody(2,:),flytracks.Centroid);
% 
%                 if T1>T2
%                     Head=Majoraxisbody(1,:);
%                 else
%                     Head=Majoraxisbody(2,:);
%                     
%                 end
                end
                
                % min-dist rule to calculate the distance between current endpoints and the
                % loci identity assigned in the previous frame
                distToTn=sqrt((xrt-oxrt)^2 + (yrt-oyrt)^2);
                distToHn=sqrt((xrh-oxrt)^2 + (yrh-oyrt)^2);
                if distToTn>distToHn
                    xrh=skeleton_x(endPoints(2));
                    yrh=skeleton_y(endPoints(2));
                    xrt=skeleton_x(endPoints(1));
                    yrt=skeleton_y(endPoints(1));
                end
                %
                % If that is not enough, we could use a combination of 2 distances
                % If that is still not enough, we could use a weight in the past
                % If that is even not enough, we might need to use geometrical features or
                % increase the temporal resolution so that the distance rule is always OK
                %
                % We might lose crazy jumps the fly does. Then we need to correct by hand
                
                % save new positions to use as old in the following iteration
                oxrh=xrh;
                oyrh=yrh;
                oxrt=xrt;
                oyrt=yrt;
                
                % else of the Arees0 condition
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
            %
            %FlytracksNew{file}=[xc yc xrh yrh xrt yrt];
            %         FlytracksNew{frameCount}=[xc yc xrh yrh xrt yrt];
            
            % remeber to have the left, center and right versions of it
            if arenaside==1
                FlytracksNewL(frameCount,:)=[xc yc xrh yrh xrt yrt];
                
            elseif arenaside==2
                FlytracksNewC(frameCount,:)=[xc yc xrh yrh xrt yrt];
                
            else
                FlytracksNewR(frameCount,:)=[xc yc xrh yrh xrt yrt];
                %% Processing Time info %%
                if 0==mod(lframe,100)
                    CurrentFrame=[lframe]
                    toc;
                    percentComplete = [lframe/finalFrame*100]
                end
            end
            %% Saving Backup at 10000 frames %%
            if 0==mod(lframe,10000)
                save(['D:\Documents\AlexTracking\Temp Back Up\tracking_10000_' filename(1:end-4) '-Left.mat'],'FlytracksNewL','param','filename')
                save(['D:\Documents\AlexTracking\Temp Back Up\tracking_10000_' filename(1:end-4) '-Centre.mat'],'FlytracksNewC','param','filename')
                save(['D:\Documents\AlexTracking\Temp Back Up\tracking_10000_' filename(1:end-4) '-Right.mat'],'FlytracksNewR','param','filename')
            end
            
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
    atoc=toc
    %%
%     save(['D:\Documents\AlexTracking\TotaltrakingNew-' filename(1:end-4) '-Left.mat'],'FlytracksNewL','atoc','param','filename')
%     save(['D:\Documents\AlexTracking\TotaltrakingNew-' filename(1:end-4) '-Centre.mat'],'FlytracksNewC','atoc','param','filename')
%     save(['D:\Documents\AlexTracking\TotaltrakingNew-' filename(1:end-4) '-Right.mat'],'FlytracksNewR','atoc','param','filename')
    
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


