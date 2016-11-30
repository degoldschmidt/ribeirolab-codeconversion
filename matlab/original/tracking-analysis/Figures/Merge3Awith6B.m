%% Saving data from EXP 6B - To Run only if 6B data is loaded!
lsubs=1;
EXP6ALabels={'Mated AA-,  n=15';...
    'Virgin AA-,  n=14';...
    'Mated AA+ (Yaa),  n=26';...
    'Virgin AA+ (Yaa),  n=15'};
Variables6B=struct('Labels',EXP6ALabels,'TotaltimesHmm',[],...
    'InlineYV',[],'pYEng3',[],'pYEng4',[],'FractYNE',[],'NYVisits',[],'NYBouts3',[],'AvYVDur',[]);
lcondcounter=0;
for lcond=unique(params.ConditionIndex)
    lcondcounter=lcondcounter+1;
    %%% Total times Hmm
    Variables6B(lcondcounter).TotaltimesHmm=sum(CumTimeH{lsubs}(:,params.ConditionIndex==lcond));%fr
    %%% Inline Yeast visits
    temp=[];
    for lfly=params.IndexAnalyse
        temp=[temp;DurInV{lfly}(DurInV{lfly}(:,1)==lsubs,5)/50];
    end
    Variables6B(lcondcounter).InlineYV=temp;
    
end
save([Variablesfolder 'Variables6B ' date '.mat'],'Variables6B','-v7.3')
load('E:\Analysis Data\Experiment 0006\Variables\Variables6B 30-Nov-2015.mat')
%% Saving data from EXP 3A - To Run only if 3A data is loaded!
EXP3AR1_4Labels={'Mated AA+ (Hunt),  n=34';...
    'Virgin AA+ (Hunt),  n=31';...
    'Mated AA-,  n=35';...
    'Virgin AA-,  n=36'};
Variables3AR1_4=struct('Labels',EXP3AR1_4Labels,'TotaltimesHmm',[],...
    'InlineYV',[],'pYEng3',[],'pYEng4',[],'FractYNE',[],'NYVisits',[],'NYBouts3',[],'AvYVDur',[]);
lcondcounter=0;
for lcond=unique(params.ConditionIndex)
    lcondcounter=lcondcounter+1;
    Variables3AR1_4(lcondcounter).TotaltimesHmm=sum(CumTimeH{lsubs}(:,params.ConditionIndex==lcond));%fr
end
save([Variablesfolder 'Variables3AR1_4 ' date '.mat'],'Variables3AR1_4','-v7.3')
%% Merging data sets
Variables3A6AR1_4=struct('Labels',cell(5,1),'TotaltimesHmm',[],...
    'InlineYV',[],'pYEng3',[],'pYEng4',[],'FractYNE',[],'NYVisits',[],'NYBouts3',[],'AvYVDur',[]);
Variables3A6AR1_4(1)=Variables6B(4);%Virgin AA+ Yaa (6A)
Variables3A6AR1_4(2)=Variables3AR1_4(4);%Virgin AA- (3AR1_4)
Variables3A6AR1_4(3)=Variables6B(3);%Mated AA+ (Yaa) (6A)
Variables3A6AR1_4(4)=Variables3AR1_4(1);%Mated AA+ Hunt (3AR1_4)
Variables3A6AR1_4(5)=Variables3AR1_4(3);%Mated AA- (3AR1_4)
Labelsmergedshort={'V AA+';'V AA-';'M AA+';'M AA+ sub';'M AA-'};
save([Variablesfolder 'Variables3A6AR1_4 ' date '.mat'],'Variables3A6AR1_4','Labelsmergedshort','-v7.3')
load('E:\Analysis Data\Experiment 0003\Variables\Variables3A6AR1_4 30-Nov-2015.mat')