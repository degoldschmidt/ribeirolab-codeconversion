%% 
% load('E:\Dropbox (Behavior&Metabolism)\Ribeiro Lab Shared Folders\Celia\FlyPad results\w- females 48h deprived\data_Excel.mat')
% load('E:\Dropbox (Behavior&Metabolism)\Ribeiro Lab Shared Folders\Celia\FlyPad results\w- females 48h deprived\w- females 48h deprived.mat')



close all
Conditions=[1 2];
figname=['w- flyPAD microstructure ' date];
FtSz=10;
FntName='arial';

figure('Position',[2100 50 1400 930],'Color','w','Name',figname,'PaperUnits',...
    'centimeters','PaperPosition',[5.5 5 10 10])

Labels=Events.ConditionLabel(Conditions);
%% Number of sips

for lsubs=1:2
    subplot(3,2,lsubs)
        
    X=data.NumberOfSips{lsubs}(:,Conditions);

    [~,lineh] = plot_boxplot_tiltedlabels(X,Labels,[1:length(Conditions)],...
            repmat([1 1 1],size(X,2),1),zeros(size(X,2),3),...
            'k',.4,FtSz,FntName,'.');
        ax=get(gca,'Ylim');
        set(gca,'TickDir','out','LineWidth',1);
    font_style(Events.SubstrateLabel{lsubs},[],'Number of Sips','bold',FntName,FtSz)
    if lsubs==1
        ylim([ax(1) 6000])
    else
        ylim([ax(1) 600])
    end
end


%% Feeding Burst IBI

for lsubs=1:2
    subplot(3,2,lsubs+2)
        
    X=data.FeedingBurst_nSips{lsubs}(:,Conditions);

    [~,lineh] = plot_boxplot_tiltedlabels(X,Labels,[1:length(Conditions)],...
            repmat([1 1 1],size(X,2),1),zeros(size(X,2),3),...
            'k',.4,FtSz,FntName,'.');
        ax=get(gca,'Ylim');
        set(gca,'TickDir','out','LineWidth',1);
    font_style(Events.SubstrateLabel{lsubs},[],'Number of Sips per burst','bold',FntName,FtSz)
    if lsubs==1
        ylim([ax(1) 20])
    else
        ylim([ax(1) 10])
    end
end
%% Feeding Burst IBI

for lsubs=1:2
    subplot(3,2,lsubs+4)
        
    X=data.FeedingBurstIBI{lsubs}(:,Conditions);

    [~,lineh] = plot_boxplot_tiltedlabels(X,Labels,[1:length(Conditions)],...
            repmat([1 1 1],size(X,2),1),zeros(size(X,2),3),...
            'k',.4,FtSz,FntName,'.');
        ax=get(gca,'Ylim');
        set(gca,'TickDir','out','LineWidth',1);
    font_style(Events.SubstrateLabel{lsubs},[],{'Feeding burst';'IBI'},'bold',FntName,FtSz)
    if lsubs==1
        ylim([ax(1) 60])
    else
        ylim([ax(1) 250])
    end
end
saveplot=1
if saveplot==1
  savefig_withname(0,'600','png','E:\Analysis Data\Experiment ','0003','A',...
    'Figures')
end