function [CumTime_FlyPAD_Cond, OnsFlyPAD_Cond, DursFlyPAD_Cond]=...
    CumulativeActB_or_FeedBurst(Events,lsubs,MaxSample,FlyPAD_var)
%[CumTimeAB_FlyPAD_Cond, OnsABFlyPAD_Cond, DursABFlyPAD_Cond]=...
%     CumulativeActivityBouts(Events,lsubs,MaxSample,plotYN,microstr_var)
% if plotYN=1, plots cumulative of selected variable described in
% microstr_var as 'Feeding Bursts' or 'Activity Bouts'

Conditions=unique(cell2mat(cellfun(@unique,Events.Condition,'UniformOutput',false )));
Conditions=Conditions(~isnan(Conditions));

%%
AllvarsRunsConds=cell(3,1);%1:ActBoutsOnsets,2:ActBoutsOffsets,3:ActBoutsDurs
Allkus=cell(3,1);
All_VARS=cell(3,1);
if strfind(FlyPAD_var,'Feeding Bursts')
    labelvar={'FeedingBurstOns','FeedingBurstDurs'};
elseif strfind(FlyPAD_var,'Activity Bouts')
    labelvar={'RMSEventsOns','RMSEventsDurs'};
else
    error('Options for microstr_var are ''Activity Bouts'' or ''Feeding Bursts''')
end

for lvar=1:2
    AllvarsRunsConds{lvar}=cell(size(Events.(labelvar{lvar}),1),length(Conditions));
    for nRuns=1:size(Events.(labelvar{1}),1)
        % get number of events per condition
        for C=Conditions
            AllvarsRunsConds{lvar}{nRuns,C}=Events.(labelvar{lvar})(nRuns,Events.Substrate{nRuns}==lsubs&Events.Condition{nRuns}==Conditions(C));%Rows: Runs, Cols: conditions
        end
    end
    
    
    for lcond=1:size(AllvarsRunsConds{lvar},2)
        Allkus{lvar}=[];
        for m=1:size(AllvarsRunsConds{lvar},1)
            Allkus{lvar}=[Allkus{lvar} AllvarsRunsConds{lvar}{m,lcond}];
        end
        
        for lchannel=1:max(size(Allkus{lvar}))
            All_VARS{lvar}{lchannel,lcond}=Allkus{lvar}{lchannel};%Rows:channels/flies,Cols=Conditions
        end
    end
    
end
%%
for x=1:size(All_VARS{1},1)
    for y=1:size(All_VARS{1},2)
        DUR{x,y}=MaxSample;
    end
end

CumTimeAB_Fly_Cond=cellfun(@CumulativeAB,All_VARS{1},All_VARS{2},DUR,'UniformOutput',false);

CumTime_FlyPAD_Cond=cell(1,size(CumTimeAB_Fly_Cond,2));
for lcond=1:size(CumTimeAB_Fly_Cond,2)
    CumTime_FlyPAD_Cond{lcond}=cell2mat(CumTimeAB_Fly_Cond(:,lcond))';
end
OnsFlyPAD_Cond=All_VARS{1};
DursFlyPAD_Cond=All_VARS{2};


end

function CumTimeAB_Fly=CumulativeAB(Onsets,Durations,MaxSample)

BinaryAB=zeros(1,1.5*MaxSample);
for lbout=1:length(Onsets)
%     BinaryAB(Onsets(lbout):Offsets(lbout)-1)=ones(1,Durations(lbout));
    BinaryAB(Onsets(lbout):Onsets(lbout)+Durations(lbout)-1)=ones(1,Durations(lbout));
end
BinaryAB(MaxSample:end)=[];%
CumTimeAB_Fly=cumsum(BinaryAB);
end
