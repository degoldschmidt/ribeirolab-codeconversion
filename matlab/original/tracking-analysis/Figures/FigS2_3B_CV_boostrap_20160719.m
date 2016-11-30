%% Set bootstrap paramaters, Conditions and Tracking parameters to analyse
nReps = 100000;
alpha = .05;        %alpha value
lsubs=1;
Conditions=[6 5 1 4 3];
saveplot=0;
SubFolder_name='Total times';

%%
FntName='arial';
FtSz=10;
LnWdt=0.8;
close all
[ColorsinPaper,orderinpaper,~,IQRcolor]=ColorsPaper5cond_fun;
AllConditions=unique(params.ConditionIndex);
condtag=['cond' num2str(Conditions)];%'All cond';%'cond1 3';%
AllConditions=unique(params.ConditionIndex);
numcond=nan(length(Conditions),1);
[CondColors,Cmap_patch]=Colors(length(unique(params.ConditionIndex)));%
newcolors=nan(length(Conditions),3);
for lcond=Conditions
    numcond(lcond==Conditions)=sum(params.ConditionIndex==lcond);
    if length(Conditions)<=size(ColorsinPaper,1)%strfind([Exp_num Exp_letter],'0003D')
        newcolors(lcond==Conditions,:)=ColorsinPaper(orderinpaper==lcond,:);%ColorsFig2C(orderinpaper==lcond,:);
    else
        newcolors(lcond==Conditions,:)=CondColors(ismember(AllConditions,lcond),:);
    end
end


x=0.1;
y=0.1;
dy=0.03;
heightsubplot=1-2*y;
widthsubplot=1-1.4*x;
close all
figname=['Barplot ' condtag ' Coeff variation '];
figure('Position',[50 50 800 800],'Color','w','PaperUnits','centimeters',...
    'PaperPosition',[1 1 4 4],'Name',[figname date]);%'10minafterLagphase '
set(gca,'Position',[x y widthsubplot heightsubplot])

lcondcounter=0;
for lcond=Conditions
    lcondcounter=lcondcounter+1;
    n1 = sum(params.ConditionIndex==lcond);%sample size 1
    X=CumTimeH{1}(end,params.ConditionIndex==lcond)';
    
    myStatistic=@(x) nanstd(x)/nanmean(x);%define the statistic as the difference between medians
    
    sampStat = myStatistic(X);
    bootstrapStat = zeros(nReps,1);
    for i=1:nReps
        sampX1 = X(ceil(rand(n1,1)*n1));
        bootstrapStat(i) = myStatistic(sampX1);
    end
    
    CI = prctile(bootstrapStat,[100*alpha/2,100*(1-alpha/2)]);% Calculate the confidence interval
    %Hypothesis test: Does the confidence interval cover zero?
    % H = CI(1)>0 | CI(2)<0;% H=true if it doesn't :P
    
    display([params.LabelsShort{lcond},...
        ' mean:' num2str(nanmean(X)), ', std:' num2str(nanstd(X)),...
        ', CV:' num2str(sampStat) ', CI:' num2str(CI)])
        
    %% Plotting Stat + Confidence intervals
    hbar=bar(lcondcounter,sampStat,'FaceColor',newcolors(lcond==Conditions,:),'EdgeColor',newcolors(lcond==Conditions,:));
    hold on
    plot(lcondcounter,sampStat,'ok',...
        'LineWidth',LnWdt,'MarkerSize',5,'MarkerFaceColor','k')
    plot([lcondcounter lcondcounter],[CI(1) CI(2)],'k','LineWidth',LnWdt)
    plot([lcondcounter-0.1 lcondcounter+0.1],[CI(1) CI(1)],'k','LineWidth',LnWdt)
    plot([lcondcounter-0.1 lcondcounter+0.1],[CI(2) CI(2)],'k','LineWidth',LnWdt)
  
end

font_style([],[],{'Coefficient of';'variation'},'normal','arial',10)

set(gca,'xcolor','w')
xlim([0.25 (length(Conditions)+.5)])

if saveplot==1
    savefig_withname(1,'600','png',DataSaving_dir_temp,Exp_num,Exp_letter,...
        SubFolder_name)
    savefig_withname(0,'600','eps',DataSaving_dir_temp,Exp_num,Exp_letter,...
        'Figures')
end