%% General FlyPAD Experiment Info
clc 
clear all
close all
load('E:\Analysis Data\Experiment 0003\FlyPAD\1_12 Matedonly\1-12_Mated_Fulldata.mat','Events')
load('E:\Analysis Data\Experiment 0003\Variables\DurInHR05R06 27-Jan-2016.mat','CumTimeHR05R06','DurInHR05R06','paramsR05R06')
% % % save('E:\Analysis Data\Experiment 0003\Variables\DurInHR05R06 27-Jan-2016.mat','CumTimeHR05R06','DurInHR05R06','paramsR05R06')
save_plot=1;
Conditions=[1 3];
lsubs=2;%yeast
% % paramsR05R06.Subs_Numbers=[1 2];
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

[ColorsFig2C,orderinpaper]=ColorsPaper5cond_fun;
newcondcolors=nan(length(Conditions),3);
for lcond=Conditions
    if length(Conditions)<=size(ColorsFig2C,1)
        newcondcolors(lcond==Conditions,:)=ColorsFig2C(orderinpaper==lcond,:);%
    else
        newcondcolors(lcond==Conditions,:)=CondColors(ismember(unique(paramsR05R06.ConditionIndex),lcond),:);
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
FntName='Arial';
labels2={'AA+','AA-'};
%%% Colors
[CondColors,Cmap_patch]=Colors(4);%Colors(length(Conditions));
[Color, Color_patch]=Colors(3);
Colors1=[0 0 0;0 0 0]/255;% Mean line color ;CondColors([1 3],:);%[0 0 0;Color(3,:)];
Colors2=newcondcolors;%Cmap_patch([1 3],:);%[[0.7 .7 .7];Color_patch(3,:)];

Colors_PAD=cell(length(unique(Cond_Idx_PAD)),1);
for lcond=1:length(unique(Cond_Idx_PAD))
    Colors_PAD{lcond,1}=Colors1(lcond,:);%Mean line
    Colors_PAD{lcond,2}=Colors2(lcond,:);%Error area
end

FtSz=8;
    LineW=0.8;
    MkSz=1;

%%
% paperpos=[0 0 14 14];%4x4 structure
paperpos=[0 0 14 5];%1x4 structure
figname=['Fig2BC_flyPAD sips and micromov - ' paramsR05R06.Subs_Names{lsubs} ' ' date];
figure('Position',[2100 50 900 900],'Color','w','Name',figname,'PaperUnits',...
    'centimeters','PaperPosition',paperpos)
% AxesPositions=[0.1,0.55,.4,.4;
%     0.6,0.55,0.4,0.4;
%     0.1,0.05,0.4,0.4;
%     0.6,0.05,0.4,0.4];%4x4 structure
cols=3;
% x=0.1;y=0.2;dh=0.15;w=(1-3*dh-x)/(3+0.2);h=3*w;
x=0.1;y=0.2;dh=0.13;w=.15;h=3*.1875;
AxesPositions=[x,y,w*1.2,h;
    x+w*1.2+dh,y,w,h;
    x+w*2.2+2*dh,y,w,h;
    x+w*3.2+3*dh,y,w,h];%1x4 structure

plotcounter=0;

%% Cumulative head mm
MaxSample=360000;
MaxFrames=floor(MaxSample/2);%

%% Cumulative number of sips
plotcounter=plotcounter+1;
subplot('Position',AxesPositions(plotcounter,:))

CumulativeFeedingEventsFig2(Events,lsubs,1,labels2,Colors_PAD,MaxSample);
font_style([],'Time (min)',{...[...Events.SubstrateLabel{lsubs}(1:end-4)
    'Cumulative number';['of ' paramsR05R06.Subs_Names{lsubs} ' sips (x1000)']},'normal',FntName,FtSz)
YLim2=get(gca,'Ylim');
set(gca, 'XTick',[0:20:60]*60*100,'XTickLabel',cellfun(@(x)num2str(x),num2cell([0:18:60]),'uniformoutput',0))
if lsubs==1
    set(gca,...
    'YTick',[0:1000:YLim2(2)],'YTickLabel',cellfun(@(x)num2str(x),num2cell([0:1000:YLim2(2)]/1000),'uniformoutput',0))
else
    set(gca,...
    'YTick',[0:200:YLim2(2)],'YTickLabel',cellfun(@(x)num2str(x),num2cell([0:200:YLim2(2)]/1000),'uniformoutput',0))
end
xlim([0 MaxFrames*2])

%% Boxplot of number of sips
Labelsmergedshort={'AA+';'AA-'};
plotcounter=plotcounter+1;
subplot('Position',AxesPositions(plotcounter,:))
xvalues=1:length(Conditions);
IQRcolor=newcondcolors;
mediancolor=zeros(length(Conditions),3);
[~,lineh] = plot_boxplot_tiltedlabels(nsips_boxplotvec,Labelsmergedshort,xvalues,...
                        IQRcolor,mediancolor,[.4 .4 .4],.4,FtSz,FntName,'o',1);%'k'
stats_boxplot_tiltedlabels(nsips_boxplotvec,...
{'NºofSips'},Conditions,xvalues,...
['Fig2B-Nofsips ' paramsR05R06.Subs_Names{lsubs}],0,paramsR05R06,...
'E:\Analysis Data\Experiment ','0003','D',['cond ' num2str(Conditions)],'Total times',FtSz,FntName)
set(gca,'xcolor','w')
if lsubs==1, ylim([0 10000]); else ylim([0 800]), end
    
font_style([],[],{'Total number';['of ' paramsR05R06.Subs_Names{lsubs} ' sips (x1000)']},'normal',FntName,FtSz)
YLim2=get(gca,'Ylim');
if lsubs==1
    set(gca,'YTick',[0:2000:YLim2(2)],'YTickLabel',cellfun(@(x)num2str(x),num2cell([0:2000:YLim2(2)]/1000),'uniformoutput',0))
else
    set(gca,'YTick',[0:200:YLim2(2)],'YTickLabel',cellfun(@(x)num2str(x),num2cell([0:200:YLim2(2)]/1000),'uniformoutput',0))
end

%% Plotting Box plots of Total time of Yeast Head micromovement (YHmm)
plotcounter=plotcounter+1;
subplot('Position',AxesPositions(plotcounter,:))



numcond=nan(length(Conditions),1);
lcondcounter=0;
for lcond=Conditions
    lcondcounter=lcondcounter+1;
    numcond(lcondcounter)=sum(paramsR05R06.ConditionIndex==lcond);
end

clear X
X=nan(max(numcond),length(Conditions));
for lcondcounter=1:length(Conditions)
    X(1:numcond(lcondcounter),lcondcounter)=sum(CumTimeHR05R06{lsubs}(:,paramsR05R06.ConditionIndex==Conditions(lcondcounter)))/50/60;
end

[~,lineh] = plot_boxplot_tiltedlabels(X,Labelsmergedshort,1:length(Conditions),...
    IQRcolor,mediancolor,[.4 .4 .4],.4,FtSz,FntName,'o',1);%'k'
font_style([],[],{paramsR05R06.Subs_Names{lsubs};'micromovements';'total time (min)'},'normal',FntName,FtSz)
set(gca,'xcolor','w')

MergedConditions=1:length(Conditions);
stats_boxplot_tiltedlabels(X,...
    {['Total ' paramsR05R06.Subs_Names{lsubs} ' Hmm']},Conditions,1:length(Conditions),...
    ['Fig2C Boxplot Hmm Ttimes '],0,paramsR05R06,...
    'E:\Analysis Data\Experiment ',Exp_num,Exp_letter,['cond ' num2str(Conditions)],'Total times',FtSz,FntName);
if lsubs==1,ylim([0 55]);else ylim([0 4]);end
% xlim([0.5 (length(MergedConditions)+.5)])
if save_plot==1
    savefig_withname(1,'600','png','E:\Analysis Data\Experiment ',Exp_num,Exp_letter,...
        'Total times')
end

