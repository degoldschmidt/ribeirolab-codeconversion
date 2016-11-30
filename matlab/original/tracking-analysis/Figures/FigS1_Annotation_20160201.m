% 
save_plot=0;
FtSz=10;
FntName='arial';
lsubs=1;
plot_type='Line';%'Bars';%'Line';%


MaxSpeed=20;%mm/s
% X_range=0:MaxSpeed/20:MaxSpeed;%
X_range=[0 0.2 2 4 20 Inf];
if length(Conditions)<length(unique(params.ConditionIndex))
    figname_cond=[];
    for lcond=Conditions
        figname_cond=[figname_cond ' - ' params.LabelsShort{lcond}];
    end
else
    figname_cond=' - All conditions';
end
%% Colors
Color=Colors(3);
% figure('Position',[2026 50 params.scrsz(3)-450 params.scrsz(4)-150],'Color','w')
Behav_2_plot={'Resting';'Feeding';'Grooming';'Walking'};%'Turning';
behavColors=[[.6 .6 .6]*255;...%Resting
    243 164 71;...%Feeding
    243 7 198;...%Grooming
    Color(3,:)*255;...%Walking
    Color(2,:)*255]/255;...%Turning

%% Histogram of speed for annotated behaviours
Speeds_temp=nan(100000,length(Behav_2_plot));
lbehavcounter=zeros(1,length(Behav_2_plot));
framescounter=ones(1,length(Behav_2_plot));
for lbout=1:140
    lfly=Annotation_micromovements(lbout).Info(4);
    for lbehav=1:length(Behav_2_plot)
        nrows=size(Annotation_micromovements(lbout).(Behav_2_plot{lbehav}),1);
        if nrows>0
            for nrow=1:nrows
                lbehavcounter(lbehav)=lbehavcounter(lbehav)+1;
                framestart=Annotation_micromovements(lbout).(Behav_2_plot{lbehav})(nrow,1);
                frameend=Annotation_micromovements(lbout).(Behav_2_plot{lbehav})(nrow,2);
                Speeds_temp(framescounter(lbehav):framescounter(lbehav)+frameend-framestart,lbehav)=...
                    Steplength_Sm_h{lfly}(framestart:frameend)*50*params.px2mm;
                framescounter(lbehav)=framescounter(lbehav)+frameend-framestart+1;
                %% plot annotated traces
                %                 clf
                %                 range=framestart:frameend;
                %                 plot_tracks_single(FlyDB,Centroids_Sm{lfly},lfly,0,params,1,...
                %                 Color(2,:),range,FtSz,1,2)
                %                 range_h=range(1:3:end);
                %                 plot_heading(Centroids_Sm{lfly},Heads_Sm{lfly},Tails_Sm{lfly},1,...
                %                     Color(2,:),params,range_h,2,0.5,2)
                %                 plot_tracks_single(FlyDB,Heads_Sm{lfly},lfly,0,params,1,...
                %                     Color(1,:),range,FtSz,0,2)
                %                 plot_tracks_single(FlyDB,Heads_Sm{lfly},lfly,0,params,1,...
                %                     'k',range,FtSz,0,1)
                %                 title(Behav_2_plot{lbehav})
                %                 pause
            end
        end
    end
end
HistCount=histc(Speeds_temp,X_range);
Freq=HistCount./repmat(nansum(HistCount),length(X_range),1);

%% Plot histogram
% close all
% figname=['Hist annotated behav speedh_line ' date];
% figure('Position',[100 50 params.scrsz(3)-450 params.scrsz(4)-150],...
%     'Color','w','Name',figname);
% Symbol_plot={'-o';'-s';'-^';'-d';'-v'};
% 
% %%% Histogram as Line
% h=zeros(length(Behav_2_plot),1);
% lbehavcounter2=0;
% for lbehav=1:length(Behav_2_plot)
%     lbehavcounter2=lbehavcounter2+1;
%     if strfind(plot_type,'Line')
%         %% Mean and stderr (average across flies)
%         h(lbehavcounter2)=plot(X_range,Freq(:,lbehav),Symbol_plot{lbehavcounter2},...
%             'Color',behavColors(lbehav,:),'LineWidth',1,'MarkerSize',2,'MarkerFaceColor',behavColors(lbehav,:));
%         hold on
%     end
%     
% end
% 
% font_style([],'Speed_h (mm/s)',...
%     'Ocurrences (normalised)','normal',FntName,FtSz)
% legend(h,Behav_2_plot,'Location','Best')
% legend boxoff
% 
% % ylim([0 0.35])
% % xlim([X_range(1) X_range(end)])
% savefig_withname(1,'600','png',DataSaving_dir_temp,Exp_num,Exp_letter,...
%     'Manual Ann')

%% Plot histogram as bars
close all
figname=['Hist annotated behav speedh_bars ' date];
figure('Position',[100 50 params.scrsz(3)-450 params.scrsz(4)-150],...
    'Color','w','Name',figname,'PaperUnits','centimeters','PaperPosition',[0 0 8 10]);
x=0.23;y=0.11;dy=0.05;
heightsubplot=(1-2*y-3*dy)/4;
widthsubplot=1-1.5*x;

AxesPositions=[x y+3*heightsubplot+3*dy widthsubplot heightsubplot;...
    x y+2*heightsubplot+2*dy widthsubplot heightsubplot;...
    x y+heightsubplot+dy widthsubplot heightsubplot;...
    x y widthsubplot heightsubplot];
plotcounter=0;
for lbehav=1:length(Behav_2_plot)
    plotcounter=plotcounter+1;
    subplot('Position',AxesPositions(plotcounter,:))
    hold on
    for lbin=1:length(X_range)-2
        fillhw=fill([X_range(lbin);X_range(lbin);...
            X_range(lbin+1); X_range(lbin+1)],...
            [0;Freq(lbin,lbehav);...
            Freq(lbin,lbehav);0],...
            behavColors(lbehav,:));
        
        set(fillhw,'EdgeColor','k','FaceAlpha',.5,...
            'EdgeAlpha',1);
    end
    xticks=[0:2:X_range(end-1)];
    set(gca,'Xlim',[-.5 X_range(end-1)+.5],'Ylim',[0 1],...
        'Xtick',xticks,'XtickLabel',cellfun(@num2str,num2cell(xticks),'UniformOutput',0))%'XScale','log',
    if lbehav==1
        font_style([],[],...
        {'Ocurrences';'(normalized)'},'normal',FntName,FtSz)
    end
    text(3,.95,[Behav_2_plot{lbehav} ', n = ' num2str(lbehavcounter(lbehav)),...
        ', ' num2str(framescounter(lbehav)/50/60) ' min'],'fontweight','normal','FontNAme',FntName,...
    'FontSize',FtSz,'Color',behavColors(lbehav,:))
    plot([.2 .2],[0 1],':','Color','k')
    plot([2 2],[0 1],':','Color','k')
    if lbehav~=4
        set(gca,'XTickLabel',[])
    end
end
font_style([],'Head speed (mm/s)',...
    [],'normal',FntName,FtSz)

savefig_withname(1,'600','png',DataSaving_dir_temp,Exp_num,Exp_letter,...
    'Manual Ann')
% % % framescounter =
% % %        27342       90177       45419        4083
% % % lbehavcounter =
% % %     19    97   105    30
%% Finding the proportion of behaviours in food micromovements
% load('E:\Analysis Data\Experiment 0003\Variables\Annotation_micromovements_0003A 15-Feb-2016.mat')
% Behav_2_plot={'Resting';'Feeding';'Grooming';'Walking';'Turning';'Stopping';'Other'};
% 
% Foodmmcounter=[0 0];
% Behav_in_Food_mm=zeros(2,length(Behav_2_plot));%Top row: behavs in yeast; bottom: in sucrose
% nframes=size(CumTimeH{1},1);
% framescounter=ones(1,length(Behav_2_plot));
% for lbout=1:140
%     lfly=Annotation_micromovements(lbout).Info(4);
%     framestart_bout=Annotation_micromovements(lbout).Info(1);
%     frameend_bout=Annotation_micromovements(lbout).Info(2);
%     if framestart_bout>=nframes,continue, end
%     if frameend_bout>nframes,frameend_bout=nframes;end
%     Foodmmcounter(1)=Foodmmcounter(1)+sum(CumTimeH{1}(framestart_bout:frameend_bout,lfly));
%     Foodmmcounter(2)=Foodmmcounter(2)+sum(CumTimeH{2}(framestart_bout:frameend_bout,lfly));
%     for lbehav=1:length(Behav_2_plot)
%         binary_behav=zeros(nframes,1);
%         nrows=size(Annotation_micromovements(lbout).(Behav_2_plot{lbehav}),1);
%         if nrows>0
%             for nrow=1:nrows
%                 framestart=Annotation_micromovements(lbout).(Behav_2_plot{lbehav})(nrow,1);
%                 frameend=Annotation_micromovements(lbout).(Behav_2_plot{lbehav})(nrow,2);
%                 binary_behav(framestart:frameend)=1;
%             end
%             Behav_in_Food_mm(1,lbehav)=Behav_in_Food_mm(1,lbehav)+sum(binary_behav(1:nframes)&CumTimeH{1}(:,lfly));
%             Behav_in_Food_mm(2,lbehav)=Behav_in_Food_mm(2,lbehav)+sum(binary_behav(1:nframes)&CumTimeH{2}(:,lfly));
%         end
%     end
% end
% close all
% figname=['Pie chart behaviours on food micromovements ' date];
% figure('Position',[100 50 params.scrsz(3)-450 params.scrsz(4)-150],...
%     'Color','w','Name',figname,'PaperUnits','centimeters','PaperPosition',[0 0 8 7]);
% subplot(1,2,1)
% % pie(Behav_in_Food_mm(1,:)./repmat(Foodmmcounter(1),1,length(Behav_2_plot)),[0 0 0 1 1 1 1],Behav_2_plot)
% colapsedperc=[Behav_in_Food_mm(1,1:3) sum(Behav_in_Food_mm(1,4:7))];
% labels={'1.5% Resting';'92.2% Feeding';'5.6% Grooming';'0.7% Other'};
% pie(colapsedperc./repmat(Foodmmcounter(1),1,length(colapsedperc)),[0 1 0 0],labels)
% title('Yeast')
% subplot(1,2,2)
% % pie(Behav_in_Food_mm(2,:)./repmat(Foodmmcounter(2),1,length(Behav_2_plot)),[0 0 0 1 1 1 1],Behav_2_plot)
% colapsedperc=[Behav_in_Food_mm(2,1:3) sum(Behav_in_Food_mm(2,4:7))];
% labels={'4.3% Resting';'70.6% Feeding';'19.4% Grooming';'5.7% Other'};
% pie(colapsedperc./repmat(Foodmmcounter(2),1,length(colapsedperc)),[0 1 0 0],labels)
% title('Sucrose')
% savefig_withname(1,'600','png',DataSaving_dir_temp,Exp_num,Exp_letter,'Manual Ann')