%% General FlyPAD Experiment Info
% clc 
% clear all
% close all
% load('E:\Analysis Data\Experiment 0003\FlyPAD\18-04-2016\Analysis 2_1\MVYaaHuntS_Full.mat')
% load('E:\Analysis Data\Experiment 0011\FlyPAD\26&27JointAnalysis\Tbh_1_12_Conds2,4,6,8\VCSTbhHuntS_1_12_20160424\VCSTbhHuntS_1_12_20160424_Full.mat')
% load('E:\Analysis Data\Experiment 0011\FlyPAD\26&27JointAnalysis\Tbh_1_12_Conds3,4,7,8\MVCSTbH_1_12_20160901_Full.mat')
ConditionsFlyPAD=[2 1 4 3];%[2 6 1 3 5];
lsubs=2;%2-yeast, 1-sucrose
substratename={'sucrose';'yeast'};% In flyPAD experiment with Octopamine EXP 11A
params.Subs_Names=substratename;
params.Subs_Numbers=[1,2];

if lsubs==1,width=4;%18.9;
else width=4;end
Channels_num=[1:2:64;2:2:64];%[Yeast;Sucrose];
MaxSample=360000;

[ColorsinPaper,orderinpaper,labelspaper]=ColorsPaper5cond_fun(Exp_num, Exp_letter);
%% FlyPAD DATA - Number of sips on yeast
nsips_vector=nan(size(Events.Ons,1)*size(Events.Ons,2)/2,1);
Cond_Idx_PAD=nan(size(Events.Ons,1)*size(Events.Ons,2)/2,1);
counter=1;
for lrun=1:size(Events.Ons,1)
    for lchannel=Channels_num(lsubs,:)
        nsips_vector(counter)=numel(Events.Ons{lrun,lchannel});
        Cond_Idx_PAD(counter)=Events.Condition{lrun}(lchannel);
        counter=counter+1;
    end

end
nsips_vector=nsips_vector(~isnan(Cond_Idx_PAD));
Cond_Idx_PAD=Cond_Idx_PAD(~isnan(Cond_Idx_PAD));

numfliespercond=nan(length(unique(Cond_Idx_PAD)),1);
for lcond=1:length(unique(Cond_Idx_PAD))
    numfliespercond(lcond)=sum(Cond_Idx_PAD==lcond);
end

nsips_vec=nan(max(numfliespercond),length(unique(Cond_Idx_PAD)));
for lcond=1:length(unique(Cond_Idx_PAD))
    nsips_vec(1:numfliespercond(lcond),lcond)=nsips_vector(Cond_Idx_PAD==lcond);
end
nsips_boxplotvec=nsips_vec(:,ConditionsFlyPAD);
%% Plotting
close all
FntName='Arial';
FtSz=10;
MkSz=1;
%%% Colors
[CondColors,Cmap_patch]=Colors(4);%Colors(length(Conditions));
[Color, Color_patch]=Colors(3);
Colors1=[0 0 0;0 0 0]/255;% Mean line color ;CondColors([1 3],:);%[0 0 0;Color(3,:)];
Colors2=ColorsinPaper;%Cmap_patch([1 3],:);%[[0.7 .7 .7];Color_patch(3,:)];

%% Boxplot of number of sips
save_plot=1;
subfolder='flyPAD';
close all
x=.45;
y=0.2;%0.11 when x labels are one line, 0.18 when they are tilted labels
dy=0.03;
heightsubplot=1-1.6*y;
widthsubplot=1-1.1*x;

figname='Boxplot octopamine postmating yeast AA-';%['FigS8 Boxplot ' substratename{lsubs} 'Delta Sips - VirginsCSTbh Hunt,AA- '  date]);%

figure('Position',[50 50 800 400],'Color','w','PaperUnits','centimeters',...
    'PaperPosition',[1 1 5 4.5],'Name',figname);%
set(gca,'Position',[x y widthsubplot heightsubplot])
xvalues=1:length(ConditionsFlyPAD);
mediancolor=zeros(length(ConditionsFlyPAD),3);
IQRcolor=ColorsinPaper;%newcondcolors;

[~,lineh] = plot_boxplot_tiltedlabels(nsips_boxplotvec,cell(length(ConditionsFlyPAD),1),1:length(ConditionsFlyPAD),...
    IQRcolor,mediancolor,[.4 .4 .4],.4,FtSz,FntName,'o',1);%'k'
set(gca,'xcolor','w')
font_style([],[],{'Total number';['of ' substratename{lsubs} ' sips'];'(x1000)'},'normal',FntName,FtSz)
MergedConditions=1:length(ConditionsFlyPAD);
stats_boxplot_tiltedlabels_Fig2B(nsips_boxplotvec,...
    {'Nofsips'},MergedConditions,1:length(ConditionsFlyPAD),...
    figname,0,params,...
    DataSaving_dir_temp,Exp_num,Exp_letter,'All new conds','FlyPAD',FtSz,FntName,Events.ConditionLabel(ConditionsFlyPAD));
if lsubs==1, ylim([0 8000]);
else ylim([0 10000]);%ylim([0 1400]),
end

YLim2=get(gca,'Ylim');

if lsubs==2
    set(gca,'YTick',[0:2000:YLim2(2)],'YTickLabel',cellfun(@(x)num2str(x),num2cell([0:2000:YLim2(2)]/1000),'uniformoutput',0))
else
    set(gca,'YTick',[0:200:YLim2(2)],'YTickLabel',cellfun(@(x)num2str(x),num2cell([0:200:YLim2(2)]/1000),'uniformoutput',0))
end

xlim([0.5 (length(MergedConditions)+.5)])
ylim(YLim2)
if save_plot==1
savefig_withname(1,'600','png',DataSaving_dir_temp,Exp_num,Exp_letter,...
        subfolder)
% savefig_withname(0,'600','eps',DataSaving_dir_temp,Exp_num,Exp_letter,...
%     subfolder)
savefig_withname(0,'600','eps',DataSaving_dir_temp,'0003','D',...
        'Figures')
end

%% Cumulative number of sips
% plotcounter=plotcounter+1;
% subplot('Position',AxesPositions(plotcounter,:))
% 
% CumulativeFeedingEventsFig2(Events,lsubs,1,labels2,Colors_PAD,MaxSample);
% font_style([],'Time (min)',{...[...Events.SubstrateLabel{lsubs}(1:end-4)
%     'Cumulative number';['of ' paramsR05R06.Subs_Names{lsubs} ' sips (x1000)']},'normal',FntName,FtSz)
% YLim2=get(gca,'Ylim');
% set(gca, 'XTick',[0:20:60]*60*100,'XTickLabel',cellfun(@(x)num2str(x),num2cell([0:18:60]),'uniformoutput',0))
% if lsubs==1
%     set(gca,...
%     'YTick',[0:1000:YLim2(2)],'YTickLabel',cellfun(@(x)num2str(x),num2cell([0:1000:YLim2(2)]/1000),'uniformoutput',0))
% else
%     set(gca,...
%     'YTick',[0:200:YLim2(2)],'YTickLabel',cellfun(@(x)num2str(x),num2cell([0:200:YLim2(2)]/1000),'uniformoutput',0))
% end
% xlim([0 MaxFrames*2])
%% Box plot Number of sips per burst
BoxPlotYN=2;
figname='Boxplot octopamine N sips per burst';%['FigS8 Boxplot ' substratename{lsubs} 'Delta Sips - VirginsCSTbh Hunt,AA- '  date]);%
params.LabelsShort= {'MCS';'VCS';'MTbH';'VTbH'};
Conditions=ConditionsFlyPAD;

figure('Position',[50 50 800 400],'Color','w','PaperUnits','centimeters',...
    'PaperPosition',[1 1 5 4.5],'Name',figname);%
set(gca,'Position',[x y widthsubplot heightsubplot])
Boxplot_Matrix=BoxplotPASHAfun_Fig2(Events,@nanmean,'FeedingBurstnEvents',params.LabelsShort,0,ColorsinPaper,BoxPlotYN,lsubs);

xvalues=1:length(Conditions);
IQRcolor=ColorsinPaper;
mediancolor=zeros(length(Conditions),3);
[~,lineh] = plot_boxplot_tiltedlabels(Boxplot_Matrix(:,ConditionsFlyPAD),cell(length(xvalues),1),xvalues,...
                        IQRcolor,mediancolor,[.4 .4 .4],.4,FtSz,FntName,'o',1);%'k'
stats_boxplot_tiltedlabels_Fig2B(Boxplot_Matrix(:,ConditionsFlyPAD),...
    {'NSipsperburst'},MergedConditions,1:length(ConditionsFlyPAD),...
    figname,0,params,...
    DataSaving_dir_temp,Exp_num,Exp_letter,'All new conds','FlyPAD',FtSz,...
    FntName,Events.ConditionLabel(ConditionsFlyPAD));
                    
set(gca,'xcolor','w')

font_style([],[],{'Number of' ;'sips per burst'},'normal',FntName,FtSz)
% ylim([0 35])
box off

%% Box plot IBurstI
figname='Boxplot octopamine IBI';%
figure('Position',[50 50 800 400],'Color','w','PaperUnits','centimeters',...
    'PaperPosition',[1 1 5 4.5],'Name',figname);%
set(gca,'Position',[x y widthsubplot heightsubplot])

Boxplot_Matrix=BoxplotPASHAfun_Fig2(Events,@(x)(nanmean(x)./100),'FeedingBurstIBI',params.LabelsShort,0,ColorsinPaper,BoxPlotYN,lsubs);

xvalues=1:length(Conditions);
IQRcolor=ColorsinPaper;
mediancolor=zeros(length(Conditions),3);
[~,lineh] = plot_boxplot_tiltedlabels(Boxplot_Matrix(:,ConditionsFlyPAD),cell(length(xvalues),1),xvalues,...
                        IQRcolor,mediancolor,[.4 .4 .4],.4,FtSz,FntName,'o',1);%'k'
stats_boxplot_tiltedlabels_Fig2B(Boxplot_Matrix(:,ConditionsFlyPAD),...
    {'IBI'},MergedConditions,1:length(ConditionsFlyPAD),...
    figname,0,params,...
    DataSaving_dir_temp,Exp_num,Exp_letter,'All new conds','FlyPAD',FtSz,...
    FntName,Events.ConditionLabel(ConditionsFlyPAD));
set(gca,'xcolor','w')
ylim([0 400])
font_style([],[],{'Average Inter-Burst';'Interval (s)'},'normal',FntName,FtSz)
box off