%% Set bootstrap paramaters, Conditions and Tracking parameters to analyse
nReps = 10000;
alpha = .05;        %alpha value
lsubs=1;
Conditions=[4 3 8 7];%EXP 11A
params2plot=[48 88 9];%If =0, means SIPS! and it assumes you have 4 Conditions
saveplot=0;
SubFolder_name='Parameters';

%% 
FntName='arial';
FtSz=10;
LnWdt=0.8;
close all
condtag=['cond' num2str(Conditions)];%'All cond';%'cond1 3';%
[~,~,~,IQRcolor]=ColorsPaper5cond_fun;%
AllConditions=unique(params.ConditionIndex);
x=.5;
paperpos=[1 1 4 4];%[1 1 5 4];
y=0.2;%0.11 when x labels are one line, 0.18 when they are tilted labels
dy=0.03;
heightsubplot=1-1.6*y;
widthsubplot=1-1.1*x;

for lparam=params2plot
    if lparam~=0 
        figure('Position',[50 50 800 800],'Color','w','PaperUnits','centimeters',...
            'PaperPosition',paperpos,'Name',['Fig8-TbhBoxplot ' condtag ' param ' num2str(lparam) ' ' date]);%'10minafterLagphase '
    else
        figure('Position',[50 50 800 800],'Color','w','PaperUnits','centimeters',...
            'PaperPosition',paperpos,'Name',['Fig8D-TbhBoxplot sips ' date]);%'10minafterLagphase '
        SipsDeltaBootstrap_20160425
        SubFolder_name='flyPAD';
    end
    set(gca,'Position',[x y widthsubplot heightsubplot])
    hold on

    for lpaircond=1:floor(length(Conditions)/2)
        %% CI for Median
        if lparam~=0 
            %% For Tracking parameters
            lcond1=Conditions(lpaircond*2-1);
            lcond2=Conditions(lpaircond*2);
            n1 = sum(params.ConditionIndex==lcond1);%sample size 1
            n2 = sum(params.ConditionIndex==lcond2);%sample size 2

            x1 = TimeSegmentsParams{lcond1==AllConditions}(lparam).Data';% Data set 1
            x2 = TimeSegmentsParams{lcond2==AllConditions}(lparam).Data';% Data set 2
        else
            %% For SIP data
            lcond1=ConditionsFlyPAD(lpaircond*2-1);
            lcond2=ConditionsFlyPAD(lpaircond*2);
            n1 = sum(Cond_Idx_PAD==lcond1);%sample size 1
            n2 = sum(Cond_Idx_PAD==lcond2);%sample size 2

            x1 = nsips_vector(Cond_Idx_PAD==lcond1);% Data set 1
            x2 = nsips_vector(Cond_Idx_PAD==lcond2);% Data set 2
            
        end
        myStatistic=@(x1,x2) median(x2)-median(x1);%define the statistic as the difference between medians
        
        sampStat = myStatistic(x1,x2);
        bootstrapStat = zeros(nReps,1);
        for i=1:nReps
            sampX1 = x1(ceil(rand(n1,1)*n1));
            sampX2 = x2(ceil(rand(n2,1)*n2));
            bootstrapStat(i) = myStatistic(sampX1,sampX2);
        end
        
        CI = prctile(bootstrapStat,[100*alpha/2,100*(1-alpha/2)]);% Calculate the confidence interval
        %Hypothesis test: Does the confidence interval cover zero?
        % H = CI(1)>0 | CI(2)<0;% H=true if it doesn't :P
        
        display(sampStat)
        display(CI)
        % display(H)
        
        %% Plotting Stat + Confidence intervals
        hbar=bar(lpaircond,sampStat,'FaceColor',IQRcolor(lpaircond,:),'EdgeColor','none');
        hold on
        plot(lpaircond,sampStat,'ok',...
            'LineWidth',LnWdt,'MarkerSize',5,'MarkerFaceColor','k')
        plot([lpaircond lpaircond],[CI(1) CI(2)],'k','LineWidth',LnWdt)
        plot([lpaircond-0.1 lpaircond+0.1],[CI(1) CI(1)],'k','LineWidth',LnWdt)
        plot([lpaircond-0.1 lpaircond+0.1],[CI(2) CI(2)],'k','LineWidth',LnWdt)
%         errorbar(lpaircond,sampStat,sampStat-CI(1),CI(2)-sampStat,'or',...
%             'LineWidth',2,'MarkerSize',5)
        %% Labels
        if lparam~=0 
            [y_label]=LabelsParamsPaper(TimeSegmentsParams,lparam);
            y_labelnew=y_label;
            if lparam~=88
                y_labelnew{1}=['\Delta( ' y_label{1}];
                y_labelnew{2}=[y_label{2} ' )'];
            else
                y_labelnew{1}=['\Delta[ ' y_label{1}];

                y_labelnew{3}=[y_label{3} ' ]'];
            end
        else
            y_labelnew={'\Delta( Total number';'of yeast sips )'};
        end
        font_style([],[],y_labelnew,'normal',FntName,FtSz)
        set(gca,'xcolor','w')
        xlim([0.5 2.5])
    end
end
if saveplot==1
    savefig_withname(1,'600','png',DataSaving_dir_temp,Exp_num,Exp_letter,...
        SubFolder_name)
    savefig_withname(0,'600','eps',DataSaving_dir_temp,Exp_num,Exp_letter,...
        'Figures')
end