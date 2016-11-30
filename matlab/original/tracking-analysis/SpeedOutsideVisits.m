%% Average Speed outside visits distribution %%
flies_idx=params.IndexAnalyse;

Speed_OutVisits_all=nan(length(flies_idx),1);
flycounter=0;
for lfly=flies_idx
    display(lfly)
    flycounter=flycounter+1;
    logicaloutsidevisits=~(Binary_V(:,lfly)');

    if sum(logicaloutsidevisits)~=0
        Speed_temp=Steplength_Sm_c{lfly}(1:params.MinimalDuration);
        Speed_NoVisits=Speed_temp(logicaloutsidevisits)*params.px2mm*params.framerate;
        Speed_OutVisits_all(flycounter)=nanmean(Speed_NoVisits);%mm/s
    end
end
%% Hist of speed outside visits (Whole Assay)
close all
saveplot=0;
FntName='arial';
FtSz=8;
figure('Position',[100 50 700 930],'Color','w','Name',['Speed outside visits hist' date])
lcondcounter=0;
for lcond=Conditions
    lcondcounter=lcondcounter+1;
    subplot(2,ceil(length(Conditions)/2),lcondcounter)
    [counts,centers]=hist(Speed_OutVisits_all(params.ConditionIndex==lcond),[1:12]);
    bar(centers,counts/sum(counts))
    font_style(params.Labels{lcond},'Speed outside visits (mm/s)',...
        'Ocurrences, normalised','normal',FntName,FtSz)
    axis([0 12.5 0 0.35])
end
if (saveplot==1)
    savefig_withname(1,'600','png',DataSaving_dir_temp,Exp_num,Exp_letter,'Activity')
end
%% Hist of speed outside visits (Time Segments)
ranges=[1 30000;30001 90000;90001 150000;150001 210000;210001 270000;270001 345000];%

Speed_OutVisits_TimeSegments=nan(length(flies_idx),size(ranges,1));
flycounter=0;
for lfly=flies_idx
    display(lfly)
    flycounter=flycounter+1;
    for lrange=1:size(ranges,1)
        logicaloutsidevisits=~(Binary_V(ranges(lrange,1):ranges(lrange,2),lfly)');

        if sum(logicaloutsidevisits)~=0
            Speed_temp=Steplength_Sm_c{lfly}(ranges(lrange,1):ranges(lrange,2));
            Speed_NoVisits=Speed_temp(logicaloutsidevisits)*params.px2mm*params.framerate;
            Speed_OutVisits_TimeSegments(flycounter,lrange)=nanmean(Speed_NoVisits);%mm/s
        end
    end
end
%% PLOT Hist of speed outside visits (Time Segments)
% close all
saveplot=1;
FntName='arial';
FtSz=6;
figure('Position',[100 50 1200 930],'Color','w','Name',['Speed outside visits hist, Time Segments ' date])
Colors_cond=Colors(length(Conditions));
plotcounter=0;
lcondcounter=0;
for lcond=Conditions
    lcondcounter=lcondcounter+1;
    for lrange=1:size(ranges,1)
        plotcounter=plotcounter+1;
        subplot(length(Conditions),size(ranges,1),plotcounter)
        range=ranges(lrange,1):ranges(lrange,2);
        [counts,centers]=hist(Speed_OutVisits_TimeSegments(params.ConditionIndex==lcond,lrange),[1:12]);
        bh=bar(centers,counts/sum(counts),'FaceColor',Colors_cond(lcondcounter,:));
%         set(bh,'FaceColor
        if lrange==1
        font_style([num2str(floor(range(1)/params.framerate/60)) ' - ',...
            num2str(floor(range(end)/params.framerate/60)) ' min'],...
            'Speed outside visits (mm/s)',...
            {params.Labels{lcond};'Ocurrences, normalised'},'normal',FntName,FtSz)
        end
        if lcondcounter==1
        title([num2str(floor(range(1)/params.framerate/60)) ' - ',...
            num2str(floor(range(end)/params.framerate/60)) ' min'],'FontSize',FtSz,'FontName',FntName)
        end
        set(gca,'FontSize',FtSz,'FontName',FntName)
        axis([0 12.5 0 0.45])
    end
end
if (saveplot==1)
    savefig_withname(1,'600','png',DataSaving_dir_temp,Exp_num,Exp_letter,'Activity')
end
%% Correlation with Total time (Total head micromovement) on Yeast - Each condition
close all
saveplot=0;
FntName='arial';
FtSz=8;

TotalTimesHmm=sum(CumTimeH{1})/params.framerate/60;%min
clusterdividers=[14;105;64;68];%Mated AA+ and Virgin AA+ flipped

figure('Position',[2100 50 1200 930],'Color','w','Name',['Speed out v correl T t Headmm per cond ' date])
Colors_cond=Colors(length(Conditions));
Rsq=nan(length(Conditions),1);
lcondcounter=0;
for lcond=Conditions
    lcondcounter=lcondcounter+1;
    display(['------ ' params.LabelsShort{lcond} ' -----'])
    if (lcond==1)||(lcond==2)
        Idx_sort=flipud(Flies_cluster{lcondcounter});
    else
        Idx_sort=Flies_cluster{lcondcounter};
    end
    rovers_Idx=Idx_sort(1:find(Idx_sort==clusterdividers(lcondcounter)));
    subplot(2,ceil(length(Conditions)/2),lcondcounter)
    y=TotalTimesHmm(params.ConditionIndex==lcond)';
    x=Speed_OutVisits_all(params.ConditionIndex==lcond);
    plot(x,y,'o',...
        'MarkerEdgeColor',[.7 .7 .7],'MarkerFaceColor',Colors_cond(lcondcounter,:));
    axis([0 14 0 60])
    font_style(params.Labels{lcond},'Speed outside visits (mm/s)',...
        'Total time on Yeast -Head microm- (min)','normal',FntName,FtSz)
    hold on
    for lrover=rovers_Idx'
        plot(Speed_OutVisits_all(lrover),TotalTimesHmm(lrover),'o',...
            'MarkerEdgeColor',[.7 .7 .7],'MarkerFaceColor','w','MarkerSize',3);
    end
    %% Linear Regression TYPE 1%%
    statopts=statset('Display','final');% If you specify 'iter', output is
    %%% displayed at each iteration. If you specify 'final', output is
    %%% displayed after the final iteration.
    fitparams = nlinfit(x,y,...
        @StraightLine,[1 0],statopts);
    Slope=fitparams(1);
    
    %%% Computing R2
    yresid = y - (fitparams(1).*x+fitparams(2));
    SSresid = sum(yresid.^2);
    SStotal = (length(y)-1) * var(y);%sum((y-mean(y)).^2)
    
    
    Rsq(lcondcounter) = 1 - SSresid/SStotal; % Compute R2
    display(['R2 using formula: ' num2str(Rsq(lcondcounter))])
    hold on
    plot([min(x) max(x)],[fitparams(1)*min(x)+fitparams(2) fitparams(1)*max(x)+fitparams(2)],'-r','Color',.4*[1 1 1])
    
    %% Linear Regression TYPE 2 %%
    %     p= polyfit(x,y,1);
    %     f= polyval(p,x);
    %     hold on
    %     plot([min(x) max(x)],[min(f) max(f)],'-r','Color',.4*[1 1 1])
    %%
    display('R2 using corrcoef')
    [R,p] = corrcoef(x,y,'rows','pairwise');
    R2 = R(1,2).^2
    pvalue = p(1,2);
    text(8,50,{['R= ' num2str(R(1,2))];['R^2= ' num2str(R2)];['p value= ' num2str(pvalue)]},'FontName',FntName,'FontSize',FtSz)
    set(gca,'box','off')
end
if (saveplot==1)
    savefig_withname(1,'600','png',DataSaving_dir_temp,Exp_num,Exp_letter,'Activity')
end
%% Correlation with Total time (Total head micromovement) on Yeast - All flies
% close all
% saveplot=0;
% FntName='arial';
% FtSz=8;
% 
% TotalTimesHmm=sum(CumTimeH{1})/params.framerate/60;%min
% 
% figure('Position',[2100 50 1200 930],'Color','w','Name','Speed outside visits correlation Total Headmm all flies')
% Colors_cond=Colors(length(Conditions));
% 
% display(['------ ' params.LabelsShort{lcond} ' -----'])
% 
% y=TotalTimesHmm';
% x=Speed_OutVisits_all;
% plot(x,y,'o',...
%     'MarkerEdgeColor',[.7 .7 .7],'MarkerFaceColor',Colors_cond(6,:));
% axis([0 14 0 60])
% font_style(params.Labels{lcond},'Speed outside visits (mm/s)',...
%     'Total time on Yeast -Head microm- (min)','normal',FntName,FtSz)
% 
% %%% Linear Regression TYPE 1%%
% statopts=statset('Display','final');% If you specify 'iter', output is
% %%% displayed at each iteration. If you specify 'final', output is
% %%% displayed after the final iteration.
% fitparams = nlinfit(x,y,...
%     @StraightLine,[1 0],statopts);
% Slope=fitparams(1);
% 
% %%% Computing R2
% yresid = y - (fitparams(1).*x+fitparams(2));
% SSresid = sum(yresid.^2);
% SStotal = (length(y)-1) * var(y);%sum((y-mean(y)).^2)
% 
% 
% Rsq = 1 - SSresid/SStotal; % Compute R2
% display(['R2 using formula: ' num2str(Rsq)])
% hold on
% plot([min(x) max(x)],[fitparams(1)*min(x)+fitparams(2) fitparams(1)*max(x)+fitparams(2)],'-r','Color',.4*[1 1 1])
% 
% %%% Linear Regression TYPE 2 %%
% %     p= polyfit(x,y,1);
% %     f= polyval(p,x);
% %     hold on
% %     plot([min(x) max(x)],[min(f) max(f)],'-r','Color',.4*[1 1 1])
% %%%
% display('R2 using corrcoef')
% [R,p] = corrcoef(x,y,'rows','pairwise');
% R2 = R(1,2).^2
% pvalue = p(1,2);
% text(8,50,{['R= ' num2str(R(1,2))];['R^2= ' num2str(R2)];['p value= ' num2str(pvalue)]},'FontName',FntName,'FontSize',FtSz)
% 
% if (saveplot==1)
%     savefig_withname(1,'600','png',DataSaving_dir_temp,Exp_num,Exp_letter,'Activity')
% end
%% Correlation with Total time (Total head micromovement) on Yeast - Each condition - Time Segments

% ranges=[1 30000;30001 90000;90001 150000;150001 210000;210001 270000;270001 345000];%
% %%% Speed outside visits and total time on yeast for each segment
% Speed_OutVisits_TimeSegments=nan(length(flies_idx),size(ranges,1));
% TotaltimeHmm_TimeSegments=nan(length(flies_idx),size(ranges,1));
% flycounter=0;
% for lfly=flies_idx
%     display(lfly)
%     flycounter=flycounter+1;
%     for lrange=1:size(ranges,1)
%         range=ranges(lrange,1):ranges(lrange,2);
%         logicaloutsidevisits=~(Binary_V(range,lfly)');
%         
%         if sum(logicaloutsidevisits)~=0
%             Speed_temp=Steplength_Sm_c{lfly}(ranges(lrange,1):ranges(lrange,2));
%             Speed_NoVisits=Speed_temp(logicaloutsidevisits)*params.px2mm*params.framerate;
%             Speed_OutVisits_TimeSegments(flycounter,lrange)=nanmean(Speed_NoVisits);%mm/s
%             TotaltimeHmm_TimeSegments(flycounter,lrange)=sum(CumTimeH{1}(range,lfly))/params.framerate/60;%min
%         end
%     end
% end
% 
% 
% close all
% saveplot=0;
% FntName='arial';
% FtSz=8;
% 
% clusterdividers=[14;105;64;68];%Mated AA+ and Virgin AA+ flipped
% 
% figure('Position',[2100 50 1500 950],'Color','w',...
%     'Name','Speed out v correl T t Headmm whole per cond, Time Segm, Rovers',...
%     'PaperUnits','centimeters','PaperPosition',[0 0 40 20])
% Colors_cond=Colors(length(Conditions));
% Rsq=nan(length(Conditions),1);
% plotcounter=0;
% lcondcounter=0;
% for lcond=Conditions
%     lcondcounter=lcondcounter+1;
%     display(['------ ' params.LabelsShort{lcond} ' -----'])
%     if (lcond==1)||(lcond==2)
%         Idx_sort=flipud(Flies_cluster{lcondcounter});
%     else
%         Idx_sort=Flies_cluster{lcondcounter};
%     end
%     rovers_Idx=Idx_sort(1:find(Idx_sort==clusterdividers(lcondcounter)));
%     
%     for lrange=1:size(ranges,1)
%         range=ranges(lrange,1):ranges(lrange,2);
%         plotcounter=plotcounter+1;
%         subplot(length(Conditions),size(ranges,1),plotcounter)
% %         y=TotaltimeHmm_TimeSegments(params.ConditionIndex==lcond,lrange);
%         y=TotalTimesHmm(params.ConditionIndex==lcond)';
%         x=Speed_OutVisits_TimeSegments(params.ConditionIndex==lcond,lrange);
%         
%         plot(x,y,'o',...
%             'MarkerEdgeColor',[.7 .7 .7],'MarkerFaceColor',Colors_cond(lcondcounter,:));
%         hold on
%         for lrover=rovers_Idx'
%             plot(Speed_OutVisits_TimeSegments(lrover,lrange),TotalTimesHmm(lrover),'o',...
%                 'MarkerEdgeColor',[.7 .7 .7],'MarkerFaceColor','w','MarkerSize',3);
%         end
%             
%         
%         axis([0 14 0 60])
%         
%         
%         %% Linear Regression TYPE 1%%
%         statopts=statset('Display','final');% If you specify 'iter', output is
%         %%% displayed at each iteration. If you specify 'final', output is
%         %%% displayed after the final iteration.
%         fitparams = nlinfit(x,y,...
%             @StraightLine,[1 0],statopts);
%         Slope=fitparams(1);
%         
%         %%% Computing R2
%         yresid = y - (fitparams(1).*x+fitparams(2));
%         SSresid = sum(yresid.^2);
%         SStotal = (length(y)-1) * var(y);%sum((y-mean(y)).^2)
%         
%         
%         Rsq = 1 - SSresid/SStotal; % Compute R2
%         display(['R2 using formula: ' num2str(Rsq)])
%         hold on
%         plot([min(x) max(x)],[fitparams(1)*min(x)+fitparams(2) fitparams(1)*max(x)+fitparams(2)],'-r','Color',.4*[1 1 1])
%         
%         %% Linear Regression TYPE 2 %%
%         %     p= polyfit(x,y,1);
%         %     f= polyval(p,x);
%         %     hold on
%         %     plot([min(x) max(x)],[min(f) max(f)],'-r','Color',.4*[1 1 1])
%         %%
%         display('R2 using corrcoef')
%         [R,p] = corrcoef(x,y,'rows','pairwise');
%         R2 = R(1,2).^2
%         pvalue = p(1,2);
% %         text(5,15,{['R= ' num2str(R(1,2))];['R^2= ' num2str(R2)];['p value= ' num2str(pvalue)]},'FontName',FntName,'FontSize',FtSz)
%         text(5,50,{['R= ' num2str(R(1,2))];['R^2= ' num2str(R2)];['p value= ' num2str(pvalue)]},'FontName',FntName,'FontSize',FtSz)
%         if lrange==1
%             font_style([],'Speed outside visits (mm/s)',...
%             {params.Labels{lcond};'Total time Y Head microm (min)'},'normal',FntName,FtSz)
%         end
%         if lcondcounter==1
%             title([num2str(floor(range(1)/params.framerate/60)) ' - ',...
%                 num2str(floor(range(end)/params.framerate/60)) ' min'],'FontSize',FtSz,'FontName',FntName)
%         end
%         set(gca,'FontSize',FtSz,'FontName',FntName,'box','off')
% %         axis([0 12.5 0 20])
%         axis([0 12.5 0 60])
%         
%     end
% end
% if (saveplot==1)
%     savefig_withname(1,'600','png',DataSaving_dir_temp,Exp_num,Exp_letter,'Activity')
% end