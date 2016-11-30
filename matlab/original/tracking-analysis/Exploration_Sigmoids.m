%%
%%% Run Plot_TimeSegments_Allflies
saveplot=0;
close all 
figure('Position',[100,9,1600,985],'Color','w',...
        'Name',['Y spot dist - All conditions ' date])

lcondcounter=0;
    lparam=13;
for lcond=Conditions
    lcondcounter=lcondcounter+1;
    subplot(2,ceil(length(Conditions)/2),lcondcounter)
    cond_idx=find(params.ConditionIndex==lcond);
    
    h=plot(1:size(All_vars_allconds{lcondcounter}(lparam).Data,1),...
        All_vars_allconds{lcondcounter}(lparam).Data','-o','LineWidth',2);
    
    
        set(gca,'XTick',1:length(All_vars_allconds{lcondcounter}(lparam).Data),'Xticklabel',xticklabels)
        font_style(params.LabelsShort{lcond},'Time of assay (min)',All_vars_allconds{lcondcounter}(lparam).YLabel,'normal',FntName,FtSz)
end
if (saveplot==1)
    savefig_withname(1,'600','png',DataSaving_dir_temp,Exp_num,Exp_letter,'Ethograms')
end
%% Sigmoid fit
close all
figure
for lfly=1:30;
    clf
lcondcounter=3;
h=plot(1:size(All_vars_allconds{lcondcounter}(lparam).Data,1),...
        All_vars_allconds{lcondcounter}(lparam).Data(:,lfly)','-o','LineWidth',2);
    try
[param,stat]=sigm_fit(1:size(All_vars_allconds{lcondcounter}(lparam).Data),...
    All_vars_allconds{lcondcounter}(lparam).Data(1:end,lfly)');
    catch
    end
pause
end
%%
% close all
% figure('Position',[1930 10 1850 900],'Color','w')
% lflycounter=0;
% for lfly=find(params.ConditionIndex==lcond)
%     lflycounter=lflycounter+1;
% y=All_vars_allconds{lcondcounter}(11).Data(:,lflycounter);
% x=All_vars_allconds{lcondcounter}(9).Data(:,lflycounter);
% clf
% subplot(3,2,[1 2])
% plot(1:6,x,'-o')
% hold on
% plot(1:6,y,'-or')
% title(['Fly ' num2str(lfly)])
% legend({'Y Av Dur';'Y Nº Visits'})
% subplot(3,2,[3 4])
% c1=xcov(x,y);
% plot(c1,'-om');title('Cross Covariance')
% 
% subplot(3,2,[5 6])
% c2=xcorr(x,y);
% plot(c2,'-og');title('Cross Correlation')
% pause
% end