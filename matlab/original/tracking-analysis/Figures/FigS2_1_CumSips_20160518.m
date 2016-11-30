%% General FlyPAD Experiment Info
% NOTE: For this script to work, the input Events has to have all
% conditions that you need. Since there is no CondIdx for flyPAD. To set
% the colors, write in "Conditions" the conditions in the order they appear
% in the flyPAD
% clc 
% clear all
% close all
 load('E:\Analysis Data\Experiment 0003\FlyPAD\2016-04-22\1_12AllbutVhunt\MVYaaHuntS_1_12_Full.mat')
Conditions=[5 6 1 3 4];% Write in the order they are in the flyPAD
ConditionsFlyPAD=[2 5 1 3 4];

lsubs=2;%1-yeast, 2-sucrose
substratename={'yeast';'sucrose'};

Channels_num=[1:2:64;2:2:64];%[Yeast;Sucrose];
% % Dur=320000;
MaxSample=360000;
BoxPlotYN=2;
subfolder='flyPAD';
% 
% totalnumflies_FlyPAD=size(Events.Ons,1)*size(Events.Ons,2)/2;
% DurIn_FlyPAD=cell(totalnumflies_FlyPAD,1);
% paramsFlyPAD.ConditionIndex=nan(1,totalnumflies_FlyPAD);
% paramsFlyPAD.framerate=100;
% paramsFlyPAD.Subs_Names=Events.SubstrateLabel';
% paramsFlyPAD.LabelsShort=Events.ConditionLabel';

[CondColors,Cmap_patch]=Colors(length(Conditions));
[ColorsinPaper,orderinpaper]=ColorsPaper5cond_fun;
newcondcolors=nan(length(Conditions),3);
for lcond=Conditions
    if length(Conditions)<=size(ColorsinPaper,1)
        newcondcolors(lcond==Conditions,:)=ColorsinPaper(orderinpaper==lcond,:);%
    else
        newcondcolors(lcond==Conditions,:)=CondColors(ismember(unique(params.ConditionIndex),lcond),:);
    end
end
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
saveplot=0;
FntName='Arial';
labels2={'AA+','AA-'};
%%% Colors
Colors1=repmat([0 0 0],length(Conditions),1);% Mean line color ;CondColors([1 3],:);%[0 0 0;Color(3,:)];
Colors2=newcondcolors;%Cmap_patch([1 3],:);%[[0.7 .7 .7];Color_patch(3,:)];

Colors_PAD=cell(length(unique(Cond_Idx_PAD)),1);
for lcond=1:length(unique(Cond_Idx_PAD))
    Colors_PAD{lcond,1}=Colors1(lcond,:);%Mean line
    Colors_PAD{lcond,2}=Colors2(lcond,:);%Error area
end

FtSz=10;
LineW=0.8;
MkSz=1;

x=0.1;y=0.2;dh=0.07;w=(1-4*dh-x)/(4+0.2);h=4*w;
AxesPositions=[x,y,w*1.2,h;
    x+w*1.4+dh,y,w,h;
    x+w*2.4+2*dh,y,w,h;
    x+w*3.4+3*dh,y,w,h];%1x4 structure

plotcounter=0;
%% Cumulative head mm
MaxSample=360000;
MaxFrames=floor(MaxSample/2);%
%% Cumulative number of sips
% figure('Position',[50 50 800 400],'Color','w','PaperUnits','centimeters',...
%     'PaperPosition',[1 1 4.5 4],'Name',['Fig2-suppl1 Cumulative Sips - VYaa,AA-,MatedYaa,Hunt,AA- '  date]);%
% 
% CumulativeFeedingEventsFig2(Events,lsubs,1,labels2,Colors_PAD,MaxSample);
% font_style([],'Time (min)',{...[...Events.SubstrateLabel{lsubs}(1:end-4)
%     'Cumulative number';'of sips (x1000)'},'normal',FntName,FtSz)
% YLim2=get(gca,'Ylim');
% set(gca, 'XTick',[0:20:60]*60*100,'XTickLabel',cellfun(@(x)num2str(x),num2cell([0:20:60]),'uniformoutput',0),...
%     'YTick',[0:1000:YLim2(2)],'YTickLabel',cellfun(@(x)num2str(x),num2cell([0:1000:YLim2(2)]/1000),'uniformoutput',0))
% xlim([0 MaxFrames*2])
%% SIps Box plots
x=0.1;%0.18 when ylabels are three lines, 0.13 for single line ylabels
y=0.1;%0.11 when x labels are one line, 0.18 when they are tilted labels
dy=0.03;
heightsubplot=1-2*y;
widthsubplot=1-1.4*x;

figure('Position',[50 50 800 400],'Color','w','PaperUnits','centimeters',...
    'PaperPosition',[1 1 4 4],'Name',['Fig2suppl2B Boxplot ' substratename{lsubs} 'Sips - VYaa,AA-,MatedYaa,Hunt,AA- '  date]);%
set(gca,'Position',[x y widthsubplot heightsubplot])
xvalues=1:length(ConditionsFlyPAD);
mediancolor=zeros(length(ConditionsFlyPAD),3);
IQRcolor=ColorsinPaper;%newcondcolors;

[~,lineh] = plot_boxplot_tiltedlabels(nsips_boxplotvec,cell(length(ConditionsFlyPAD),1),1:length(ConditionsFlyPAD),...
    IQRcolor,mediancolor,[.4 .4 .4],.4,FtSz,FntName,'o');%'k'
set(gca,'xcolor','w')
font_style([],[],{'Total number';['of ' substratename{lsubs} ' sips'];'(x1000)'},'normal',FntName,FtSz)
MergedConditions=1:length(ConditionsFlyPAD);
stats_boxplot_tiltedlabels_Fig2B(nsips_boxplotvec,...
    {'Nofsips'},MergedConditions,1:length(ConditionsFlyPAD),...
    ['Fig2suppl2B Boxplot ' substratename{lsubs} ' sips - VYaa,AA-,MatedYaa,Hunt,AA- '],0,params,...
    DataSaving_dir_temp,Exp_num,Exp_letter,'All new conds','flyPAD',FtSz,FntName,Events.ConditionLabel(ConditionsFlyPAD));
if lsubs==1, ylim([0 8000]); else ylim([0 800]), end

YLim2=get(gca,'Ylim');

if lsubs==1
    set(gca,'YTick',[0:2000:YLim2(2)],'YTickLabel',cellfun(@(x)num2str(x),num2cell([0:2000:YLim2(2)]/1000),'uniformoutput',0))
else
    set(gca,'YTick',[0:200:YLim2(2)],'YTickLabel',cellfun(@(x)num2str(x),num2cell([0:200:YLim2(2)]/1000),'uniformoutput',0))
end

xlim([0.5 (length(MergedConditions)+.5)])
ylim(YLim2)
%%
if saveplot==1
    savefig_withname(1,'600','png','E:\Analysis Data\Experiment ','0003','D',...
        subfolder)
    savefig_withname(0,'600','eps','E:\Analysis Data\Experiment ','0003','D',...
        'Figures')
end

