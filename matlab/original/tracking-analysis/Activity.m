%% %% Activity %% %%
% flies_idx=params.IndexAnalyse;
  
%%
% %%% Saving test to create the folder
% SubFolder_name='Activity';
% mkdir([DataSaving_dir_temp Exp_num '\Plots\' SubFolder_name])
% %% Percentage of time moving out of time far from spots (d>4.5mm)
% maxlengthTimes=2100;%% This is an arbitrary large number just to pre-allocate space in memory.
% TimemovingFarSpots=nan(length(flies_idx),1);
% AvWSpeed=nan(length(flies_idx),1);
% TimeonEdge=nan(length(flies_idx),1);
% DistWalk=nan(length(flies_idx),1);
% MSDR=nan(length(flies_idx),1);
% AvDurMoving=nan(length(flies_idx),1);
% AvDurStopping=nan(length(flies_idx),1);
% NumBouts=nan(length(flies_idx),1);
%
% %% Edge Apactivity Parameters
% Intimes_edge=nan(maxlengthTimes,length(flies_idx));
% DistonEdge=nan(length(flies_idx),1);
% EdgeExploration=nan(length(flies_idx),1);
% PercTimemovingEdge=nan(length(flies_idx),1);
% AvWalkingSpeedEdge=nan(length(flies_idx),1);
% AvStoppingSpeedEdge=nan(length(flies_idx),1);
%
% Inact_Dur=cell(size(Heads_Sm));
%
% % Walking_vec=walking_fun(Steplength_Sm_c,Steplength_Sm180_h,flies_idx,params);
% %%
% lflycounter=1;
% for lfly=flies_idx
%     display(lfly)
%
%     %     f_spot=FlyDB(lfly).WellPos;%(FlyDB(lfly).Geometry==1,:);%All spots
% %     Dist2fSpots=nan(size(Heads_Sm{lfly},1),size(f_spot,1));
% %     for n=1:size(f_spot,1)
% %         Dist2fSpots(:,n)=sqrt(sum(((Heads_Sm{lfly}-...
% %             repmat(f_spot(n,:),...
% %             length(Heads_Sm{lfly}),1)).^2),2));
% %     end
%
% %     log_farfromfood=~(logical(sum(Dist2fSpots(1:size(Steplength_Sm_c{lfly},1))<(4.5/params.px2mm),2)));%frames outside vicinity of spots
%     log_farfromfood=true(size(Steplength_Sm_c{lfly}));
%     log_Moving=Walking_vec{lfly}==1;%Time walking
%
%     %% Edge Bouts, using two thresholds
%
%     [ log_edge ] = Edge_Explor(Heads_Sm,Steplength_Sm_c,lfly,params);
%     %%
%     InOut_Mov=conv(double(log_Moving),[1 -1]);%col vector
%     InOutfr=find(InOut_Mov);
%     DurIn_tmp=diff(InOutfr);
%     DurIn_Mov=DurIn_tmp(1:2:length(DurIn_tmp))/params.framerate; %In sec %Without params.framerate:In frame
%     DurIn_Stop=DurIn_tmp(2:2:length(DurIn_tmp)-1)/params.framerate;
%
%     MSDR_temp=nan(length(DurIn_Mov),1);
%     for lbout=1:length(DurIn_Mov)
%         frame_out=InOutfr(2*lbout);
%         frame_in=InOutfr(2*lbout-1);
%         if frame_out==(length(Steplength_Sm_c{lfly})+1)
%             frame_out=frame_out-1;
%         end
%         MSDR_temp(lbout)=max(Steplength_Sm_c{lfly}(frame_in:frame_out))/...
%             DurIn_Mov(lbout);
%     end
%
% % % % %     EdgeExploration(lfly)=sum(~isnan(Intimes(:,lfly,3)))/Tot_t_moving(lfly);
%
%     %% Saving Parameters
%     AvDurMoving(lflycounter,1)=nanmean(DurIn_Mov);
%     AvDurStopping(lflycounter,1)=nanmean(DurIn_Stop);
%     NumBouts(lflycounter,1)=length(DurIn_Mov);
%     MSDR(lflycounter,1)=nanmean(MSDR_temp);
%     DistWalk(lflycounter,1)=nansum(Steplength_Sm_c{lfly}(log_Moving))*params.px2mm/1000;%m
%     AvWSpeed(lflycounter,1)=DistWalk(lflycounter,1)*1000/(sum(log_Moving)/params.framerate);%mm/s
%     TimemovingFarSpots(lflycounter,1)=((sum(log_Moving)/sum(log_farfromfood))*100);%Percentage
%
%     %% Inactivity as no-movement (speed < 0.1 mm/s)
%     [~,InactDur_fly]=speed_engagement(Steplength_Sm_c{lfly}*params.px2mm*params.framerate,params);
%     Inact_Dur{lfly}=InactDur_fly;
%
%     %% Activity on Edge
%     InOut_edge=conv(double(log_edge),[1 -1]);
%     if   ~isempty(find(InOut_edge,1))
%         DurIn_edge_temp=diff(find(InOut_edge));
%         DurIn_edge=DurIn_edge_temp(1:2:length(DurIn_edge_temp))/params.framerate;%sec
%
%         Intimes_edge(1:length(DurIn_edge),lfly)=DurIn_edge;
%         TimeonEdge(lflycounter,1)=nansum(Intimes_edge(:,lfly));
%         EdgeExploration(lflycounter,1)=sum(~isnan(Intimes_edge(:,lfly)))/...
%             (sum(log_Moving)/params.framerate);% Number of visits per second of movement
%
%     end
%     AvWalkingSpeedEdge(lflycounter,1)=nanmean(Steplength_Sm_c{lfly}(log_Moving&log_edge))*params.px2mm*params.framerate;
%     AvStoppingSpeedEdge(lflycounter,1)=nanmean(Steplength_Sm_c{lfly}(~log_Moving))*params.px2mm*params.framerate;
%     PercTimemovingEdge(lflycounter,1)=(sum(log_Moving&log_edge)/sum(log_edge));%(sum(log_Moving&log_edge)/params.framerate)/(TimeonEdge(lflycounter,1));
%     DistonEdge(lflycounter,1)=nansum(Steplength_Sm_c{lfly}(log_edge))*params.px2mm;%mm
%     lflycounter=lflycounter+1;
% end
%
% %% Histogram and Speed-related parameters
% close all
% figure('Position',[100 50 params.scrsz(3)-150 params.scrsz(4)-150],'Color','w')
MarkrSz=4;FontSz=10;LnWdth=2;fontName='arial';
% colssubplot=4;rowssubplot=2;
% subplot(rowssubplot,colssubplot,[1,2,5,6])
Vel_range=[0:4/20:25];%0:30/50:30; % Velocity range in mm/s %bins=80 for Vmax=4, non-zero
Conditions=3;
close all
plot_hist_speed(Steplength_Sm_h,Vel_range,Conditions,FontSz,params,fontName,CumTimeEnc);%CumTimeEnc from Lagphase.m with lthr=2.5mm
% % h=plot_hist_speed(Steplength_Sm_c,Heads_Sm,Vel_range,Conditions,20,params)
% share=0;
%
% subplot(rowssubplot,colssubplot,3)
% plot_bar(AvWSpeed,'Av. Walking Speed [mm/s]','Av Walking Speed',...
%     Conditions, params,SubFolder_name,...
%     Dropbox_choicestrategies,DataSaving_dir_temp,Exp_num,Exp_letter,share,1,MarkrSz,FontSz,LnWdth,fontName)
%
% subplot(rowssubplot,colssubplot,4)
% plot_bar(NumBouts,'Nº of Stopping or Moving Bouts','Nº of Stopping Bouts',...
%     Conditions, params,SubFolder_name,...
%     Dropbox_choicestrategies,DataSaving_dir_temp,Exp_num,Exp_letter,share,1,MarkrSz,FontSz,LnWdth,fontName)
%
% subplot(rowssubplot,colssubplot,7)
% plot_bar(AvDurMoving,'Av. Duration of Moving Bouts [s]','Av Duration of Moving Bouts',...
%     Conditions,params,SubFolder_name,...
%     Dropbox_choicestrategies,DataSaving_dir_temp,Exp_num,Exp_letter,share,1,MarkrSz,FontSz,LnWdth,fontName)
%
% subplot(rowssubplot,colssubplot,8)
% plot_bar(AvDurStopping,'Av. Duration of Stopping Bouts [s]','Av Duration of Stopping Bouts',...
%     Conditions,params,SubFolder_name,...
%     Dropbox_choicestrategies,DataSaving_dir_temp,Exp_num,Exp_letter,share,1,MarkrSz,FontSz,LnWdth,fontName)
%
% hsuptitle=suptitle('Speed related parameters');
% set(hsuptitle,'FontSize',FontSz+2,'FontName',fontName,'FontWeight','bold')
% %%% Saving images
% figname=[Exp_num Exp_letter ' Speed related parameters'];
% % print('-dpng','-r600',[DataSaving_dir_temp Exp_num '\Plots\' SubFolder_name '\' figname '.png'])
% export_fig([DataSaving_dir_temp Exp_num '\Plots\' SubFolder_name '\' figname], '-tif')
% %% Activity parameters
% figure('Position',[100 50 params.scrsz(3)-150 params.scrsz(4)-150],'Color','w')
% MarkrSz=5;FontSz=12;LnWdth=2;fontName='calibri';
%
% colssubplot=4;rowssubplot=2;
% subplot(rowssubplot,colssubplot,1)
% plot_bar(TimemovingFarSpots,'Time moving [%]','Time moving',Conditions,params,SubFolder_name,...
%     Dropbox_choicestrategies,DataSaving_dir_temp,Exp_num,Exp_letter,share,1,MarkrSz,FontSz,LnWdth,fontName)
%
% subplot(rowssubplot,colssubplot,2)
% plot_bar(DistWalk,'Distance covered while walking [m]','Distance covered while walking',...
%         Conditions,params,SubFolder_name,...
%     Dropbox_choicestrategies,DataSaving_dir_temp,Exp_num,Exp_letter,share,1,MarkrSz,FontSz,LnWdth,fontName)
%
% subplot(rowssubplot,colssubplot,3)
% plot_bar(MSDR,'(Max Speed)/Duration [mm/s^2]','MSDR',Conditions,params,SubFolder_name,...
%     Dropbox_choicestrategies,DataSaving_dir_temp,Exp_num,Exp_letter,share,1,MarkrSz,FontSz,LnWdth,fontName)
%
% subplot(rowssubplot,colssubplot,4)
% plot_bar(TimeonEdge/60,'Time on Edge [min]','Time on Edge',...
%     Conditions,params,SubFolder_name,...
%     Dropbox_choicestrategies,DataSaving_dir_temp,Exp_num,Exp_letter,share,1,MarkrSz,FontSz,LnWdth,fontName)
%
% subplot(rowssubplot,colssubplot,5)
% plot_bar(DistonEdge/1000,'Distance covered in edge [m]','Distance covered in edge',...
%     Conditions,params,SubFolder_name,...
%     Dropbox_choicestrategies,DataSaving_dir_temp,Exp_num,Exp_letter,share,1,MarkrSz,FontSz,LnWdth,fontName)
%
% subplot(rowssubplot,colssubplot,6)
% plot_bar(AvWalkingSpeedEdge,'Av Walking speed in edge [mm/s]','Av Walking speed in edge',...
%     Conditions,params,SubFolder_name,...
%     Dropbox_choicestrategies,DataSaving_dir_temp,Exp_num,Exp_letter,share,1,MarkrSz,FontSz,LnWdth,fontName)
%
% ylim([5 20])
% subplot(rowssubplot,colssubplot,7)
% plot_bar(EdgeExploration,'Edge exploration [visits/s moving]','Edge exploration',...
%     Conditions,params,SubFolder_name,...
%     Dropbox_choicestrategies,DataSaving_dir_temp,Exp_num,Exp_letter,share,1,MarkrSz,FontSz,LnWdth,fontName)
%
% subplot(rowssubplot,colssubplot,8)
% plot_bar(PercTimemovingEdge,'Time moving in edge [%]','Time moving in edge',...
%     Conditions,params,SubFolder_name,...
%     Dropbox_choicestrategies,DataSaving_dir_temp,Exp_num,Exp_letter,share,1,MarkrSz,FontSz,LnWdth,fontName)
%
% %%% Saving images
% figname=[Exp_num Exp_letter ' Activity related parameters'];
% % print('-dpng','-r600',[DataSaving_dir_temp Exp_num '\Plots\Activity\',figname '.png'])
% export_fig([DataSaving_dir_temp Exp_num '\Plots\' SubFolder_name '\' figname], '-tif')
% %% Inactivity as no-movement (speed < 0.1 mm/s)
% % binfly=hist_InactDur(Inact_Dur,params,Conditions);%,1);%for plotting hist
% % plot_bar(binfly,'Average long inactivity bout duration [s]',...
% %         Conditions,params,0)
% % saveas(gcf,[dir2savefigs 'Long Inactivity Bouts.png'],'png')
% %% Food Related Activity
% % figure('Position',[100 50 params.scrsz(3)-1150 params.scrsz(4)-250],'Color','w')
% % MarkrSz=10;FontSz=40;LnWdth=4;fontName='calibri';
% % MarkrSz=5;FontSz=12;LnWdth=2;fontName='calibri';
% % colssubplot=4;rowssubplot=2;
% % subplot(rowssubplot,colssubplot,1)
% % plot_bar(TimemovingFarSpots,'Time moving when r_f \geq 3mm (%)',Conditions,params,1,MarkrSz,FontSz,LnWdth,fontName)
% % plot_bar(AvStoppingSpeedEdge,'Av. Stopping speed [mm/s]',Conditions,params,1,MarkrSz,FontSz,LnWdth,fontName)
% % ylim([0 2])
%
% % %%% Saving images
% % dir2savefigs=[DataSaving_dir_temp Exp_num '\Plots\Activity\'];
% % fignameSpeed1=[dir2savefigs Exp_letter '_Activity parameters'];
% % saveas(gcf,[fignameSpeed1 '.fig'],'fig')
% % saveas(gcf,[fignameSpeed1 '.bmp'],'bmp')
% % cd(dir2savefigs)
% % export_fig A_Activity_parameters -tif
% % cd(workingdir)
% %% Rank-freq  plot of Edge bouts
% % CondSymbol={'o';'o';'o';'o'};
% % plot_rank_freq(Intimes_edge,Conditions,CondSymbol,params)
%
% %% Histogram Stopping and Walking Bouts %% Sanity check for long tails --> It seems we can use mean, the variance is not so big
% % X_range=0:50/50:50; % Velocity range in mm/s %bins=80 for Vmax=4, non-zero
% % Y_label='p(Duration of Stopping bouts)';
% % X_Label='Duration [s]';
% % hist_cell(X_range,StoppingBouts,X_Label,Y_label,Conditions,params)
% %
% % for lfly=1:length(Steplength_Sm_c)
% %    close all
% %     plot_bar(MovingBouts{lfly},'Durations Moving Bouts [s]',params.ConditionIndex(lfly),params)
% %     pause
% % end
%
% %% Histogram of concatenated speed
% % SpeedOutSpots=cell(length(flies_idx),1);
% % for lfly=flies_idx
% %
% %         spots_idxs=1:18;
% %         f_spot=FlyDB(lfly).WellPos(spots_idxs,:);
% %         Dist2fSpots_log=nan(params.MinimalDuration,length(spots_idx));
% %
% %         for n=1:size(f_spot,1)
% %             Diff2fSpot=Heads_Sm{lfly}(1:params.MinimalDuration,:)-...
% %                 repmat(f_spot(n,:),...
% %                 params.MinimalDuration,1);
% %
% %             Dist2fSpots_log(:,n)=(sqrt(sum(((Diff2fSpot).^2),2)).*params.px2mm)>3;%for all further than 3 mm
% %         end
% %     SpeedOutSpots{lfly}=
% % end
% % close all
% % x_label='Speed [mm/s]';%'Speed in QuickDis [mm/s]';%'Dist from spot in QD [mm]';%
% % y_label='Event Nº';%'Revisits';%
% % saveplot=1;
% % Rank_Freq_plot(RawRevisits,Conditions,params,2,100,[100 100],... QuickDiseng 80,[100 10] RawRevisits 50,[50 10]
% %     x_label,y_label,saveplot,Dropbox_choicestrategies,Exp_num,Exp_letter,DataSaving_dir_temp)

%% SAve
SubFolder_name='Activity';
savefig_withname(1,'600','png',DataSaving_dir_temp,Exp_num,Exp_letter,...
            SubFolder_name)