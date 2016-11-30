clear all
close all

%% Changes from the previous verisons and instructions

% 1. This code save the name of the file you are using, so you can backtrack which version you used to analyse your data
% 2. I have added the condition headers to the _excel data file 
% 3. I have added 3 new measures of feeding behavior and now you will have several more new figures and statistics   
% a. number of feeding bursts for activity bouts
% b. latency of feeding bursts within the activity bouts (in samples)
% c. fraction of feeding activity bouts with 2 or more feeding bursts
% 

%% How to use it:
% set this to variable to the maximum duration of the assay in samples 
Dur=360000;
Events.ThisScriptName = mfilename('fullpath');

% specify whether or not you want to remove substrate non eaters(this will remove all the data from channels which had less than 'NonEaterThreshold' activity bouts ) 


RemoveSubstrateNoneaters=0; % 0- do not do anything, 1- remove , 
% specify whether or not you want to remove global non eaters(this will remove all the data from flies which had less than 'NonEaterThreshold' activity bouts on both of the channels) 

RemoveGlobalNoneaters=0;% 0- do not do anything, 1- remove
NonEaterThreshold=2;

% if this variables is set to '1' it will run a quality check and remove
% the flies  which had suspected leak of food between the internal and the
% outer electrodes
RemoveSpillQuality=1;% 0- do not do anything, 1- remove
RemoveSpillQualityThreshold=0.01;
PlotYN{1}='Y';
secRecording=5; % duration of act bouts to plot

SaveEps=1;% save eps format
VeroTypeStatsFile=0; % Which format of stats should you use(I recommend 0)
PreSipForm=10; % irrelevant
PostSipForm=10; % irrelevant
Different_Subs=0;%Default is 0 (No comparison between channels).
%   Write 2 if
%%% all substrates are the same across conditions,
%%% but you want to see the results of channel 1 vs channel 2 for each condition.
%
%%% Write 1 if the substrates are different in different conditions and
%%% then fill the substrates in Events.Diff_Subs_Labels.
%%% 2 columns for the 2 substrates and 1 row per condition (as many rows as conditions you have).
%%% Example: if you have 6 conditions, this cell should have 6 rows.
%%% Even if that implies that 3 of them are repeated.
prompt = {'use existing datafile?'};
dlg_title = 'use existing datafile?';
num_lines = 1;
def = {'0'};
AnswerT = inputdlg(prompt,dlg_title,num_lines,def,'on');

if str2double(AnswerT)==0
    %% This is the name of the file where the data will be stored
    [DataFilename DataPathName ]= uiputfile;
    if strcmp(DataFilename(end-3:end),'.rpt')
    DataFilename(end-3:end)='.mat';
    end
    
    DataFilename2=[DataPathName DataFilename];
    
    %% Put analysis parameters here
    % these are the labels for different conditions
    
    Events.ConditionLabel{1}= 'AA+';
    Events.ConditionLabel{2}= 'AA-';
%     Events.ConditionLabel{3}= 'Mated AA-';
%     Events.ConditionLabel{4}= 'Virgin AA-';    
%     Events.ConditionLabel{1}= 'T\betaH Mated, SAA (Hunt)';
%     Events.ConditionLabel{1}= 'T\betaH Virgin, SAA (Hunt)';
%     Events.ConditionLabel{1}= 'T\betaH Mated, S';
%     Events.ConditionLabel{2}= 'T\betaH Virgin, S';    

    
    
    %% These are the labels for substrates (what goes on channel 1 and 2)
    Events.SubstrateLabel{1}='Yeast 18%';
    Events.SubstrateLabel{2}='Sucrose 18%';
    
    if Different_Subs==1
        Events.SubstrateLabel{1}='Channel 1';
        Events.SubstrateLabel{2}='Channel 2';
        
        Events.Diff_Subs_Labels={'1-Hunt','2-molFly';...
            '1-Hunt','2-Hunt';...
            '1-molFLY','2-molFLY';...
            '1-HUNT','2-molFLY(noR)';...
            '1-molFly','2-HUNT(moreR)'};
        
    elseif Different_Subs==2
        
        for lcond=1:size(Events.ConditionLabel,2)
            Events.Diff_Subs_Labels{lcond,1}=Events.SubstrateLabel{1};
            Events.Diff_Subs_Labels{lcond,2}=Events.SubstrateLabel{2};
        end
    end
    
    
    %% This Line defines which channels(devices) should be annotated as to be removed
    Remove=[ ];%% !!!!!!!!!! CheckThis line always!!!!
    
    %% Don`t change anything below this point !!!!
    DatabaseOffset=0;
    
    nCond=max(size(Events.ConditionLabel));
    colors = distinguishable_colors(nCond+1);
    Colors=cell(size(colors,1),1);
    
    for n=1:size(colors,1)
        Colors{n}=colors(n,:);
    end
    
    %% Settings
    Threshold1=30000;
    Threshold2=4095;
    Channels=[1 2;3 4; 5 6; 7 8; 9 10;11 12; 13 14;15 16;17 18;19 20;21 22;23 24;25 26;27 28;29 30;31 32;33 34;35 36;37 38;39 40;41 42;43 44;45 46;47 48;49 50;51 52;53 54;55 56;57 58;59 60;61 62; 63 64];
    ChannelsToRemove=Channels(Remove,:);
    ChannelsToRemove=ChannelsToRemove(~isnan(ChannelsToRemove));
    DateOffset=4;
    RMSWindow=50;
    PlayFrameRate=10;
    RMSThresh=10;
    Window=100;% maximum duration of the sip in samples
    MinWindow=4; % minimum duration of the bout in samples
    EqualityFactor=0.5; % set to 50 % , meaning that the down transition should be at least 50 % the size of the up transition
    ProximityWindow=MinWindow+3; % How many samples far should the transitions be
    
    
    
    
    %% Don`t change anything below this point !!!!
    DatabaseOffset=0;
    
    
    currentDir=DataPathName;
    cd(currentDir)
    fileList = getAllFiles(currentDir);
    numel(currentDir)
    z=nan(size(size(fileList,1)));
    for n=1:size(fileList,1)
        
        namez=fileList{n,1};
        z(n)=numel(strfind(namez,'CapacitanceData'));
        
    end
    %% Manually set for quickness
    CapFilenames=fileList(logical(z));
    for FileNameCounter=1:size(CapFilenames,1)
        CapFilename=CapFilenames{FileNameCounter,1};
        CapFilename=CapFilename(numel(currentDir)+1:end);
        %% Extract from the filename which channel is yeast and which is sucrose
        fileID=fopen(CapFilename);
        CapData=fread(fileID,'ushort');
        CapData=reshape(CapData,64,size(CapData,1)/64);
        
        
        %     Dur=nan;
        c=0;
        test=CapData';
        
        
        
        if ~isnan(Dur)
            test=test(1:Dur,:);
        else
            test=test(1:end,:);
            Dur=size(test,1);
        end
        test(test==-1)=0;
        %% This bit of code removes glitches assuming that any sample larger than 30000 is a communication error
        %     icount=0;
        %         stopTrying=0;
        %
        %
        %         [test uncleaned PercentGlitches]=GlitchRemover_Complex(test,Threshold1,Threshold2);
        %%
        nChannels=size(test,2);
        
        C(1,1)=str2double([CapFilename(strfind(CapFilename,'C01')+4) CapFilename(strfind(CapFilename,'C01')+5)]);
        C(1,2)=str2double([CapFilename(strfind(CapFilename,'C01')+7) CapFilename(strfind(CapFilename,'C01')+8)]);
        
        C(2,1)=str2double([CapFilename(strfind(CapFilename,'C02')+4) CapFilename(strfind(CapFilename,'C02')+5)]);
        C(2,2)=str2double([CapFilename(strfind(CapFilename,'C02')+7) CapFilename(strfind(CapFilename,'C02')+8)]);
        
        C(3,1)=str2double([CapFilename(strfind(CapFilename,'C03')+4) CapFilename(strfind(CapFilename,'C03')+5)]);
        C(3,2)=str2double([CapFilename(strfind(CapFilename,'C03')+7) CapFilename(strfind(CapFilename,'C03')+8)]);
        
        C(4,1)=str2double([CapFilename(strfind(CapFilename,'C04')+4) CapFilename(strfind(CapFilename,'C04')+5)]);
        C(4,2)=str2double([CapFilename(strfind(CapFilename,'C04')+7) CapFilename(strfind(CapFilename,'C04')+8)]);
        
        C(5,1)=str2double([CapFilename(strfind(CapFilename,'C05')+4) CapFilename(strfind(CapFilename,'C05')+5)]);
        C(5,2)=str2double([CapFilename(strfind(CapFilename,'C05')+7) CapFilename(strfind(CapFilename,'C05')+8)]);
        
        C(6,1)=str2double([CapFilename(strfind(CapFilename,'C06')+4) CapFilename(strfind(CapFilename,'C06')+5)]);
        C(6,2)=str2double([CapFilename(strfind(CapFilename,'C06')+7) CapFilename(strfind(CapFilename,'C06')+8)]);
        
        C(7,1)=str2double([CapFilename(strfind(CapFilename,'C07')+4) CapFilename(strfind(CapFilename,'C07')+5)]);
        C(7,2)=str2double([CapFilename(strfind(CapFilename,'C07')+7) CapFilename(strfind(CapFilename,'C07')+8)]);
        
        C(8,1)=str2double([CapFilename(strfind(CapFilename,'C08')+4) CapFilename(strfind(CapFilename,'C08')+5)]);
        C(8,2)=str2double([CapFilename(strfind(CapFilename,'C08')+7) CapFilename(strfind(CapFilename,'C08')+8)]);
        
        C(9,1)=str2double([CapFilename(strfind(CapFilename,'C09')+4) CapFilename(strfind(CapFilename,'C09')+5)]);
        C(9,2)=str2double([CapFilename(strfind(CapFilename,'C09')+7) CapFilename(strfind(CapFilename,'C09')+8)]);
        
        C(10,1)=str2double([CapFilename(strfind(CapFilename,'C10')+4) CapFilename(strfind(CapFilename,'C10')+5)]);
        C(10,2)=str2double([CapFilename(strfind(CapFilename,'C10')+7) CapFilename(strfind(CapFilename,'C10')+8)]);
        
        S=cell(numel(11:99),1);
        C(11:99,1:2)=nan(numel(11:99),2);
        for n = 11:99
            
            S{n}=['C' num2str(n)];
            C(n,1)=str2double([CapFilename(strfind(CapFilename,S{n})+4) CapFilename(strfind(CapFilename,S{n})+5)]);
            C(n,2)=str2double([CapFilename(strfind(CapFilename,S{n})+7) CapFilename(strfind(CapFilename,S{n})+8)]);
            
        end
        
        Events.Condition{FileNameCounter}=nan(1,64);
        
        %%
        
        if strfind(CapFilename,'SCRAMBLED')>0
            Events.Condition{FileNameCounter}(1:10)=1;
            Events.Condition{FileNameCounter}(11:20)=2;
            Events.Condition{FileNameCounter}(21:30)=3;
            Events.Condition{FileNameCounter}([31 32 57:64])=4;
            Events.Condition{FileNameCounter}([41 42 49:56])=5;
            Events.Condition{FileNameCounter}([33:36 43:64])=6;
            
        else
            %             for n=1:size(C,1)
            %                 if ~isnan(C(n,:))
            %                     Events.Condition{FileNameCounter}(C(n,1):C(n,2))=n;
            %                 end
            %             end
            for n=find(~isnan(C(:,1)))'
                
                Events.Condition{FileNameCounter}(C(n,1):C(n,2))=n;
                if (Different_Subs==1)||(Different_Subs==2)
                    Events.Condition_Substrate{FileNameCounter}(C(n,1):2:C(n,2))=2*n-1;
                    Events.Condition_Substrate{FileNameCounter}(C(n,1)+1:2:C(n,2))=2*n;
                end
                
                
            end
        end
        
        
        
        
        
        
        %%
        Events.Yeast{FileNameCounter}=zeros(1,64);
        Events.Yeast{FileNameCounter}(1:2:64)=1;
        Events.Sucrose{FileNameCounter}=zeros(1,64);
        Events.Sucrose{FileNameCounter}(2:2:64)=1;
        Events.Substrate{FileNameCounter}=zeros(1,64);
        Events.Substrate{FileNameCounter}(1:2:64)=1;
        Events.Substrate{FileNameCounter}(2:2:64)=2;
        %         Events.Colors{FileNameCounter}=Colors;
        
        ToRemove=Channels(Remove,:);
        Events.ToRemove{FileNameCounter}=zeros(1,64);
        Events.ToRemove{FileNameCounter}(sort(ToRemove(~isnan(ToRemove))))=1;
        %% this code defines which channels correspond to which condition
        Events.ChannelsToRemove{FileNameCounter+DatabaseOffset}=ChannelsToRemove;
        Events.Date{FileNameCounter+DatabaseOffset,1}=CapFilename(strfind(CapFilename,'201'):strfind(CapFilename,'201')+9);
        time=CapFilename(strfind(CapFilename,'201')+11:end);
        time([3 6])=':';
        Events.Time{FileNameCounter+DatabaseOffset,1}=time;
        %% Filtering
        filteredTraces=nan(size(test));
        for i = 1:1:size(test,2)
            c=c+1 %#ok<NOPTS>
            Ch1=test(:,i);
            span=50;
            window = ones(span,1)/span;
            filteredTraces(:,i) = convn(Ch1,window,'same');
        end
        RfilteredTraces=test-filteredTraces;
        %% remove the edges
        RfilteredTraces([1:span end-span:end],:)=0;
        test([1:span end-span:end],:)=0;
        %% get the RMS
        testRMS= fastrms(RfilteredTraces,RMSWindow,1,0);
        %%
        RRfilteredTraces=RfilteredTraces(2:end,:);
        FDerivative=diff(RfilteredTraces);
        %% use Quiroga`s method to find the signal
        clear thrPos thrNeg PosEvents NegEvents
        
        %% Dyn Thresh
        Window_For_Threshold=300;
        for n=1:size(FDerivative,2);
            
            FDerivativePos=FDerivative(:,n);
            FDerivativeNeg=FDerivative(:,n);
            c=1;
            Count=0;
            for m=1:Window_For_Threshold:size(FDerivative,1)-Window_For_Threshold
                c=c+Window_For_Threshold;
                Count=Count+1;
                Fpos=FDerivativePos(m:c);
                Fneg=FDerivativeNeg(m:c);
                thrPos{n,Count}=4.*median(Fpos(Fpos>1))./0.6745;
                
                thrNeg{n,Count}=4.*median(Fneg(Fneg<-1))./0.6745;
                
                PosEvents(n,m:c)=FDerivative(m:c,n)>thrPos{n,Count};
                NegEvents(n,m:c)=FDerivative(m:c,n)<thrNeg{n,Count};
                
            end
        end
        
        %%
        RRfilteredTraces=RfilteredTraces(2:end,:);
        TimeStamps=(1:size(RRfilteredTraces,1))./100;
        
        %% Assign zeros to all signals that are not defined as events
        FFDerivative=zeros(size(FDerivative));
        derivativeForFigure=FDerivative;
        
        clear NE PE
        for n=1:size(NegEvents,1)
            
            NE=logical(NegEvents(n,:))';
            PE=logical(PosEvents(n,:))';
            FunDerivative=FDerivative(:,n);
            FuckingDerivative=FDerivative(:,n);
            FunDerivative(:,:)=0;
            FunDerivative(NE)=FuckingDerivative(NE);
            FunDerivative(PE)=FuckingDerivative(PE);
            FFDerivative(:,n)=FunDerivative;
        end
        
        FDerivative=FFDerivative;
        ChosenOnes=false(size(NegEvents));
        ChosenOnes=ChosenOnes';
        
        for nChanels=1:size(RRfilteredTraces,2)
            if sum(abs(FDerivative(:,nChanels)))>10
                disp(nChanels)
                [~,locsPos]=findpeaks(FDerivative(:,nChanels),'minpeakdistance',ProximityWindow);
                [~,locsNeg]=findpeaks(-1.*FDerivative(:,nChanels),'minpeakdistance',ProximityWindow);
                ChosenOnes(locsPos,nChanels)=true;
                ChosenOnes(locsNeg,nChanels)=true;
            else
            end
        end
        
        %% see what happened
        PPosEvents=PosEvents&ChosenOnes';
        NNegEvents=NegEvents&ChosenOnes';
        %remove the filtered events from the derivative signal
        for n=1:size(NNegEvents,1)
            
            NE=NNegEvents(n,:)';
            PE=PPosEvents(n,:)';
            FunDerivative=FDerivative(:,n);
            FuckingDerivative=FDerivative(:,n);
            FunDerivative(:,:)=0;
            FunDerivative(NE)=FuckingDerivative(NE);
            FunDerivative(PE)=FuckingDerivative(PE);
            FFDerivative(:,n)=FunDerivative;
        end
        
        FDerivative=FDerivative(1:max(size(PosEvents)),:);
        RRfilteredTraces=RRfilteredTraces(1:max(size(PosEvents)),:);
        RfilteredTraces=RfilteredTraces(1:max(size(PosEvents)),:);
        TimeStamps=TimeStamps(:,1:max(size(PosEvents)));
        test=test(1:max(size(PosEvents)),:);
        %% While version
        for nChannels=1:size(test,2)
            clear trace PosEvents NegEvents EventCounter CurrentIndexUp
            clear EventDuration indNeg indPos
            
            trace=FFDerivative(:,nChannels);
            PosEvents=find(PPosEvents(nChannels,:));
            NegEvents=find(NNegEvents(nChannels,:));
            EventCounter=0;
            disp(nChannels)
            if numel(PosEvents)>=2
                CurrentIndexUp=PosEvents(1);
                
                while CurrentIndexUp<size(trace,1)
                    offset=CurrentIndexUp;
                    
                    % if the window doesnt go out of the range and if there is an event in the window
                    if (CurrentIndexUp+Window < numel(trace))
                        
                        % if there are negative events in window
                        if find(NegEvents>CurrentIndexUp  & NegEvents<CurrentIndexUp+Window)
                            
                            % If there are negative events of the right size
                            if  find(trace(CurrentIndexUp:CurrentIndexUp+Window)<=(trace(CurrentIndexUp)*-EqualityFactor),1,'first')>=MinWindow;
                                EventCounter=EventCounter+1;
                                indNeg(EventCounter)=find(trace(CurrentIndexUp:CurrentIndexUp+Window)<=(trace(CurrentIndexUp)*-EqualityFactor),1,'first')+offset-1;
                                indPos(EventCounter)=CurrentIndexUp;
                                EventDuration(EventCounter)=indNeg(EventCounter)-indPos(EventCounter);
                                
                                % if there are positive events after this negative then
                                % update the CurrentIndexUp
                                if find(PosEvents>indNeg(EventCounter),1,'first')
                                    CurrentIndexUp=PosEvents(find(PosEvents>indNeg(EventCounter),1,'first'));
                                else %% otherwise exit the while loop
                                    CurrentIndexUp=size(trace,1);
                                end
                            else
                                if numel(PosEvents)<=(find(PosEvents==CurrentIndexUp)+1)
                                    CurrentIndexUp=size(trace,1);
                                else
                                    CurrentIndexUp=PosEvents(find(PosEvents==CurrentIndexUp)+1);
                                end
                            end
                        else
                            if numel(PosEvents)<=(find(PosEvents==CurrentIndexUp)+1)
                                CurrentIndexUp=size(trace,1);
                            else
                                CurrentIndexUp=PosEvents(find(PosEvents==CurrentIndexUp)+1);
                            end
                        end
                    else
                        
                        % If there are negative events of the right size
                        if  find(trace(CurrentIndexUp:end)<=(trace(CurrentIndexUp)*-EqualityFactor),1,'first')>=MinWindow;
                            EventCounter=EventCounter+1;
                            indNeg(EventCounter)=find(trace(CurrentIndexUp:end)<=(trace(CurrentIndexUp)*-EqualityFactor),1,'first')+offset-1;
                            indPos(EventCounter)=CurrentIndexUp;
                            EventDuration(EventCounter)=indNeg(EventCounter)-indPos(EventCounter);
                            
                            % if there are positive events after this negative then
                            % update the CurrentIndexUp
                            if find(PosEvents>indNeg(EventCounter),1,'first')
                                CurrentIndexUp=PosEvents(find(PosEvents>indNeg(EventCounter),1,'first'));
                                
                            else %% otherwise exit the while loop
                                CurrentIndexUp=size(trace,1);
                            end
                        else
                            
                            if numel(PosEvents)<=(find(PosEvents==CurrentIndexUp)+1)
                                CurrentIndexUp=size(trace,1);
                            else
                                CurrentIndexUp=PosEvents(find(PosEvents==CurrentIndexUp)+1);
                            end
                        end
                    end
                end
                
                if  exist('indPos','var')
                    Events.Ons{FileNameCounter+DatabaseOffset,nChannels}= indPos;
                    Events.Offs{FileNameCounter+DatabaseOffset,nChannels}= indNeg;
                    Events.Durations{FileNameCounter+DatabaseOffset,nChannels}= EventDuration;
                    Events.IFI{FileNameCounter+DatabaseOffset,nChannels}= indPos(2:end)-indNeg(1:end-1);
                    
                else
                    indNeg=0;
                    indPos=0;
                    EventDuration=0;
                    Events.Ons{FileNameCounter+DatabaseOffset,nChannels}= indPos;
                    Events.Offs{FileNameCounter+DatabaseOffset,nChannels}= indNeg;
                    Events.Durations{FileNameCounter+DatabaseOffset,nChannels}= EventDuration;
                    Events.IFI{FileNameCounter+DatabaseOffset,nChannels}= indPos(2:end)-indNeg(1:end-1);
                    
                end
            else
                
                indNeg=0;
                indPos=0;
                EventDuration=0;
                Events.Ons{FileNameCounter+DatabaseOffset,nChannels}= indPos;
                Events.Offs{FileNameCounter+DatabaseOffset,nChannels}= indNeg;
                Events.Durations{FileNameCounter+DatabaseOffset,nChannels}= EventDuration;
                Events.IFI{FileNameCounter+DatabaseOffset,nChannels}= indPos(2:end)-indNeg(1:end-1);
            end
            
        end
        
        %% use Quiroga`s method to find the RMS threshold
        clear RMSthrPos RMSPosEvents  F_RMS PosDiffFoundEvents NegDiffFoundEvents IndRMSDiffFoundEvents FoundEvents TrueRMSEvents
        
        for n=1:size(testRMS,2);
            F_RMS=testRMS(:,n);
            RMSPosEvents(1:size(testRMS,1),n)=F_RMS>RMSThresh;
        end
        
        for n=1:size(RMSPosEvents,2)
            
            FoundEvents{1,n}=find(RMSPosEvents(:,n));
            PosDiffFoundEvents(:,n)=diff(RMSPosEvents(:,n))>0;
            NegDiffFoundEvents(:,n)=diff(RMSPosEvents(:,n))<0;
            IndRMSDiffFoundEvents{1,n}=find(PosDiffFoundEvents(:,n));
            IndRMSDiffFoundEvents{2,n}=find(NegDiffFoundEvents(:,n));
            IndRMSDiffFoundEvents{3,n}=IndRMSDiffFoundEvents{2,n}-IndRMSDiffFoundEvents{1,n};
        end
        %% keep only RMS events which have at least 1 feeding event inside (to remove false events due to signal drift)
        nRMSEvents=cell(1,size(IndRMSDiffFoundEvents,2));
        
        for n=1:size(IndRMSDiffFoundEvents,2)
            
            for m=1:size(IndRMSDiffFoundEvents{1,n},1)
                TrueRMSEvents{1,n}(m)=sum(Events.Ons{FileNameCounter+DatabaseOffset,n}>=IndRMSDiffFoundEvents{1,n}(m)&Events.Ons{FileNameCounter+DatabaseOffset,n}<=IndRMSDiffFoundEvents{2,n}(m));
                IndRMSDiffFoundEvents{1,n}(TrueRMSEvents{1,n}<=1)=nan;
                IndRMSDiffFoundEvents{2,n}(TrueRMSEvents{1,n}<=1)=nan;
                IndRMSDiffFoundEvents{3,n}(TrueRMSEvents{1,n}<=1)=nan;
                nRMSEvents{1,n}(m)=TrueRMSEvents{1,n}(m);
                nRMSEvents{1,n}(TrueRMSEvents{1,n}<=1)=nan;
            end
        end
        for n=1:size(IndRMSDiffFoundEvents,2)
            IndRMSDiffFoundEvents{1,n}=IndRMSDiffFoundEvents{1,n}(~isnan(IndRMSDiffFoundEvents{1,n}));
            IndRMSDiffFoundEvents{2,n}=IndRMSDiffFoundEvents{2,n}(~isnan(IndRMSDiffFoundEvents{2,n}));
            IndRMSDiffFoundEvents{3,n}=IndRMSDiffFoundEvents{3,n}(~isnan(IndRMSDiffFoundEvents{3,n}));
            nRMSEvents{1,n}= nRMSEvents{1,n}(~isnan( nRMSEvents{1,n}));
        end
        
        %% save in Events structure
        Events.RMSEventsOns(FileNameCounter+DatabaseOffset,1:size(IndRMSDiffFoundEvents,2))=IndRMSDiffFoundEvents(1,:);
        Events.RMSEventsOffs(FileNameCounter+DatabaseOffset,1:size(IndRMSDiffFoundEvents,2))=IndRMSDiffFoundEvents(2,1:size(IndRMSDiffFoundEvents,2));
        Events.RMSEventsDurs(FileNameCounter+DatabaseOffset,1:size(IndRMSDiffFoundEvents,2))=IndRMSDiffFoundEvents(3,1:size(IndRMSDiffFoundEvents,2));
        Events.RMSEventsnEvents(FileNameCounter+DatabaseOffset,1:size(IndRMSDiffFoundEvents,2))=nRMSEvents;
        
        clear IndRMSDiffFoundEvents
        
        %% RawData Figures
        % ACTIVITY BOUTS
        %     Events.SpillQuality(FileNameCounter+DatabaseOffset,64)=nan;
        Events.RawDataOnActBouts{FileNameCounter+DatabaseOffset,64}=[];
        
        for i=1:size(Events.RMSEventsOns,2)
            numelements=numel(Events.RMSEventsOns{FileNameCounter+DatabaseOffset,i});
            Events.SpillQuality{FileNameCounter+DatabaseOffset,i}=(sum(test(:,i)>=4095))./size(test,1);
            if numelements>0
                %             figure
                %             n=round2(numelements,4)/4;
                for fig=1:numelements
                    
                    on=Events.RMSEventsOns{FileNameCounter+DatabaseOffset,i}(fig);
                    
                    if on+(secRecording*100)<Dur
                        Events.RawDataOnActBouts{FileNameCounter+DatabaseOffset,i}(fig,:)=CapData(i,on:on+(secRecording*100));
                    end
                    
                    %                 subplot(4,n,fig)
                    %                 plot(CapData(i,on:on+(secRecording*100)))
                end
            end
        end
        
        
        %% SIP FORMS
        
        Events.SipForms{FileNameCounter+DatabaseOffset,64}=[];
        
        WindowSip= Window+PreSipForm+PostSipForm;
        
        for i=1:size(Events.Ons,2)
            numelements=numel(Events.Ons{FileNameCounter+DatabaseOffset,i});
            if numelements>0
                for n=1:numelements
                    
                    if Events.Ons{FileNameCounter+DatabaseOffset,i}(n)>0
                        on=Events.Ons{FileNameCounter+DatabaseOffset,i}(n);
                        off=Events.Offs{FileNameCounter+DatabaseOffset,i}(n);
                    else
                        break
                    end
                    
                    %                 if on+WindowSip-2<Dur
                    SipFormsVector=NaN(WindowSip+1,1);
                    try
                        SipFormsVector(1:PreSipForm+1+off+PostSipForm-on)=test(on-PreSipForm:off+PostSipForm,i);
                    catch
                        SipFormsVector(1:PreSipForm+1+off-on)=test(on-PreSipForm:off,i);
                    end
                        
                    Events.SipForms{FileNameCounter+DatabaseOffset,i}(n,:)=SipFormsVector';
                    %                 end
                end
            end 
        end
    end
    
    cd
    
%     if strncmp(DataFilename2(end-3:end),'.mat',4)
        save(DataFilename2,'Events','-mat')
%     else
%         DataFilename2(end-3:end)=['.mat'];
%         save([DataFilename2],'Events','-mat')
%         
%     end
    
    
else
    [DataFilename DataPathName]=uigetfile;
end
fclose all
%%
if PlotYN{1}=='Y'
    
    clear Events
    BinSize=100;% How many samples to use to calculate number of feeding events for the timecourse
    PreTime=-200;
    PostTime=1000;
    Comment=[' '];
    Lags=[-100:100];
    
    %% Errorbar or boxplots
    BoxPlotYN=2;
    binsForHistDurs=[1:2:60];
    binsForHistIFI=[1:3:200];
    binsForHistRMSDurs=[1:100:10000];
    Mean_or_Median=1;SW=BinSize;
    JBFILL=0;
    s=pwd;
    screen_size = get(0, 'ScreenSize');
    Substrate=2;
    userpath_name=[s,'\'];
    Preview=0;
    Comment='';
    Resolution=300;
    SaveFig=1;
    cd (DataPathName)
    filename1=DataFilename;
    load (filename1,'Events','-mat')
    check_filename_delete_if_exists_for_mrep(userpath_name,filename1)
    secondVar=cell(size(Events.SubstrateLabel));
    for n=1:size(secondVar,2)
        secondVar{n}='blank';
    end
    blanks=cellfun(@strmatch,Events.SubstrateLabel,secondVar,'UniformOutput',false);
    
    
    for nRows=1:size(Events.Ons,1)
        Events.Condition{nRows}(logical(Events.ToRemove{nRows}))=nan;
    end
    
    %% this remove flies with less than 2 activity bouts from the analysis3
    if RemoveSubstrateNoneaters
        for x=1:size(Events.RMSEventsOns,1)
            for y=1:size(Events.RMSEventsOns,2)
                if numel(Events.RMSEventsOns{x,y})<=NonEaterThreshold
                    Events.Condition{x}(1,y)=nan;
                    Events.Ons{x,y}=[];
                    Events.Offs{x,y}=[];
                    Events.Durations{x,y}=[];
                    Events.IFI{x,y}=[];
                    Events.RMSEventsOns{x,y}=[];
                    Events.RMSEventsOffs{x,y}=[];
                    Events.RMSEventsDurs{x,y}=[];
                    Events.RMSEventsnEvents{x,y}=[];
                end
            end
        end
        
    else
    end
    
    nCond=max(size(Events.ConditionLabel));
    colors = distinguishable_colors(nCond+1);
    Colors=cell(size(colors,1),1);
    
    
    for n=1:size(colors,1)
        Colors{n}=colors(n,:);
    end
    
    figure
    Substrate=1;
    subplot(1,2,Substrate)
    [stats.SpillQuality{Substrate} data.SpillQuality{Substrate}]=GetAnyEvents_ForLab_Excel_Dots(Events,@nanmean,'SpillQuality',Events.ConditionLabel,0,Colors,BoxPlotYN,1);
    ylabel('Spill Quality');
    title(Events.SubstrateLabel{Substrate})
    ylim([0 1])
    box off
    
    Substrate=2;
    subplot(1,2,Substrate)
    [stats.SpillQuality{Substrate} data.SpillQuality{Substrate}]=GetAnyEvents_ForLab_Excel_Dots(Events,@nanmean,'SpillQuality',Events.ConditionLabel,0,Colors,BoxPlotYN,2);
    ylabel('Spill Quality');
    title(Events.SubstrateLabel{Substrate})
    ylim([0 1])
    
    box off
    
    %% count and remove global non eaters
    Conditions=unique(cell2mat(cellfun(@unique,Events.Condition,'UniformOutput',false )));
    Conditions=Conditions(~isnan(Conditions));
    RemovedGlobalNonEaters=zeros(1,length(Conditions));
    nFliesPCond=zeros(1,length(Conditions));
    for x=1:size(Events.RMSEventsOns,1)
            
            RemoveFlies=(cellfun(@numel,Events.RMSEventsOns(x,Events.Substrate{x}==1))<=NonEaterThreshold)&(cellfun(@numel,Events.RMSEventsOns(x,Events.Substrate{x}==2))<=NonEaterThreshold);
            RemoveFlies2=false(1,max(size(Events.Condition{x})));
            RemoveFlies2(1:2:end)=RemoveFlies;
            RemoveFlies2(2:2:end)=RemoveFlies;
%           Events.Condition{x}(RemoveFlies2)=nan;


%             Events.RemovedNonEaters{x,RemoveFlies2}=1;
            for lcond=Conditions
                RemovedGlobalNonEaters(lcond)=RemovedGlobalNonEaters(lcond)+sum(RemoveFlies2(Events.Condition{x}==Conditions(lcond)));
                nFliesPCond(lcond)=nFliesPCond(lcond)+sum(Events.Condition{x}==Conditions(lcond));
            end
            
            
            
    end
        
    %% Remove  global non Eaters
    if RemoveGlobalNoneaters
        
        
        for x=1:size(Events.RMSEventsOns,1)
            
            RemoveFlies=(cellfun(@numel,Events.RMSEventsOns(x,Events.Substrate{x}==1))<=NonEaterThreshold)&(cellfun(@numel,Events.RMSEventsOns(x,Events.Substrate{x}==2))<=NonEaterThreshold);
            RemoveFlies2=false(1,max(size(Events.Condition{x})));
            RemoveFlies2(1:2:end)=RemoveFlies;
            RemoveFlies2(2:2:end)=RemoveFlies;
            
%             for lcond=Conditions
%                 RemovedGlobalNonEaters(lcond)=RemovedGlobalNonEaters(lcond)+sum(RemoveFlies2(Events.Condition{x}==Conditions(lcond)));
%                 nFliesPCond(lcond)=nFliesPCond(lcond)+sum(Events.Condition{x}==Conditions(lcond));
% 
%             end
%             
            for mm=1:numel(RemoveFlies2)
                Events.RemovedNonEaters{x,mm}=RemoveFlies2(mm);
            end
            
           Events.Condition{x}(RemoveFlies2)=nan;

            for y=1:size(Events.RMSEventsOns,2)
                if RemoveFlies2(y)
                    Events.Ons{x,y}=[];
                    Events.Offs{x,y}=[];
                    Events.Durations{x,y}=[];
                    Events.IFI{x,y}=[];
                    Events.RMSEventsOns{x,y}=[];
                    Events.RMSEventsOffs{x,y}=[];
                    Events.RMSEventsDurs{x,y}=[];
                    Events.RMSEventsnEvents{x,y}=[];
                end
            end
            
        end
        
    else
       
    end
    
    %% plot how many non eaters
    
    figure('Position',[100 250 700 700],'Color','w');
    plot(Conditions,RemovedGlobalNonEaters./nFliesPCond,'ob','MarkerFaceColor','b')
    ylabel('Fraction of flies removed per condition')
    set(gca,'XTick',[],'XTickLabel',[])
    ax=get(gca,'Ylim');
    %%% Rotate x axis labels
    
    angle_labels=15;
    
    t=text(1:length(Events.ConditionLabel),ax(1)*ones(1,length(Events.ConditionLabel)),Events.ConditionLabel);
    
    set(t,'HorizontalAlignment','right','VerticalAlignment','top',...
        'Rotation',angle_labels);%,'FontSize',FontSz-1,'FontName',fontName);
    xlim([0.5 length(Conditions)+0.5])
    
    %% spill quality
    
    if RemoveSpillQuality
        
        for x=1:size(Events.RMSEventsOns,1)
            
            RemoveFlies=cell2mat(Events.SpillQuality(x,Events.Substrate{x}==1))>RemoveSpillQualityThreshold|cell2mat(Events.SpillQuality(x,Events.Substrate{x}==2))>RemoveSpillQualityThreshold;
            RemoveFlies2(1:2:end)=RemoveFlies;
            RemoveFlies2(2:2:end)=RemoveFlies;
            Events.Condition{x}(RemoveFlies2)=nan;
            Events.RemovedSpillQuality{x}(RemoveFlies2)=1;
            
            for y=1:size(Events.RMSEventsOns,2)
                if RemoveFlies2(y)
                    Events.Ons{x,y}=[];
                    Events.Offs{x,y}=[];
                    Events.Durations{x,y}=[];
                    Events.IFI{x,y}=[];
                    Events.RMSEventsOns{x,y}=[];
                    Events.RMSEventsOffs{x,y}=[];
                    Events.RMSEventsDurs{x,y}=[];
                    Events.RMSEventsnEvents{x,y}=[];
                end
            end
        end
    else
    end
    
    
    
    %% Find how many conditions were present
    nCond=unique(cell2mat(cellfun(@unique,Events.Condition,'UniformOutput',false )));
    nCond=nCond(~isnan(nCond));
    labels=Events.ConditionLabel;%{'1','2','3','5','8'};
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
    
    
    %% find Feeding burst latency
    
    
    for x=1:size(Events.RMSEventsOns,1)
        for y=1:size(Events.RMSEventsOns,2)
            for nRMSEvents=1:numel(Events.RMSEventsnBursts{x,y})
                
                if Events.RMSEventsnBursts{x,y}(nRMSEvents)>=1
                    
                   diffEvents=abs(Events.FeedingBurstOns{x,y}-Events.RMSEventsOns{x,y}(nRMSEvents));
                   DiffEventsIndex=find(diffEvents==min(diffEvents),1,'first');
                   
                    Events.FeedingBurstLatency{x,y}(nRMSEvents)=diffEvents(DiffEventsIndex);
                else
                    
                    Events.FeedingBurstLatency{x,y}(nRMSEvents)=nan;
                    
                end
            end
        end
    end   
    %%  GetAnyEvents_4(Events,@hist,'Durations',labels,binsForHistDurs./100,Colors,binsForHistDurs)
    
    
    %  for n=1:max(size(Events.Condition))
    %         Events.Condition{n}(ismember(Events.Condition{n},[4 5 6]))=nan;
    %         Events.Condition{n}(ismember(Events.Condition{n},[1]))=1;
    %         Events.Condition{n}(ismember(Events.Condition{n},[2]))=2;
    %         Events.Condition{n}(ismember(Events.Condition{n},[3]))=3;
    % %                 Events.Condition{n}(ismember(Events.Condition{n},[8]))=4;
    %
    % %         Events.Condition{n}(ismember(Events.Condition{n},[6 7 8]))=nan;
    %
    %  end
    %
    
    
    %%
    if RemoveGlobalNoneaters
        figure
        Substrate=1;
        subplot(1,2,Substrate)
        [stats.RemovedNonEaters{Substrate} data.RemovedNonEaters{Substrate}]=GetAnyEvents_ForLab_Excel_Dots(Events,@(x)(x),'RemovedNonEaters',Events.ConditionLabel,0,Colors,BoxPlotYN,1);
        ylabel('RemovedNonEaters');
        title(Events.SubstrateLabel{Substrate})
        ylim([0 1])
        box off
        
        Substrate=2;
        subplot(1,2,Substrate)
        [stats.RemovedNonEaters{Substrate} data.RemovedNonEaters{Substrate}]=GetAnyEvents_ForLab_Excel_Dots(Events,@(x)(x),'RemovedNonEaters',Events.ConditionLabel,0,Colors,BoxPlotYN,2);
        ylabel('RemovedNonEaters');
        title(Events.SubstrateLabel{Substrate})
        ylim([0 1])
        
        box off
        
    end
    
    
    
    %% Get the stats for the number of NonEaters
    
    [stats.FractionNonEaters data.FractionNonEaters]=BinaryDataPermutationTest(RemovedGlobalNonEaters,nFliesPCond,1000);
%     [stats.FractionNonEaters data.FractionNonEaters]=BinaryDataPermutationTest(RemovedGlobalNonEaters,nFliesPCond,nPerm)
    %% plot  a subset of activity bouts
    SubstrateColors={'b','k'};
    % PlotActBoutTracesBothSubstrGen(Events,UserString,SubstrateColors,PlotYN,varargin)
    PlotYN=1;
    
%     [Sips{1} Sips{2}]=PlotActBoutTracesBothSubstrGen(Events,'SipForms',SubstrateColors,PlotYN);
    
%     [NormSips SipDurs Wigliness SipAmp]=NormalizeSips(Sips);
% %     
%     figure
%     subplot(1,2,1)
%     hist(SipDurs{2}{1}(1:10:end),1000)
%     subplot(1,2,2)
%     hist(Wigliness{2}{1}(1:10:end),1000)
%     
%     figure
%     scatter3(SipDurs{2}{1}(1:10:end),Wigliness{2}{1}(1:10:end),SipAmp{2}{1}(1:10:end),'.k')
    
%     figure
%     for ii=1:max(size(NormSips{1,1}))
%     SEMTraces2(NormSips{1,1}{ii},1:numel(NormSips{1,1}{ii}(1,:)),Colors{ii},0)
%     hold on
%     end
%     
%     figure
%         for ii=1:max(size(NormSips{1,1}))
% 
%     SEMTraces2(Sips{1,2}{ii},1:numel(Sips{1,1}{ii}(1,:)),Colors{ii},1)
%     hold on
%     
%         end
%   
%         
%     [Traces{1} Traces{2}]=PlotActBoutTracesBothSubstrGen(Events,'RawDataOnActBouts',SubstrateColors,PlotYN);


            
            
              %% Average  number of Feeding Bursts in Activity bout
                            figureN(Substrate) = figure;
              set(figureN(Substrate), 'Position', [0 0 screen_size(3) screen_size(4) ],...
                  'Color','w','Name',['nFeedingBurstsPerActBout ' Events.SubstrateLabel{Substrate}]);
ha = tight_subplot(1,2,[.04 .03],[.1 .1],[.1 .1]);

for Substrate = [1 2];
    if numel(blanks{Substrate})<1||blanks{Substrate}~=1
        
        axes(ha(Substrate))
        
        %             axes('Parent',figureN(Substrate),...
        %                  'Position',[c(2) r(3) height width]);
        [stats.nFeedingBurstPerActivityBout{Substrate} data.nFeedingBurstPerActivityBout{Substrate}]=GetAnyEvents_ForLab_Excel_Dots(Events,@nanmean,'RMSEventsnBursts',labels,0,Colors,BoxPlotYN,Substrate);
        ylabel({'number of', 'feeding burst per Act Bout'});
        box off
        title(Events.SubstrateLabel{Substrate})
        
    end
end
clear ha




%%  Fraction of Act Bouts with N or more feeding bursts

NThreshold=2;
                            figureN(Substrate) = figure;
              set(figureN(Substrate), 'Position', [0 0 screen_size(3) screen_size(4) ],...
                  'Color','w','Name',[['Fraction Of ActBoutWith ' num2str(NThreshold) ' or  moreBursts '] Events.SubstrateLabel{Substrate}]);
ha = tight_subplot(1,2,[.04 .03],[.1 .1],[.1 .1]);

for Substrate = [1 2];
    if numel(blanks{Substrate})<1||blanks{Substrate}~=1
        
        axes(ha(Substrate))
        
        %             axes('Parent',figureN(Substrate),...
        %                  'Position',[c(2) r(3) height width]);
        [stats.nFeedingBurstFraction{Substrate} data.nFeedingBurstFraction{Substrate}]=GetAnyEvents_ForLab_Excel_Dots(Events,@(x)(sum(x>=NThreshold)./numel(x>=0)),'RMSEventsnBursts',labels,0,Colors,BoxPlotYN,Substrate);
        ylabel({'fraction of Act bouts', ' with >= 2 Bursts'});
        box off
        title(Events.SubstrateLabel{Substrate})
        
    end
end
clear ha



%% Histograms of n feeding burst in Act bout



figure('Name','Hist n feeding burst in Act bout');
Substrate=1;
binsForHistIFI=[0:1:10];
subplot(2,2,1)
%             axes('Parent',figureN(Substrate),...
%                 'Position',[c(4) r(3) height width]);
GetAnyEvents_ForLab_Excel_Dots(Events,@hist,'RMSEventsnBursts',labels,binsForHistIFI,Colors,BoxPlotYN,Substrate,binsForHistIFI);
%             [stats.IFI{Substrate} data.IFI{Substrate}]=GetAnyEvents_ForLab_Excel_Dots(Events,@hist,'IFI',labels,0,Colors,BoxPlotYN,Substrate,binsForHistIFI);
ylabel({'count'});
xlabel('n feeding burst in Act bout ')
        title(Events.SubstrateLabel{Substrate})

box off

subplot(2,2,3)
%             axes('Parent',figureN(Substrate),...
%                 'Position',[c(4) r(3) height width]);
GetAnyEvents_ForLab_Excel_Dots(Events,@hist,'RMSEventsnBursts',labels,binsForHistIFI,Colors,BoxPlotYN,Substrate,binsForHistIFI);
%             [stats.IFI{Substrate} data.IFI{Substrate}]=GetAnyEvents_ForLab_Excel_Dots(Events,@hist,'IFI',labels,0,Colors,BoxPlotYN,Substrate,binsForHistIFI);
ylabel({'count'});
xlabel('n feeding burst in Act bout ')
title(Events.SubstrateLabel{Substrate})

box off

Substrate=2;

subplot(2,2,2)
%             axes('Parent',figureN(Substrate),...
%                 'Position',[c(4) r(3) height width]);
GetAnyEvents_ForLab_Excel_Dots(Events,@hist,'RMSEventsnBursts',labels,binsForHistIFI,Colors,BoxPlotYN,Substrate,binsForHistIFI);
%             [stats.IFI{Substrate} data.IFI{Substrate}]=GetAnyEvents_ForLab_Excel_Dots(Events,@hist,'IFI',labels,0,Colors,BoxPlotYN,Substrate,binsForHistIFI);
ylabel({'count'});
xlabel('n feeding burst in Act bout ')
title(Events.SubstrateLabel{Substrate})

box off

subplot(2,2,4)
%             axes('Parent',figureN(Substrate),...
%                 'Position',[c(4) r(3) height width]);
GetAnyEvents_ForLab_Excel_Dots(Events,@hist,'RMSEventsnBursts',labels,binsForHistIFI,Colors,BoxPlotYN,Substrate,binsForHistIFI);
%             [stats.IFI{Substrate} data.IFI{Substrate}]=GetAnyEvents_ForLab_Excel_Dots(Events,@hist,'IFI',labels,0,Colors,BoxPlotYN,Substrate,binsForHistIFI);
ylabel({'count'});
xlabel('n feeding burst in Act bout ')
title(Events.SubstrateLabel{Substrate})

box off

              %% Average  latency of Feeding Bursts in Activity bout
              
              
              figureN(Substrate) = figure;
              set(figureN(Substrate), 'Position', [0 0 screen_size(3) screen_size(4) ],...
                  'Color','w','Name',['FeedingBurstLatency ' Events.SubstrateLabel{Substrate}]);
              ha = tight_subplot(1,2,[.04 .03],[.1 .1],[.1 .1]);

for Substrate = [1 2];
    if numel(blanks{Substrate})<1||blanks{Substrate}~=1
        
        axes(ha(Substrate))
        
        %             axes('Parent',figureN(Substrate),...
        %                  'Position',[c(2) r(3) height width]);
        [stats.FeedingBurstLatency{Substrate} data.FeedingBurstLatency{Substrate}]=GetAnyEvents_ForLab_Excel_Dots(Events,@nanmean,'FeedingBurstLatency',labels,0,Colors,BoxPlotYN,Substrate);
        ylabel({'feeding burst', 'latency, (samples)'});
        box off
        title(Events.SubstrateLabel{Substrate})
        
    end
end


clear ha



%% Histograms of n feeding burst in Act bout



figure('Name','Hist Feeding burst latency');

Substrate=1;
binsForHistIFI=[1:10:300];
subplot(2,2,1)
%             axes('Parent',figureN(Substrate),...
%                 'Position',[c(4) r(3) height width]);
GetAnyEvents_ForLab_Excel_Dots(Events,@hist,'FeedingBurstLatency',labels,binsForHistIFI,Colors,BoxPlotYN,Substrate,binsForHistIFI);
%             [stats.IFI{Substrate} data.IFI{Substrate}]=GetAnyEvents_ForLab_Excel_Dots(Events,@hist,'IFI',labels,0,Colors,BoxPlotYN,Substrate,binsForHistIFI);
ylabel({'count'});
xlabel('FeedingBurstLatency,(samples) ')
        title(Events.SubstrateLabel{Substrate})

box off

subplot(2,2,3)
%             axes('Parent',figureN(Substrate),...
%                 'Position',[c(4) r(3) height width]);
GetAnyEvents_ForLab_Excel_Dots(Events,@hist,'FeedingBurstLatency',labels,binsForHistIFI,Colors,BoxPlotYN,Substrate,binsForHistIFI);
%             [stats.IFI{Substrate} data.IFI{Substrate}]=GetAnyEvents_ForLab_Excel_Dots(Events,@hist,'IFI',labels,0,Colors,BoxPlotYN,Substrate,binsForHistIFI);
ylabel({'count'});
xlabel('FeedingBurstLatency,(samples) ')
title(Events.SubstrateLabel{Substrate})

box off

Substrate=2;

subplot(2,2,2)
%             axes('Parent',figureN(Substrate),...
%                 'Position',[c(4) r(3) height width]);
GetAnyEvents_ForLab_Excel_Dots(Events,@hist,'FeedingBurstLatency',labels,binsForHistIFI,Colors,BoxPlotYN,Substrate,binsForHistIFI);
%             [stats.IFI{Substrate} data.IFI{Substrate}]=GetAnyEvents_ForLab_Excel_Dots(Events,@hist,'IFI',labels,0,Colors,BoxPlotYN,Substrate,binsForHistIFI);
ylabel({'count'});
xlabel('FeedingBurstLatency,(samples) ')
title(Events.SubstrateLabel{Substrate})

box off

subplot(2,2,4)
%             axes('Parent',figureN(Substrate),...
%                 'Position',[c(4) r(3) height width]);
GetAnyEvents_ForLab_Excel_Dots(Events,@hist,'FeedingBurstLatency',labels,binsForHistIFI,Colors,BoxPlotYN,Substrate,binsForHistIFI);
%             [stats.IFI{Substrate} data.IFI{Substrate}]=GetAnyEvents_ForLab_Excel_Dots(Events,@hist,'IFI',labels,0,Colors,BoxPlotYN,Substrate,binsForHistIFI);
ylabel({'count'});
xlabel('FeedingBurstLatency,(samples) ')
title(Events.SubstrateLabel{Substrate})

box off




    %%

    for Substrate = [1 2];
        
        if numel(blanks{Substrate})<1||blanks{Substrate}~=1
            
            
            
            
            
            figureN(Substrate) = figure;
            set(figureN(Substrate), 'Position', [0 0 screen_size(3) screen_size(4) ],...
                'Color','w','Name',['Microstructure ' Events.SubstrateLabel{Substrate}]);
            height=0.16;
            width=0.20;
            c=0.2:0.21:1;
            r=0.77:-0.28:0;
            
            %% number  feeding events per burst
            axes('Parent',figureN(Substrate),...
                'Position',[c(2) r(3) height width]);
            
            [stats.FeedingBurst_nSips{Substrate} data.FeedingBurst_nSips{Substrate}]=GetAnyEvents_ForLab_Excel_Dots(Events,@nanmean,'FeedingBurstnEvents',labels,0,Colors,BoxPlotYN,Substrate);
            ylabel({'number of', 'sips per burst'});
            box off
            
            %                         %% Quality
            %             axes('Parent',figureN(Substrate),...
            %                 'Position',[c(4) r(3) height width]);
            %
            %             [stats.SpillQuality{Substrate} data.SpillQuality{Substrate}]=GetAnyEvents_ForLab_Excel_Dots(Events,@nanmean,'SpillQuality',labels,0,Colors,BoxPlotYN,Substrate);
            %             ylabel({'number of', 'sips per burst'});
            %             box off
            %% Get number of feeding Events
            axes('Parent',figureN(Substrate),...
                'Position',[c(1) r(3) height width]);
            
            [stats.NumberOfSips{Substrate} data.NumberOfSips{Substrate}]=GetAnyEvents_ForLab_Excel_Dots(Events,@numel,'Ons',labels,0,Colors,BoxPlotYN,Substrate);
            ylabel({'number', 'of sips'});
            %% number  of RMS  Events
            axes('Parent',figureN(Substrate),...
                'Position',[c(1) r(1) height width]);
            box off
            [stats.ActivityBoutNumber{Substrate} data.ActivityBoutNumber{Substrate}]=GetAnyEvents_ForLab_Excel_Dots(Events,@numel,'RMSEventsOns',labels,0,Colors,BoxPlotYN,Substrate);
            ylabel({'number ', 'of activity bouts,s'});
            box off
            %% Get mean Durations of RMS  Events
            axes('Parent',figureN(Substrate),...
                'Position',[c(2) r(1) height width]);
            
            [stats.ActivityBoutDurarion{Substrate} data.ActivityBoutDurarion{Substrate}]=GetAnyEvents_ForLab_Excel_Dots(Events,@(x)(nanmean(x)./100),'RMSEventsDurs',labels,0,Colors,BoxPlotYN,Substrate);
            ylabel({'mean duration', 'of activity bouts,s'});box off
            
            %% Get total mean Durations of RMS  Events
            axes('Parent',figureN(Substrate),...
                'Position',[c(4) r(1) height width]);
            [stats.ActivityBoutTotalDuration{Substrate} data.ActivityBoutTotalDuration{Substrate}]=GetAnyEvents_ForLab_Excel_Dots(Events,@(x)(nansum(x)./100),'RMSEventsDurs',labels,0,Colors,BoxPlotYN,Substrate);
            ylabel({'total duration', 'of activity bouts,s'});box off
            
            
            %% Get activity bout IBI
            axes('Parent',figureN(Substrate),...
                'Position',[c(3) r(1) height width]);
            
            [stats.ActivityBoutIBI{Substrate} data.ActivityBoutIBI{Substrate}]=GetAnyEvents_ForLab_Excel_Dots(Events,@(x)(nanmean(x)./100),'RMSEventsIBI',labels,0,Colors,BoxPlotYN,Substrate);
            ylabel({'activity bout', 'IBI,s'});
            
            box off
            %% get feeding burst number
            axes('Parent',figureN(Substrate),...
                'Position',[c(1) r(2) height width]);
            
            [stats.FeedingBurstsNumber{Substrate} data.FeedingBurstsNumber{Substrate}]=GetAnyEvents_ForLab_Excel_Dots(Events,@numel,'FeedingBurstOns',labels,0,Colors,BoxPlotYN,Substrate);
            ylabel({'number ', 'of feeding bursts'});
            box off
            %% feeding burst duration
            
            axes('Parent',figureN(Substrate),...
                'Position',[c(2) r(2) height width]);
            
            [stats.FeedingBurstsDurations{Substrate} data.FeedingBurstsDurations{Substrate}]=GetAnyEvents_ForLab_Excel_Dots(Events,@(x)(nanmean(x)./100),'FeedingBurstDurs',labels,0,Colors,BoxPlotYN,Substrate);
            ylabel({'mean duration ', 'of feeding bursts, s '});
            box off
            
            %% feeding burst total duration
            
            axes('Parent',figureN(Substrate),...
                'Position',[c(4) r(2) height width]);
            
            [stats.FeedingBurstsTotalDuration{Substrate} data.FeedingBurstsTotalDuration{Substrate}]=GetAnyEvents_ForLab_Excel_Dots(Events,@(x)(nansum(x)./100),'FeedingBurstDurs',labels,0,Colors,BoxPlotYN,Substrate);
            box off
            ylabel({'total duration ', 'of feeding bursts, s '});
            %% feeding burst IFI
            axes('Parent',figureN(Substrate),...
                'Position',[c(3) r(2) height width]);
            
            [stats.FeedingBurstIBI{Substrate} data.FeedingBurstIBI{Substrate}]=GetAnyEvents_ForLab_Excel_Dots(Events,@(x)(nanmean(x)./100),'FeedingBurstIBI',labels,0,Colors,BoxPlotYN,Substrate);
            ylabel({'mean IFI ', 'of feeding bursts, s '});
            box off
            
            
            
            %% InterSipIntervals
            
            %             binsForHistIFI=[1:3:200];
            %             axes('Parent',figureN(Substrate),...
            %                 'Position',[c(4) r(3) height width]);
            %             GetAnyEvents_ForLab_Excel_Dots(Events,@hist,'Durations',labels,binsForHistIFI,Colors,BoxPlotYN,Substrate,binsForHistIFI);
            % %             [stats.IFI{Substrate} data.IFI{Substrate}]=GetAnyEvents_ForLab_Excel_Dots(Events,@hist,'IFI',labels,0,Colors,BoxPlotYN,Substrate,binsForHistIFI);
            %             ylabel({'Inter-Sip-Intervals '});
            %             box off
            
            axes('Parent',figureN(Substrate),...
                'Position',[c(3) r(3) height width]);
            suptitle(Events.SubstrateLabel{Substrate})
            
            
            stepFactor=100;
            cumFeeding=CumulativeFeedingEvents(Events,Substrate,1,labels,Colors,Dur);
            
            for n=1:max(size(cumFeeding))
                for m=1:size(cumFeeding{n},1)
                    sparsecumFeeding{n}(m,:)=cumFeeding{n}(m,1:stepFactor:end);
                end
            end
            
            ylabel({'cumulative number','of sips'})
            xlabel('time,s')
            axis tight
            box off
            X=1:size(sparsecumFeeding{n},2);
            for n=1:size(sparsecumFeeding,2)
                for m=1:size(sparsecumFeeding{n},1)
                    [p{n}(m,:) rsq{n}(m,:) Y{n}(m,:)]=FitPoly_WithRSquare([1:size(sparsecumFeeding{n},2)],sparsecumFeeding{n}(m,1:end),2);
                end
            end
            for n=1:size(p,2)
                Coeff1{n}=p{n}(:,1);
                Coeff2{n}=p{n}(:,2);
                Coeff3{n}=p{n}(:,3);
                
            end
            for n=1:size(Coeff1,2)
                
                data.QuadraticCoeff(1:max(size(Coeff1{n})),n)=(Coeff1{n});
            end
            
            for n=1:size(Coeff2,2)
                
                data.LinearCoeff(1:max(size(Coeff2{n})),n)=(Coeff2{n});
            end
            
            for n=1:size(Coeff3,2)
                
                data.OffsetCoeff(1:max(size(Coeff3{n})),n)=(Coeff3{n});
                
            end
            
            
            
        end
        
        if exist('Coeff1','var')
            figure('Name',['Cuadratic Coeff - ' Events.SubstrateLabel{Substrate}]);
            subplot(1,2,1)
            %             try
            stats.QuadraticCoeff{Substrate}=pairwise_comparisons(cell2mat(Coeff1)',0);
            stats.LinearCoeff{Substrate}=pairwise_comparisons(cell2mat(Coeff2)',0);
            
            %             catch
            %                  stats.QuadraticCoeff{Substrate}=nan;
            %                  stats.LinearCoeff{Substrate}=nan;
            %             end
            %
            boxplot(cell2mat(Coeff1),labels,'outliersize',0.5,'Color',[0 0 0])
            ylabel('quadratic coefficient')
            subplot(1,2,2)
            boxplot(cell2mat(Coeff2),labels,'outliersize',0.5,'Color',[0 0 0])
            ylabel('linear coefficient')
            suptitle(Events.SubstrateLabel{Substrate})
            box off
        end
    end
    
end

%     figure
%     varargout=GetAnyEvents_fig_6_noBoxPlotSpread(Events,@numel,'Ons',labels,0,Colors,1,0,'PI');
%     ylabel({'number ', 'sips '});
%
%     box off
try
    figure('Name','Scatter plot Number of Sips');
    
    ScatterPlotConditions(Events,data,'NumberOfSips',Colors)
catch
end
%% Figure - Box plots of Nº of Sips per condition, 1 channel in each subplot
[stats.Number_of_Sips{1} stats.Number_of_Sips{2}]=GetAnyEvents_fig_6_noBoxPlotSpread(Events,@numel,'Ons',labels,0,Colors,1,1,'BoxPlot');
ylabel({'number ', 'sips '});
box off
set(gcf,'Name','Number of Sips boxplots');


%%
%% (Optional) Figure - Comparison of channels per condition
if (Different_Subs==1)||(Different_Subs==2)
    
    Cond_numbers=unique(cell2mat(cellfun(@unique,Events.Condition,'UniformOutput',false )));
    Cond_numbers=Cond_numbers(~isnan(Cond_numbers));
    for lcond=Cond_numbers
        figure('Position', [0 0 screen_size(3) screen_size(4) ],...
            'Color','w','Name',['Channel comparison - Cond' num2str(lcond)]);
        subslabels=Events.Diff_Subs_Labels(lcond,:);
        subplot(3,4,1)
        [stats.ActivityBoutNumber_Subs{lcond}, data.ActivityBoutNumber_Subs{lcond}]=...
            GetAnyEvents_ForLab_Excel_Dots_SubstrateComparison(Events,@numel,'RMSEventsOns',BoxPlotYN,lcond);
        ylabel({'number ', 'of activity bouts,s'});
        box off
        
        
        subplot(3,4,2)
        [stats.ActivityBoutDuration_Subs{lcond}, data.ActivityBoutDuration_Subs{lcond}]=...
            GetAnyEvents_ForLab_Excel_Dots_SubstrateComparison(Events,@(x)(nanmean(x)./100),'RMSEventsDurs',BoxPlotYN,lcond);
        ylabel({'mean duration', 'of activity bouts,s'});
        box off
        
        
        subplot(3,4,3)
        [stats.ActivityBoutIBI_Subs{lcond}, data.ActivityBoutIBI_Subs{lcond}]=...
            GetAnyEvents_ForLab_Excel_Dots_SubstrateComparison(Events,@(x)(nanmean(x)./100),'RMSEventsIBI',BoxPlotYN,lcond);
        ylabel({'activity bout', 'IBI,s'});
        box off
        
        
        subplot(3,4,4)
        [stats.ActivityBoutTotalDuration_Subs{lcond}, data.ActivityBoutTotalDuration_Subs{lcond}]=...
            GetAnyEvents_ForLab_Excel_Dots_SubstrateComparison(Events,@(x)(nansum(x)./100),'RMSEventsDurs',BoxPlotYN,lcond);
        ylabel({'total duration', 'of activity bouts,s'});
        box off
        
        
        subplot(3,4,5)
        [stats.FeedingBurstsNumber_Subs{lcond}, data.FeedingBurstsNumber_Subs{lcond}]=...
            GetAnyEvents_ForLab_Excel_Dots_SubstrateComparison(Events,@numel,'FeedingBurstOns',BoxPlotYN,lcond);
        ylabel({'number ', 'of feeding bursts'});
        box off
        
        
        subplot(3,4,6)
        [stats.FeedingBurstsDurations_Subs{lcond}, data.FeedingBurstsDurations_Subs{lcond}]=...
            GetAnyEvents_ForLab_Excel_Dots_SubstrateComparison(Events,@(x)(nanmean(x)./100),'FeedingBurstDurs',BoxPlotYN,lcond);
        ylabel({'mean duration ', 'of feeding bursts, s '});
        box off
        
        
        subplot(3,4,7)
        [stats.FeedingBurstIBI_Subs{lcond}, data.FeedingBurstIBI_Subs{lcond}]=...
            GetAnyEvents_ForLab_Excel_Dots_SubstrateComparison(Events,@(x)(nanmean(x)./100),'FeedingBurstIBI',BoxPlotYN,lcond);
        ylabel({'mean IFI ', 'of feeding bursts, s '});
        box off
        
        
        subplot(3,4,8)
        [stats.FeedingBurstsTotalDuration_Subs{lcond}, data.FeedingBurstsTotalDuration_Subs{lcond}]=...
            GetAnyEvents_ForLab_Excel_Dots_SubstrateComparison(Events,@(x)(nansum(x)./100),'FeedingBurstDurs',BoxPlotYN,lcond);
        ylabel({'total duration ', 'of feeding bursts, s '});
        box off
        
        
        subplot(3,4,9)
        [stats.NumberOfSips_Subs{lcond}, data.NumberOfSips_Subs{lcond}]=...
            GetAnyEvents_ForLab_Excel_Dots_SubstrateComparison(Events,@numel,'Ons',BoxPlotYN,lcond);
        ylabel({'number', 'of sips'});
        box off
        
        
        subplot(3,4,10)
        [stats.FeedingBurst_nSips_Subs{lcond}, data.FeedingBurst_nSips_Subs{lcond}]=...
            GetAnyEvents_ForLab_Excel_Dots_SubstrateComparison(Events,@nanmean,'FeedingBurstnEvents',BoxPlotYN,lcond);
        ylabel({'number of', 'sips per burst'});
        box off
        
        
        subplot(3,4,11)
        CumulativeFeedingEvents_2diffS(Events,lcond,1,...
            Events.Diff_Subs_Labels(lcond,:),Colors,Dur);
        axis tight
        title(labels{lcond})
        axis tight
        xlabel('time,s')
        ylabel('number of sips')
        box off
        
        suptitle(Events.ConditionLabel{lcond})
    end
end

%%

figure('Name','Cumulative Number of sips');
for i=1:size(labels,2)
    subplot(1,size(labels,2),i)
    Cond1Stuff{i}=CumulativeFeedingEvents_2S(Events,i,1,{Events.SubstrateLabel{1},Events.SubstrateLabel{2}},Colors,Dur);
    axis tight
    title(labels{i})
    ylim([0 max(max(cell2mat(cellfun(@numel,Events.Ons, 'UniformOutput', false))))+(max(max(cell2mat(cellfun(@numel,Events.Ons, 'UniformOutput', false))))).*.1])
    xlabel('time,s')
    ylabel('number of sips')
    box off
end
SFactor=1000;

for n=1:size(Cond1Stuff,2)
    
    for m=1:size(Cond1Stuff{n},2)
        for k=1:size(Cond1Stuff{n}{m},1)
            CumulFeedingRates{n}{m}(k,:)=Cond1Stuff{n}{m}(k,1:SFactor:end)+1;
        end
    end
    
end

for n=1:size(Cond1Stuff,2)
    for k=1:size(Cond1Stuff{n}{m},1)
        CumulPI{n}(k,:)=(CumulFeedingRates{n}{1}(k,:)-CumulFeedingRates{n}{2}(k,:))./(CumulFeedingRates{n}{1}(k,:)+CumulFeedingRates{n}{2}(k,:));
    end
end


% counter=0;
% figure('Name','Individual flies CumulIntake')
% for nCond=1:max(size(Cond1Stuff))
%     for nSubstr=1:numel(unique(Events.Substrate{1}))
%         counter=counter+1;
%         subplot(numel(unique(Events.Substrate{1})),max(size(Cond1Stuff)),counter)
%         
%         plot(Cond1Stuff{nCond}{nSubstr}')
%         
%     end
% end

% counter=0;
% figure('Name','Individual flies CumulPI')
% for nCond=1:max(size(Cond1Stuff))
% %     for nSubstr=1:numel(unique(Events.Substrate{1}))
%         counter=counter+1;
%         subplot(1,max(size(Cond1Stuff)),counter)
%         
%         plot(CumulPI{nCond}')
%         ylim([-1 1])
% %     end
% end

% figure
% task_14_shaded_plot_jbfill_WithIRQ_SFactor(CumulFeedingRates{1}{1},'1',1:(SFactor./100):(Dur./100),Colors,1,1)
% 

figure('Name','Preference index');
task_14_shaded_plot_jbfill_WithIRQ_SFactor(CumulPI,labels,1:(SFactor./100):(Dur./100),Colors,1,1)
axis tight
box off
ylim([-1.1 1.1])
xlabel('time,s')
ylabel('preference index')
set(gca,'YTick',[ -1 -0.5 0 0.5 1 ],'YTicklabel',{Events.SubstrateLabel{2},'-0.5','0','0.5',Events.SubstrateLabel{1}})
box off



figure('Name','Hist Sips and ISI');

Substrate=1;
binsForHistIFI=[1:1:50];
subplot(2,2,1)
%             axes('Parent',figureN(Substrate),...
%                 'Position',[c(4) r(3) height width]);
GetAnyEvents_ForLab_Excel_Dots(Events,@hist,'IFI',labels,binsForHistIFI/100,Colors,BoxPlotYN,Substrate,binsForHistIFI);
%             [stats.IFI{Substrate} data.IFI{Substrate}]=GetAnyEvents_ForLab_Excel_Dots(Events,@hist,'IFI',labels,0,Colors,BoxPlotYN,Substrate,binsForHistIFI);
ylabel({'Inter-Sip-Intervals '});
box off

subplot(2,2,2)
%             axes('Parent',figureN(Substrate),...
%                 'Position',[c(4) r(3) height width]);
GetAnyEvents_ForLab_Excel_Dots(Events,@hist,'Durations',labels,binsForHistIFI/100,Colors,BoxPlotYN,Substrate,binsForHistIFI);
%             [stats.IFI{Substrate} data.IFI{Substrate}]=GetAnyEvents_ForLab_Excel_Dots(Events,@hist,'IFI',labels,0,Colors,BoxPlotYN,Substrate,binsForHistIFI);
ylabel({'sip durations '});
box off


Substrate=2;
subplot(2,2,3)
%             axes('Parent',figureN(Substrate),...
%                 'Position',[c(4) r(3) height width]);
GetAnyEvents_ForLab_Excel_Dots(Events,@hist,'IFI',labels,binsForHistIFI/100,Colors,BoxPlotYN,Substrate,binsForHistIFI);
%             [stats.IFI{Substrate} data.IFI{Substrate}]=GetAnyEvents_ForLab_Excel_Dots(Events,@hist,'IFI',labels,0,Colors,BoxPlotYN,Substrate,binsForHistIFI);
ylabel({'Inter-Sip-Intervals '});
box off

Substrate=2;
subplot(2,2,4)
%             axes('Parent',figureN(Substrate),...
%                 'Position',[c(4) r(3) height width]);
GetAnyEvents_ForLab_Excel_Dots(Events,@hist,'Durations',labels,binsForHistIFI/100,Colors,BoxPlotYN,Substrate,binsForHistIFI);
%             [stats.IFI{Substrate} data.IFI{Substrate}]=GetAnyEvents_ForLab_Excel_Dots(Events,@hist,'IFI',labels,0,Colors,BoxPlotYN,Substrate,binsForHistIFI);
ylabel({'sip durations '});
box off

Substrate=1;


figure('Name',['Rank frequency loglog - ' Events.SubstrateLabel{Substrate}]);

suptitle(Events.SubstrateLabel{Substrate})
subplot(3,3,1)
title('number of sips')
ICDF(Events,'Ons',labels,Colors,Substrate)
legend('off')
subplot(3,3,2)
title('sip durations')
ICDF(Events,'Durations',labels,Colors,Substrate)
legend('off')
subplot(3,3,3)
title('ISI')
ICDF(Events,'IFI',labels,Colors,Substrate)
legend('off')
subplot(3,3,4)
title('number of Act bouts')
ICDF(Events,'RMSEventsOns',labels,Colors,Substrate)
legend('off')
subplot(3,3,5)
title('duration of Act bouts')
ICDF(Events,'RMSEventsDurs',labels,Colors,Substrate)
legend('off')
subplot(3,3,6)
title('IBI of Act bouts')
ICDF(Events,'RMSEventsIBI',labels,Colors,Substrate)
legend('off')
subplot(3,3,7)
title('number of feeding bursts')
ICDF(Events,'FeedingBurstOns',labels,Colors,Substrate)
legend('off')
subplot(3,3,8)
title('duration of feeding bursts')
ICDF(Events,'FeedingBurstDurs',labels,Colors,Substrate)
legend('off')
subplot(3,3,9)
title('IBI of feeding bursts')
ICDF(Events,'FeedingBurstIBI',labels,Colors,Substrate)
Substrate=2;


figure('Name',['Rank frequency loglog - ' Events.SubstrateLabel{Substrate}]);

suptitle(Events.SubstrateLabel{Substrate})
subplot(3,3,1)
title('number of sips')
ICDF(Events,'Ons',labels,Colors,Substrate)
legend('off')
subplot(3,3,2)
title('sip durations')
ICDF(Events,'Durations',labels,Colors,Substrate)
legend('off')
subplot(3,3,3)
title('ISI')
ICDF(Events,'IFI',labels,Colors,Substrate)
legend('off')
subplot(3,3,4)
title('number of Act bouts')
ICDF(Events,'RMSEventsOns',labels,Colors,Substrate)
legend('off')
subplot(3,3,5)
title('duration of Act bouts')
ICDF(Events,'RMSEventsDurs',labels,Colors,Substrate)
legend('off')
subplot(3,3,6)
title('IBI of Act bouts')
ICDF(Events,'RMSEventsIBI',labels,Colors,Substrate)
legend('off')
subplot(3,3,7)
title('number of feeding bursts')
ICDF(Events,'FeedingBurstOns',labels,Colors,Substrate)
legend('off')
subplot(3,3,8)
title('duration of feeding bursts')
ICDF(Events,'FeedingBurstDurs',labels,Colors,Substrate)
legend('off')
subplot(3,3,9)
title('IBI of feeding bursts')
ICDF(Events,'FeedingBurstIBI',labels,Colors,Substrate)

Comment=' ';
figHandles = findall(0,'Type','figure');
%     Comment=[' '];
screen_size = get(0, 'ScreenSize');

for n=1:numel(figHandles)
    
    F(n)=figure(figHandles(n));
    set(F(n), 'Position', [0 0 screen_size(3) screen_size(4) ] );
    set(gcf,'PaperPositionMode','auto')
    GraphName=get(F(n),'Name');
    task_14_define_parameters_for_plotting
    task_14_reportfig2(gcf, filename1, GraphName, Preview, Comment, 300,SaveFig,SaveEps)
    
end
cd mrep
cd (filename1)
save stats.mat stats


names = fieldnames(stats);
for n=1:size(names,1);
    
    if VeroTypeStatsFile
        fid=fopen([names{n},'.txt'],'w');
        
        for ltype=1:size(stats.(names{n}),2)
            if ~isempty(strfind(names{n},'_Subs'))
                fprintf(fid,'\r\n\r\n%s\r\n\r\n',['----- p-values for ' Events.ConditionLabel{ltype} ' -----']);
            else
                fprintf(fid,'\r\n\r\n%s\r\n\r\n',['----- p-values for ' Events.SubstrateLabel{ltype} ' -----']);
            end
            for lcomparison=1:size(stats.(names{n}){ltype},1)
                cond1=stats.(names{n}){ltype}(lcomparison,1);
                cond2=stats.(names{n}){ltype}(lcomparison,2);
                
                if ~isempty(strfind(names{n},'_Subs'))
                    cond1=Events.Diff_Subs_Labels{lcomparison,cond1};
                    cond2=Events.Diff_Subs_Labels{lcomparison,cond2};
                else
                    cond1=Events.ConditionLabel{cond1};
                    cond2=Events.ConditionLabel{cond2};
                end
                pvaluncorr=stats.(names{n}){ltype}(lcomparison,3);
                pvalcorr=stats.(names{n}){ltype}(lcomparison,4);
                
                fprintf(fid,'%s\r\n',[cond1 ' vs ' cond2,...
                    ':' num2str(pvaluncorr) ' uncorrected']);
                fprintf(fid,'%s\r\n',[cond1 ' vs ' cond2,...
                    ':' num2str(pvalcorr) ' corrected']);
            end
        end
    else
        dlmwrite([names{n},'.txt'],stats.(names{n}),'\t')
    end
    fclose all
end

save data_Excel.mat data
fclose all
close all
names = fieldnames(data);

c=0;
for sLabel=1:size(Events.SubstrateLabel,2)
    for cLabel=1:size(Events.ConditionLabel,2)

                if numel(blanks{sLabel})<1||blanks{sLabel}~=1

        
        
        c=c+1;
        LABELS{c}=[Events.SubstrateLabel{sLabel} ' ' Events.ConditionLabel{cLabel}];
                end
    end
end


for n=1:size(names,1);
    fclose all
          fid=fopen([names{n},'_Excel.txt'],'w');

    for mm=1:size(LABELS,2)
      fprintf(fid,'%s\t\',LABELS{mm})
%         dlmwrite([names{n},'_Excel.txt'],,'delimiter','\t','roffset',0,'coffset',mm-1)
    end
        fclose all

    dlmwrite([names{n},'_Excel.txt'],data.(names{n}),'-append','delimiter','\t','roffset',1,'coffset',0)
end


