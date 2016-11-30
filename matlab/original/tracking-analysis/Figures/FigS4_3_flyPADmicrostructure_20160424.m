%% General FlyPAD Experiment Info
% NOTE: For this script to work, the input Events has to have all
% conditions that you need. Since there is no CondIdx for flyPAD. To set
% the colors, write in "Conditions" the conditions in the order they appear
% in the flyPAD
% clc 
% clear all
% close all
% % % load('E:\Analysis Data\Experiment 0003\FlyPAD\1_12 Matedonly\1-12_Mated_Fulldata.mat','Events')
% % % load('E:\Analysis Data\Experiment 0003\Variables\Fig1 20-Aug-2015.mat','CumTimeHR0506','DurInHR0506','paramsR05R06')
%  load('E:\Analysis Data\Experiment 0003\FlyPAD\2016-04-22\1_12\mrep\MVYaaHuntS1_12.mat\MVYaaHuntS_1_12_Full.mat')
Conditions=[5 1 3];
lsubs=1;%yeast
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
% 
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

nsips_boxplotvec=nan(max(numfliespercond),length(unique(Cond_Idx_PAD)));
for lcond=1:length(unique(Cond_Idx_PAD))
    nsips_boxplotvec(1:numfliespercond(lcond),lcond)=nsips_vector(Cond_Idx_PAD==lcond);
end
%% Plotting
close all
saveplot=0;
FntName='Arial';
labels2={'AA+','AA-'};
%%% Colors
[CondColors,Cmap_patch]=Colors(4);%Colors(length(Conditions));
[Color, Color_patch]=Colors(3);
Colors1=repmat([170 170 170]/255,length(Conditions),1);% Mean line color ;CondColors([1 3],:);%[0 0 0;Color(3,:)];
Colors2=newcondcolors;%Cmap_patch([1 3],:);%[[0.7 .7 .7];Color_patch(3,:)];

Colors_PAD=cell(length(unique(Cond_Idx_PAD)),1);
for lcond=1:length(unique(Cond_Idx_PAD))
    Colors_PAD{lcond,1}=Colors1(lcond,:);%Mean line
    Colors_PAD{lcond,2}=Colors2(lcond,:);%Error area
end

if saveplot==1
    FtSz=8;
    LineW=0.8;
    MkSz=1;
else
    FtSz=11;
    LineW=1.5;
    MkSz=3;
end

% paperpos=[0 0 14 14];%4x4 structure
paperpos=[0 0 16 5];%1x4 structure
figname=['FigS4_3_flyPAD microstructure ' date];
figure('Position',[2100 50 900 900],'Color','w','Name',figname,'PaperUnits',...
    'centimeters','PaperPosition',paperpos)
% AxesPositions=[0.1,0.55,.4,.4;
%     0.6,0.55,0.4,0.4;
%     0.1,0.05,0.4,0.4;
%     0.6,0.05,0.4,0.4];%4x4 structure
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
figure('Position',[50 50 800 400],'Color','w','PaperUnits','centimeters',...
    'PaperPosition',[1 1 4.5 5],'Name',['Fig2-suppl1 Cumulative Sips - VYaa,AA-,MatedYaa,Hunt,AA- '  date]);%

CumulativeFeedingEventsFig2(Events,lsubs,1,labels2,Colors_PAD,MaxSample);
font_style([],'Time (min)',{...[...Events.SubstrateLabel{lsubs}(1:end-4)
    'Cumulative number';'of sips (x1000)'},'normal',FntName,FtSz)
YLim2=get(gca,'Ylim');
set(gca, 'XTick',[0:20:60]*60*100,'XTickLabel',cellfun(@(x)num2str(x),num2cell([0:20:60]),'uniformoutput',0),...
    'YTick',[0:1000:YLim2(2)],'YTickLabel',cellfun(@(x)num2str(x),num2cell([0:1000:YLim2(2)]/1000),'uniformoutput',0))
xlim([0 MaxFrames*2])
%% Boxplot of number of sips
% plotcounter=plotcounter+1;
% subplot('Position',AxesPositions(plotcounter,:))
% xvalues=1:length(Conditions);
% IQRcolor=newcondcolors;
% mediancolor=zeros(length(Conditions),3);
% [~,lineh] = plot_boxplot_tiltedlabels(nsips_boxplotvec,cell(length(xvalues),1),xvalues,...
%                         IQRcolor,mediancolor,[.4 .4 .4],.4,FtSz,FntName,'o',1);%'k'
% stats_boxplot_tiltedlabels(nsips_boxplotvec,...
% {'NºofSips'},Conditions,xvalues,...
% 'FigS4_3C-Nofsips ',0,params,...
% 'E:\Analysis Data\Experiment ','0003','D',['cond ' num2str(Conditions)],subfolder,FtSz,FntName)
% set(gca,'xcolor','w')
% 
% font_style([],[],{'Total number';'of sips (x1000)'},'normal',FntName,FtSz)
% YLim2=get(gca,'Ylim');
% set(gca,'YTick',[0:2000:YLim2(2)],'YTickLabel',cellfun(@(x)num2str(x),num2cell([0:2000:YLim2(2)]/1000),'uniformoutput',0))

%% Box plot Number of feeding bursts
plotcounter=plotcounter+1;
subplot('Position',AxesPositions(plotcounter,:))
Boxplot_Matrix=BoxplotPASHAfun_Fig2(Events,@numel,'FeedingBurstOns',labels2,0,Colors2,BoxPlotYN,lsubs);

xvalues=1:length(Conditions);
IQRcolor=newcondcolors;
mediancolor=zeros(length(Conditions),3);
[~,lineh] = plot_boxplot_tiltedlabels(Boxplot_Matrix,cell(length(xvalues),1),xvalues,...
                        IQRcolor,mediancolor,[.4 .4 .4],.4,FtSz,FntName,'o',1);%'k'
stats_boxplot_tiltedlabels(Boxplot_Matrix,...
{'NFbursts'},Conditions,xvalues,...
'FigS4_3-NFbursts ',0,params,...
'E:\Analysis Data\Experiment ','0003','D',['cond ' num2str(Conditions)],subfolder,FtSz,FntName)
set(gca,'xcolor','w')

font_style([],[],{'Number of' ;'feeding bursts'},'normal',FntName,FtSz)
% ylim([0 35])
box off
%% Box plot Number of sips per burst
plotcounter=plotcounter+1;
subplot('Position',AxesPositions(plotcounter,:))
Boxplot_Matrix=BoxplotPASHAfun_Fig2(Events,@nanmean,'FeedingBurstnEvents',labels2,0,Colors2,BoxPlotYN,lsubs);

xvalues=1:length(Conditions);
IQRcolor=newcondcolors;
mediancolor=zeros(length(Conditions),3);
[~,lineh] = plot_boxplot_tiltedlabels(Boxplot_Matrix,cell(length(xvalues),1),xvalues,...
                        IQRcolor,mediancolor,[.4 .4 .4],.4,FtSz,FntName,'o',1);%'k'
stats_boxplot_tiltedlabels(Boxplot_Matrix,...
{'NSipsperburst'},Conditions,xvalues,...
'FigS4_3-Nofsipsperburst ',0,params,...
'E:\Analysis Data\Experiment ','0003','D',['cond ' num2str(Conditions)],subfolder,FtSz,FntName)
set(gca,'xcolor','w')

font_style([],[],{'Number of' ;'sips per burst'},'normal',FntName,FtSz)
% ylim([0 35])
box off

%% Box plot IBurstI
plotcounter=plotcounter+1;
subplot('Position',AxesPositions(plotcounter,:))
Boxplot_Matrix=BoxplotPASHAfun_Fig2(Events,@(x)(nanmean(x)./100),'FeedingBurstIBI',labels2,0,Colors2,BoxPlotYN,lsubs);

xvalues=1:length(Conditions);
IQRcolor=newcondcolors;
mediancolor=zeros(length(Conditions),3);
[~,lineh] = plot_boxplot_tiltedlabels(Boxplot_Matrix,cell(length(xvalues),1),xvalues,...
                        IQRcolor,mediancolor,[.4 .4 .4],.4,FtSz,FntName,'o',1);%'k'
stats_boxplot_tiltedlabels(Boxplot_Matrix,...
{'IBI'},Conditions,xvalues,...
'FigS4_3-IBI ',0,params,...
'E:\Analysis Data\Experiment ','0003','D',['cond ' num2str(Conditions)],subfolder,FtSz,FntName)
set(gca,'xcolor','w')

font_style([],[],{'Average Inter-Burst';'Interval (s)'},'normal',FntName,FtSz)
ylim([0 50])
box off
%% Stats of SIP and ISI durations
 load('E:\Analysis Data\Experiment 0003\FlyPAD\2016-04-22\1_12\mrep\MVYaaHuntS1_12.mat\MVYaaHuntS_1_12_Full.mat')
FtSz=10;
close all
figure('Position',[50 50 800 400],'Color','w','PaperUnits','centimeters',...
    'PaperPosition',[1 1 15 7],'Name',['FigS4-3 Boxplot SIP dur and ISI dur stats '  date]);%
Substrate=1;
BoxPlotYN=2;
nCond=max(size(Events.ConditionLabel));
    colors = distinguishable_colors(nCond+1);
    ColorsPAD=cell(size(colors,1),1);
    
    for n=1:size(colors,1)
        ColorsPAD{n}=colors(n,:);
    end
    
subplot('Position',[.15 .2 .3 .7])
stats.ISIMode{Substrate}=GetAnyEvents_ForLab_Excel_Dots(Events,@(x)(mode(x)./100),'IFI',cell(1,6),0,ColorsPAD,BoxPlotYN,Substrate);
font_style('ISI mode',[],'Inter-sip-interval (s)','normal','arial',FtSz)
ax=get(gca,'Ylim');
thandle=text(1:6,ax(1)*ones(1,6),Events.ConditionLabel);

set(thandle,'HorizontalAlignment','right','VerticalAlignment','top',...
    'Rotation',20,'FontSize',FtSz,'FontName','arial');


subplot('Position',[.65 .2 .3 .7])
stats.SipdurationsMode{Substrate}=GetAnyEvents_ForLab_Excel_Dots(Events,@(x)(mode(x)./100),'Durations',cell(1,6),0,ColorsPAD,BoxPlotYN,Substrate);
font_style('Sip durations mode',[],'Sip durations (s)','normal','arial',FtSz)
ax=get(gca,'Ylim');
thandle=text(1:6,ax(1)*ones(1,6),Events.ConditionLabel);
ylim(ax)
set(thandle,'HorizontalAlignment','right','VerticalAlignment','top',...
    'Rotation',20,'FontSize',FtSz,'FontName','arial');

%%
if saveplot==1
    savefig_withname(1,'600','png','E:\Analysis Data\Experiment ','0003','D',...
        subfolder)
    savefig_withname(0,'600','eps','E:\Analysis Data\Experiment ','0003','D',...
        'Figures')
end

