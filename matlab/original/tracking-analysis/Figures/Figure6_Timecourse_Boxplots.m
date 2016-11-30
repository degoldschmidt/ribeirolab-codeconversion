clear all
close all
Dur=310000;%% this is a minimal duration of the shortest session(a bit less than 1 hour)
BinSize=100;% How many samples to use to calculate number of feeding events for the timecourse
PreTime=-200;
PostTime=1000;
Comment=[' '];
Lags=[-100:100];
%% Errorbar or boxplots
BoxPlotYN=1;
binsForHistDurs=[1:2:60];
binsForHistIFI=[1:3:200];
binsForHistRMSDurs=[1:100:10000];
Mean_or_Median=1;SW=BinSize;
Colors={'b','r','m','g','k','y','c','b'};
JBFILL=0;
s=pwd;
screen_size = get(0, 'ScreenSize');
Substrate=2;
%userpath([s,'\'])
userpath_name=[s,'\'];
Preview=0;
Comment='';
Resolution=300;
SaveFig=1;
FileName=['PSTHsExp1'];
check_filename_delete_if_exists_for_mrep(userpath_name,FileName)
% cd ('D:\Dropbox\FlyPad\MatlabEssentialsForAnalysis')
% [FileName,PathName,FilterIndex] =uigetfile('.mat');
% load(FileName)

try
    load('D:\Dropbox\FlyPad\MatlabEssentialsForAnalysis\AllEventsStructure_With_RMS_1Hour_Starvation_DynThresh2_A.mat','Events')
catch
%     load('C:\Users\pcadmin\Dropbox\FlyPad\MatlabEssentialsForAnalysis\AllEventsStructure_With_RMS_1Hour_Starvation_DynThresh2_A.mat','Events')
    load('E:\Analysis Data\Experiment 0003\Plots\flyPAD\AllEventsStructure_With_RMS_1Hour_Starvation_DynThresh2_A.mat','Events')
end
% 
for nRows=1:size(Events.Ons,1)
    Events.Condition{nRows}(logical(Events.ToRemove{nRows}))=nan;
end

%% remove extra control conditions 
Events.ConditionLabel=[];

Events.ConditionLabel{2}='4 h';
Events.ConditionLabel{3}='8 h';
% Events.ConditionLabel{4}='16 h';
% Events.ConditionLabel{5}='24 h';
Events.ConditionLabel{1}='fed';
for n=1:max(size(Events.Condition))
% bla=Events.Condition{n};
Events.Condition{n}(ismember(Events.Condition{n},[4 6 8]))=nan;
%Events.ConditionLabel{n}(ismember(Events.Condition{n},[4 6 8]))=nan;
Events.Condition{n}(ismember(Events.Condition{n},[2]))=10;
Events.Condition{n}(ismember(Events.Condition{n},[3]))=3;
Events.Condition{n}(ismember(Events.Condition{n},[5]))=4;
Events.Condition{n}(ismember(Events.Condition{n},[7]))=5;
Events.Condition{n}(ismember(Events.Condition{n},[1]))=2;

Events.Condition{n}(ismember(Events.Condition{n},[10]))=1;

end
%% remove 16 and 24 hour starved flies
for n=1:max(size(Events.Condition))
Events.Condition{n}(Events.Condition{n}>=4)=nan;
end
%% Find how many conditions were present
nCond=unique(cell2mat(cellfun(@unique,Events.Condition,'UniformOutput',false )));
nCond=nCond(~isnan(nCond));

labels=Events.ConditionLabel;%{'1','2','3','5','8'};
% 
% labels=Events.ConditionLabel;%{'1','2','3','5','8'};
% % 
% % labels=labels(1:3);
% nCond=unique(cell2mat(cellfun(@unique,Events.Condition,'UniformOutput',false )));
% nCond=nCond(~isnan(nCond));
% %% Find how many conditions were present
% nCond=unique(cell2mat(cellfun(@unique,Events.Condition,'UniformOutput',false )));
% nCond=nCond(~isnan(nCond));
% 
% labels=Events.ConditionLabel;%{'1','2','3','5','8'};

for x=1:size(Events.Ons,1)
    for y=1:size(Events.Ons,2)
        [BOUT_ENDS_AND_BEGINNINGS_indices,BOUT_ENDS_AND_BEGINNINGS]=GET_FEEDING_BURSTS(Events.Ons{x,y},...
            Events.IFI{x,y},mode(Events.IFI{x,y}).*2,3,0);
        
        try
            
            Events.FeedingBurstOns{x,y}=BOUT_ENDS_AND_BEGINNINGS(:,1);
            Events.FeedingBurstOffs{x,y}=BOUT_ENDS_AND_BEGINNINGS(:,2);
            Events.FeedingBurstDurs{x,y}=BOUT_ENDS_AND_BEGINNINGS(:,2)-BOUT_ENDS_AND_BEGINNINGS(:,1);
            Events.FeedingBurstnEvents{x,y}=BOUT_ENDS_AND_BEGINNINGS(:,3);
            Events.FeedingBurstIBI{x,y}=BOUT_ENDS_AND_BEGINNINGS(2:end,1)-BOUT_ENDS_AND_BEGINNINGS(1:end-1,2);
            Events.RMSEventsIBI{x,y}=Events.RMSEventsOns{x,y}(2:end)-Events.RMSEventsOffs{x,y}(1:end-1);

        catch
            
            Events.FeedingBurstOns{x,y}=[];
            Events.FeedingBurstOffs{x,y}=[];
            Events.FeedingBurstDurs{x,y}=[];
            Events.FeedingBurstnEvents{x,y}=[];
            Events.FeedingBurstIBI{x,y}=[];
            Events.RMSEventsIBI{x,y}=[];

        end
    end
end

for x=1:size(Events.RMSEventsOns,1)
    
    for y=1:size(Events.RMSEventsOns,2)
        
        if numel(Events.RMSEventsOns{x,y}) >=1 ||numel(Events.FeedingBurstOns)>=1
            
            for i=1:numel(Events.RMSEventsOns{x,y})
                
               dummy=Events.FeedingBurstOns{x,y}>=Events.RMSEventsOns{x,y}(i)&Events.FeedingBurstOns{x,y}<=Events.RMSEventsOffs{x,y}(i);
                Events.RMSEventsnBursts{x,y}(i)=sum(dummy);
            end
        else
            Events.RMSEventsnBursts{x,y}=[];
        end
        
     end
     
end
% nBINS=5;
overlap=1;
BinSize=60000;
Step=BinSize/overlap;
% tbins(1:nBINS-1,1)=[1:Dur/nBINS:Dur-Dur/nBINS];
% tbins(1:nBINS-1,2)=tbins(1:nBINS-1,1)+Dur/nBINS;
% 
tbins(:,1)=[1:Step:Dur-BinSize];
tbins(:,2)=tbins(:,1)+BinSize;
% tbins=[1 100000;100000 200000; 200000 300000];%150000 200000;200000 250000;250000 300000];

% tbins=[1 50000;50000 100000; 100000 150000;150000 200000;200000 250000;250000 300000];
 for tt=1:size(tbins,1)
% nTimes=1
CutEvents=CutEventsForTimecourse(Events,tbins(tt,1:2));


Substrate=2;
    
%%  GetAnyEvents_4(Events,@hist,'Durations',labels,binsForHistDurs./100,Colors,binsForHistDurs)
figure1 = figure;
     set(figure1, 'Position', [0 0 screen_size(3) screen_size(4) ] );

height=0.16;
width=0.20;

c=0.2:0.21:1;
r=0.77:-0.28:0;

%% Get number of feeding Events
axes('Parent',figure1,...
    'Position',[c(1) r(3) height width]);

[statsOns{tt} Ons2{tt} Ons2T{tt}]=GetAnyEvents_Choice_noBox(CutEvents,@numel,'Ons',labels,0,Colors,BoxPlotYN,Substrate);
ylabel({'number', 'of feeding events'});

%% number  of RMS  Events
axes('Parent',figure1,...
    'Position',[c(1) r(1) height width]);

[statsRMSEventsOns{tt} RMSEventsOns2{tt} RMSEventsOns2T{tt}]=GetAnyEvents_Choice_noBox(CutEvents,@numel,'RMSEventsOns',labels,0,Colors,BoxPlotYN,Substrate);
% set(gca,'XTickLabel',{' '})
ylabel({'number ', 'of activity bouts,s'});

%% Get mean Durations of RMS  Events
axes('Parent',figure1,...
    'Position',[c(2) r(1) height width]);

[statsRMSEventsDurs{tt} RMSEventsDurs2{tt} RMSEventsDurs2T{tt}]=GetAnyEvents_Choice_noBox(CutEvents,@(x)(mean(x)./100),'RMSEventsDurs',labels,0,Colors,BoxPlotYN,Substrate);
ylabel({'mean duration', 'of activity bouts,s'});

 
 
%% Get total mean Durations of RMS  Events
axes('Parent',figure1,...
    'Position',[c(4) r(1) height width]);

[statsRMSEventsTotalDurs{tt} RMSEventsTotalDurs2{tt} RMSEventsTotalDurs2T{tt}]=GetAnyEvents_Choice_noBox(CutEvents,@(x)(sum(x)./100),'RMSEventsDurs',labels,0,Colors,BoxPlotYN,Substrate);
ylabel({'total duration', 'of activity bouts,s'});


%% Get activity bout IBI
axes('Parent',figure1,...
    'Position',[c(3) r(1) height width]);

[statsRMSEventsIBI{tt} RMSEventsIBI2{tt} RMSEventsIBI2T{tt}]=GetAnyEvents_Choice_noBox(CutEvents,@(x)(mean(x)./100),'RMSEventsIBI',labels,0,Colors,BoxPlotYN,Substrate);
ylabel({'activity bout', 'IBI,s'});


%% get feeding burst number
axes('Parent',figure1,...
    'Position',[c(1) r(2) height width]);

[statsBurstsOns{tt} BurstsOns2{tt} BurstsOns2T{tt}]=GetAnyEvents_Choice_noBox(CutEvents,@numel,'FeedingBurstOns',labels,0,Colors,BoxPlotYN,Substrate);
% set(gca,'XTickLabel',{' '})
ylabel({'number ', 'of feeding bursts'});
%% feeding burst duration

axes('Parent',figure1,...
    'Position',[c(2) r(2) height width]);

[statsBurstsDurs{tt} BurstsDurs2{tt} BurstsDurs2T{tt}]=GetAnyEvents_Choice_noBox(CutEvents,@(x)(mean(x)./100),'FeedingBurstDurs',labels,0,Colors,BoxPlotYN,Substrate);
% set(gca,'XTickLabel',{' '})
ylabel({'mean duration ', 'of feeding bursts, s '});



[statsBurstsnEvents{tt} BurstsnEvents2{tt} BurstsnEvents2T{tt}]=GetAnyEvents_Choice_noBox(CutEvents,@median,'FeedingBurstnEvents',labels,0,Colors,BoxPlotYN,Substrate);
% set(gca,'XTickLabel',{' '})
ylabel({'mean duration ', 'of feeding bursts, s '});


%% feeding burst total duration

axes('Parent',figure1,...
    'Position',[c(4) r(2) height width]);

[statsBurstsTotalDurs{tt} BurstsTotalDurs2{tt} BurstsTotalDurs2{tt}]=GetAnyEvents_Choice_noBox(CutEvents,@(x)(sum(x)./100),'FeedingBurstDurs',labels,0,Colors,BoxPlotYN,Substrate);
% set(gca,'XTickLabel',{' '})
ylabel({'total duration ', 'of feeding bursts, s '});
%% feeding burst IFI
axes('Parent',figure1,...
    'Position',[c(3) r(2) height width]);

[statsBurstsIBI{tt} BurstsIBI2{tt} BurstsIBI2T{tt}]=GetAnyEvents_Choice_noBox(CutEvents,@(x)(mean(x)./100),'FeedingBurstIBI',labels,0,Colors,BoxPlotYN,Substrate);
% set(gca,'XTickLabel',{' '})
ylabel({'mean IFI ', 'of feeding bursts, s '});


axes('Parent',figure1,...
    'Position',[c(3) r(3) height width]);
close
 end
 %% activity bout durations 8 h starved
 figure;
%  subplot(1,3,1)
%  boxplot([RMSEventsDurs2{1}(:,1) RMSEventsDurs2{2}(:,1) RMSEventsDurs2{3}(:,1)],'notch','on') % RMSEventsDurs2{4}(:,1) RMSEventsDurs2{5}(:,1) RMSEventsDurs2{6}(:,1) ])
%  title(' ff')
%   subplot(1,3,2)
%  boxplot([RMSEventsDurs2{1}(:,2) RMSEventsDurs2{2}(:,2) RMSEventsDurs2{3}(:,2)],'notch','on') % RMSEventsDurs2{4}(:,2) RMSEventsDurs2{5}(:,2) RMSEventsDurs2{6}(:,2) ])
%  title('4h')
%   subplot(1,3,3)
%  boxplot([RMSEventsDurs2{1}(:,3) RMSEventsDurs2{2}(:,3) RMSEventsDurs2{3}(:,3)],'notch','on') % RMSEventsDurs2{4}(:,3) RMSEventsDurs2{5}(:,3) RMSEventsDurs2{6}(:,3) ])
%  title('8h')
%   suptitle('activity bout durations') 
% 

  figure
  subplot(1,2,1)
PlotShitT(RMSEventsDurs2T,0)
  suptitle('activity bout durations') 
  axis tight
      set(gca,'ActivePositionProperty', 'Position')

    subplot(1,2,2)

PlotShitT(BurstsIBI2T,0)
  suptitle('burst IBI') 
    axis tight
        set(gca,'ActivePositionProperty', 'Position')
        
      figure  
  
PlotShitT(BurstsnEvents2T,0)
  suptitle('n sips /burst') 
    axis tight
        set(gca,'ActivePositionProperty', 'Position')
      
        
        

%   subplot(2,2,3)
% 
% PlotShitT(RMSEventsIBI2T,0)
%   suptitle('activity bout IBI') 
%     axis tight
%         set(gca,'ActivePositionProperty', 'Position')
% 
%   subplot(2,2,4)
% 
% PlotShitT(BurstsDurs2T,0)
%   suptitle('burst durations') 
%    axis tight
%     set(gca,'ActivePositionProperty', 'Position')
% 
% 
    
    
    figure
[RMSEventsDurs2TFS_FF RMSEventsDurs2TFS_8h]=PlotShitT(RMSEventsDurs2T,1);
  axis tight
      set(gca,'ActivePositionProperty', 'Position')
      task_14_equate_y_lim_for_subplots
      suptitle('activity bout durations') 
  
        statsRMSDUR8h=pairwise_comparisons(RMSEventsDurs2TFS_8h',0)
        statsRMSDURff=pairwise_comparisons(RMSEventsDurs2TFS_FF',0)

      
figure
[BurstsIBI2TFS_FF BurstsIBI2TFS_8h]=PlotShitT(BurstsIBI2T,1);
    axis tight
        set(gca,'ActivePositionProperty', 'Position')
        task_14_equate_y_lim_for_subplots
          suptitle('burst IBI') 

        statsBurstIBI8h=pairwise_comparisons(BurstsIBI2TFS_8h',0)
        statsBurstIBIff=pairwise_comparisons(BurstsIBI2TFS_FF',0) 
        
    figure
RMSEventsDurs2TFS=PlotShitT(RMSEventsDurs2T,2);
  axis tight
      set(gca,'ActivePositionProperty', 'Position')
      task_14_equate_y_lim_for_subplots
      suptitle('activity bout durations')
      
figure
BurstsIBI2TFS=PlotShitT(BurstsIBI2T,2);
    axis tight
        set(gca,'ActivePositionProperty', 'Position')
        task_14_equate_y_lim_for_subplots    
              suptitle('burst IBI')

        stop
        
figure
RMSEventsIBI2TFS= PlotShitT(RMSEventsIBI2T,1);
  suptitle('activity bout IBI') 
    axis tight
        set(gca,'ActivePositionProperty', 'Position')
        task_14_equate_y_lim_for_subplots
figure
BurstsDurs2TFS=PlotShitT(BurstsDurs2T,1);
  suptitle('burst durations') 
   axis tight
    set(gca,'ActivePositionProperty', 'Position') 
    task_14_equate_y_lim_for_subplots
    
    
    
    
    
    
    stop
    
    
    
  
PlotShit(RMSEventsDurs2,2)
  suptitle('activity bout durations') 
  
PlotShit(BurstsIBI2,1)
  suptitle('burst IBI') 
  
PlotShit(RMSEventsIBI2,1)
  suptitle('activity bout IBI') 
  
PlotShit(BurstsDurs2,1)
  suptitle('burst durations') 
  
  stop
  
RMSDURS2_ff=[];
RMSDURS2_4h=[];
RMSDURS2_8h=[];

for n=1:size(RMSEventsDurs2,2)
    RMSDURS2_ff=[RMSDURS2_ff RMSEventsDurs2{n}(:,1)];
    RMSDURS2_4h=[RMSDURS2_4h RMSEventsDurs2{n}(:,2)];
    RMSDURS2_8h=[RMSDURS2_8h RMSEventsDurs2{n}(:,3)];
    timeLabel{n}=num2str(n);
end


figure
 subplot(1,3,1)
 Median_CI_PLot(RMSDURS2_ff,timeLabel)%,'notch','on') % RMSEventsDurs2{4}(:,1) RMSEventsDurs2{5}(:,1) RMSEventsDurs2{6}(:,1) ])
 title(' ff')
  subplot(1,3,2)
 Median_CI_PLot(RMSDURS2_4h,timeLabel)%,'notch','on') % RMSEventsDurs2{4}(:,2) RMSEventsDurs2{5}(:,2) RMSEventsDurs2{6}(:,2) ])
 title('4h')
  subplot(1,3,3)
 Median_CI_PLot(RMSDURS2_8h,timeLabel)%,'notch','on') % RMSEventsDurs2{4}(:,3) RMSEventsDurs2{5}(:,3) RMSEventsDurs2{6}(:,3) ])
 title('8h')
  suptitle('activity bout durations') 
  
  
Median_CI_PLot


% h=boxplot(...)
% set(h(7,:),'Visible','off') 

     figure;
 subplot(1,3,1)
 h=boxplot([BurstsIBI2{1}(:,1) BurstsIBI2{2}(:,1) BurstsIBI2{3}(:,1) ])%BurstsIBI2{4}(:,1) BurstsIBI2{5}(:,1) BurstsIBI2{6}(:,1)])
 set(h(7,:),'Visible','off') 
 title('ff')
  subplot(1,3,2)
h= boxplot([BurstsIBI2{1}(:,2) BurstsIBI2{2}(:,2) BurstsIBI2{3}(:,2) ])%BurstsIBI2{4}(:,2) BurstsIBI2{5}(:,2) BurstsIBI2{6}(:,2)])
set(h(7,:),'Visible','off') 
title('4h')
  subplot(1,3,3)
h= boxplot([BurstsIBI2{1}(:,3) BurstsIBI2{2}(:,3) BurstsIBI2{3}(:,3) ])%BurstsIBI2{4}(:,3) BurstsIBI2{5}(:,3) BurstsIBI2{6}(:,3)])
set(h(7,:),'Visible','off') 
title('8h')
  suptitle('Bursts IBI') 
  stop
  
 figure;
 subplot(1,3,1)
 boxplot([RMSEventsIBI2{1}(:,1) RMSEventsIBI2{2}(:,1) RMSEventsIBI2{3}(:,1) ])
 title(' ff')
  subplot(1,3,2)
 boxplot([RMSEventsIBI2{1}(:,2) RMSEventsIBI2{2}(:,2) RMSEventsIBI2{3}(:,2) ])
 title('4h')
  subplot(1,3,3)
 boxplot([RMSEventsIBI2{1}(:,3) RMSEventsIBI2{2}(:,3) RMSEventsIBI2{3}(:,3) ])
 title('8h')
  suptitle('activity bout IBI') 
     figure;
 subplot(1,3,1)
 boxplot([BurstsDurs2{1}(:,1) BurstsDurs2{2}(:,1) BurstsDurs2{3}(:,1) ])
 title('ff')
  subplot(1,3,2)
 boxplot([BurstsDurs2{1}(:,2) BurstsDurs2{2}(:,2) BurstsDurs2{3}(:,2) ])
 title('4h')
  subplot(1,3,3)
 boxplot([BurstsDurs2{1}(:,3) BurstsDurs2{2}(:,3) BurstsDurs2{3}(:,3) ])
 title('8h')
  suptitle('Bursts duration') 

  

  
  
     figure;
 subplot(1,3,1)
 boxplot([Ons2{1}(:,1) Ons2{2}(:,1) Ons2{3}(:,1) ])
 title('ff')
  subplot(1,3,2)
 boxplot([Ons2{1}(:,2) Ons2{2}(:,2) Ons2{3}(:,2) ])
 title('4h')
  subplot(1,3,3)
 boxplot([Ons2{1}(:,3) Ons2{2}(:,3) Ons2{3}(:,3) ])
 title('8h')
  suptitle('number of feeding events') 
 
 %% activity bout durations 8 h starved
 figure;boxplot([RMSEventsDurs2{1}(:,3) RMSEventsDurs2{2}(:,3) RMSEventsDurs2{3}(:,3) ])

 
stop
stepFactor=1000;
cumFeeding=CumulativeFeedingEvents(Events,2,1,labels,Colors,Dur);

ylabel({'cumulative number','of feeding events'})
xlabel('time,s')
axis tight
stop
for n=1:size(cumFeeding,2)
    for m=1:size(cumFeeding{n},1)
[p{n}(m,:) S{n}(m,:) ]= polyfit([1:stepFactor:size(cumFeeding{n},2)],cumFeeding{n}(m,1:stepFactor:end),2);
    end
end

Coeff1{1}=p{1}(:,1);
Coeff1{2}=p{2}(:,1);
Coeff1{3}=p{3}(:,1);

Coeff2{1}=p{1}(:,2);
Coeff2{2}=p{2}(:,2);
Coeff2{3}=p{3}(:,2);

Coeff3{1}=p{1}(:,3);
Coeff3{2}=p{2}(:,3);
Coeff3{3}=p{3}(:,3);

figure
subplot(1,3,1)
boxplot(cell2mat(Coeff1),labels,'notch','on')
subplot(1,3,2)
boxplot(cell2mat(Coeff2),labels,'notch','on')
subplot(1,3,3)
boxplot(cell2mat(Coeff3),labels,'notch','on')

%% Get number of feeding Bursts per activity bout
axes('Parent',figure1,...
    'Position',[c(2) r(3) height width]);

statsRMSEventsnBursts=GetAnyEvents_fig4_4_noBox(Events,@mean,'RMSEventsnBursts',labels,0,Colors,BoxPlotYN);
ylabel({'number of feeding bursts/','activity bout'});
stop
%% PSTHs

EqualizedYN=0;
PreTime=-100;
PostTime=2500;
plotYN=1;
Substrate=2;

axes('Parent',figure1,...
    'Position',[c(2) r(3) height width]);
[ons RMSOns RMSDurs]=GetFormatedDataForFeedingRates(Events,Substrate);
[BinnedDataDY Centers blaMean] = GetBinnedData_Updated_Events_fig4(ons,BinSize,SW,Dur,PreTime, PostTime, RMSOns,RMSDurs,Events.ConditionLabel,Colors,plotYN,EqualizedYN);

title(Events.SubstrateLabel{Substrate})
%  suptitle('PSTHs unequalized')
xlim([-5 PostTime./100])
ylim([0 1])
ylabel({'probability of', 'feeding event'})
xlabel('time from touch onset,s')
axis tight
stop