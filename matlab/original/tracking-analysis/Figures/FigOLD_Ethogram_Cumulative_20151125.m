%% Initial parameters
Conditions=unique(params.ConditionIndex);
lsubs=1; %Order ethograms according to Yeast = Substrate 1
save_plot=1;
FtSz=8;%20;
FntName='arial';
LineW=0.8;

x=0.1;%0.18 when ylabels are three lines, 0.13 for single line ylabels
y=0.15;%0.11 when x labels are one line, 0.18 when they are tilted labels
dy=0.03;
heightsubplot=1-1.6*x;
widthsubplot=1-1.4*x;

%% Colors
ColorsFig2C=[84 130 53;... Green - Virgin Yaa
    0,64,255;... Blue - Virgin AA-
    179 83 181;... Orchid - Mated Yaa
    255 192 0;... Yellow - Mated Hunt
    204,0,0;... Red - Mated AA-
    ]/255;%

%% Plotting Box plots of Total time of Yeast Head micromovement (YHmm)
% save_plot=1;
% close all
% x=0.1;%0.18 when ylabels are three lines, 0.13 for single line ylabels
% y=0.08;%0.11 when x labels are one line, 0.18 when they are tilted labels
% dy=0.03;
% heightsubplot=1-2*y;
% widthsubplot=1-1.4*x;
% Labelsmergedshort={'V AA+b';'V AA-';'M AA+b';'M AA+u';'M AA-'};
% figure('Position',[50 50 800 400],'Color','w','PaperUnits','centimeters',...
%     'PaperPosition',[1 1 17 3],'Name',['Fig2B Boxplot Head mm Total times - VYaa,AA-,MatedYaa,Hunt,AA- '  date]);%
% set(gca,'Position',[x y widthsubplot heightsubplot])
% 
% ncond=nan(length(TotalYHmm3A6AR1_4),1);
% for l=1:length(TotalYHmm3A6AR1_4)
%     ncond(l)=length(TotalYHmm3A6AR1_4(l).Data);
% end
% 
% X=nan(max(ncond),length(TotalYHmm3A6AR1_4));
% for l=1:length(TotalYHmm3A6AR1_4)
%     X(1:ncond(l),l)=TotalYHmm3A6AR1_4(l).Data/50/60;
% end
% 
% mediancolor=zeros(length(TotalYHmm3A6AR1_4),3);
% IQRcolor=ColorsFig2C;
% [~,lineh] = plot_boxplot_tiltedlabels(X,cell(length(TotalYHmm3A6AR1_4),1),1:length(TotalYHmm3A6AR1_4),...
%     IQRcolor,mediancolor,[.4 .4 .4],.4,FtSz,FntName,'o');%'k'
% set(gca,'xcolor','w')
% font_style([],[],{'Total time Yeast';'head micromov (min)'},'normal',FntName,FtSz)
% MergedConditions=1:length(TotalYHmm3A6AR1_4);
% stats_boxplot_tiltedlabels_Fig2B(X,...
%     {'Total YHmm'},MergedConditions,1:length(TotalYHmm3A6AR1_4),...
%     ['Fig2B Boxplot Head mm Total times - VYaa,AA-,MatedYaa,Hunt,AA- '],0,params,...
%     DataSaving_dir_temp,Exp_num,Exp_letter,'All new conds','Total times',FtSz,FntName,Labelsmergedshort);
% ylim([0 60])
% xlim([0.5 (length(MergedConditions)+.5)])
% if save_plot==1
% savefig_withname(1,'600','png',DataSaving_dir_temp,Exp_num,Exp_letter,...
%         'Total times')
% end
%% Plotting Ethogram
% save_plot=1;
% close all
% x=0.08;%0.18 when ylabels are three lines, 0.13 for single line ylabels
% y=0.05;%0.11 when x labels are one line, 0.18 when they are tilted labels
% dy=0.03;
% heightsubplot=1-1.3*y;
% widthsubplot=1-1.2*x;
% 
% Color_track=Colors(3);
% 
% Etho_H_new=Etho_H;
% Etho_H_new(Etho_H_new==3)=2;%Fast into micro
% Etho_H_new(Etho_H_new==4)=3;% Slow walk into merged walk
% Etho_H_new(Etho_H_new==5)=3;% Walk into merged walk
% Etho_H_new(Etho_H_new==6)=4;% Turn into new turn
% Etho_H_new(Etho_H_new==7)=5;% Jump into new jump
% Etho_H_new(Etho_H_new==9)=6;% YEast
% Etho_H_new(Etho_H_new==10)=7;% Sucrose
% 
% Etho_Colors=[...
%     [0.6 0.6 0.6]*255;...%1 - Gray (Resting)
%     243 7 198;%2 - Magenta (micromovement)
%     Color_track(3,:)*255;...%3 - Light Blue (Walking)
%     Color_track(2,:)*255;...%4 - Green (Turn)
%     255 0 0;...%5 - Red (Jump)
%     250 244 0;...%6 - Yellow (Yeast micromovement)
%     0 0 0;...%7 - Sucrose
%     255 255 255]/255;% Nothing
% Etho_Colors_Labels={'Rest','Microm','Walk',...
%     'Sharp Turn','Jump','Head Y','Head S'};
% 
% close all
% 
% Conditions=[1 3 4];
% 
% lcondcounter=0;
% for lcond=Conditions
%     lcondcounter=lcondcounter+1;
%     figure('Position',[50 50 800 800],'Color','w','PaperUnits','centimeters',...
%     'PaperPosition',[1 1 3 3.5],'Name',['Fig2C Head mm Etho - ' params.LabelsShort{lcond} ' ' date]);%
% set(gca,'Position',[x y widthsubplot heightsubplot])
%     %% Plotting Ethogram
%     Totaltimes_cond=sum(CumTimeV{lsubs}(:,params.ConditionIndex==lcond));%sum(CumTimeH{1}(:,params.ConditionIndex==lcond));
%     Etho_H_cond=Etho_H_new(params.ConditionIndex==lcond,:);
%     Idx_cond=find(params.ConditionIndex==lcond);
%     [Totalt_sorted,Idx_sort]=sort(Totaltimes_cond,...
%         'ascend');
%     image(Etho_H_cond(Idx_sort,:))
%     
%     %%% Other settings
%     colormap(Etho_Colors);
%     freezeColors
%     set(gca,'XTick',[0:30*50*60:120*50*60],...
%         'XTickLabel',[],'YDir','normal',...cellfun(@num2str,num2cell(0:30:120),'UniformOutput',0)
%         'YTick',[],'ycolor','w')%,...
%     xlim([0 120*50*60])%params.MinimalDuration
%     ylim([.5 37])
%     box off
%     font_style([],[],...'Time (min)'
%         [],'normal',FntName,FtSz)
%     
%     
%     
% end
% if save_plot==1
% savefig_withname(1,'600','png',DataSaving_dir_temp,Exp_num,Exp_letter,...
%         'Ethograms')
% end

%% Plotting Cumulative
save_plot=1;
close all
x=0.04;%0.2;%
y=0.22;
dy=0.03;
heightsubplot=1-1.3*y;
widthsubplot=1-2.45*x;

Conditions=[1 3 4];%3A[3 4];%6A 
oldtonewCond=[4 5 2];%map for 1,3,4 3A [3 1];%map for 3,4 6A 
for lcond=Conditions
fig=figure('Position',[50 50 800 800],'Color','w','PaperUnits','centimeters',...
    'PaperPosition',[1 1 3 3.5],'Name',['Fig2C Cumulative single fly - ' params.LabelsShort{lcond} ' ' date]);%
set(gca,'Position',[x y widthsubplot heightsubplot])
hold on
maxframe=120*50*60;
if maxframe>size(CumTimeH{lsubs}(:,1),1), maxframe=size(CumTimeH{lsubs}(:,1),1);end
% if maxframe>params.MinimalDuration, maxframe=params.MinimalDuration;end
for lfly=find(params.ConditionIndex==lcond)
    plot((1:maxframe)/params.framerate/60,...
        cumsum(CumTimeH{lsubs}(1:maxframe,lfly))/50/60,'-k','Color',[.5 .5 .5],...
        'LineWidth',0.4)
%     plot(maxframe/params.framerate/60,...
%         sum(CumTime{lsubs}(1:maxframe,lfly))/60,'ok','MarkerFaceColor',[.5 .5 .5],...
%         'MarkerEdgeColor','k','MarkerSize',2)
end
plot((1:maxframe)/params.framerate/60,...
    nanmedian(cumsum(CumTimeH{lsubs}(1:maxframe,params.ConditionIndex==lcond)),2)/50/60,...
    '-k','Color','k','LineWidth',2);
plot((1:maxframe)/params.framerate/60,...
    nanmedian(cumsum(CumTimeH{lsubs}(1:maxframe,params.ConditionIndex==lcond)),2)/50/60,...
    '-k','Color',ColorsFig2C(oldtonewCond(lcond==Conditions),:),'LineWidth',1);
% plot(maxframe/params.framerate/60,...
%     nanmedian(sum(CumTime{lsubs}(1:maxframe,params.ConditionIndex==lcond)),2)/60,...
%     'ob','MarkerSize',4,'MarkerEdgeColor','k','MarkerFaceColor','k',...Colors_cond(find(Conditions==lcond),:),...
%     'LineWidth',1)
set(gca,'XTick',0:30:120,'Xticklabel',{'0','30','60','90',[]})%cellfun(@num2str,num2cell(0:30:90),'UniformOutput',0))
font_style([],'Time (min)',...
    [],'normal','arial',FtSz)%{['Cumulative time'];['on ' params.Subs_Names{lsubs}]}

axis([0 120 -5 60])%params.MinimalDuration
end
if save_plot==1
    savefig_withname(1,'600','png',DataSaving_dir_temp,Exp_num,Exp_letter,...
        'Total times')
end