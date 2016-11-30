% function [nofnotcorrected,DistCovered,AvSpeed]=UncorrectedHeading(Allfilenames,...
%     Movies_idx,Heads_SteplengthDir,StopVel,ForwardWalkThresh)
%[nofnotcorrected,DistCovered,AvSpeed]=UncorrectedHeading(Allfilenames,...
%     Movies_idx,Heads_SteplengthDir,StopVel,ForwardWalkThresh)
% Plotting number of not corrected segments between jumps, distance covered
% and speed during those segments
% Inputs:
% ForwardWalkThresh in px
% StopVel in mm/s

flycounter=1;
eventcounter=1;
num_uncorrected=nan(length(Movies_idx)*3,1);
NumofJumps=nan(length(Movies_idx)*3,1);
DistCovered=nan(2500,2);
AvSpeed=nan(2500,2);
Problem_flies_temp=nan(1,length(Movies_idx)*3);
framerate=50;
px2mm=1/6.4353; % mm in 1 px
Ann_counter=6;
for lfile=Movies_idx(17:end)%1:length(Files)
    %     filename=Files{lfile};%'0007C03R02Cam01P0WT-CantonS.avi'
    filename=Allfilenames{lfile}
    load([Heads_SteplengthDir 'DB-Heads ' filename(1:end-4) '.mat'],'DB')
    for arenaside=1:3
        arenaside
        frames2plot=[];
        num_uncorrected(flycounter)=size(DB(arenaside).Uncorrected,1);
        if num_uncorrected(flycounter)>20,Problem_flies_temp(flycounter)=flycounter;display(flycounter),end
        if flycounter~=114 %(fly with 492 events)
            %%
            
            %         HeadingvsWalk=CircleDiff(DB(arenaside).Heading(1:end-1),DB(arenaside).WalkDir);
            AvWalkingSpeed=nanmean(DB(arenaside).Vel_Filt(DB(arenaside).Vel_Filt>StopVel));
            log_jump=(DB(arenaside).Steplength>(4*AvWalkingSpeed));%&(DB(arenaside).Steplength<=(5*AvWalkingSpeed));%DB(arenaside).Vel_Filt>4*AvWalkingSpeed;%
            InOut=conv(double(log_jump),[1 -1]);%Notebook1 pg148
            JumpStart=find(InOut==1);
            JumpEnd=find(InOut==-1);
            NumofJumps(flycounter)=size(JumpStart,1);
            %%
            unc_counter=1;
            for luncframe=DB(arenaside).Uncorrected(:,1)'
                frameend=DB(arenaside).Uncorrected(unc_counter,2);
                col=1;
                
                if sum(Problem_flies_temp(flycounter)==flycounter)~=0, col=2;end
                DistCovered(eventcounter,col)=nansum(DB(arenaside).Steplength(luncframe:frameend))/framerate;
                AvSpeed(eventcounter,col)=nanmean(DB(arenaside).Steplength(luncframe:frameend));
                eventcounter=eventcounter+1;
                
                
                %% Plot specific cases
                if (DistCovered(eventcounter-1,col)>10)%&&(AvSpeed(eventcounter-1,col)>=4)%(ForwardWalkThresh*px2mm)
                    display(luncframe)
                    display({['Av Speed: ' num2str(AvSpeed(eventcounter-1,col))];...
                        ['Dist= ' num2str(DistCovered(eventcounter-1,col))]})

                    frames2plot=[frames2plot,DB(arenaside).Uncorrected(unc_counter,1)];
                    
%                     return %pause
                end
                unc_counter=unc_counter+1;
            end
            %         if DistCovered>10, break, end
        end
        
        if ~isempty(frames2plot),Plot_Head,end
        flycounter=flycounter+1;
        
    end
    %     if DistCovered>10, display('BREAK'), break, end
    
end
%% PLOTTING
% Problem_flies=Problem_flies_temp(~isnan(Problem_flies_temp));
% Colormap=[179 83 181;243 164 71]/255;%[magenta;orange]
% scrsz = get(0,'ScreenSize');
% close all
% figure('Position',[100 50 scrsz(3)-950 scrsz(4)-350])
% plot(num_uncorrected,'ok','MarkerFaceColor',Colormap(1,:),'MarkerSize',6)
% hold on
% plot(Problem_flies, num_uncorrected(Problem_flies),'ok','MarkerFaceColor',Colormap(2,:),'MarkerSize',6)
% font_style('Not Corrected Segments','Fly Nº','Nº of Events','normal','calibri',20)
% %%
% figure('Position',[100 50 scrsz(3)-950 scrsz(4)-350])
% plot(NumofJumps,'ok','MarkerFaceColor',Colormap(1,:),'MarkerSize',6)
% hold on
% plot(Problem_flies, NumofJumps(Problem_flies),'ok','MarkerFaceColor',Colormap(2,:),'MarkerSize',6)
% plot([0 length(NumofJumps)],[mean(NumofJumps) mean(NumofJumps)],'-r','LineWidth',2)
% font_style([],'Fly Nº','Nº of Jumps','normal','calibri',20)
% %%
% totalnumevents=find(sum(isnan(DistCovered),2)==2,1,'first')-1;
% figure('Position',[100 50 scrsz(3)-950 scrsz(4)-350])
% plot(DistCovered(1:totalnumevents,1),'ok','MarkerFaceColor',Colormap(1,:),'MarkerSize',6)
% hold on
% plot(DistCovered(1:totalnumevents,2),'ok','MarkerFaceColor',Colormap(2,:),'MarkerSize',6)
% font_style('Not Corrected Segments','Event Nº','Distance covered (mm)','normal','calibri',20)
% % plot([0 totalnumevents],[(ForwardWalkThresh*px2mm) (ForwardWalkThresh*px2mm)],'--b','LineWidth',1)
% % t=text(1,ForwardWalkThresh*px2mm+1,'Distance threshold');
% % set(t,'FontName','calibri','FontSize',16,'Color','b')
% plot([0 totalnumevents],[10 10],'-r','LineWidth',2)
% axis([0 totalnumevents 0 max(max(DistCovered))])
% %%
% 
% figure('Position',[100 50 scrsz(3)-950 scrsz(4)-350])
% plot(AvSpeed(1:totalnumevents,1),'ok','MarkerFaceColor',Colormap(1,:),'MarkerSize',6)
% hold on
% plot(AvSpeed(1:totalnumevents,2),'ok','MarkerFaceColor',Colormap(2,:),'MarkerSize',6)
% font_style('Not Corrected Segments','Event Nº','Average speed (mm/s)','normal','calibri',20)
% xlim([0 totalnumevents])
% %%
% figure('Position',[100 50 scrsz(3)-950 scrsz(4)-350])
% distthresh=10;
% plot(AvSpeed(DistCovered(1:totalnumevents,1)>(distthresh),1),'ok','MarkerFaceColor',Colormap(1,:),'MarkerSize',10)
% hold on
% plot(AvSpeed(DistCovered(1:totalnumevents,2)>(distthresh),2),'ok','MarkerFaceColor',Colormap(2,:),'MarkerSize',10)
% plot([0 max([length(AvSpeed(DistCovered(:,1)>(distthresh),1)) length(AvSpeed(DistCovered(:,2)>(distthresh),2))])],[StopVel StopVel],'--r','LineWidth',2)
% t=text(1,StopVel+0.5,'Stopping threshold');
% set(t,'FontName','calibri','FontSize',16,'Color','r')
% font_style('Not Corrected Segments','Event Nº','Average speed (mm/s), when D > 10 mm','normal','calibri',20)
% xlim([0 max([length(AvSpeed(DistCovered(:,1)>(distthresh),1)) length(AvSpeed(DistCovered(:,2)>(distthresh),2))])])
%% Run code of Distance Windows. Replace the index of the JumpEnd in lframecounter
% % % HeadingvsWalk=CircleDiff(DB(arenaside).Heading(1:end-1),DB(arenaside).WalkDir);
% % % CorrectedFrames=[];
% % %         Uncorrected=[];
% % %         ForwardWalkThresh=40;%px
% % %         PercThr=0.75;%Threshold for walking forward most of the time
% % %         lframecounter=197;
% % %         if ~isempty(JumpStart)
% % %             for lframe=JumpEnd(lframecounter)'
% % %                 %%% a) Slide a window to find fly walking forward for 2
% % %                 %%% BodyLengths
% % %                 lframe
% % %                 CurrentFrame=lframe;
% % %                 for lstep=lframe:JumpStart(lframecounter+1)
% % %                     lstep
% % %                     DistCovered=nansum(DB(arenaside).Steplength(lstep:CurrentFrame)/framerate/px2mm);
% % %                     while DistCovered<ForwardWalkThresh
% % %                         DistCovered=nansum(DB(arenaside).Steplength(lstep:CurrentFrame)/framerate/px2mm);
% % %                         CurrentFrame=CurrentFrame+1;%Step of sliding window=1
% % %
% % %                         %%% Guarantee that speed is below jumping threshold by
% % %                         %%% breaking the loop when next jump is reached
% % %                         if CurrentFrame==JumpStart(lframecounter+1)
% % %                             display('REACHED NEXT JUMP')
% % %                             %%% Do this when we reached the next jump without covering
% % %                             %%% a 40 px distance
% % %                             break
% % %
% % %
% % %                         end
% % %
% % %                     end
% % %
% % %
% % %                     if CurrentFrame==JumpStart(lframecounter+1)
% % %                         Uncorrected=[Uncorrected; lframe];
% % %                         ReachNextJump=1; break %stop sliding window
% % %                     else
% % %                         display(['TEST WINDOW, dist:' num2str(DistCovered) 'fr:' num2str(CurrentFrame-1)])
% % %                         %%%% When a distance of 45 px has been reached:
% % %                         %%%% b) Count how many of those frames are moving forward,
% % %                         %%%% meaning Walking Direction and Heading differ less than
% % %                         %%%% 80º. Note:remember there are nans when fly stops
% % %                         WindowFrames=lstep:(CurrentFrame-1);
% % %                         DistWindow_temp=DB(arenaside).Steplength(WindowFrames);
% % %                         ForwardWalk_log=(HeadingvsWalk(WindowFrames)>=-80)&(HeadingvsWalk(WindowFrames)<=80);
% % %                         BackwardWalk_log=(HeadingvsWalk(WindowFrames)<-80)|(HeadingvsWalk(WindowFrames)>80);
% % %
% % %                         %%%% c) If PercThr of them are, then establish new heading and
% % %                         %%%% propagate backwards, if not, continue sliding the window
% % %                         ForwardDPerc=nansum(DistWindow_temp(ForwardWalk_log)/framerate/px2mm)/...
% % %                             (nansum(DistWindow_temp(ForwardWalk_log)/framerate/px2mm)+nansum(DistWindow_temp(BackwardWalk_log)/framerate/px2mm));
% % %
% % % %                         ForwardPerc=sum(ForwardWalk_log)/(sum(ForwardWalk_log)+sum(BackwardWalk_log));
% % %                         display(['Forward: ' num2str(ForwardDPerc*100) '%'])
% % %                         if ForwardDPerc>=PercThr% If they are mostly walking forward
% % %                             % Then do nothing, because heads are correct and no need
% % %                             % to keep sliding the window
% % %                             break
% % %
% % %                         elseif (1-ForwardDPerc)>=PercThr % If they walk backwards all this distance
% % %                             % Flip head and propagate this direction until last jump and next jump
% % %                             OldHs=DB(arenaside).hBon(lframe:JumpStart(lframecounter+1)-1,:);% Old Heads within jumps
% % %                             OldTs=DB(arenaside).tBon(lframe:JumpStart(lframecounter+1)-1,:);% Old Tails within jumps
% % %                             DB(arenaside).hBon(lframe:JumpStart(lframecounter+1)-1,:)=OldTs;
% % %                             DB(arenaside).tBon(lframe:JumpStart(lframecounter+1)-1,:)=OldHs;
% % %                             %                     else (ForwardPerc<PercThr)&&(ForwardPerc>(1-PercThr)) %If none of previous
% % %                             %                         % Continue sliding the window
% % %                             display(['FIXED HEADING ' num2str(lframe) ' to ' num2str(JumpStart(lframecounter+1)-1)])
% % %                             CorrectedFrames=[CorrectedFrames;lframe];
% % %                             break
% % %                         end
% % %                     end
% % %                 end
% % %                 lframecounter=lframecounter+1;
% % %
% % %             end
% % %
% % %
% % %         end
% % %         DB(arenaside).Uncorrected=Uncorrected;
% % %         DB(arenaside).CorrectedFrames=CorrectedFrames;
%% Problem flies
% % % Problem_flies(2,:)=[1 3 1 2 2 3 3 2 3 1 2];
