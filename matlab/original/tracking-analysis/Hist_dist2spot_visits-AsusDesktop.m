%%
%% Histogram of Distance to Spots
new_figure=0;
save_plot=0;
FtSz=6;
FntName='arial';
lsubs=1;
plot_type='Bars';%'Line';%


MaxRad=4;%%
X_range=0:2*params.px2mm:MaxRad;%

if new_figure==1
    Conditions=unique(params.ConditionIndex);
end

if length(Conditions)<length(unique(params.ConditionIndex))
    figname_cond=[];
    for lcond=Conditions
        figname_cond=[figname_cond ' - ' params.LabelsShort{lcond}];
    end
else
    figname_cond=' - All conditions';
end

if new_figure==1
    close all
    figname=['Hist dist from ' params.Subs_Names{lsubs==params.Subs_Numbers} ' spots ' figname_cond];
    figure('Position',[100 50 params.scrsz(3)-450 params.scrsz(4)-150],...
        'Color','w','Name',figname);
else
    plotcounter=plotcounter+1;
    subplot('Position',Positions(plotcounter,:))
    hold on
end


%% Dist to spot HIst
fliescond=nan(length(Conditions),1);

% Alldist_Cond=cell(length(unique(params.ConditionIndex)),1);
for lcond=Conditions
    fliescond(lcond)=sum(params.ConditionIndex==lcond);
%     Alldist_Cond{lcond}=[];
end

HistCount=zeros(size(X_range,2),params.numflies);

MeandistFlies=nan(max(fliescond(lcond)),length(unique(params.ConditionIndex)));
AvDurVisits=nan(max(fliescond(lcond)),length(unique(params.ConditionIndex)));
Flycondcounter=zeros(1,length(unique(params.ConditionIndex)));
for lfly=1:params.numflies
    Flycondcounter(params.ConditionIndex(lfly))=Flycondcounter(params.ConditionIndex(lfly))+1;
    display(lfly)
    
    Geometry = FlyDB(lfly).Geometry;
    WellPos=FlyDB(lfly).WellPos;
    
    
    if ~isempty(DurInV{lfly})
        
        visit_rows=find(DurInV{lfly}(:,1)==lsubs)';
        
        Alldists=[];
        visitcounter=0;
        for lvisit=visit_rows
            visitcounter=visitcounter+1;
            Heads_temp=repmat(WellPos(DurInV{lfly}(lvisit,4),:),DurInV{lfly}(lvisit,5),1) -...
                Heads_Sm{lfly}(DurInV{lfly}(lvisit,2):DurInV{lfly}(lvisit,3),:);%
            
            Dist2fSpot=sqrt(sum(((Heads_temp).^2),2)).*params.px2mm;
            Alldists=[Alldists;Dist2fSpot];
%             Alldist_Cond{params.ConditionIndex(lfly)}=[Alldist_Cond{params.ConditionIndex(lfly)};Dist2fSpot];
        end
        
    end
    HistCount(:,lfly)=hist(Alldists,X_range);%Steplength_Sm{lfly}(log_vectIn)
    MeandistFlies(Flycondcounter(params.ConditionIndex(lfly)),params.ConditionIndex(lfly))=mean(Alldists);
    AvDurVisits(Flycondcounter(params.ConditionIndex(lfly)),params.ConditionIndex(lfly))=sum(DurInV{lfly}(:,5))/params.framerate/60;%min
end

%% Plot histogram
% close all
inact_thr=0.1;
Symbol_plot={'-o';'-^';'-o';'-o'};%{'-';'--';'-.'};

% HistCountPooled=zeros(size(X_range,2),length(unique(params.ConditionIndex)));
% FreqPooled=zeros(size(X_range,2),length(unique(params.ConditionIndex)));
Freq=HistCount./repmat(nansum(HistCount),length(X_range),1);
Condfr_mean=nan(size(HistCount,1),length(unique(params.ConditionIndex)));
Condfr_stderr=nan(size(HistCount,1),length(unique(params.ConditionIndex)));

[CondColors,Cmap_patch]=Colors(length(params.Labels));%Colors(length(Conditions));
% figure('Position',[100 50 params.scrsz(3)-150 params.scrsz(4)-150],'Color','w'),

%%% Histogram as Line
h=zeros(length(Conditions),1);
lcondcounter=0;
for lcond=Conditions
    lcondcounter=lcondcounter+1;
    Condfr_mean(:,lcond)=nanmean(Freq(:,params.ConditionIndex==lcond),2);
    Condfr_stderr(:,lcond)=nanstd(Freq(:,params.ConditionIndex==lcond),0,2)./sqrt(sum(params.ConditionIndex==lcond));
%     HistCountPooled(:,lcond)=hist(Alldist_Cond{lcond},X_range);
%     FreqPooled(:,lcond)=HistCountPooled(:,lcond)/sum(HistCountPooled(:,lcond));
    
    if strfind(plot_type,'Line')
        %% Mean and stderr (average across flies)
        h(lcondcounter)=plot(X_range,Condfr_mean(:,lcond),Symbol_plot{lcondcounter},...
            'Color',CondColors(lcond,:),'LineWidth',1,'MarkerSize',2,'MarkerFaceColor',CondColors(lcond,:));
        hold on
        
        line(repmat(X_range,2,1),[Condfr_mean(:,lcond)'-Condfr_stderr(:,lcond)';...
            Condfr_mean(:,lcond)'+Condfr_stderr(:,lcond)'],'LineWidth',0.5*LineW,'Color',CondColors(lcond,:))
        %     y_lim(lcondcounter,:)=get(gca,'YLim');
        
        
        
    end
    
end
%%% Histogram as bars
if strfind(plot_type,'Bars')
    barhandle=bar(X_range,Condfr_mean(:,Conditions));
    hold on
    for lbarcond=1:size(Condfr_mean(:,Conditions),2)
        set(barhandle(lbarcond),'FaceColor',CondColors(Conditions(lbarcond),:),...
            'LineWidth', 1,'EdgeColor',CondColors(Conditions(lbarcond),:));%,'BarWidth',0.4);
%         text(nanmedian(MeandistFlies(:,Conditions(lbarcond))),0.3,'\downarrow',...
%             'Color',CondColors(Conditions(lbarcond),:),...
%             'FontWeight','bold','fontName',FntName,'FontSize',FtSz)
    end
    %% Adding the error bars
        ybuff=0;
    for i=1:length(barhandle)
        XDATA=get(get(barhandle(i),'Children'),'XData');
        YDATA=get(get(barhandle(i),'Children'),'YData');
        for j=1:size(XDATA,2)
            x=XDATA(1,j)+(XDATA(3,j)-XDATA(1,j))/2;
            y=YDATA(2,j)+ybuff;
%             plot(x,y,'o','Color',[.5 .5 .5],'MarkerSize',3,'MarkerFaceColor',[.5 .5 .5])
            plot([x x],[y,...
            y+Condfr_stderr(j,Conditions(i))],'-','Color',[.5 .5 .5],'MarkerFaceColor',[.5 .5 .5],'LineWidth',.8)
        end
    end
%     ylim([0 100])
    
    
end



font_style([],{'Distance from center'; 'of spot (mm)'},...params.Subs_Names{lsubs}
    'Ocurrences (normalised)','normal',FntName,FtSz)%Uncomment for not subplots
%     legend(h,params.LabelsShort(Conditions),'Location','Best')%Uncomment for not subplots
%     legend box off




ylim([0 0.35])
xlim([X_range(1) X_range(end)])

%% Plot box plot of mean distance from center
if new_figure==1
    figname=['Mean dist from ' params.Subs_Names{lsubs==params.Subs_Numbers} ' spots' figname_cond];
    figure('Position',[100 50 params.scrsz(3)-450 params.scrsz(4)-150],...
        'Color','w','Name',figname);
    labels2=params.LabelsShort(Conditions);
    xvalues=1:length(Conditions);
else labels2=labels;
    plotcounter=plotcounter+1;
    subplot('Position',Positions(plotcounter,:))
end

% plot_boxplot_tiltedlabels(MeandistFlies,params.LabelsShort(Conditions))
plot_boxplot_Fig2(MeandistFlies(:,Conditions),labels2,xvalues,...plot_boxplot_tiltedlabels
    repmat(Cmap_patch(Conditions,:),numvariables,1),repmat(CondColors(Conditions,:),numvariables,1),...
    'k',.4,FtSz,FntName,'.');

font_style([],[],{'Mean distance from';'center of spot (mm)'},'normal',FntName,FtSz)%params.Subs_Names{lsubs}

stats_boxplot_tiltedlabels(MeandistFlies(:,Conditions),cell(1,1),Conditions,xvalues,...
    ['Mean distance from spot'],lsubs,params,...
    DataSaving_dir_temp,Exp_num,Exp_letter,figname_cond,'Visits',FtSz,FntName)
xlim([0 (length(Conditions)+1)])
if save_plot==1
    savefig_withname(1,'600','png',DataSaving_dir_temp,Exp_num,Exp_letter,...
        'Visits')
end
%% Plot box plot of mean durantion of visits
% if new_figure==1
%     figname=['Mean duration of ' params.Subs_Names{lsubs==params.Subs_Numbers} ' visits' figname_cond];
%     figure('Position',[100 50 params.scrsz(3)-450 params.scrsz(4)-150],...
%         'Color','w','Name',figname);
%     labels2=params.LabelsShort(Conditions);
%     xvalues=1:length(Conditions);
%     title_=params.Subs_Names{lsubs};
% else labels2=labels;
%     plotcounter=plotcounter+1;
%     subplot('Position',Positions(plotcounter,:))
%     title_=[];
% end
% 
% % plot_boxplot_tiltedlabels(MeandistFlies,params.LabelsShort(Conditions))
% plot_boxplot_Fig2(AvDurVisits(:,Conditions),labels2,xvalues,...plot_boxplot_tiltedlabels
%     repmat(Cmap_patch(Conditions,:),numvariables,1),repmat(CondColors(Conditions,:),numvariables,1),...
%     'k',.4,FtSz,FntName,'.');
% 
% font_style(title_,[],{'Mean duration of';'visits (min)'},'normal',FntName,FtSz)%
% % xvalues=1:length(Conditions);
% stats_boxplot_tiltedlabels(AvDurVisits(:,Conditions),cell(1,1),Conditions,xvalues,...
%     ['Mean duration of visits'],lsubs,params,...
%     DataSaving_dir_temp,Exp_num,Exp_letter,figname_cond,'Visits',FtSz,FntName)
% xlim([0 (length(Conditions)+1)])
% if save_plot==1
%     savefig_withname(1,'600','png',DataSaving_dir_temp,Exp_num,Exp_letter,...
%         'Visits')
% end