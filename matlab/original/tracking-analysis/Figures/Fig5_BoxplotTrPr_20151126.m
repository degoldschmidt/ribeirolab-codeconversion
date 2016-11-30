%%
load('E:\Analysis Data\Experiment 0006\Variables\TimeSegmentsBoxplot6A 26-Nov-2015.mat')
load('E:\Analysis Data\Experiment 0003\Variables\TimeSegmentsBoxplot3A 26-Nov-2015.mat')
load('E:\Analysis Data\Experiment 0003\Variables\TimeSegmentsParams_1r_until115_0003A 26-Nov-2015.mat','TimeSegmentsParams')
%% Plotting Box plots of TrPrs
% % - 34.	Transition Probabilities to the Same Subs1
% % 35.	Transition Probabilities to the Same Subs2
% % - 36.	Transition Probabilities to the Adj Subs1
% % 37.	Transition Probabilities to the Adj Subs2
% % - 38.	Transition Probabilities to the Far Subs1
% % 39.	Transition Probabilities to the Far Subs2

close all
x=0.04;%0.18 when ylabels are three lines, 0.13 for single line ylabels
y=0.22;%0.11 when x labels are one line, 0.18 when they are tilted labels
dy=0.03;
heightsubplot=1-1.3*y;
widthsubplot=1-1.2*x;
Labelsmergedshort={'M AA+b';'M AA+u';'M AA-'};
Params=[34 36 38];

ncond=nan(length(Labelsmergedshort),1);
ncond(1)=sum(~isnan(TimeSegmentsBoxplot6A{1}(:,3)));%'M AA+b'
ncond(2)=sum(~isnan(TimeSegmentsBoxplot3A{1}(:,1)));%'M AA+u'
ncond(3)=sum(~isnan(TimeSegmentsBoxplot3A{1}(:,3)));%'M AA-'

for lplot
figure('Position',[50 50 800 400],'Color','w','PaperUnits','centimeters',...
    'PaperPosition',[1 1 3 3.5],'Name',['Fig6 Boxplot TrPr - MatedYaa,Hunt,AA- '  date]);%
set(gca,'Position',[x y widthsubplot heightsubplot])

X=nan(max(ncond),length(Labelsmergedshort));
X(1:ncond(1),1)=TimeSegmentsBoxplot6A{1}(~isnan(TimeSegmentsBoxplot6A{1}(:,3)),3);%'M AA+b'
X(1:ncond(2),2)=TimeSegmentsBoxplot3A{1}(~isnan(TimeSegmentsBoxplot3A{1}(:,1)),1);%'M AA+u'
X(1:ncond(3),3)=TimeSegmentsBoxplot3A{1}(~isnan(TimeSegmentsBoxplot3A{1}(:,3)),3);%'M AA-'


mediancolor=zeros(length(Labelsmergedshort),3);
IQRcolor=[179 83 181;... Orchid - Mated Yaa
    255 192 0;... Yellow - Mated Hunt
    204,0,0;... Red - Mated AA-
    ]/255;%

[~,lineh] = plot_boxplot_tiltedlabels(X,Labelsmergedshort,1:length(TotalYHmm3A6AR1_4),...
    IQRcolor,mediancolor,[.4 .4 .4],.4,FtSz,FntName,'o');%'k'
font_style([],[],{'Total time Yeast';'head micromov (min)'},'normal',FntName,FtSz)
MergedConditions=1:length(TotalYHmm3A6AR1_4);
stats_boxplot_tiltedlabels_Fig2B(X,...
    {'Total YHmm'},MergedConditions,1:length(TotalYHmm3A6AR1_4),...
    ['Fig2B Boxplot Head mm Total times - VYaa,AA-,MatedYaa,Hunt,AA- '],0,params,...
    DataSaving_dir_temp,Exp_num,Exp_letter,'All new conds','Total times',FtSz,FntName,Labelsmergedshort)
ylim([-0.1 65])
xlim([0.5 (length(MergedConditions)+.5)])
end
if save_plot==1
savefig_withname(1,'600','png',DataSaving_dir_temp,Exp_num,Exp_letter,...
        'Figures')
end