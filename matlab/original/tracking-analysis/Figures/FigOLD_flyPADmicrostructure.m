%% General FlyPAD Experiment Info
clc 
clear all
close all
load('E:\Analysis Data\Experiment 0003\FlyPAD\1_12 Matedonly\1-12_Mated_Fulldata.mat','Events')
load('E:\Analysis Data\Experiment 0003\Variables\Fig1 20-Aug-2015.mat','CumTimeHR0506','DurInHR0506','paramsR05R06')
Channels_num=[1:2:64;2:2:64];%[Yeast;Sucrose];
% Dur=320000;
MaxSample=360000;
BoxPlotYN=2;

totalnumflies_FlyPAD=size(Events.Ons,1)*size(Events.Ons,2)/2;
DurIn_FlyPAD=cell(totalnumflies_FlyPAD,1);
paramsFlyPAD.ConditionIndex=nan(1,totalnumflies_FlyPAD);
paramsFlyPAD.framerate=100;
paramsFlyPAD.Subs_Names=Events.SubstrateLabel';
paramsFlyPAD.LabelsShort=Events.ConditionLabel';
%% FlyPAD DATA - Number of sips on yeast
lsubs=1;%yeast
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
Colors1=CondColors([1 3],:);%[0 0 0;Color(3,:)];
Colors2=Cmap_patch([1 3],:);%[[0.7 .7 .7];Color_patch(3,:)];

Colors_PAD=cell(length(unique(Cond_Idx_PAD)),1);
for lcond=1:length(unique(Cond_Idx_PAD))
    Colors_PAD{lcond,1}=Colors1(lcond,:);
    Colors_PAD{lcond,2}=Colors2(lcond,:);
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
%%
figname=['Fig2-flyPAD microstructure ' date];
figure('Position',[2100 50 1400 930],'Color','w','Name',figname,'PaperUnits',...
    'centimeters','PaperPosition',[5.5 9 10 12])
%% Cumulative head mm
MaxSample=360000;
MaxFrames=floor(MaxSample/2);%
Conditions=[1 3];
lsubs=1;
subplot(3,2,1)
hold on
h=nan(length(Conditions),1);
for lcond=Conditions
       
    [h(lcond==Conditions),CumTimes_mean]=plot_Cumulative(CumTimeHR0506,lcond,lsubs,MaxFrames,paramsR05R06,[],FtSz,FntName,CondColors(lcond,:),Cmap_patch(lcond,:));
    %             ylims=get(gca,'YLim');
    if lsubs==1,ylims=[0 25];
    elseif lsubs==2, ylims=[0 1];
    end
    ylabel({'Cumulative Time of';'Head microm. (min)'})
end
axis([0 ceil(MaxFrames/50/60) 0 ylims(2)])
set(gca, 'XTick',[0:20:60],'XTickLabel',cellfun(@(x)num2str(x),num2cell([0:20:60]),'uniformoutput',0))
%% Boxplots Total time Head micromovement
subplot(3,2,2)
hold on
var_label='Total duration';
if lsubs==1,y_label={'Total duration of';'Head microm. (min)'};
else y_label=[];
end
numcond=nan(length(Conditions),1);
for lcondcounter=1:length(Conditions)
    numcond(lcondcounter)=sum(paramsR05R06.ConditionIndex==Conditions(lcondcounter));
end

X_Tr=nan(max(numcond),length(Conditions));

lcondcounter=0;
for lcond=Conditions
    lcondcounter=lcondcounter+1;
    X_Tr(1:numcond(lcondcounter),lcond==Conditions)=sum(CumTimeHR0506{lsubs}(1:MaxFrames,paramsR05R06.ConditionIndex==lcond))'/50/60;
end
plot_boxplot_Fig2(X_Tr,labels2,...
    [1 2],Colors2,zeros(2,3),...
        'k',.4,FtSz,FntName,'.');%
font_style([],[],y_label,'normal',FntName,FtSz)
%% Cumulative number of sips
subplot(3,2,3);% FlyPAD at bottom
CumulativeFeedingEventsFig2(Events,lsubs,1,labels2,Colors_PAD,MaxSample);
font_style([],'Time (min)',{...[...Events.SubstrateLabel{lsubs}(1:end-4)
    'Cumulative number';'of sips (x1000)'},'normal',FntName,FtSz)
YLim2=get(gca,'Ylim');
set(gca, 'XTick',[0:20:60]*60*100,'XTickLabel',cellfun(@(x)num2str(x),num2cell([0:20:60]),'uniformoutput',0),...
    'YTick',[0:1000:YLim2(2)],'YTickLabel',cellfun(@(x)num2str(x),num2cell([0:1000:YLim2(2)]/1000),'uniformoutput',0))
xlim([0 MaxFrames*2])
%% Boxplot of number of sips
subplot(3,2,4)
xvalues=[1 2];
[~,lineh] = plot_boxplot_Fig2(nsips_boxplotvec,labels2,xvalues,...
        Colors2,zeros(2,3),...
        'k',.4,FtSz,FntName,'.');%[.5 .5 .5]
% set(lineh,'LineWidth',2)
font_style([],[],{'Total number';'of sips (x1000)'},'normal',FntName,FtSz)
YLim2=get(gca,'Ylim');
set(gca,'YTick',[0:2000:YLim2(2)],'YTickLabel',cellfun(@(x)num2str(x),num2cell([0:2000:YLim2(2)]/1000),'uniformoutput',0))

%% Box plot Number of sips per burst
subplot(3,2,5)
BoxplotPASHAfun(Events,@nanmean,'FeedingBurstnEvents',labels2,0,Colors2,BoxPlotYN,lsubs);
font_style([],[],{'Number of' ;'sips per burst'},'normal',FntName,FtSz)
% ylim([0 35])
box off

%% Box plot IBurstI
subplot(3,2,6)
BoxplotPASHAfun(Events,@(x)(nanmean(x)./100),'FeedingBurstIBI',labels2,0,Colors2,BoxPlotYN,lsubs);
font_style([],[],{'Mean IBI';'of of feeding bursts (s)'},'normal',FntName,FtSz)
ylim([0 35])
box off
%%
if saveplot==1
  savefig_withname(0,'600','png','E:\Analysis Data\Experiment ','0003','A',...
    'Figures')
end

% export_fig('E:\Analysis Data\Experiment 0003\Plots\Figures\Fig2test', '-eps')