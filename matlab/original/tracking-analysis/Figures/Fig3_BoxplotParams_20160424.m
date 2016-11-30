%% Fig 4 Plotting Box plots comparing different parameters

%% General initial parameters
param2plot=[59];%[1 4 54:56 74];% Locomotor ACtivity%[48 96 88 9]+1;%Fig3% 46;%[48 9 88];%Fig8[30 58 59];%;%[30 60 58 59];%Fig 4 59;%[2 74];%   25;%Fig5G 70:72;%Fig 5  
save_plot=1;
subfolder='Parameters';%'Transitions';% 
Figlabel='Thesis';%'Fig3';%'Fig8S1D';%'Fig4S2';%'Fig3S1';%'Fig5';%
FtSz=10;%8;%20;
FntName='arial';
LineW=0.8;
[ColorsinPaper,orderinpaper]=ColorsPaper5cond_fun(Exp_num, Exp_letter,params);

Conditions=[2 3 1 5 6 4];% EXP 12A%[2 4 1 3];%EXP 4A[6 4 5 1 3];%Exp3D [2 4 6 8];%EXP 11AFig8S1D [4 3 8 7];%EXP 11AFig8S1AC  [2 1 3 4];%EXP 8B[1 3];%  
condtag=['cond' num2str(Conditions)];%'All cond';%'cond1 3';%
%% Plotting Box plots comparing different conditions for a given parameter
% load('E:\Analysis Data\Experiment 0003\Variables\TimeSegmentsParams_H0_1r_until115_0003D 28-Jan-2016.mat')

close all
if strfind(Figlabel,'Fig4S2')%'Fig3S1')
    markersz=2;
    x=0.1;
    y=0.1;
    dy=0.03;
    heightsubplot=1-2*y;
    widthsubplot=1-1.4*x;
    paperpos=[1 1 3 4];%%'Fig4S2'[1 1 4 4];%%'Fig3S1'
elseif strfind(Figlabel,'Thesis')
    x=0.2;%0.27;
    paperpos=[1 1 4.5 3.5];%[1 1 3 3];%[1 1 5.5 4.5];%
    markersz=1;
else
    if length(Conditions)<=3
        x=0.47;%Fig4 0.35;%Fig5  0.18 when ylabels are three lines, 0.13 for single line ylabels
        paperpos=[1 1 3 4];%Fig4 [1 1 3.5 4];%Fig 5
    else
        x=.45;
        paperpos=[1 1 5 4];%Fig3 [1 1 5 4.5];%Fig8S1[1 1 6.5 4.5];%Fig3S1  [1 1 4 4];%
    end
    y=0.2;%0.11 when x labels are one line, 0.18 when they are tilted labels
    dy=0.03;
    heightsubplot=1-1.6*y;
    widthsubplot=1-1.1*x;% 1-1.2*x;%Fig5

    markersz=1;
end

AllConditions=unique(params.ConditionIndex);
numcond=nan(length(Conditions),1);
[CondColors,Cmap_patch]=Colors(length(unique(params.ConditionIndex)));%
newcolors=nan(length(Conditions),3);
for lcond=Conditions
    numcond(lcond==Conditions)=sum(params.ConditionIndex==lcond);
    if length(Conditions)<=size(ColorsinPaper,1)%strfind([Exp_num Exp_letter],'0003D')
        newcolors(lcond==Conditions,:)=ColorsinPaper(orderinpaper==lcond,:);%ColorsFig2C(orderinpaper==lcond,:);
    else
        newcolors(lcond==Conditions,:)=CondColors(ismember(AllConditions,lcond),:);
    end
end

   

for lparam=param2plot
    [y_label,y_labelname]=LabelsParamsPaper(TimeSegmentsParams,lparam);
    y_label2=['param ' num2str(lparam)];
    extralabel=' 115 min ';%' no stats ';%
    figname=[Figlabel 'Boxplot ' condtag ' param ' num2str(lparam) extralabel];
    figure('Position',[50 50 800 800],'Color','w','PaperUnits','centimeters',...
        'PaperPosition',paperpos,'Name',[figname date]);%'10minafterLagphase '
    set(gca,'Position',[x y widthsubplot heightsubplot])
        
    X=nan(max(numcond),length(Conditions));
    lcondcounter=0;
    
% % %     MergedConditions=nan(length(Conditions),1);
    for lcond=Conditions
        lcondcounter=lcondcounter+1;
        if lparam~=59&&lparam~=55%Angular speed on visits
            X(1:numcond(lcondcounter),lcondcounter)=TimeSegmentsParams{lcond==AllConditions}(lparam).Data(1,:)';
        else
            %Transform Angular speed into º/s
            X(1:numcond(lcondcounter),lcondcounter)=TimeSegmentsParams{lcond==AllConditions}(lparam).Data(1,:)'*params.framerate;
        end
        
%         X(1:sum(fliesidx{Conditions==lcond}),lcondcounter)=...
%             TimeSegmentsParams{lcond==AllConditions}(lparam).Data(1,fliesidx{Conditions==lcond})';
%         MergedConditions(lcondcounter)=find(orderinpaper==lcond);
    end
    
    mediancolor=zeros(length(Conditions),3);
    IQRcolor=newcolors;
    [~,lineh] = plot_boxplot_tiltedlabels(X,cell(size(X,2),1),1:size(X,2),...
        IQRcolor,mediancolor,[.4 .4 .4],.4,FtSz,FntName,'o',markersz);%'k'
    font_style([],[],y_label,'normal',FntName,FtSz)
% % %     if length(Conditions)==2, MergedConditions=1:length(Conditions);end
% % %     stats_boxplot_tiltedlabels_Fig2B(X,...
% % %         {['param ' num2str(lparam)]},MergedConditions,1:size(X,2),...
% % %         ['Fig4ABoxplot ' condtag ' param ' num2str(lparam) ' '],0,params,...
% % %         DataSaving_dir_temp,Exp_num,Exp_letter,'All cond','Time Segments',FtSz,FntName,LabelsShortPaper);
    if ~isempty(strfind(Figlabel,'Fig5'))||~isempty(strfind(Figlabel,'Fig4S2'))
        stats_boxplot_tiltedlabels_Fig5(X,...
        {['param ' num2str(lparam)]},Conditions,1:size(X,2),...TrPrLabels{ltrpr}(2)
        figname,0,params,...
        DataSaving_dir_temp,Exp_num,Exp_letter,condtag,subfolder,FtSz,FntName,params.LabelsShort);
    else
    stats_boxplot_tiltedlabels(X,...
        {['param ' num2str(lparam)]},Conditions,1:size(X,2),...
        figname,0,params,...'10minafterLagphase '
        DataSaving_dir_temp,Exp_num,Exp_letter,condtag,subfolder,FtSz,FntName);
    end
    ylim([0 1.8*max(prctile(X,75))])
    if strfind(y_labelname,'YPI'), ylim([-1 max(1.8*max(prctile(X,75)),1)]),
        plot([0.5 (length(Conditions)+.5)],[0 0],'--','LineWidth',0.8,'Color',[0.5 .5 .5])
    elseif lparam==2, ylim([0 12]),
    elseif lparam==9, ylim([0 2]),
    elseif lparam==25, ylim([0 80]),
    elseif lparam==30, ylim([0.5 2.5]),
    elseif lparam==48, ylim([0 40]);set(gca,'YTick',0:10:40),
    elseif lparam==58, ylim([0 0.5]),
    elseif lparam==59, ylim([0 30]),%15
    elseif lparam==60, ylim([0 150]),
    elseif lparam==70, ylim([0 40])
    elseif lparam==75, ylim([0 500]),
    elseif lparam==89, ylim([0 1]),
    elseif lparam==97, ylim([0 15]),
    end
    xlim([0.5 (length(Conditions)+.5)])
    set(gca,'xcolor','w')
end

%% Figure with Labels of parameters
% figname=[Figlabel 'Boxplot ' condtag ' param labels ' extralabel date];
% figure('Position',[2100 50 500 500],'Color','w','Name',figname,'PaperUnits',...
%     'centimeters','PaperPosition',[0 0 10 10])
% hold on
% lparamcounter=0;
% for lparam=param2plot
%     lparamcounter=lparamcounter+1;
%     [y_label,y_labelname]=LabelsParamsPaper(TimeSegmentsParams,lparam);
%     
%     plot([1 2],[lparamcounter lparamcounter],'-','LineWidth',2,'Color','k')
%     text(3,lparamcounter,[['Param ' num2str(lparam) ': ']; y_label],'FontName',FntName,'FontSize',FtSz)
%     
% end 
% axis([0 10 0 lparamcounter+1])
%     font_style({'Condition labels time segment parameters';['Exp ' num2str(Exp_num) num2str(Exp_letter) ', ' date]},[],[],'normal',FntName,FtSz)
%     axis off
%%%
if save_plot==1
    savefig_withname(1,'600','png',DataSaving_dir_temp,Exp_num,Exp_letter,...
        subfolder)
    savefig_withname(0,'600','eps',DataSaving_dir_temp,Exp_num,Exp_letter,...
        'Thesis')%'Figures'
end

%% Fraction of non-eaters
% NonEaterThr=60;%s
% save_plot=1;
% close all
% x=0.1;%0.18 when ylabels are three lines, 0.13 for single line ylabels
% y=0.1;%0.11 when x labels are one line, 0.18 when they are tilted labels
% dy=0.03;
% heightsubplot=1-2*y;
% widthsubplot=1-1.4*x;
% lsubs=1;
% figure('Position',[50 50 800 800],'Color','w','PaperUnits','centimeters',...
%         'PaperPosition',[1 1 4 4],'Name',['FigS4Boxplot ' condtag ' Fraction non-eaters ' date]);%
%     set(gca,'Position',[x y widthsubplot heightsubplot])
%   
%     hold on
%     lcondcounter=0;
%     for lcond=Conditions
%         lcondcounter=lcondcounter+1;
%         numerator=sum((sum(CumTimeV{lsubs}(:,params.ConditionIndex==lcond))/50)<NonEaterThr);
%         Fraction_NonEaters=numerator/...
%             sum(params.ConditionIndex==lcond);
%         display([params.LabelsShort{lcond} '-noneaters: ' num2str(numerator),...
%             '; -totaln: ' num2str( sum(params.ConditionIndex==lcond))])
%         barhandle=bar(lcondcounter,Fraction_NonEaters);
%         set(barhandle,'FaceColor',newcolors(lcondcounter,:),...
%             'LineWidth', 1,'EdgeColor',newcolors(lcondcounter,:));
%     end  
%     xlim([0.25 (length(Conditions)+.5)])
%     set(gca,'xcolor','w')
%     stats_boxplot_tiltedlabels(X,...
%         {['param ' num2str(lparam)]},Conditions,1:size(X,2),...
%         [Figlabel 'Boxplot ' condtag ' param ' num2str(lparam) extralabel],0,params,...'10minafterLagphase '
%         DataSaving_dir_temp,Exp_num,Exp_letter,condtag,subfolder,FtSz,FntName);
% font_style([],[],{'Fraction of';'non-eaters'},'normal',FntName,FtSz)
% % legend(Labelsmergedshort)
% % legend('boxoff')
% if save_plot==1
%         savefig_withname(1,'600','png',DataSaving_dir_temp,Exp_num,Exp_letter,...
%             'Total times')
%         savefig_withname(0,'600','eps',DataSaving_dir_temp,Exp_num,Exp_letter,...
%             'Figures')
% end

