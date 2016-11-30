%% Calculating the ranges of yeast for each fly
% NonEaterThr=60;%s
% ranges_str='selfYquartilesHmmLag';%'selfYquintiles';%'lagphase+113r_until115_5w_1st';%
% startinglag=1;
% windowsize=5;%min
% windowstep=1;%min
% ranges_temp=0;
% AllConditions=unique(params.ConditionIndex);
% 
% % % % if slidingwindow==1
% % % %     lastframe=params.MinimalDuration;
% % % %     ranges_temp=[(1:windowstep*50*60:lastframe-windowsize*60*50);...
% % % %         (1:windowstep*50*60:lastframe-windowsize*60*50)+windowsize*60*50]';
% % % % else
% % % % %     ranges_temp=[1 15000;15001 30000;30001 90000;90001 180000;180001 360000];
% % % %     ranges_temp=[1 30000;30001 90000;90001 180000;180001 360000];
% % % % end
% Perc_selfY=[25 50 75 100];%[20 40 60 80 100];%
% ranges_fly=cell(params.numflies,1);
% if strfind(ranges_str,'Hmm')
%     vartoanalyse=CumTimeH;
% else
%     vartoanalyse=CumTimeV;
% end
% trouble=zeros(length(params.IndexAnalyse),1);
% for lfly=params.IndexAnalyse
%     lfly
%     for lquartile=1:length(Perc_selfY)
%         
%         CumVfly=find(cumsum(CumTimeV{1}(:,lfly))/50>=NonEaterThr,1,'first');%min
%         if CumVfly>1
%             
%             if startinglag==1 && ~isnan(latency_root(lfly))
%                 vartoanalyse{1}(1:latency_root(lfly)-1,lfly)=0;
%             end
%             if lquartile==1
%                 %%% Starting percentiles from latency point
%                 rangestart=latency_root(lfly);
%                 if isnan(rangestart)||startinglag==0
%                     %%% Starting percentiles from first Y micromov./visit
%                     rangestart=find((cumsum(vartoanalyse{1}(:,lfly))/...
%                     sum(vartoanalyse{1}(:,lfly)))>0,1,'first');%min
%                 end
%             else
%                 
%                 
%                 rangestart=find((cumsum(vartoanalyse{1}(:,lfly))/...
%                     sum(vartoanalyse{1}(:,lfly)))>=Perc_selfY(lquartile-1)/100,1,'first');%min
%                 if rangestart<=ranges_fly{lfly}(lquartile-1,2),
%                     rangestart=ranges_fly{lfly}(lquartile-1,2);
%                 end
%             end
%             
%             
%             
%             rangeend=find((cumsum(vartoanalyse{1}(:,lfly))/...
%                     sum(vartoanalyse{1}(:,lfly)))>=Perc_selfY(lquartile)/100,1,'first');%min
%             if rangeend<rangestart
%                 display(['Latency > 1st Y% in fly:' num2str(lfly) ', ' params.LabelsShort{params.ConditionIndex(lfly)}])
%                 display(ranges_fly{lfly})
%                 display(['range start: ' num2str(rangestart)])
%                 display(['range end: ' num2str(rangeend)])
%                 rangeend=rangestart+1;
%                 trouble(lfly)=1;
%             end
%             ranges_fly{lfly}(lquartile,:)=[rangestart rangeend];
%              
%         else
%             %%% Representative values, just to avoid errors in the Time
%             %%% segments algorithms. These flies (the non-eaters) should be
%             %%% removed from the results of this particular calculation
%             %%% ALWAYS SET noneaters = 1 in Plot_TimeSegments_Allflies.m
%             %%% when running this script
%             ranges_fly{lfly}=[(1:length(Perc_selfY))*2-1;...
%                 (1:length(Perc_selfY))*2]';
%         end 
%     end
%     
% end
% 
% for lfly=find(trouble)'
%     display(['Fly ' num2str(lfly) ', ' params.LabelsShort{params.ConditionIndex(lfly)}])
%     display(ranges_fly{lfly})
% end
% 
% save([Variablesfolder ranges_str num2str(Perc_selfY),...
%     '_' Exp_num Exp_letter ' ' date '.mat'],...
%             'ranges_fly','Perc_selfY','trouble','-v7.3')
% display('Y self percentiles saved')
%% If calculating the values:
% ranges=[[0 Perc_selfY(1:end-1)+1]' Perc_selfY']*50*60;
% Plot_TimeSegments_Allflies %Make sure that initial parameters are:
% % % NonEaterThr=60;%s
% % % HEAD_YN=0;
% % % eachflyrange=1;% 0;% To use fixed ranges for all flies
% % % slidingwindow=0;
% % % windowsize=5;%min
% % % windowstep=1;%min
% % % removenoneaters=1;%1-Remove non eaters

%% If already calculated
% % load('E:\Analysis Data\Experiment 0003\Variables\TimeSegmentsParamsfly_selfYquartiles_0003D 06-Jan-2016')
% % load('E:\Analysis Data\Experiment 0003\Variables\TimeSegmentsParamsfly_selfYquartilesHmm_0003D 03-Apr-2016.mat')
% param2plot=[9 30 59 70 71 72 23 25];
% Conditions=3;%Only one condition!!!
% lcond=Conditions;
% condtag=['cond' num2str(lcond)];%
% save_plot=0;
% 
% 
% FtSz=8;%20;
% FntName='arial';
% LineW=0.8;
% [ColorsFig2C,orderinpaper]=ColorsPaper5cond_fun;
% 
% close all
% x=.35;
% paperpos=[1 1 4 4];%[1 1 5 4];
% 
% y=0.2;%0.11 when x labels are one line, 0.18 when they are tilted labels
% dy=0.03;
% heightsubplot=1-1.6*y;
% widthsubplot=1-1.12*x;
% 
% singleflycolor=[.8 .8 .8];
% AllConditions=unique(params.ConditionIndex);
% numcond=nan(length(Conditions),1);
% [CondColors,Cmap_patch]=Colors(length(unique(params.ConditionIndex)));%
% newcolors=nan(length(Conditions),3);
% for lcond=Conditions
%     numcond(lcond==Conditions)=sum(params.ConditionIndex==lcond);
%     if length(Conditions)<=size(ColorsFig2C,1)%strfind([Exp_num Exp_letter],'0003D')
%         newcolors(lcond==Conditions,:)=ColorsFig2C(orderinpaper==lcond,:);%ColorsFig2C(orderinpaper==lcond,:);
%     else
%         newcolors(lcond==Conditions,:)=CondColors(ismember(AllConditions,lcond),:);
%     end
% 
% end
% 
%    
% 
% for lparam=param2plot
%     if iscell(TimeSegmentsParams{1}(lparam).YLabel)
%         y_label=TimeSegmentsParams{1}(lparam).YLabel;
%         y_labelname=y_label{1};
%     else
%         y_label=TimeSegmentsParams{1}(lparam).YLabel;
%         y_labelname=y_label;
%     end
%     
%     figure('Position',[50 50 800 800],'Color','w','PaperUnits','centimeters',...
%         'PaperPosition',paperpos,'Name',['Fig6CBoxplots ' condtag ' param ' num2str(lparam) ' ' ranges_str ' ' date]);%'10minafterLagphase '
%     set(gca,'Position',[x y widthsubplot heightsubplot])
%     hold on
%     X=TimeSegmentsParams{lcond==AllConditions}(lparam).Data;
%     
%     %% Single fly traces
% 	plot(Perc_selfY,X,'o-','MarkerSize',2,...
%         'Color',singleflycolor,'MarkerFAceColor',singleflycolor,'LineWidth',LineW);% 
%     %% Median and IQR
%     h=plot(Perc_selfY,nanmedian(X,2),'o-',...
%         'Color',newcolors,'MarkerFAceColor',newcolors,'LineWidth',2*LineW);
%     
%     line(repmat(Perc_selfY,2,1),[prctile(X,25,2)';...
%         prctile(X,75,2)'],'LineWidth',LineW,...
%         'Color',newcolors)
%     set(gca,'XTick',Perc_selfY,'XTickLabel',cellfun(@(x)num2str(x),num2cell(Perc_selfY),'uniformoutput',0))
%     font_style([],'Yeast quartiles',y_label,'normal',FntName,FtSz)
%     box off
%     if sum(TimeSegmentsParams{1}(lparam).YAxes==0)~=2
%         ylim(TimeSegmentsParams{1}(lparam).YAxes)
%     end
% %     if lparam==9
% %         ylim([0 10])
% %     elseif lparam==25
% %         ylim([0 70])
% %     end
%     xlim([Perc_selfY(1)-5 Perc_selfY(end)+5])
%     ylim1=get(gca,'Ylim');
%     %% Stats
%     l1=1;%2;%1
%     for l2=size(Perc_selfY,2)%2:size(Perc_selfY,2)
%         p=ranksum(X(l1,:),X(l2,:));%*(size(Perc_selfY,2)-1);
%         yposstats=(0.5+0.1*l2)*ylim1(2);
%         plotstatsFig7(p,Perc_selfY,l1,l2,yposstats,FtSz,FntName)
%     end
% end
% if save_plot==1
%     savefig_withname(1,'600','png',DataSaving_dir_temp,Exp_num,Exp_letter,...
%         'Parameters')
%     savefig_withname(0,'600','eps',DataSaving_dir_temp,Exp_num,Exp_letter,...
%         'Figures')
% end
%% Comparing values of parameters in Q4 with values of Hunt and FF flies
% load('E:\Analysis Data\Experiment 0003\Variables\selfYquartilesHmmLag25   50   75  100_0003D 06-May-2016.mat')
% load('E:\Analysis Data\Experiment 0003\Variables\TimeSegmentsParamsfly_selfYquartilesHmmLag_0003D 06-May-2016.mat')
% TimeSegmentsParams_YQ=TimeSegmentsParams;
% load('E:\Analysis Data\Experiment 0003\Variables\TimeSegmentsParams_5mmH0_1r_until115_0003D 29-Apr-2016.mat')

subfolder='Parameters';
param2plot=[30 59 9];%[9 30 59 70 71 72 23 25];
CondYQ=3;%Only one condition!!!
Qstart=1;%Number of quartile to compare.
Qend=4;%Number of quartile to compare.
Conditions=[CondYQ CondYQ 1 5];
condtag=['YQcond' num2str(CondYQ) ' vs conds ' num2str(Conditions(3:end))];%
save_plot=1;

FtSz=8;%20;
FntName='arial';
LineW=0.8;
[ColorsinPaper,orderinpaper]=ColorsPaper5cond_fun;
close all
if length(Conditions)<=3
    x=0.53;%Fig4 0.35;%Fig5  0.18 when ylabels are three lines, 0.13 for single line ylabels
    paperpos=[1 1 4 5];%Fig4 [1 1 3.5 4];%Fig 5
else
    x=.4;
    paperpos=[1 1 4 5];%[1 1 5 4];
end
y=0.3;%0.11 when x labels are one line, 0.18 when they are tilted labels
dy=0.03;
heightsubplot=1-1.6*y;
widthsubplot=1-1*x;% 1-1.2*x;%Fig5

AllConditions=unique(params.ConditionIndex);
numcond=nan(length(Conditions),1);
newcolors=nan(length(Conditions),3);
lcondcounter=0;
for lcond=Conditions
    lcondcounter=lcondcounter+1;
    numcond(lcondcounter)=sum(params.ConditionIndex==lcond);
    if length(Conditions)<=size(ColorsinPaper,1)%strfind([Exp_num Exp_letter],'0003D')
        newcolors(lcondcounter,:)=ColorsinPaper(orderinpaper==lcond,:);%ColorsFig2C(orderinpaper==lcond,:);
    else
        newcolors(lcondcounter,:)=CondColors(ismember(AllConditions,lcond),:);
    end
end

  

for lparam=param2plot
    [y_label,y_labelname]=LabelsParamsPaper(TimeSegmentsParams,lparam);
    y_label2=['param ' num2str(lparam)];
    extralabel=' ';%' no stats ';%
    figure('Position',[50 50 800 800],'Color','w','PaperUnits','centimeters',...
        'PaperPosition',paperpos,'Name',['Fig6S1Boxplot ' condtag ' param ' num2str(lparam) extralabel date]);%'10minafterLagphase '
    set(gca,'Position',[x y widthsubplot heightsubplot])
        
    X=nan(max(numcond),length(Conditions));
    lcondcounter=0;
    
    for lcond=Conditions
        lcondcounter=lcondcounter+1;
        if lcondcounter==1
            if lparam~=59%Angular speed on visits
                X(1:numcond(lcondcounter),lcondcounter)=TimeSegmentsParams_YQ{lcond==AllConditions}(lparam).Data(Qstart,:)';
            else
                %Transform Angular speed into º/s
                X(1:numcond(lcondcounter),lcondcounter)=TimeSegmentsParams_YQ{lcond==AllConditions}(lparam).Data(Qstart,:)'*params.framerate;
            end
        elseif lcondcounter==2
            if lparam~=59%Angular speed on visits
                X(1:numcond(lcondcounter),lcondcounter)=TimeSegmentsParams_YQ{lcond==AllConditions}(lparam).Data(Qend,:)';
            else
                %Transform Angular speed into º/s
                X(1:numcond(lcondcounter),lcondcounter)=TimeSegmentsParams_YQ{lcond==AllConditions}(lparam).Data(Qend,:)'*params.framerate;
            end    
        else
            if lparam~=59%Angular speed on visits
                X(1:numcond(lcondcounter),lcondcounter)=TimeSegmentsParams{lcond==AllConditions}(lparam).Data(1,:)';
            else
                %Transform Angular speed into º/s
                X(1:numcond(lcondcounter),lcondcounter)=TimeSegmentsParams{lcond==AllConditions}(lparam).Data(1,:)'*params.framerate;
            end
        end
    end
    labels=params.LabelsShort(Conditions);
    labels{1}=['YQ' num2str(Qstart) ' ' labels{1}];
    labels{2}=['YQ' num2str(Qend) ' ' labels{2}];
    mediancolor=zeros(length(Conditions),3);
    IQRcolor=newcolors;
    [~,lineh] = plot_boxplot_tiltedlabels(X,labels,1:size(X,2),...
        IQRcolor,mediancolor,[.4 .4 .4],.4,FtSz,FntName,'o',1.5);%'k'
    font_style([],[],y_label,'normal',FntName,FtSz)
    stats_boxplot_tiltedlabels_FigS6(X,...
        {['param ' num2str(lparam)]},Conditions,1:size(X,2),...
        ['Boxplot ' condtag ' param ' num2str(lparam) extralabel],0,params,...'10minafterLagphase '
        DataSaving_dir_temp,Exp_num,Exp_letter,condtag,subfolder,FtSz,FntName);
    
    ylim([0 1.8*max(prctile(X,75))])
    if lparam==9, ylim([0 10]),
    elseif lparam==30, ylim([0 2.5]),
    elseif lparam==59, ylim([0 20]),
    end
    
    
    xlim([0.5 (length(Conditions)+.5)])
    set(gca,'xcolor','w')
end
if save_plot==1
    savefig_withname(1,'600','png',DataSaving_dir_temp,Exp_num,Exp_letter,...
        subfolder)
    savefig_withname(0,'600','eps',DataSaving_dir_temp,Exp_num,Exp_letter,...
        'Figures')
end