%% General initial parameters
FtSz=8;%20;
FntName='arial';
LineW=0.8;
ColorsFig2C=ColorsPaper5cond_fun;

Conditions=[5 1 3];%[6 4 5 1 3];%[1 3];%[2 4 1 3];%EXP 4A 
condtag='cond5 1 3';%'All cond';%'cond1 3';%
orderinpaper=[6 4 5 1 3 2];%[2 4 1 3];%EXP 4A 
LabelsShortPaper={'Virgin, AA+';'Virgin, AA-';'Mated, AA+';'Mated, AA+ suboptimal';'Mated, AA-'};
%%
nsamples=1000;
lparam=46;%Total Y micromov. 79; %Rate of engagement
y_label=TimeSegmentsParams{1}(lparam).YLabel;
AllConditions=unique(params.ConditionIndex);
X=cell(length(Conditions),1);
for lcond=Conditions
X{Conditions==lcond}=TimeSegmentsParams{AllConditions==lcond}(lparam).Data;
end
close all
bootstat=cell(length(Conditions),1);
bootsample=cell(length(Conditions),1);
StatX=cell(length(Conditions),1);
lcondcounter=0;
for lcond=Conditions
    lcondcounter=lcondcounter+1;
    [~,bootsample{lcond==Conditions}] = ...
        bootstrp(nsamples, [], X{lcond==Conditions});
    newbootsample=nan(length(X{lcond==Conditions}),nsamples);
    for l=1:nsamples
        newbootsample(:,l)=X{lcond==Conditions}(bootsample{lcond==Conditions}(:,l));
    end
    StatX{lcond==Conditions}=nanmedian(newbootsample);%row vector with nsamples of the stat
     
end
%%
save_plot=1;
subfolder='Parameters';
close all
paperpos=[1 1 10 10];
figure('Position',[50 50 800 800],'Color','w','PaperUnits','centimeters',...
        'PaperPosition',paperpos,'Name',['Bootstrap example ' condtag ' param ' num2str(lparam) ' ' date]);%
    set(gca,'Position',[x y widthsubplot heightsubplot])
clear h NewLabels
lcondcounter=0;
for lcond=Conditions    
    lcondcounter=lcondcounter+1;
    [n,c]=hist(StatX{lcond==Conditions},20);
    bh=bar(c,n,'Facecolor',ColorsFig2C(orderinpaper==lcond,:),'EdgeColor',[.5 .5 .5]);
    set(get(bh,'Children'),'FaceAlpha',0.2)
    [counts,bins_x]=hist(StatX{lcond==Conditions},...
        0:max(StatX{lcond==Conditions})/99:max(StatX{lcond==Conditions}));
    ICdo=bins_x(find(cumsum(counts/sum(counts))>=0.025, 1,'first'));
    ICup=bins_x(find(cumsum(counts/sum(counts))>=0.975, 1,'first'));
    hold on
    h(lcondcounter)=plot([ICdo ICdo],[0 300],'-','color',ColorsFig2C(orderinpaper==lcond,:));
    plot([ICup ICup],[0 300],'-','color',ColorsFig2C(orderinpaper==lcond,:),'LineWidth',LineW)
    plot([ICdo ICdo],[0 300],'-','color',ColorsFig2C(orderinpaper==lcond,:),'LineWidth',LineW)
    NewLabels{lcondcounter}=LabelsShortPaper{orderinpaper==lcond};
end
legend(h,NewLabels)
legend('boxoff')
box off

if save_plot==1
    savefig_withname(1,'600','png',DataSaving_dir_temp,Exp_num,Exp_letter,...
        subfolder)
end
%% Comparing CI calculated by bootci vs cumsum 
% nsamples=1000;
% Conditions=5%[5 1 3];
% lparam=79; %Rate of engagement
% y_label=TimeSegmentsParams{1}(lparam).YLabel;
% AllConditions=unique(params.ConditionIndex);
% X=cell(length(Conditions),1);
% for lcond=Conditions
% X{Conditions==lcond}=TimeSegmentsParams{AllConditions==lcond}(lparam).Data;
% end
% close all
% bootstat=cell(length(Conditions),1);
% bootsample=cell(length(Conditions),1);
% lcondcounter=0;
% for lcond=Conditions
%     lcondcounter=lcondcounter+1;
% %     hold on
% %     plot(lcondcounter,X{lcond==Conditions},'o')
%     subplot(length(Conditions),lcondcounter,1)
%     [bootstat{lcond==Conditions},bootsample{lcond==Conditions}] = ...
%         bootstrp(nsamples, @nanmedian, X{lcond==Conditions});
%     hold on
%     %%% sanity check to confirm that it's the same calculation: 
%     %%% bootstat{lcond==Conditions} is same as newbootsample
%     plot(1,bootstat{lcond==Conditions},'ob')
%     newbootsample=nan(26,nsamples);
%     for l=1:nsamples
%         newbootsample(:,l)=X{lcond==Conditions}(bootsample{lcond==Conditions}(:,l));
%     end
%     plot(1,nanmedian(newbootsample),'*r')
%     legend('MATLAB','median')
%     
% end
% %%
% close all
% [n,c]=hist(bootstat{lcond==Conditions},20);
% bar(c,n);
% [counts,bins_x]=hist(bootstat{lcond==Conditions},0:max(bootstat{lcond==Conditions})/99:max(bootstat{lcond==Conditions}));
% ICdo=bins_x(find(cumsum(counts/sum(counts))>=0.025, 1,'first'));
% ICup=bins_x(find(cumsum(counts/sum(counts))>=0.975, 1,'first'));
% hold on
% h1=plot([ICdo ICdo],[0 300],'-r');
% plot([ICup ICup],[0 300],'-r')
% 
% ci = bootci(nsamples,@nanmedian,X{lcond==Conditions});
% h2=plot([ci(1) ci(1)],[0 300],'-b');
% plot([ci(2) ci(2)],[0 300],'-b')
% legend([h1 h2],{'CI cumsum','CI bootci'})
%%
% % function [CI] = IC_Median_Cumtimes(Seq,Subs_Names,Conditions,params)
% %UNTITLED Summary of this function goes here
% %   Detailed explanation goes here
% % Nut_Geom_Pop=cumsum([Seq==1 Seq==2 Seq==3])./params.framerate;%(frames,subs,flies)
% 
close all
nReps = 10000;
alpha = .05;        %alpha value
lsubs=1;

figure
hold on
lcondcounter=0;

for lcond=1%Conditions
    lcondcounter=lcondcounter+1;
%% CI for Median
n1 =sum(params.ConditionIndex==lcond);            %sample size 1
x = randn(n1,1);%generate fake data by drawing from normal distributionssqueeze(Nut_Geom_Pop(end,lsubs,params.ConditionIndex==lcond));%

myStatistic = @(x) median(x);%@(x1,x2) mean(x1)-mean(x2);%define the statistic as the difference between means

sampStat = myStatistic(x);
bootstrapStat = zeros(nReps,1);
for i=1:nReps
    sampX1 = x(ceil(rand(n1,1)*n1));
    bootstrapStat(i) = myStatistic(sampX1);
end

CI = prctile(bootstrapStat,[100*alpha/2,100*(1-alpha/2)]);% Calculate the confidence interval
%Hypothesis test: Does the confidence interval cover zero?
% H = CI(1)>0 | CI(2)<0;% H=true if it doesn't :P

display(sampStat)
display(CI)
% display(H)

%% Plotting Median + Box plot + Confidence intervals
    plot_boxplot_tiltedlabels(x,cell(1,1),lcondcounter);
    hold on
    errorbar(lcondcounter+1,sampStat,sampStat-CI(1),CI(2)-sampStat,'or','LineWidth',2,'MarkerSize',5)
    
end
xlim([0 3])
% set(gca,'XTick',[1:length(Conditions)],'XTickLabel',params.LabelsShort(Conditions),'XLim',[0 lcondcounter])
