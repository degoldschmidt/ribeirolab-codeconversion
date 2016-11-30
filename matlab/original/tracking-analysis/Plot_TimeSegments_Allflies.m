%% Plot Time Segments
% load('E:\Analysis Data\Experiment 0004\Variables\Etho_AB&Etho_H0004A 02-Oct-2015.mat')
% load('E:\Analysis Data\Experiment 0004\Variables\ActivityBouts&CumulativeTimeV0004A 02-Oct-2015.mat')
NonEaterThr=60;%s
HEAD_YN=0;
eachflyrange=0;% 0;% To use fixed ranges for all flies
slidingwindow=0;%If 1, remember loop is l=1;
windowsize=5;%min
windowstep=1;%min


if slidingwindow==0
    RANGES={[1 30000;30001 90000;90001 150000;150001 210000;210001 270000;270001 360000];...
        [1 180000];[1 345000];[1 30000];[1 30000;30001 90000;90001 180000;180001 360000];...
        [1 30000;30001 90000;90001 180000];[1 15000]};
else
    %%% Creating ranges for sliding window
    lastframe=params.MinimalDuration;
    RANGES={[(1:windowstep*50*60:lastframe-windowsize*60*50);...
        (1:windowstep*50*60:lastframe-windowsize*60*50)+windowsize*60*50]'};
end

if ~exist('Etho_Tr','var')
    [~,Etho_Tr]=TransitionProb(DurInV,Heads_Sm,FlyDB,params);
end
if ~exist('Etho_Tr2','var')
    [~,Etho_Tr2]=TransitionProb2(DurInV,Heads_Sm,FlyDB,params);
end
if ~exist('HeadingDiff','var'),flies_idx=params.IndexAnalyse;
    [~,~,HeadingDiff] =Heading_WalkingDir(Heads_Sm,Tails_Sm,Centroids_Sm);
end
for l=2%[2 3]%[3 4 7]%[2 3 6]%It must be 1 if slidingwindow=1
   %% Calculating Parameters for Each Time Segment
   if slidingwindow==1,l=1;end
   if eachflyrange==0
        
        ranges=RANGES{l};
        
        if ranges(end)>params.MinimalDuration
            last_idx=find(ranges(:,2)>= params.MinimalDuration,1,'first');
            ranges=ranges(1:last_idx,:);
            ranges(last_idx,2)=params.MinimalDuration;
        end
        
%         [TimeSegmentsParams,CondFlyIdx,Spot_thrs,VisitDurs_TS]=timesegmentsparams(ranges,FlyDB,params,...
%             Heads_Sm,Steplength_Sm_c,Steplength_Sm_h,DurInV,CumTimeV,Binary_V,...
%             Breaks,Etho_Tr,Etho_Tr2, Walking_vec,Etho_Speed,InSpot,HEAD_YN,Binary_Head_mm,CumTimeH,HeadingDiff,eachflyrange,DurInVRV);
%         save([Variablesfolder 'TimeSegmentsParams_5mmH' num2str(HEAD_YN) '_' num2str(size(ranges,1)),...
%             'r_until' num2str(floor((ranges(end)/50/60))) '_' Exp_num Exp_letter ' ' date '.mat'],...
%             'TimeSegmentsParams','VisitDurs_TS','ranges','Head_thr','Spot_thrs','Conditions','params','-v7.3')
%         display('Time Segments saved')
        load([Variablesfolder 'TimeSegmentsParams_5mmH' num2str(HEAD_YN) '_' num2str(size(ranges,1)),...
            'r_until' num2str(floor((ranges(end)/50/60))) '_' Exp_num Exp_letter ' 25-Aug-2016.mat'],...
            'TimeSegmentsParams','VisitDurs_TS','ranges','Head_thr','Spot_thrs')
        
    else
% %         ranges=[1 2;1 30000;30001 90000;90001 180000];%ranges_fly{1};
% %         lastframe=params.MinimalDuration/2;
% %         ranges=[1 2;ranges_temp];
%         % % % %         Note: "ranges", "ranges_fly" and "ranges_str" calculated in
%         % Lagphase.m or in Fig7_SelfYtime_20160105.m
%         
%         [TimeSegmentsParams,CondFlyIdx,Spot_thrs,VisitDurs_TS]=timesegmentsparams(ranges_fly,FlyDB,params,...
%             Heads_Sm,Steplength_Sm_c,Steplength_Sm_h,DurInV,CumTimeV,Binary_V,...
%             Breaks,Etho_Tr,Etho_Tr2, Walking_vec,Etho_Speed,InSpot,HEAD_YN,Binary_Head_mm,CumTimeH,HeadingDiff,eachflyrange,DurInVRV);
%         save([Variablesfolder 'TimeSegmentsParamsfly_' ranges_str,...
%             '_' Exp_num Exp_letter ' ' date '.mat'],...
%             'TimeSegmentsParams','ranges_fly','Head_thr','Spot_thrs',...
%             'VisitDurs_TS','Conditions','params','ranges_temp','-v7.3')
%         display('Time Segments fly saved')
        
                load([Variablesfolder 'TimeSegmentsParamsfly_' ranges_str,...
                    '_' Exp_num Exp_letter ' 25-Aug-2016.mat'])
    end
    
    
    %% Plot Params
    if HEAD_YN==1
        params2plot=[1:6 8:12 13 14 16 22:26 30 33:39 40:66 [63 64 77 78 80 96 120 123]+6];%1:49;%length(TimeSegmentsBoxplot);%[1 2 3 4 11 12 16 9 10 6 13 14 17 20 22 21];%[40:74];%
    else
        params2plot=[48 49 46 47 11 12 6 9 10 73 74 89 83 30 31 60 58 59 2 25 26 27 34 35 36 37 38 39 54 4 56 64 70:72 97:100];%[2 3 54 4 9 10 30 31 40 41 59 69 70:72 23:26 52:53 91 93];%[1:6 8:12 13 14 16 22:26 30 33:39 40:66 [64:67 72 73 78 79:81]+3 85];%
    end
    Conditions=[2 3 1 5 6 4];% EXP 12A [5 1 3];%EXP3D[2 4 1 3];%EXP 4A Mated [2 1 3 4];%EXP 8B[6 4 5 1 3];%EXP 3D [4 3 8 7];%EXP 11A unique(params.ConditionIndex);% [2 1 3];%EXP 8B
    removenoneaters=0;%1-Remove non eaters
    nrows=6;
    if size(ranges,1)<2, ncols=5;else ncols=3;end
    ncols=4;
    fliesidx=cell(length(Conditions),1);
    for lcond=Conditions
        if removenoneaters==1
            fliesidx{Conditions==lcond}=logical((sum(CumTimeV{1}(:,params.ConditionIndex==lcond))/50)>=NonEaterThr);
            eaterslabel='onlyeaters ';
        else
            fliesidx{Conditions==lcond}=true(1,sum(params.ConditionIndex==lcond));
            eaterslabel=' ';
        end
    end
    
    [TimeSegmentsBoxplot,xvalues,numcond,num_subgroups]=...
        timesegmentsboxplot(TimeSegmentsParams,Conditions,ranges,params,params2plot,fliesidx);
    % % %     TimeSegmentsBoxplot3A=TimeSegmentsBoxplot;
    % % %     save([Variablesfolder 'TimeSegmentsBoxplot3A ' date '.mat'],'TimeSegmentsBoxplot3A','-v7.3')
    SubFolder_name='Time Segments';
    Color=Colors(3);%hsv(length(flies_idx));%
    [ColorsinPaper,orderinpaper]=ColorsPaper5cond_fun(Exp_num, Exp_letter,params);
    [CondColors,Cmap_patch]=Colors(length(unique(params.ConditionIndex)));%
    newcondcolors=nan(length(Conditions),3);
    for lcond=Conditions
        if length(Conditions)<=size(ColorsinPaper,1)
            newcondcolors(lcond==Conditions,:)=ColorsinPaper(orderinpaper==lcond,:);%
        else
            newcondcolors(lcond==Conditions,:)=CondColors(ismember(unique(params.ConditionIndex),lcond),:);
        end
    end
    
%     if strfind([Exp_num Exp_letter],'0003D')
%         ColorsFig2C=[84 130 53;... Green - Virgin Yaa
%             0,64,255;... Blue - Virgin AA-
%             179 83 181;... Orchid - Mated Yaa
%             255 192 0;... Yellow - Mated Hunt
%             204,0,0;... Red - Mated AA-
%             ]/255;%
%         newcondcolors=ColorsFig2C;
%     elseif strfind([Exp_num Exp_letter],'0008B')
%         ColorsFig2C=[84 130 53;... Green - Or83b-/-
%             0,64,255;... Blue - Canton S AA-
%             179 83 181;... Orchid -Or83b+/-
%             255 192 0;... Yellow - Canton S AA+ (Yaa)
%             ]/255;%
%         newcondcolors=ColorsFig2C;
%     end
    
    TimeColors=jet(size(ranges,1));
    ColorAx1=[238 96 8]/255;%Color(1,:);
    ColorAx2=[.4 .4 .4];%Color(2,:);
    FntName='arial';
    if eachflyrange==0
        Xticklabels=xticklabelsfun(ranges);
    else
        Xticklabels=xticklabelsfun(ranges);
        if strfind(ranges_str,'lag')
            Xticklabels{1}='Lag';
        end
    end
    
    %% Subplots positions
    AxesPositions=axespositionsfun(nrows,ncols);
    nfigures=ceil(size(params2plot,2)/(nrows*ncols));
    %% Plot boxplots
    saveplot=1;
    close all
    if slidingwindow==1
        plot_types={'Window'};%
    else
        plot_types={'Boxplots'};%{'Median+IQR'};%{'Mean+Stderr'};%{'Window'};%{'Boxplots';'Median+IQR';'Mean+Stderr'};
    end
    
    if saveplot==1
        FtSz=9;
        LineW=1.5;
        MkSz=4;
    else
        FtSz=11;
        LineW=2;
        MkSz=4;
    end
    Interval_Separator=(1:num_subgroups)*(length(Conditions)+1);
    IntervalLabels_ticks=(1:num_subgroups)*(length(Conditions)+1)-(length(Conditions)+1)/2;
    
    if size(params2plot,2)==length(TimeSegmentsBoxplot)
        params_tag='All params';
    else
        params_tag=['Params ' num2str(min(params2plot)) 'to' num2str(max(params2plot))];
    end
    Symbol_cond={'^','o','s','d','p','v','*','>','<','.','x','h','+'};
    for lplot_type=1:length(plot_types)
        plot_type=plot_types{lplot_type}
        
        figcounter=0;
        for lfig=1:nfigures
            figcounter=figcounter+nrows*ncols;
            if figcounter>size(params2plot,2)
                params2plot_subset=params2plot(figcounter-nrows*ncols+1:size(params2plot,2));
            else
                params2plot_subset=params2plot(figcounter-nrows*ncols+1:figcounter);
            end
            
            if eachflyrange==0
                figname=['Time Segments5mm_Cond ' num2str(Conditions) '_' num2str(size(ranges,1)),...
                    'r_until' num2str(floor((ranges(end)/50/60))) '_' plot_type,...
                    ', ' params_tag '-Fig' sprintf('%.2d',lfig) eaterslabel date];%num2str(lfig)
            else
                figname=['Time Segments_Cond ' num2str(Conditions) '_' ranges_str,...
                    '_' plot_type,...
                    ', ' params_tag '-Fig' sprintf('%.2d',lfig) eaterslabel date];%num2str(lfig)
            end
            
            figure('Position',[2100 50 1400 930],'Color','w','Name',figname,'PaperUnits',...
                'centimeters','PaperPosition',[0 0 30 20])
            
            
            plotcounter=0;
            
            for lparam=params2plot_subset
                plotcounter=plotcounter+1;
                
                subplot('Position',AxesPositions(plotcounter,:))
                hold on
                
                if iscell(TimeSegmentsParams{1}(lparam).YLabel)
                    y_label={[num2str(lparam) '-' TimeSegmentsParams{1}(lparam).YLabel{1}];...
                        TimeSegmentsParams{1}(lparam).YLabel{2}};
                else
                    y_label=[num2str(lparam) '-' TimeSegmentsParams{1}(lparam).YLabel];
                end
                %% Boxplots
                if strfind(plot_type,'Boxplots')
                    mediancolor=repmat(zeros(length(Conditions),3),num_subgroups,1);%repmat(newcondcolors,num_subgroups,1);
                    IQRcolor=repmat(newcondcolors,num_subgroups,1);%Cmap_patch
                    [~,lineh] = plot_boxplot_tiltedlabels(TimeSegmentsBoxplot{lparam},cell(length(xvalues),1),xvalues,...
                        IQRcolor,mediancolor,[.4 .4 .4],.4,FtSz,FntName,'.');%'k'
                    ylim2=get(gca,'YLim');
                    if size(ranges,1)>1
                        
                        for lseparator=Interval_Separator
                            plot([lseparator lseparator],ylim2,'--','Color',[.7 .7 .7])%Color(2,:)
                        end
                    end
                    if  size(ranges,1)<=6%4
                        try
                            if eachflyrange==0
                                stats_boxplot_tiltedlabels(TimeSegmentsBoxplot{lparam},...
                                    Xticklabels,Conditions,xvalues,...
                                    ['Time Segments ' num2str(size(ranges,1)) 'r_until',...
                                    num2str(floor((ranges(end)/50/60)))],0,params,...
                                    DataSaving_dir_temp,Exp_num,Exp_letter,['cond ' num2str(Conditions)],'Time Segments',FtSz,FntName)
                            else
                                stats_boxplot_tiltedlabels(TimeSegmentsBoxplot{lparam},...
                                    Xticklabels,Conditions,xvalues,...
                                    ['Time Segments ' ranges_str],0,params,...
                                    DataSaving_dir_temp,Exp_num,Exp_letter,['cond ' num2str(Conditions)],'Time Segments',FtSz,FntName)
                            end
                        catch
                        end
                    end
                    
                    %%
                else
                    lcondcounter=0;
                    for lcond=Conditions
                        lcondcounter=lcondcounter+1;
                        col_idx=lcondcounter:length(Conditions):size(TimeSegmentsBoxplot{lparam},2);
                        if strfind(plot_type,'Median+IQR')
                            plot(xvalues(col_idx),nanmedian(TimeSegmentsBoxplot{lparam}(:,col_idx)),['-' Symbol_cond{lcondcounter}],...
                                'LineWidth',LineW,'Color',newcondcolors(lcondcounter,:),'MarkerFaceColor',newcondcolors(lcondcounter,:),...
                                'MarkerSize',MkSz)
                            line(repmat(xvalues(col_idx),2,1),[prctile(TimeSegmentsBoxplot{lparam}(:,col_idx),25);...
                                prctile(TimeSegmentsBoxplot{lparam}(:,col_idx),75)],'LineWidth',0.5*LineW,'Color',newcondcolors(lcondcounter,:))
                        elseif strfind(plot_type,'Mean+Stderr')% Stderr is based on the Nº of flies contributing to that parameter
                            plot(xvalues(col_idx),nanmean(TimeSegmentsBoxplot{lparam}(:,col_idx)),['-' Symbol_cond{lcondcounter}],...
                                'LineWidth',LineW,'Color',newcondcolors(lcondcounter,:),'MarkerFaceColor',newcondcolors(lcondcounter,:),...
                                'MarkerSize',MkSz)
                            line(repmat(xvalues(col_idx),2,1),...
                                [nanmean(TimeSegmentsBoxplot{lparam}(:,col_idx))-...
                                nanstd(TimeSegmentsBoxplot{lparam}(:,col_idx))/sqrt(sum(~isnan(TimeSegmentsBoxplot{lparam}(:,col_idx))));...
                                nanmean(TimeSegmentsBoxplot{lparam}(:,col_idx))+...
                                nanstd(TimeSegmentsBoxplot{lparam}(:,col_idx))/sqrt(sum(~isnan(TimeSegmentsBoxplot{lparam}(:,col_idx))))],...sqrt(numcond(lcondcounter))
                                'LineWidth',0.5*LineW,'Color',newcondcolors(lcondcounter,:))
                        elseif strfind(plot_type,'Window')
                            plot(xvalues(col_idx),nanmedian(TimeSegmentsBoxplot{lparam}(:,col_idx)),['-' Symbol_cond{lcondcounter}],...
                                'LineWidth',LineW,'Color',newcondcolors(lcondcounter,:),'MarkerFaceColor',newcondcolors(lcondcounter,:),...
                                'MarkerSize',MkSz)
                        end
                    end
                end
                
                
                xlim([0 num_subgroups*(length(Conditions)+1)])
                
                
                ylim2=get(gca,'YLim');
                
                if (ylim2(2)>1.5*max(prctile(TimeSegmentsBoxplot{lparam},75)))&&(max(prctile(TimeSegmentsBoxplot{lparam},75))~=0)
                    ylim([ylim2(1) 1.5*max(prctile(TimeSegmentsBoxplot{lparam},75))])
                    %                         plot([0 num_subgroups*(length(Conditions)+1)],...
                    %                             [1.4*max(prctile(TimeSegmentsBoxplot{lparam},75)),...
                    %                             1.4*max(prctile(TimeSegmentsBoxplot{lparam},75))],'--r')
                end
                
                ylim2=get(gca,'YLim');
                if ylim2(1)==0,
                    ylim2(1)=-.05*ylim2(2);
                    ylim(ylim2);
                end
                
                if sum(TimeSegmentsParams{1}(lparam).YAxes==0)~=2
                    ylim(TimeSegmentsParams{1}(lparam).YAxes)
                end
                ylim3=get(gca,'YLim');
                if strfind(plot_type,'Window')
                    font_style([],[],y_label,'normal',FntName,FtSz)
                    set(gca,'XTick',[0 Interval_Separator],'Xticklabel',[],'tickdir','out')
                else
                    if mod(plotcounter,nrows)==0 || lparam==params2plot(end)
                        %                     set(gca,'XTick',x_ticks,'Xticklabel',Xticklabels,'tickdir','out')
                        set(gca,'XTick',[0 Interval_Separator],'Xticklabel',[],'tickdir','out')
                        font_style([],[],y_label,'normal',FntName,FtSz)%'Time of assay (min)'%'Time from 1st long visit (min)'
                        thandle=text(IntervalLabels_ticks,ylim3(1)*ones(1,length(Xticklabels)),Xticklabels);
                        set(thandle,'HorizontalAlignment','center','VerticalAlignment','top',...
                            'Rotation',0,'FontSize',FtSz,'FontName',FntName);
                    else
                        set(gca,'XTick',[0 Interval_Separator],'Xticklabel',[],'tickdir','out')

                        font_style([],[],y_label,'normal',FntName,FtSz)
                    end
                
                end
                
                if plotcounter==1
                    title(['Exp ' num2str(Exp_num) num2str(Exp_letter) ', HThr=' num2str(Head_thr) 'mm, ' plot_type ' Fig' num2str(lfig) ', ' date])
                end
            end
            
        end
    end
    
        %% Figure with Labels
        figname=['Time Segments - Condition Labels_Cond ' num2str(Conditions) '_' num2str(size(ranges,1)) 'r_until' num2str(floor((ranges(end)/50/60))) '_' date];
        figure('Position',[2100 50 500 500],'Color','w','Name',figname,'PaperUnits',...
            'centimeters','PaperPosition',[0 0 10 10])
        hold on
        lcondcounter=0;
        for lcond=Conditions
            lcondcounter=lcondcounter+1;
            plot([1 2],[lcondcounter lcondcounter],'-','LineWidth',3,'Color',newcondcolors(lcondcounter,:))
            text(3,lcondcounter,params.Labels{lcond},'FontName',FntName,'FontSize',FtSz)
            axis([0 10 0 lcondcounter+1])
            font_style({'Condition labels time segment parameters';['Exp ' num2str(Exp_num) num2str(Exp_letter) ', ' date]},[],[],'normal',FntName,FtSz)
            axis off
        end
    
    %% Distributions of durations per time segment
%         for lsubcounter=1:length(params.Subs_Numbers)
%             figname=['Visit Dur ' params.Subs_Names{lsubcounter},...  
%             ' Hist_TS_Cond ' num2str(Conditions) '_' num2str(size(ranges,1)),...
%             'r_until' num2str(floor((ranges(end)/50/60))) ' ' date];%num2str(lfig)
%             figure('Position',[2100 50 1400 930],'Color','w','Name',figname,'PaperUnits',...
%                 'centimeters','PaperPosition',[0 0 30 20])
%             Colorsnew=nan(size(ColorsinPaper));
%             Colorsnew(orderinpaper,:)=ColorsinPaper;
% 
%             AxesPositions2=axespositionsfun(2,size(ranges,1),0.07,0.07);
%             for lrange=1:size(ranges,1)
%                 subplot('Position',AxesPositions2(2*lrange-1,:))
%                 maxY=120;maxS=20;
%                 hist_bout_duration(VisitDurs_TS{lrange},Conditions,params,5,10,[maxY maxS],...%80,[120 20],...Conditions
%                     'Visit Durations',Colorsnew,FtSz,FntName,params.Subs_Numbers(lsubcounter),1);
%                 box off
%                 legend off
%                 title([Xticklabels{lrange} ' min'])
%                 lcondcounter=0;
%                 for lcond=Conditions
%                     lcondcounter=lcondcounter+1;
%                     y_lim=get(gca,'Ylim');
%                     xarrow=nanmedian(TimeSegmentsBoxplot{8+lsubcounter}...
%                         (:,length(Conditions)*lrange-(length(Conditions)-lcondcounter)))*60;%s
%                     if xarrow>maxY,xarrow=maxY;end
%                     arrow('Start',[xarrow 0.8*y_lim(2)],...
%                         'Stop',[xarrow 0.65*y_lim(2)],'length',20,'baseangle',120,...
%                         'TipAngle',[],'width',5,'EdgeColor','k','FaceColor',CondColors(lcond==unique(params.ConditionIndex),:))
%                 end
%                 subplot('Position',AxesPositions2(2*lrange,:))
%                 hist_bout_duration(VisitDurs_TS{lrange},sort(Conditions),params,3,10,[80 20],...%80,[120 20],...Conditions
%                     'Visit Durations',Colorsnew,FtSz,FntName,params.Subs_Numbers(lsubcounter),1);
%                 box off
%                 legend off
%                 title([])
%             end
%     
%         end
    %% Single fly traces of X parameter
    %     params2plot3=[13];
    %     nrows3=2;ncols3=1;
    %     nfigures3=ceil(size(params2plot3,2)*length(Conditions)/(nrows3*ncols3));
    %     AxesPositions3=axespositionsfun(nrows3,ncols3);
    %     figcounter=0;
    %     %     for lfig=1:nfigures3
    %     %         figcounter=figcounter+nrows3*ncols3;
    %     %         if figcounter>size(params2plot3,2)
    %     %             params2plot_subset3=params2plot3(figcounter-nrows3*ncols3+1:size(params2plot3,2));
    %     %         else
    %     %             params2plot_subset3=params2plot3(figcounter-nrows3*ncols3+1:figcounter);
    %     %         end
    %     params2plot_subset3=params2plot3
    %     figname=['SingleFlyTS_Cond ' num2str(Conditions) '_' num2str(size(ranges,1)) 'r_until' num2str(floor((ranges(end)/50/60))) '_' plot_type ', ' params_tag '-Fig' sprintf('%.2d',lfig) ' ' date];%num2str(lfig)
    %     figure('Position',[2100 50 1400 930],'Color','w','Name',figname,'PaperUnits',...
    %         'centimeters','PaperPosition',[0 0 30 20])
    %     plotcounter=0;
    %     lcondcounter=0;
    %
    %     for lparam=params2plot_subset3
    %         for lcond=Conditions
    %             lcondcounter=lcondcounter+1;
    %             plotcounter=plotcounter+1;
    %
    %             subplot('Position',AxesPositions3(plotcounter,:))
    %             hold on
    %             col_idx=lcondcounter:length(Conditions):size(TimeSegmentsBoxplot{lparam},2);
    %             plot(IntervalLabels_ticks,TimeSegmentsBoxplot{lparam}(:,col_idx)','-o',...
    %                 'LineWidth',2)
    %
    %             xlim([0 num_subgroups*(length(Conditions)+1)])
    %             if iscell(TimeSegmentsParams{1}(lparam).YLabel)
    %                 y_label={[num2str(lparam) '-' TimeSegmentsParams{1}(lparam).YLabel{1}];...
    %                     TimeSegmentsParams{1}(lparam).YLabel{2}};
    %             else
    %                 y_label=[num2str(lparam) '-' TimeSegmentsParams{1}(lparam).YLabel];
    %             end
    %
    %
    %             ylim2=get(gca,'YLim');
    %             if ylim2(1)==0,
    %                 ylim2(1)=-.05*ylim2(2);
    %                 ylim([ylim2(1) 40]);
    %             end
    %             ylim3=get(gca,'YLim');
    %             if mod(plotcounter,nrows)==0 || lparam==params2plot(end)
    %                 %                     set(gca,'XTick',x_ticks,'Xticklabel',Xticklabels,'tickdir','out')
    %                 set(gca,'XTick',[0 Interval_Separator],'Xticklabel',[],'tickdir','out')
    %                 font_style([],'Time of assay (min)',y_label,'normal',FntName,FtSz)
    %                 thandle=text(IntervalLabels_ticks,ylim3(1)*ones(1,length(Xticklabels)),Xticklabels);
    %                 set(thandle,'HorizontalAlignment','center','VerticalAlignment','top',...
    %                     'Rotation',0,'FontSize',FtSz,'FontName',FntName);
    %             else
    %                 set(gca,'XTick',[0 Interval_Separator],'Xticklabel',[],'tickdir','out')
    %
    %                 font_style([],[],y_label,'normal',FntName,FtSz)
    %             end
    %
    %
    %
    %             %                 if plotcounter==1
    %             title(['Exp ' num2str(Exp_num) num2str(Exp_letter) ', HThr=' num2str(Head_thr) 'mm, ' params.LabelsShort{lcond} ' Fig' num2str(lfig) ', ' date])
    %             %                 end
    %
    %
    %         end
    %     end
    %     %     end
    %% Save
    if saveplot==1
        savefig_withname(1,'600','png',DataSaving_dir_temp,Exp_num,Exp_letter,...
            SubFolder_name)
    end
end