% function [ output_args ] = Untitled( input_args )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%% Plotting over frames
videoPath='C:\Users\Public\Videos\Recordings Fly Tracker Prject\Exp 0003\';
% 'E:\Videos\';% 'G:\FLY TRACKER PROJECT\TRACKING AND VIDEO ANALYSIS\Videos\Exp 0003\';%'C:\Users\Vero\Documents\Videos\Experiments\';%
Heads_SteplengthDir='C:\Users\Vero\Bonsai tracking\Exp 0003\Heads_Steplength\';%'E:\Analysis Data\Experiment 0003\Heads_Steplength\';%
Center=[216.8458,246.1174;700.7961,240.1100;1184.2,237.9];

N_of_fram=5;
close all
figure
% vidObj= VideoWriter([[DataSaving_dir_temp Exp_num '\Plots\Presentations\',...
% 'BellyUp_0003A02R02Cam02P0WT-CantonS_L_245700.avi']);
% vidObj.FrameRate=20;
% vidObj.Quality=100;
% open(vidObj);
Ann_counter=1;
filecounter=3;
% for lfile2=Problem_flies(1,:)%Movies_idx
    %%
    filename='0003A01R05Cam01P0WT-CantonS.avi';%'0003A02R01Cam01P0WT-CantonS.avi';
    sameimage=0;
%     arenaside=Problem_flies(2,Problem_flies(1,:)==lfile2);
%     lfile=(lfile2-arenaside+3)/3;
%     filename=Allfilenames{lfile}
% %     clear DB
    load([Heads_SteplengthDir 'DB-Heads ' filename(1:end-4) '.mat'],'DB')%,'Center')
    if sameimage==0
       MovieObj=VideoReader([videoPath filename]);
    end
    
%     Fliesinvideo=find(cell2mat(cellfun(@(x)~isempty(strfind(x,filename)),{FlyDB.Filename},'uniformoutput',false)));
    
%     for arenaside=1%:3
%         arenaside=1
%         lfly=Fliesinvideo([FlyDB(Fliesinvideo).Arena]==arenaside);
%         AvWalkingSpeed=nanmean(DB(arenaside).Vel_Filt(DB(arenaside).Vel_Filt>StopVel));
%         log_jump=(DB(arenaside).Steplength>(4*AvWalkingSpeed));%&(DB(arenaside).Steplength<=(5*AvWalkingSpeed));%DB(arenaside).Vel_Filt>4*AvWalkingSpeed;%
%         InOut=conv(double(log_jump),[1 -1]);%Notebook1 pg148
%         JumpStart=find(InOut==1);
        
%         frames2plot=DB(arenaside).Uncorrected(:,1)';%JumpStart;%find(log_jump);%Use JumpStart for smoothed
%         if lfile2==48,frames2plot=frames2plot([1:5,7:length(frames2plot)]);end
%         if size(frames2plot,2)>=5
%         frames2plot=frames2plot(randperm(size(frames2plot,1),N_of_fram));% Select random frames with Jumps
        
        % frames2test=;% Must be consecutive for read command
%         if ~isempty(JumpStart), endfirstsegment=JumpStart(1);
%         else endfirstsegment=size(DB(arenaside).Steplength,1)-1;end
        for llframe=100000%frames2plot%wrongframes{filecounter}%%30690%Jumps_Idx'%CorrectedFrames'%
%             display(DB(arenaside).Steplength(llframe-2:llframe+2))
%             display(DB(arenaside).HeadingDiff(llframe-2:llframe+2))
%             segmentframes=[llframe,DB(arenaside).Uncorrected((DB(arenaside).Uncorrected(:,1)==llframe),2)]
%             if ~isempty(JumpStart),
%                 if llframe>25, frames2test=llframe-5:llframe+5,
%                 else frames2test=llframe:llframe+10,end
%             else frames2test=size(DB(arenaside).Steplength,1)-10:size(DB(arenaside).Steplength,1),
%             end
            frames2test=llframe:llframe+300%llframe:DB(arenaside).Uncorrected((DB(arenaside).Uncorrected(:,1)==llframe),2);%
            display(['start:' num2str(frames2test(1)) ', end:' num2str(frames2test(end))])
            skip=0;
%             if nansum(DB(arenaside).Steplength(frames2test(1):frames2test(end)))/framerate>10,skip=1;end
%             if length(frames2test)>50, frames2test=llframe:llframe+15;end
%             frames2test=329500%:329500;
            if sameimage==0
                Rawimage=read(MovieObj,[frames2test(1) frames2test(end)]);%[1 frames2test(end)]);
            end
            clf
            % figure
            %%
            framecounter=1;
            for lframe=frames2test(1:5:end)
                if skip==1,break,end
                %%% Showing raw frame image %
%                 clf
%                 lframe
                imshow(Rawimage(:,:,1,frames2test==lframe))%lframe))
                hold on
%                 arenaside=2
                %     for arenaside=1:3%Uncomment for arena-frames plotting
                
               for arenaside=1:3
                plot(DB(arenaside).cBon(frames2test(1):lframe,1),...
                    DB(arenaside).cBon(frames2test(1):lframe,2),'.-b','MarkerSize',5,'LineWidth',2)
                       
%         set(c,'Color',[0.1 0.1 0.1],'LineWidth',2)
    %     patch(xc,yc,CmapSubs(1,:),'EdgeColor',CmapSubs(1,:))
                %%% Plotting New Head
%                 plot([DB(arenaside).hBon(frames2test(1):lframe,1)],...
%                     [DB(arenaside).hBon(frames2test(1):lframe,2) ],'oc','MarkerSize',5,'MarkerFaceColor','c')
%                 plot([DB(arenaside).hBon(frames2test(1):lframe,1)],...
%                     [DB(arenaside).hBon(frames2test(1):lframe,2) ],'-c','LineWidth',2)
%                 plot([DB(arenaside).tBon(frames2test(1):lframe,1)],...
%                     [DB(arenaside).tBon(frames2test(1):lframe,2) ],'or','MarkerSize',5,'MarkerFaceColor','r')
                
                quiver(DB(arenaside).cBon(frames2test(1):lframe,1),...
                    DB(arenaside).cBon(frames2test(1):lframe,2),...
                    (DB(arenaside).hBon(frames2test(1):lframe,1)-DB(arenaside).tBon(frames2test(1):lframe,1))/2,...
                    (DB(arenaside).hBon(frames2test(1):lframe,2)-DB(arenaside).tBon(frames2test(1):lframe,2))/2,...
                    'm','LineWidth',2,'MaxHeadSize',0.3)
                %%% Cropping the area around the fly
                delta=30;
%                 axis([floor(DB(arenaside).cBon(lframe,1))-delta,...
%                     floor(DB(arenaside).cBon(lframe,1))+delta,...
%                     floor(DB(arenaside).cBon(lframe,2))-delta,...
%                     floor(DB(arenaside).cBon(lframe,2))+delta])
                
                %     end
                %     axis([0 1400 0 478])
                pause(0.2)
                
%                     F1=getframe;
%                     writeVideo(vidObj,F1);
               end
               framecounter=framecounter+1;
            end
%             close(vidObj);
            % clf
            % imshow(ones(479,479,3))
            % axis([0 60 0 60])
            % F1.cdata=uint8(ones(479,479,3));%getframe;
            % F1.colormap=[];
            % writeVideo(vidObj1,F1);
           
            
%             pause
            if skip~=1
                Ann_counter=Ann_counter+1
            end
        end
%         end
%         pause
%     end
filecounter=filecounter+1;
% end

