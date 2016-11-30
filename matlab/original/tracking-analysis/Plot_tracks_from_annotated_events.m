% load('E:\Analysis Data\Experiment 0003\Variables\Annotation_micromovements_0003A 26-Feb-2015.mat')
saveplot=0;
EventLabel='Feeding';
ColorsTracks=Colors(3);
CmapSubs=[238 96 8;0 0 0]/255;
CmapSubs_Patch=[250 234 176;240 240 240]/255;%

%% Preprocessing struct
EventCell_temp={Annotation_micromovements(1:140).(EventLabel)};
InfoCell_temp={Annotation_micromovements(1:140).Info};
Event_log=cell2mat(cellfun(@(x)~isempty(x),EventCell_temp,'UniformOutput',false));
EventCell=EventCell_temp(Event_log);
InfoCell=InfoCell_temp(Event_log);
AllEvents=cell2mat(EventCell');
AllEventsInfo=cell2mat(cellfun(@(x,y)repmat(x(1,3:4),size(y,1),1),InfoCell,EventCell,'UniformOutput',false)');
%% Nº of events
% Geometry=FlyDB(1).Geometry;
% NYEvents=ceil(sum(ismember(AllEventsInfo(:,1),find(Geometry==1)))/10)*10;
% NSEvents=ceil(sum(ismember(AllEventsInfo(:,1),find(Geometry==2)))/10)*10;
AllEventsInfo=[AllEventsInfo(:,1:2) nan(size(AllEvents,1),1)];
for levent=1:size(AllEvents,1)
    lfly=AllEventsInfo(levent,2);
    AllEventsInfo(levent,3)=FlyDB(lfly).Geometry(AllEventsInfo(levent,1));
end
%% CAlculating First and Max distance to spot

FirstFrame=nan(max([sum(AllEventsInfo(:,3)==1),...
    sum(AllEventsInfo(:,3)==2)]),2);
MaxDist=nan(max([sum(AllEventsInfo(:,3)==1),...
    sum(AllEventsInfo(:,3)==2)]),2);

for lsubs=[1 2]
    eventcounter=0;
    for levent=find(AllEventsInfo(:,3)==lsubs)'
        eventcounter=eventcounter+1;
       
        lfly=AllEventsInfo(levent,2);
        Spot=AllEventsInfo(levent,1);
        range=(AllEvents(levent,1):AllEvents(levent,2))';
        
        FirstFrame(eventcounter,lsubs)=...
            sqrt(sum((FlyDB(lfly).WellPos(Spot,:)-...
            Heads_Sm{lfly}(range(1),:)).^2))*params.px2mm;
        MaxDist(eventcounter,lsubs)=...
            max(sqrt(sum((repmat(FlyDB(lfly).WellPos(Spot,:),size(range,1),1)-...
            Heads_Sm{lfly}(range,:)).^2,2))*params.px2mm);
            
    end
end



%% Plotting
close all
saveplot=1;
nrows=10;
FntName='arial';
if saveplot==1
    FtSz=8;
    LineW=0.8;
    MkSz=2;
else
    FtSz=11;
    LineW=1.5;
    MkSz=3;
end



for lsubs=[1 2]
    
    NumEvents=sum(AllEventsInfo(:,3)==lsubs);
    ncols=ceil(NumEvents/nrows);
    AxesPositions=axespositionsfun(nrows,ncols,0.01,0.01);
    
       
    figname=['Annotated tracks - Positive detected ' EventLabel ' ' params.Subs_Names{lsubs} ' ' date];
    figure('Position',[2100 50 1400 930],'Color','w','Name',figname,'PaperUnits',...
        'centimeters','PaperPosition',[0 0 20 28])

    
    eventcounter=0;
    for levent=find(AllEventsInfo(:,3)==lsubs)'
        eventcounter=eventcounter+1;
        
        subplot('Position',AxesPositions(eventcounter,:))
        lfly=AllEventsInfo(levent,2);
        Spot=AllEventsInfo(levent,1);
        range=(AllEvents(levent,1):AllEvents(levent,2))';
        
        plot_tracks_single(FlyDB,Heads_Sm{lfly},lfly,Spot,params,1,ColorsTracks(1,:),...
        range,FtSz,1,LineW)
        hold on
        plot(Heads_Sm{lfly}(range(1),1)*params.px2mm,Heads_Sm{lfly}(range(1),2)*params.px2mm,'o','Color',ColorsTracks(2,:),...
            'MarkerFaceColor',ColorsTracks(2,:))
        
        %% Is there a visit detected?
        if sum(CumTimeV{lsubs}(range,lfly))~=0
            [c,xc,yc]=circle_([FlyDB(lfly).WellPos(Spot,1)*params.px2mm,...
            FlyDB(lfly).WellPos(Spot,2)*params.px2mm],...
            1.6,100,'-b');
            set(c,'Color',CmapSubs(lsubs,:),'LineWidth',2)
            patch(xc,yc,CmapSubs(lsubs,:),'EdgeColor',CmapSubs(lsubs,:))
        end
        
        %% Cropping around the spot
        delta=2.5;
        axis([FlyDB(lfly).WellPos(Spot,1)*params.px2mm-delta,...
            FlyDB(lfly).WellPos(Spot,1)*params.px2mm+delta,...
            FlyDB(lfly).WellPos(Spot,2)*params.px2mm-delta,...
            FlyDB(lfly).WellPos(Spot,2)*params.px2mm+delta])

        axis off
        title([])
        box off
    end
end

%%Save
if saveplot==1
    SubFolder_name='Manual Ann';
    savefig_withname(1,'600','png',DataSaving_dir_temp,Exp_num,Exp_letter,...
        SubFolder_name)
end
%% Max/First distance to spot - BOXPLOT
close all
saveplot=1;
vardist=1;%1-First distance, 2- Max distance
if saveplot==1
    FtSz=8;
    LineW=0.8;
    MkSz=2;
else
    FtSz=11;
    LineW=1.5;
    MkSz=3;
end


if vardist==1
    y_label='First';
    var2plot=FirstFrame;
elseif vardist==2
    y_label='Max';
    var2plot=MaxDist;
end
figname=[y_label ' distance during annotated ' EventLabel ' ' date];
    figure('Position',[2100 50 1400 930],'Color','w','Name',figname,'PaperUnits',...
        'centimeters','PaperPosition',[10 10 10 10])

[~,lineh] = plot_boxplot_tiltedlabels(var2plot,params.Subs_Names,[1 2],...
        CmapSubs_Patch,zeros(2,3),...
        'k',.4,FtSz,FntName,'o');
font_style('Annotated Feeding Events',[],{y_label ' distance during ','feeding event (mm)'},'normal',FntName,FtSz)
if saveplot==1
    SubFolder_name='Manual Ann';
    savefig_withname(1,'600','png',DataSaving_dir_temp,Exp_num,Exp_letter,...
        SubFolder_name)
end

%% Histogram of Distance to Spots
close all
saveplot=1;
vardist=1;%1-First distance, 2- Max distance
if saveplot==1
    FtSz=8;
    LineW=0.8;
    MkSz=2;
else
    FtSz=11;
    LineW=1.5;
    MkSz=3;
end

if vardist==1
    y_label='First';
    var2plot=FirstFrame;
elseif vardist==2
    y_label='Max';
    var2plot=MaxDist;
end

figname=['Hist ' y_label ' distance during annotated ' EventLabel ' ' date];
    figure('Position',[2100 50 1400 930],'Color','w','Name',figname,'PaperUnits',...
        'centimeters','PaperPosition',[10 10 10 10])

MaxRad=4;%%
X_range=0:2*params.px2mm:MaxRad;%

HistCount=hist(var2plot,X_range);%Steplength_Sm{lfly}(log_vectIn)
Freq=HistCount./repmat(nansum(HistCount),length(X_range),1);

%%% Histogram as bars
barhandle=bar(X_range,Freq);
hold on
for lsubs=1:size(Freq,2)
    set(barhandle(lsubs),'FaceColor',CmapSubs(lsubs,:),...
        'LineWidth', 1,'EdgeColor',CmapSubs(lsubs,:));%,'BarWidth',0.4);
end
legend(params.Subs_Names,'Location','Best','box','off')%Uncomment for not subplots
% legend box off    
font_style('Annotated feeding events',{[y_label ' distance from center']; 'of spot (mm)'},...params.Subs_Names{lsubs}
    'Ocurrences (normalised)','normal',FntName,FtSz)%Uncomment for not subplots


if saveplot==1
    SubFolder_name='Manual Ann';
    savefig_withname(1,'600','png',DataSaving_dir_temp,Exp_num,Exp_letter,...
        SubFolder_name)
end
%% Cum Hist
close all
saveplot=1;

figname=['Cumulative Hist ' y_label ' distance during annotated ' EventLabel ' ' date];
figure('Position',[2100 50 1400 930],'Color','w','Name',figname,'PaperUnits',...
        'centimeters','PaperPosition',[10 10 10 10])
hold on
for lsubs=1:size(Freq,2)
    plot(X_range,cumsum(Freq(:,lsubs)),'-o','MarkerFaceColor',CmapSubs(lsubs,:),...
        'LineWidth', 1,'Color',CmapSubs(lsubs,:));%,'BarWidth',0.4);
end

legend(params.Subs_Names)%Uncomment for not subplots
legend('boxoff')    
font_style('Annotated feeding events',{[y_label ' distance from center']; 'of spot (mm)'},...params.Subs_Names{lsubs}
    'Cumulative Probability','normal',FntName,FtSz)%Uncomment for not subplots


if saveplot==1
    SubFolder_name='Manual Ann';
    savefig_withname(1,'600','png',DataSaving_dir_temp,Exp_num,Exp_letter,...
        SubFolder_name)
end
    