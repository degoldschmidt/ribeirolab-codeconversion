%% General FlyPAD Experiment Info
% clc 
% clear all
% close all
% load('E:\Analysis Data\Experiment 0003\FlyPAD\1_12 Matedonly\1-12_Mated_Fulldata.mat','Events')
% load('E:\Analysis Data\Experiment 0003\Variables\Fig1 20-Aug-2015.mat','CumTimeHR0506','DurInHR0506','paramsR05R06')
% 
Conditions=[6 4 5 1 3];% Must be in same order as ColorsinPaper!
lsubs=1;%yeast
paramsR05R06.Subs_Numbers=[1 2];
FtSz=8;%20;
FntName='arial';
LineW=0.8;
MaxSample=360000;
MaxFrames=floor(MaxSample/2);%
% Channels_num=[1:2:64;2:2:64];%[Yeast;Sucrose];
% % Dur=320000;
% MaxSample=360000;
% BoxPlotYN=2;
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

% numfliespercond=nan(length(unique(Cond_Idx_PAD)),1);
% for lcond=1:length(unique(Cond_Idx_PAD))
%     numfliespercond(lcond)=sum(Cond_Idx_PAD==lcond);
% end
% 
% nsips_boxplotvec=nan(max(numfliespercond),length(unique(Cond_Idx_PAD)));
% for lcond=1:length(unique(Cond_Idx_PAD))
%     nsips_boxplotvec(1:numfliespercond(lcond),lcond)=nsips_vector(Cond_Idx_PAD==lcond);
% end
%% Plotting
close all
saveplot=1;
FntName='Arial';
labels2={'AA+','AA-'};
%%% Colors
% % % [CondColors,Cmap_patch]=Colors(4);%Colors(length(Conditions));
% % % [Color, Color_patch]=Colors(3);
% % % Colors1=[0 0 0;170 170 170]/255;% Mean line color ;CondColors([1 3],:);%[0 0 0;Color(3,:)];
% % % Colors2=newcondcolors;%Cmap_patch([1 3],:);%[[0.7 .7 .7];Color_patch(3,:)];
% % % 
% % % Colors_PAD=cell(length(unique(Cond_Idx_PAD)),1);
% % % for lcond=1:length(unique(Cond_Idx_PAD))
% % %     Colors_PAD{lcond,1}=Colors1(lcond,:);%Mean line
% % %     Colors_PAD{lcond,2}=Colors2(lcond,:);%Error area
% % % end

% close all
% x=0.04;%0.2;%
% y=0.22;
% dy=0.03;
% heightsubplot=1-1.3*y;
% widthsubplot=1-2.45*x;
% lcondcounter=0;
% for lcond=Conditions
%     lcondcounter=lcondcounter+1;
% fig=figure('Position',[50 50 800 800],'Color','w','PaperUnits','centimeters',...
%     'PaperPosition',[1 1 3 3.5],'Name',['Fig2-suppl Cumulative sips - ' params.LabelsShort{lcond} ' ' date]);%
% set(gca,'Position',[x y widthsubplot heightsubplot])
% hold on
% 
% %% Cumulative number of sips
% 
% CumulativeFeedingEventsFig2(Events,lsubs,1,labels2,Colors_PAD,MaxSample,end);
% font_style([],'Time (min)',{...[...Events.SubstrateLabel{lsubs}(1:end-4)
%     'Cumulative number';['of sips ' params.Subs_Names{lsubs} ' (x1000)']},'normal',FntName,FtSz)
% YLim2=get(gca,'Ylim');
% set(gca, 'XTick',[0:20:60]*60*100,'XTickLabel',cellfun(@(x)num2str(x),num2cell([0:20:60]),'uniformoutput',0),...
%     'YTick',[0:1000:YLim2(2)],'YTickLabel',cellfun(@(x)num2str(x),num2cell([0:1000:YLim2(2)]/1000),'uniformoutput',0))
% xlim([0 MaxFrames*2])
% end
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
% 'Fig3C-Nofsips ',0,paramsR05R06,...
% 'E:\Analysis Data\Experiment ','0003','D',['cond ' num2str(Conditions)],'Total times',FtSz,FntName)
% set(gca,'xcolor','w')
% 
% font_style([],[],{'Total number';'of ' params.Subs_Names{lsubs} ' sips (x1000)'},'normal',FntName,FtSz)
% YLim2=get(gca,'Ylim');
% set(gca,'YTick',[0:2000:YLim2(2)],'YTickLabel',cellfun(@(x)num2str(x),num2cell([0:2000:YLim2(2)]/1000),'uniformoutput',0))

%% Plotting Box plots of Total time of Yeast Head micromovement (YHmm)
% plotcounter=plotcounter+1;
% subplot('Position',AxesPositions(plotcounter,:))
% 
% lsubs=2;
% Conditions=[1 3];%3;5
% save_plot=0;
% close all
% x=0.35;%0.18 when ylabels are three lines, 0.13 for single line ylabels
% y=0.2;%0.11 when x labels are one line, 0.18 when they are tilted labels
% dy=0.03;
% heightsubplot=1-1.6*y;
% widthsubplot=1-1.2*x;
% Labelsmergedshort={'AA+';'AA-'};%{'V AA+b';'V AA-';'M AA+b';'M AA+u';'M AA-'};%{'Yeast';'Sucrose'};%%
% figure('Position',[50 50 800 800],'Color','w','PaperUnits','centimeters',...
%     'PaperPosition',[1 1 4 3],'Name',['Fig2C Boxplot Hmm Ttimes - ' params.Subs_Names{lsubs} ' ' date]);%
% set(gca,'Position',[x y widthsubplot heightsubplot])
% clear X
% X=nan(length(Conditions),2);
% for lcondcounter=1:length(Conditions)
%     X(:,lcondcounter)=sum(CumTimeH{lsubs}(:,params.ConditionIndex==Conditions(lcondcounter)))/50/60;
% end
% 
% [~,lineh] = plot_boxplot_tiltedlabels(X,Labelsmergedshort,1:2,...
%     IQRcolor,mediancolor,[.4 .4 .4],.4,FtSz,FntName,'o');%'k'
% font_style([],[],{params.Subs_Names{lsubs};'micromovements';'total time (min)'},'normal',FntName,FtSz)
% MergedConditions=1:2;
% stats_boxplot_tiltedlabels_Fig2B(X,...
%     {'Total ' [params.Subs_Names{lsubs}] ' Hmm'},MergedConditions,1:2,...
%     ['Fig2C Boxplot Hmm Ttimes '],0,params,...
%     DataSaving_dir_temp,Exp_num,Exp_letter,num2str(Conditions),'Total times',FtSz,FntName,Labelsmergedshort);
% ylim([0 25])
% xlim([0.5 (length(MergedConditions)+.5)])
% if save_plot==1
%     savefig_withname(1,'600','png',DataSaving_dir_temp,Exp_num,Exp_letter,...
%         'Total times')
% end

