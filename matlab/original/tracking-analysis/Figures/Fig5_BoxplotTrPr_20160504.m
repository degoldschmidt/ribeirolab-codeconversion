%% General initial parameters
FtSz=8;%20;
FntName='arial';
LineW=0.8;
Conditions=[5 1 3];%[2 4 1 3];%EXP 4A [6 4 5 1 3];%3D[2 1 3 4];%EXP 8B
[ColorsinPaper,orderinpaper,labelspaper]=ColorsPaper5cond_fun(Exp_num, Exp_letter,params);
condtag=['Cond' num2str(Conditions)];%%'All cond';%'cond5 1 3';%
labelspaperFig6=labelspaper(Conditions);
%% Plotting Bar plots for each condition with stacked probabilities for Y and S
% % % load('E:\Analysis Data\Experiment 0003\Variables\TimeSegmentsParams_1r_until115_0003D 07-Dec-2015.mat')
% stackedPrs=[38 36 34;39 37 35];%[Far,close,same Y;S]
% save_plot=1;
% subfolder='Time Segments';
% close all
% paperpos=[1 1 4 4];%[1 1 10 10];%
% y=0.2;%0.11 when x labels are one line, 0.18 when they are tilted labels
% x=0.3;
% heightsubplot=1-1.6*y;
% widthsubplot=1-1.2*x;
% AllConditions=unique(params.ConditionIndex);
% 
% [Etho_Tr_paper_YColors]=EthoTrColorsPaper_fun;
% 
% for lcond=Conditions
%     labelspaper{lcond==Conditions}(strfind(labelspaper{lcond==Conditions},'/'))=[];
%     figure('Position',[50 50 800 800],'Color','w','PaperUnits','centimeters',...
%         'PaperPosition',paperpos,'Name',['Fig6 Bar plot StackedTrPr ' labelspaper{lcond==Conditions} ' ' date]);%
%     set(gca,'Position',[x y widthsubplot heightsubplot])
%     X=stackedPrs;
%     for lparam=stackedPrs(:)'
%         X(stackedPrs==lparam)=nanmedian(TimeSegmentsParams{lcond==AllConditions}(lparam).Data);
%     end
%     barhandle=bar(X,'stacked');
% 
%     set(barhandle(1),'FaceColor',Etho_Tr_paper_YColors(5,:),'EdgeColor','none','LineWidth',LineW)
%     set(barhandle(2),'FaceColor',Etho_Tr_paper_YColors(3,:),'EdgeColor','none','LineWidth',LineW)
%     set(barhandle(3),'FaceColor',Etho_Tr_paper_YColors(1,:),'EdgeColor','none','LineWidth',LineW)
%     set(gca,'Xtick',[1 2],'xticklabel',{'yeast','sucrose'},'xlim',[0 3],'ylim',[0 100])
%     font_style(params.LabelsShort{lcond},[],{'Probability of','transition to (%)'},'normal',FntName,FtSz)
%     box off
%     %     legend({'far spot','adjacent spot','same spot'})
%     %     legend('boxoff')
% end
% if save_plot==1
%     savefig_withname(1,'600','png',DataSaving_dir_temp,Exp_num,Exp_letter,...
%         subfolder)
% end
%% probabilities for YEAST VISITS ONLY
save_plot=1;
subfolder='Time Segments';

close all
paperpos=[1 1 5 3];%[1 1 15 15];%
y=0.2;%0.11 when x labels are one line, 0.18 when they are tilted labels
x=0.3;
heightsubplot=1-1.6*y;
widthsubplot=1-1.1*x;

[Etho_Tr_paper_YColors]=EthoTrColorsPaper_fun;

if ~exist('Etho_Tr2','var')
    [~,Etho_Tr2]=TransitionProb2(DurInV,Heads_Sm,FlyDB,params);
end

TrPrOnlyY=cell(length(Conditions),1);%Transition Prb for each fly(rows), cols: [far, close, same]
TrOnlyY=cell(length(Conditions),1);%Nº of transitions for each fly(rows), cols: [far, close, same]
range=1:params.MinimalDuration;

ltransitions=size(params.Subs_Numbers,2)+1:length(params.Subs_Numbers):4*size(params.Subs_Numbers,2); %[same, close, far]
for lcond=Conditions
    TrPrOnlyY{lcond==Conditions}=nan(sum(params.ConditionIndex==lcond),length(ltransitions));
    TrOnlyY{lcond==Conditions}=nan(sum(params.ConditionIndex==lcond),length(ltransitions));
    lflycounter=0;
    for lfly=find(params.ConditionIndex==lcond)
        display(lfly)
        lflycounter=lflycounter+1;
        temp_tr=nan(1,length(ltransitions));
        %%% Note: type help TransitionProb2 to see number notation
        ltrcounter=0;
        for ltr=ltransitions(end:-1:1)%because the stacked bars are [far,close,same]
            ltrcounter=ltrcounter+1;
            temp_tr(ltrcounter)=sum(conv(double(Etho_Tr2(lfly,...
                range(1):range(end))==ltr),[1 -1])==1);
        end
        
        %%% Sanity check transitions: There is almost always one more
        %%% transition than the number of visits correspondent to the
        %%% last IBI when the fly leaves the last food.
        if ~isempty(DurInV{lfly})&&abs(sum(temp_tr)-sum(DurInV{lfly}(:,1)==params.Subs_Numbers(1)))>2
            error('Total number of transitions doesn''t match number of visits')
        elseif isempty(DurInV{lfly})&&(sum(temp_tr)~=0)
            error('Total number of transitions doesn''t match number of visits')
        end
        if sum(temp_tr)~=0
            TrPrOnlyY{lcond==Conditions}(lflycounter,:)=temp_tr./sum(temp_tr)*100;
            TrOnlyY{lcond==Conditions}(lflycounter,:)=temp_tr;
        end
    end
    
end
%% PieChart
figure('Position',[50 50 800 800],'Color','w','PaperUnits','centimeters',...
    'PaperPosition',[1 1 10 4],'Name',['Fig5 Pie chart OnlyYV5mm ' condtag ' ' date]);%

XTrAll=zeros(length(Conditions),3);
X=zeros(length(Conditions),3);
lcondcounter=0;
for lcond=Conditions
    lcondcounter=lcondcounter+1;
    
    
    X(lcond==Conditions,:)=nanmedian(TrPrOnlyY{lcond==Conditions});
    %%% Pooling all transitions for all flies in the same condition
%     TrCond=round(sum(TrOnlyY{lcond==Conditions})/sum(sum(TrOnlyY{lcond==Conditions}))*100);
    %%% Scaling medians to sum 100%
    TrCond=round(X(lcond==Conditions,:)/sum(X(lcond==Conditions,:))*100);
    display([params.LabelsShort{lcond} ': ' num2str(TrCond)])
    XTrAll(lcond==Conditions,:)=TrCond;
    subplot(1,3,lcondcounter)
    pie(XTrAll(lcond==Conditions,:),[1 1 1])
end
%% Plotting stacked bar plot
% figure('Position',[50 50 800 800],'Color','w','PaperUnits','centimeters',...
%     'PaperPosition',paperpos,'Name',['Fig6 Bar plot OnlyYV5mmStackedTrPr ' condtag ' ' date]);%
% set(gca,'Position',[x y widthsubplot heightsubplot])
% barhandle=bar(X,'stacked');
% set(barhandle(1),'FaceColor',Etho_Tr_paper_YColors(5,:),'EdgeColor','none','LineWidth',LineW)%Far
% set(barhandle(2),'FaceColor',Etho_Tr_paper_YColors(3,:),'EdgeColor','none','LineWidth',LineW)%Close
% set(barhandle(3),'FaceColor',Etho_Tr_paper_YColors(1,:),'EdgeColor','none','LineWidth',LineW)%Same
% set(gca,'Xtick',1:length(Conditions),'xticklabel',[],'xlim',[0 length(Conditions)+1],'ylim',[0 106])
% font_style(['Only ' params.Subs_Names{1} ' visits'],[],{'Probability of','transition type (%)'},'normal',FntName,FtSz)
% box off
% 
% if strfind([Exp_num Exp_letter],'0003D')
%     thandle=text([1 3],zeros(1,2),labelspaperFig6([1 3]));
%     set(thandle,'HorizontalAlignment','center','VerticalAlignment','top',...
%         'Rotation',0,'FontSize',FtSz,'FontName',FntName);
%     thandle=text(2,0,labelspaperFig6{2});
%     set(thandle,'HorizontalAlignment','center','VerticalAlignment','top',...
%         'Rotation',0,'FontSize',FtSz,'FontName',FntName);
%     %     legend({'to far yeast spot','to adjacent yeast spot','to same yeast spot'})
%     %     legend('boxoff')
% else
%     thandle=text(1:length(Conditions),zeros(1,length(Conditions)),labelspaperFig6);
%     set(thandle,'HorizontalAlignment','right','VerticalAlignment','top',...
%         'Rotation',20,'FontSize',FtSz,'FontName',FntName);
% end
% if save_plot==1
%     savefig_withname(1,'600','png',DataSaving_dir_temp,Exp_num,Exp_letter,...
%         subfolder)
% end
%% Plotting Box plots for probabilities for YEAST VISITS ONLY
save_plot=0;
subfolder='Transitions';

paperpos=[1 1 3.5 4];
x=0.35;
y=0.2;%0.11 when x labels are one line, 0.18 when they are tilted labels
dy=0.03;
heightsubplot=1-1.6*y;
widthsubplot=1-1.2*x;
numcond=nan(length(Conditions),1);
lcondcounter=0;
for lcond=Conditions
    lcondcounter=lcondcounter+1;
    numcond(lcondcounter)=sum(params.ConditionIndex==lcond);
end

close all
TrPrLabels{1}={'Tr Pr (%)';['To far ' params.Subs_Names{1}(1)]};
TrPrLabels{2}={'Tr Pr (%)';['To adj ' params.Subs_Names{1}(1)]};
TrPrLabels{3}={'Tr Pr (%)';['To same ' params.Subs_Names{1}(1)]};

for ltrpr=1:3 %[far,close,same]
    X=nan(max(numcond),length(Conditions));
    newcolors=nan(length(Conditions),3);
    MergedConditions=nan(length(Conditions),1);
    lcondcounter=0;
    for lcond=Conditions
        lcondcounter=lcondcounter+1;
        X(1:numcond(lcondcounter),lcondcounter)=(TrPrOnlyY{lcond==Conditions}(:,ltrpr));
        newcolors(lcondcounter,:)=ColorsinPaper(orderinpaper==lcond,:);
        MergedConditions(lcondcounter)=find(orderinpaper==lcond);
    end
    
    figure('Position',[50 50 800 800],'Color','w','PaperUnits','centimeters',...
        'PaperPosition',paperpos,'Name',['Fig5 Boxplot 5mmOnlyYV ' condtag ' ' TrPrLabels{ltrpr}{2} ' ' date]);%
    set(gca,'Position',[x y widthsubplot heightsubplot])
    
    mediancolor=zeros(length(Conditions),3);
    IQRcolor=newcolors;
    [~,lineh] = plot_boxplot_tiltedlabels(X,cell(size(X,2),1),1:size(X,2),...
        IQRcolor,mediancolor,[.4 .4 .4],.4,FtSz,FntName,'o',1);%'k'
    font_style([],[],TrPrLabels{ltrpr},'normal',FntName,FtSz)
    
    stats_boxplot_tiltedlabels_Fig5(X,...
        TrPrLabels{ltrpr}(2),MergedConditions,1:size(X,2),...
        ['Fig5 Boxplot OnlyYV ' condtag ' ' TrPrLabels{ltrpr}{2} ' '],0,params,...
        DataSaving_dir_temp,Exp_num,Exp_letter,condtag,subfolder,FtSz,FntName,labelspaper);
    
    ylim([0 100])%ylim([0 1.8*max(prctile(X,75))])
    xlim([0.5 (length(MergedConditions)+.5)])
    set(gca,'xcolor','w')
    set(gca,'Ytick',0:20:100)
    
end

if save_plot==1
    savefig_withname(1,'600','png',DataSaving_dir_temp,Exp_num,Exp_letter,...
        subfolder)
    savefig_withname(0,'600','eps',DataSaving_dir_temp,Exp_num,Exp_letter,...
        'Figures')
end
%% Plotting Stacked probabilities for YEAST ENCOUNTERS ONLY
% save_plot=1;
% subfolder='Time Segments';
% 
% 
% close all
% paperpos=[1 1 5 3];%[1 1 15 15];%
% y=0.2;%0.11 when x labels are one line, 0.18 when they are tilted labels
% x=0.3;
% heightsubplot=1-1.6*y;
% widthsubplot=1-1.1*x;
% AllConditions=unique(params.ConditionIndex);
% 
% [Etho_Tr_paper_YColors,Etho_Tr_paper_SColors]=EthoTrColorsPaper_fun;
% 
% 
% 
% lHThr=3;%mm
% correctedbouts=1;%Correct short returns in less than 4mm radius
% Adj_Thr=16;%mm
% % [~,Etho_Tr2B,~,~,~,DurInBouts]=TransitionProb_Bouts(Heads_Sm,Walking_vec,InSpot,FlyDB,params);
% % save([Variablesfolder 'DurInBouts_EthoTr2B_' Exp_num Exp_letter ' ' date '.mat'],...
% % 'Etho_Tr2B','DurInBouts','lHThr','correctedbouts','Adj_Thr','params','-v7.3')
% % display('Bouts saved')
% load([Variablesfolder 'DurInBouts_EthoTr2B_' Exp_num Exp_letter ' ' date '.mat'],'Etho_Tr2B','DurInBouts')
% 
% TrPrOnlyYB=cell(length(Conditions),1);%[far, close, same]
% range=1:params.MinimalDuration;
% 
% ltransitions=size(params.Subs_Numbers,2)+1:length(params.Subs_Numbers):4*size(params.Subs_Numbers,2);%[same, close, far]
% for lcond=Conditions
%     TrPrOnlyYB{lcond==Conditions}=nan(sum(params.ConditionIndex==lcond),length(ltransitions));
%     lflycounter=0;
%     for lfly=find(params.ConditionIndex==lcond)
%         display(lfly)
%         lflycounter=lflycounter+1;
%         temp_tr=nan(1,length(ltransitions));
%         %%% Note: type help TransitionProb2 to see number notation
%         ltrcounter=0;
%         for ltr=ltransitions(end:-1:1)%because the stacked bars are [far,close,same]
%             ltrcounter=ltrcounter+1;
%             temp_tr(ltrcounter)=sum(conv(double(Etho_Tr2B(lfly,...
%                 range(1):range(end))==ltr),[1 -1])==1);
%         end
%         
%         %%% Sanity check transitions: There is almost always one more
%         %%% transition than the number of visits correspondent to the
%         %%% last IBI when the fly leaves the last food.
%         if ~isempty(DurInBouts{lfly})&&abs(sum(temp_tr)-sum(DurInBouts{lfly}(:,1)==params.Subs_Numbers(1)))>2
%             error('Total number of transitions doesn''t match number of visits')
%         elseif isempty(DurInBouts{lfly})&&(sum(temp_tr)~=0)
%             error('Total number of transitions doesn''t match number of visits')
%         end
%         if sum(temp_tr)~=0
%             TrPrOnlyYB{lcond==Conditions}(lflycounter,:)=temp_tr./sum(temp_tr)*100;
%         end
%     end
% end
% X=zeros(length(Conditions),3);
% for lcond=Conditions
%     X(lcond==Conditions,:)=nanmedian(TrPrOnlyYB{lcond==Conditions});
% end
% %%% Stacked bar plot
% figure('Position',[50 50 800 800],'Color','w','PaperUnits','centimeters',...
%     'PaperPosition',paperpos,'Name',['Fig6 Bar plot OnlyYBoutsStackedTrPr ' condtag ' ' date]);%
% set(gca,'Position',[x y widthsubplot heightsubplot])
% 
% barhandle=bar(X,'stacked');
% set(barhandle(1),'FaceColor',Etho_Tr_paper_YColors(5,:),'EdgeColor','none','LineWidth',LineW)%Far
% set(barhandle(2),'FaceColor',Etho_Tr_paper_YColors(3,:),'EdgeColor','none','LineWidth',LineW)%Close
% set(barhandle(3),'FaceColor',Etho_Tr_paper_YColors(1,:),'EdgeColor','none','LineWidth',LineW)%Same
% set(gca,'Xtick',1:length(Conditions),'xticklabel',[],'xlim',[0 length(Conditions)+1],'ylim',[0 100])
% font_style(['Only ' params.Subs_Names{1} ' encounters'],[],{'Probability of','transition type (%)'},'normal',FntName,FtSz)
% box off
% if strfind([Exp_num Exp_letter],'0003D')
%     thandle=text([1 3],zeros(1,2),labelspaperFig6([1 3]));
%     set(thandle,'HorizontalAlignment','center','VerticalAlignment','top',...
%         'Rotation',0,'FontSize',FtSz,'FontName',FntName);
%     thandle=text(2,0,labelspaperFig6{2});
%     set(thandle,'HorizontalAlignment','center','VerticalAlignment','top',...
%         'Rotation',0,'FontSize',FtSz,'FontName',FntName);
%     %     legend({'to far yeast spot','to adjacent yeast spot','to same yeast spot'})
%     %     legend('boxoff')
% else
%     thandle=text(1:length(Conditions),zeros(1,length(Conditions)),labelspaperFig6);
%     set(thandle,'HorizontalAlignment','right','VerticalAlignment','top',...
%         'Rotation',20,'FontSize',FtSz,'FontName',FntName);
% end
% 
% if save_plot==1
%     savefig_withname(1,'600','png',DataSaving_dir_temp,Exp_num,Exp_letter,...
%         subfolder)
% end
%% Plotting Box plots for probabilities for YEAST ENCOUNTERS ONLY
% save_plot=1;
% subfolder='Time Segments';
% 
% paperpos=[1 1 4 3];
% x=0.35;
% y=0.2;%0.11 when x labels are one line, 0.18 when they are tilted labels
% dy=0.03;
% heightsubplot=1-1.6*y;
% widthsubplot=1-1.2*x;
% numcond=nan(length(Conditions),1);
% lcondcounter=0;
% for lcond=Conditions
%     lcondcounter=lcondcounter+1;
%     numcond(lcondcounter)=sum(params.ConditionIndex==lcond);
% end
% 
% close all
% TrPrLabels{1}={'Tr Pr (%)';['To far ' params.Subs_Names{1}(1)]};
% TrPrLabels{2}={'Tr Pr (%)';['To adj ' params.Subs_Names{1}(1)]};
% TrPrLabels{3}={'Tr Pr (%)';['To same ' params.Subs_Names{1}(1)]};
% 
% for ltrpr=1:3 %[far,close,same]
%     X=nan(max(numcond),length(Conditions));
%     newcolors=nan(length(Conditions),3);
%     MergedConditions=nan(length(Conditions),1);
%     lcondcounter=0;
%     for lcond=Conditions
%         lcondcounter=lcondcounter+1;
%         X(1:numcond(lcondcounter),lcondcounter)=(TrPrOnlyYB{lcond==Conditions}(:,ltrpr));
%         newcolors(lcondcounter,:)=ColorsinPaper(orderinpaper==lcond,:);
%         MergedConditions(lcondcounter)=find(orderinpaper==lcond);
%     end
%     
%     figure('Position',[50 50 800 800],'Color','w','PaperUnits','centimeters',...
%         'PaperPosition',paperpos,'Name',['Fig6 Boxplot OnlyYBouts ' condtag ' ' TrPrLabels{ltrpr}{2} ' ' date]);%
%     set(gca,'Position',[x y widthsubplot heightsubplot])
%     
%     mediancolor=zeros(length(Conditions),3);
%     IQRcolor=newcolors;
%     [~,lineh] = plot_boxplot_tiltedlabels(X,cell(size(X,2),1),1:size(X,2),...
%         IQRcolor,mediancolor,[.4 .4 .4],.4,FtSz,FntName,'o',1);%'k'
%     font_style([],[],TrPrLabels{ltrpr},'normal',FntName,FtSz)
%     
%     stats_boxplot_tiltedlabels_Fig2B(X,...
%         TrPrLabels{ltrpr}(2),MergedConditions,1:size(X,2),...
%         ['Fig6 Boxplot OnlyYBouts ' condtag ' ' TrPrLabels{ltrpr}{2} ' '],0,params,...
%         DataSaving_dir_temp,Exp_num,Exp_letter,condtag,subfolder,FtSz,FntName,labelspaper);
%     
%     ylim([0 140])%ylim([0 1.8*max(prctile(X,75))])
%     xlim([0.5 (length(MergedConditions)+.5)])
%     set(gca,'xcolor','w')
%     
%     
% end
% 
if save_plot==1
    savefig_withname(1,'600','png',DataSaving_dir_temp,Exp_num,Exp_letter,...
        subfolder)
    savefig_withname(0,'600','eps',DataSaving_dir_temp,Exp_num,Exp_letter,...
        'Figures')
end
