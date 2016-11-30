%% Initial parameters
lsubs=1;
Conditions=[1:6];%EXP 12A[2 1 3];%EXP 8B [1 3];%[6 4 5 1 3];%Exp 3D[4 1];%

FtSz=10;%20;
FntName='arial';
LineW=0.8;

%%% Colors
[ColorsinPaper,orderinpaper,labelspaper]=ColorsPaper5cond_fun(Exp_num, Exp_letter,params);
%% Plotting Box plots of Total time of Yeast Head micromovement (YHmm)
% save_plot=1;
% subfolder='Total times';
% close all
% x=0.1;%0.18 when ylabels are three lines, 0.13 for single line ylabels
% y=0.1;%0.11 when x labels are one line, 0.18 when they are tilted labels
% dy=0.03;
% heightsubplot=1-2*y;
% widthsubplot=1-1.4*x;
% 
% figure('Position',[50 50 800 400],'Color','w','PaperUnits','centimeters',...
%     'PaperPosition',[1 1 18.9 3],'Name',['Fig2B Boxplot Head mm Total times - VYaa,AA-,MatedYaa,Hunt,AA- '  date]);%
% set(gca,'Position',[x y widthsubplot heightsubplot])
% 
% numcond=nan(length(Conditions),1);
% lcondcounter=0;
% for lcond=Conditions
%     lcondcounter=lcondcounter+1;
%     numcond(lcondcounter)=sum(params.ConditionIndex==lcond);
% end
% 
% X=nan(max(numcond),length(Conditions));
% lcondcounter=0;
% for lcond=Conditions
%     lcondcounter=lcondcounter+1;
%     X(1:numcond(lcondcounter),lcondcounter)=sum(CumTimeH{lsubs}(:,params.ConditionIndex==lcond))/50/60;
% end
% 
% mediancolor=zeros(length(Conditions),3);
% IQRcolor=ColorsinPaper;
% [~,lineh] = plot_boxplot_tiltedlabels(X,cell(length(Conditions),1),1:length(Conditions),...
%     IQRcolor,mediancolor,[.4 .4 .4],.4,FtSz,FntName,'o');%'k'
% set(gca,'xcolor','w')
% font_style([],[],{'Total time Yeast head';'micromovements';'(min)'},'normal',FntName,FtSz)
% MergedConditions=1:length(Conditions);
% stats_boxplot_tiltedlabels_Fig2B(X,...
%     {'Total YHmm'},MergedConditions,1:length(Conditions),...
%     ['Fig2B Boxplot Head mm Total times - VYaa,AA-,MatedYaa,Hunt,AA- '],0,params,...
%     DataSaving_dir_temp,Exp_num,Exp_letter,'All new conds','Total times',FtSz,FntName,params.LabelsShort(Conditions));
% ylim([0 60])
% xlim([0.5 (length(MergedConditions)+.5)])
% if save_plot==1
% savefig_withname(1,'600','eps',DataSaving_dir_temp,Exp_num,Exp_letter,...
%         subfolder)
% end
%% Plotting Ethogram
save_plot=1;
close all
x=0.08;%0.18 when ylabels are three lines, 0.13 for single line ylabels
y=0.05;%0.11 when x labels are one line, 0.18 when they are tilted labels
dy=0.03;
heightsubplot=1-1.3*y;
widthsubplot=1-1.2*x;

Color_track=Colors(3);

if ~exist('Etho_Speed_new','var')
    [Etho_Speed_new,Etho_colors_new,Etho_Colors_Labels] = Etho_Speed2New(params.MinimalDuration,Etho_Speed,1);
end

Etho_H_Speed=Etho_Speed_new;
Etho_H_Speed(Etho_H==9)=6;%YHmm
Etho_H_Speed(Etho_H==10)=7;%SHmm
EthoH_Colors=[Etho_colors_new;...
    [240 228 66]/255;...6 - Yellow (Yeast micromovements) %[250 244 0]/255;...%6 - Yellow (Yeast micromovement)
    0 0 0];%7 - Sucrose

% % Etho_H_new=Etho_H;
% % Etho_H_new(Etho_H_new==3)=2;%Fast into micro
% % Etho_H_new(Etho_H_new==4)=3;% Slow walk into merged walk
% % Etho_H_new(Etho_H_new==5)=3;% Walk into merged walk
% % Etho_H_new(Etho_H_new==6)=4;% Turn into new turn
% % Etho_H_new(Etho_H_new==7)=5;% Jump into new jump
% % Etho_H_new(Etho_H_new==9)=6;% YEast
% % Etho_H_new(Etho_H_new==10)=7;% Sucrose
% % 
% % Etho_Colors=[...
% %     [0.6 0.6 0.6]*255;...%1 - Gray (Resting)
% %     243 7 198;%2 - Magenta (micromovement)
% %     Color_track(3,:)*255;...%3 - Light Blue (Walking)
% %     Color_track(2,:)*255;...%4 - Green (Turn)
% %     255 0 0;...%5 - Red (Jump)
% %     250 244 0;...%6 - Yellow (Yeast micromovement)
% %     0 0 0;...%7 - Sucrose
% %     255 255 255]/255;% Nothing
% % Etho_Colors_Labels={'Rest','Microm','Walk',...
% %     'Sharp Turn','Jump','Head Y','Head S'};

close all

% Conditions=[1 3 4];
xmax=60;% 120;% min

lcondcounter=0;
for lcond=Conditions
    lcondcounter=lcondcounter+1;
    Paperpos=[10 10 5 4];%Thesis [1 1 8 7]
%     figure('Position',[50 50 800 800],'Color','none','PaperUnits','centimeters',...'w'
%     'PaperPosition',[1 1 3 3.5],'Name',['Fig2C Head mm Etho - ' params.LabelsShort{lcond} ' ' date]);%
%     figure('Position',[50 50 800 800],'Color','none','PaperUnits','centimeters',...'w'
%     'PaperPosition',[1 1 3 4.5],'Name',['Fig7D Head mm Etho - cond' num2str(lcond) ' ' date]);%
figure('Position',[50 50 800 800],'Color','none','PaperUnits','centimeters',...'w'
    'PaperPosition',Paperpos,'Name',['Head mm Etho - cond' num2str(lcond) ' ' date]);%
set(gca,'Position',[x y widthsubplot heightsubplot])
    %% Plotting Ethogram
    Totaltimes_cond=sum(CumTimeV{lsubs}(:,params.ConditionIndex==lcond));%sum(CumTimeH{1}(:,params.ConditionIndex==lcond));
    Etho_H_cond=Etho_H_Speed(params.ConditionIndex==lcond,:);
    Idx_cond=find(params.ConditionIndex==lcond);
    [Totalt_sorted,Idx_sort]=sort(Totaltimes_cond,...
        'ascend');
    image(Etho_H_cond(Idx_sort,:))
    
    %%% Other settings
    colormap(EthoH_Colors);
    freezeColors
%     set(gca,'XTick',[0:30*50*60:120*50*60])%Fig2&7
xticks=0:20*50*60:xmax*50*60;
    set(gca,'XTick',xticks)%Fig4S1
        set(gca,'XTickLabel',[],'YDir','normal',...cellfun(@num2str,num2cell(0:30:120),'UniformOutput',0)
        'YTick',[],'ycolor','w')%,...
    xlim([0 xmax*50*60])%xlim([0 120*50*60])%params.MinimalDuration
    ylim([.5 38.5])%ylim([.5 35.5])
    box off
    font_style([],[],...'Time (min)'
        [],'normal',FntName,FtSz)
%     if (lcondcounter==1)||(lcondcounter==3)||(lcondcounter==5)
%         set(gca,'Color',[220 220 220]/255,'YColor',[220 220 220]/255)
%         set(gcf,'Color',[220 220 220]/255)
%     else
        set(gca,'Color','w','YColor','w')
        set(gcf,'Color','w')
%     end
    %% Latency dot
    hold on
    latency_cond=latency_root(params.ConditionIndex==lcond);
    plot(latency_cond(Idx_sort),1:length(Idx_sort),'ob',...
        'MarkerFaceColor','b','MarkerSize',3)%Fig4S1 1.5)%fig7 3)%

end
if save_plot==1
savefig_withname(1,'600','png',DataSaving_dir_temp,Exp_num,Exp_letter,...
        'Ethograms')
end

%% Plotting Cumulative
save_plot=1;
close all
x=0.1;%0.04;%Fig2 
y=0.22;
dy=0.03;
LnW1=1;%Fig8 0.4;%Fig2
LnW2=3;%Fig8 2;%Fig2
LnW3=1.5;%Fig8 1;%Fig2
heightsubplot=1-1.3*y;
widthsubplot=1-2.45*x;
PaperPos=[10 10 5 4];%[1 1 7 7.5];%Fig2 [1 1 3 3.5];%Fig2
for lcond=Conditions
fig=figure('Position',[50 50 800 800],'Color','w','PaperUnits','centimeters',...
    'PaperPosition',PaperPos,'Name',['Cumulative single fly - cond' num2str(lcond) ' ' date]);%params.LabelsShort{lcond}
set(gca,'Position',[x y widthsubplot heightsubplot])
hold on
xmax=60;% 120;% min

maxframe=xmax*50*60;
if maxframe>size(CumTimeH{lsubs}(:,1),1), maxframe=size(CumTimeH{lsubs}(:,1),1);end
% if maxframe>params.MinimalDuration, maxframe=params.MinimalDuration;end
for lfly=find(params.ConditionIndex==lcond)
    plot((1:maxframe)/params.framerate/60,...
        cumsum(CumTimeH{lsubs}(1:maxframe,lfly))/50/60,'-k','Color',[.5 .5 .5],...
        'LineWidth',LnW1)
%     plot(maxframe/params.framerate/60,...
%         sum(CumTime{lsubs}(1:maxframe,lfly))/60,'ok','MarkerFaceColor',[.5 .5 .5],...
%         'MarkerEdgeColor','k','MarkerSize',2)
end
plot((1:maxframe)/params.framerate/60,...
    nanmedian(cumsum(CumTimeH{lsubs}(1:maxframe,params.ConditionIndex==lcond)),2)/50/60,...
    '-k','Color','k','LineWidth',LnW2);
plot((1:maxframe)/params.framerate/60,...
    nanmedian(cumsum(CumTimeH{lsubs}(1:maxframe,params.ConditionIndex==lcond)),2)/50/60,...
    '-k','Color',ColorsinPaper(lcond==orderinpaper,:),'LineWidth',LnW3);
% plot(maxframe/params.framerate/60,...
%     nanmedian(sum(CumTime{lsubs}(1:maxframe,params.ConditionIndex==lcond)),2)/60,...
%     'ob','MarkerSize',4,'MarkerEdgeColor','k','MarkerFaceColor','k',...Colors_cond(find(Conditions==lcond),:),...
%     'LineWidth',1)
ymax=40;% 60;%Exp 3D
xticks=0:20:xmax;
set(gca,'XTick',xticks,'Xticklabel',cellfun(@num2str,num2cell(xticks),'UniformOutput',0))%{'0','30','60','90',[]}
font_style([],'Time (min)',...
    [],'normal','arial',FtSz)%{['Cumulative time'];['on ' params.Subs_Names{lsubs}]}

axis([0 xmax -3 ymax])%thesis ([0 120 -5 60])%params.MinimalDuration
end
%% Figure with Labels
figname=['Time Segments - Condition Labels_Cond ' num2str(Conditions) '_' num2str(size(ranges,1)) 'r_until' num2str(floor((ranges(end)/50/60))) '_' date];
figure('Position',[2100 50 500 500],'Color','w','Name',figname,'PaperUnits',...
    'centimeters','PaperPosition',[0 0 10 10])
hold on
lcondcounter=0;
for lcond=Conditions
    lcondcounter=lcondcounter+1;
    plot([1 2],[lcondcounter lcondcounter],'-','LineWidth',3,'Color',ColorsinPaper(lcond==orderinpaper,:))
    text(3,lcondcounter,params.Labels{lcond},'FontName',FntName,'FontSize',FtSz)
    axis([0 10 0 lcondcounter+1])
    font_style({'Condition labels time segment parameters';['Exp ' num2str(Exp_num) num2str(Exp_letter) ', ' date]},[],[],'normal',FntName,FtSz)
    axis off
end
%%
if save_plot==1
    savefig_withname(1,'600','png',DataSaving_dir_temp,Exp_num,Exp_letter,...
        'Total times')%
    savefig_withname(0,'600','eps',DataSaving_dir_temp,Exp_num,Exp_letter,...
        'Total times')
end