import fnmatch
import os
from glob import glob
import numpy as np

nch = 64

def basename(val):
    return os.path.basename(val)

def getAllFilepathsWith(dir, str):
    return [y for x in os.walk(dir) \
            for y in glob(os.path.join(x[0], '*'+str+'*')) \
            if os.path.isfile(y)]

def getAllFilesWith(dir, str):
    return [basename(y) for x in os.walk(dir) \
            for y in glob(os.path.join(x[0], '*'+str+'*')) \
            if os.path.isfile(y)]                                               # return basename (file) for all files y in subfolders x recursively within dir (incl. itself) that contain str and are a file

def filled(m, val):
    X = np.empty(m)
    X[:] = val
    return X

def process_data(filepath, duration, events):
    events["Condition"] = []                                                    # contains vectors with length of # channels
    for filename in getAllFilepathsWith(filepath, 'CapacitanceData'):           # for all files in filepath containing 'CapacitanceData'
        print(filename)
        with open(filename, 'rb') as f:                                         # with opening
            cap_data = np.fromfile(f, dtype=np.ushort)                          # read binary data into numpy ndarray (1-dim.)
            cap_data = (cap_data.reshape((nch, cap_data.shape[0]/nch))).T          # reshape array into 64-dim. matrix and take the transpose (rows = time, cols = channels)
            if np.isfinite(duration) and duration < cap_data.shape[0]:
                cap_data = cap_data[:duration,:]                                # cut off data longer than duration
                this_duration = duration                                        # actual duration of experiment
            else:
                if duration > cap_data.shape[0]:                                # warning
                    print("Warning: data shorter than given duration")
                this_duration = cap_data.shape[0]                               # duration is equal to number of rows in data
            cap_data[cap_data==-1]=0
            events["Condition"].append(filled(nch, np.nan))                     # condition in channel matrix
            for icond, condition in enumerate(events["ConditionLabel"]):        # check whether condition is in current file
                condstr = "C"+"{0:02d}".format(icond+1)                         # build string for condition indicator
                if condstr in filename:
                    ch = []
                    ch.append(int(filename.split(condstr,1)[1][1:3]))           # take start channel from 2nd and 3rd position after condstr
                    ch.append(int(filename.split(condstr,1)[1][4:6]))           # take end channel from 5th and 6th position after condstr
                    events["Condition"][-1][ch[0]-1:ch[1]] = icond              # write which condition corresponds to channel
                    #print("Condition label:", condition,
                    #      "from channel", ch[0],
                    #      "to", ch[1])                                        # print condition-to-channel mapping
            print(events["Condition"][-1])



"""


        for n=find(~isnan(C(:,1)))'

            Events.Condition{FileNameCounter}(C(n,1):C(n,2))=n;
            if (Different_Subs==1)||(Different_Subs==2)
                Events.Condition_Substrate{FileNameCounter}(C(n,1):2:C(n,2))=2*n-1;
                Events.Condition_Substrate{FileNameCounter}(C(n,1)+1:2:C(n,2))=2*n;
            end


        end
    end






    %%

    if  strcmp(Events.SubstrateLabel{1},Events.SubstrateLabel{2})
        Events.Substrate{FileNameCounter}(1:2:64)=1;
        Events.Substrate{FileNameCounter}(2:2:64)=1;

    else
        Events.Substrate{FileNameCounter}(1:2:64)=1;
        Events.Substrate{FileNameCounter}(2:2:64)=2;
    end



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
    for nnn=1:size(test,2)
%         test(:,nnn) =wrev(FlyPAS4(wrev(FlyPAS4(test(:,nnn),20,12)),20,12)); %%Good Filter
        test(:,nnn) = medfilt1(test(:,nnn),6);%% Median filter
%                test(:,nnn) = FilterData(test(:,nnn));


    end

        c=0;
    for i = 1:1:size(test,2)
disp(num2str(i))
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

    %%
    RRfilteredTraces=RfilteredTraces(2:end,:);
    FDerivative=diff(RfilteredTraces);
    %% use Quiroga`s method to find the signal
    clear thrPos thrNeg PosEvents NegEvents


    IBIS=RfilteredTraces.*(~RMSPosEvents);
    %% Dyn Thresh
    Window_For_Threshold=300;
    for n=1:size(FDerivative,2);

        FDerivativePos=FDerivative(:,n);
        FDerivativeNeg=FDerivative(:,n);
        c=1;
        Count=0;


                  ConstThresPOS=max(diff(IBIS(:,n)));
                  ConstThresNEG=min(diff(IBIS(:,n)));
                PosEvents(n,:)=FDerivative(:,n)>ConstThresPOS;
                 NegEvents(n,:)=FDerivative(:,n)<ConstThresNEG;

%         for m=1:Window_For_Threshold:size(FDerivative,1)-Window_For_Threshold
%             c=c+Window_For_Threshold;
%             Count=Count+1;
%             Fpos=FDerivativePos(m:c);
%             Fneg=FDerivativeNeg(m:c);
%             thrPos{n,Count}=4.*median(Fpos(Fpos>1))./0.6745;
%             thrNeg{n,Count}=4.*median(Fneg(Fneg<-1))./0.6745;
%
%             if ConstThresPOS<thrPos{n,Count}
%                 PosEvents(n,m:c)=FDerivative(m:c,n)>thrPos{n,Count};
%             else
%                 PosEvents(n,m:c)=FDerivative(m:c,n)>ConstThresPOS;
%             end
%
%             if ConstThresNEG>thrNeg{n,Count}
%                 NegEvents(n,m:c)=FDerivative(m:c,n)<thrNeg{n,Count};
%             else
%                 NegEvents(n,m:c)=FDerivative(m:c,n)<ConstThresNEG;
%             end
%         end
%

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

    %% LOAD TimeStamps of Digital Ons(LEDs) and Catch Trials
    %         importAllOptoPadData_phototransistor
    %             importAllOptoPadData


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
                %                     indNeg=0;
                %                     indPos=0;
                %                     EventDuration=0;
                %                     Events.Ons{FileNameCounter+DatabaseOffset,nChannels}= indPos;
                %                     Events.Offs{FileNameCounter+DatabaseOffset,nChannels}= indNeg;
                %                     Events.Durations{FileNameCounter+DatabaseOffset,nChannels}= EventDuration;
                %                     Events.IFI{FileNameCounter+DatabaseOffset,nChannels}= indPos(2:end)-indNeg(1:end-1);

                indNeg=0;
                indPos=0;
                EventDuration=0;
                Events.Ons{FileNameCounter+DatabaseOffset,nChannels}=[];
                Events.Offs{FileNameCounter+DatabaseOffset,nChannels}= [];
                Events.Durations{FileNameCounter+DatabaseOffset,nChannels}= [];
                Events.IFI{FileNameCounter+DatabaseOffset,nChannels}= [];

            end




        else

            %                 indNeg=0;
            %                 indPos=0;
            %                 EventDuration=0;
            %                 Events.Ons{FileNameCounter+DatabaseOffset,nChannels}= indPos;
            %                 Events.Offs{FileNameCounter+DatabaseOffset,nChannels}= indNeg;
            %                 Events.Durations{FileNameCounter+DatabaseOffset,nChannels}= EventDuration;
            %                 Events.IFI{FileNameCounter+DatabaseOffset,nChannels}= indPos(2:end)-indNeg(1:end-1);


            indNeg=0;
            indPos=0;
            EventDuration=0;
            Events.Ons{FileNameCounter+DatabaseOffset,nChannels}=[];
            Events.Offs{FileNameCounter+DatabaseOffset,nChannels}= [];
            Events.Durations{FileNameCounter+DatabaseOffset,nChannels}= [];
            Events.IFI{FileNameCounter+DatabaseOffset,nChannels}= [];

        end

    end

% figure
% plot(RfilteredTraces(:,3));hold all;plot(Events.Ons{3},RfilteredTraces(Events.Ons{3},3),'^r','MarkerSize',2)     %% keep only RMS events which have at least 1 feeding event inside (to remove false events due to signal drift)
%
% figure
% plot(test(:,3));hold all;plot(Events.Ons{3},test(Events.Ons{3},3),'^r','MarkerSize',2)     %% keep only RMS events which have at least 1 feeding event inside (to remove false events due to signal drift)

if removeDrift
        nRMSEvents=cell(1,size(IndRMSDiffFoundEvents,2));

        for n=1:size(IndRMSDiffFoundEvents,2)

            for m=1:size(IndRMSDiffFoundEvents{1,n},1)
                TrueRMSEvents{1,n}(m)=sum(Events.Ons{FileNameCounter+DatabaseOffset,n}>=IndRMSDiffFoundEvents{1,n}(m)&Events.Ons{FileNameCounter+DatabaseOffset,n}<=IndRMSDiffFoundEvents{2,n}(m));
                IndRMSDiffFoundEvents{1,n}(TrueRMSEvents{1,n}<=1)=nan;
                IndRMSDiffFoundEvents{2,n}(TrueRMSEvents{1,n}<=1)=nan;
                IndRMSDiffFoundEvents{3,n}(TrueRMSEvents{1,n}<=1)=nan;
                nRMSEvents{1,n}(m)=TrueRMSEvents{1,n}(m);
                %                 nRMSEvents{1,n}(TrueRMSEvents{1,n}<=1)=nan;
            end
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

    %% merging 2 channels of each chamber
    if MergeChannels==1
        Ccounter=0;
        for nCham=1:2:size(Events.Ons,2)
            Ccounter=Ccounter+1;
            EventsTemp.Ons{FileNameCounter+DatabaseOffset,Ccounter}=sort([Events.Ons{FileNameCounter+DatabaseOffset,nCham} Events.Ons{FileNameCounter+DatabaseOffset,nCham+1}]);
            EventsTemp.Offs{FileNameCounter+DatabaseOffset,Ccounter}=sort([Events.Offs{FileNameCounter+DatabaseOffset,nCham} Events.Offs{FileNameCounter+DatabaseOffset,nCham+1}]);
            EventsTemp.Durations{FileNameCounter+DatabaseOffset,Ccounter}=EventsTemp.Offs{FileNameCounter+DatabaseOffset,Ccounter}-EventsTemp.Ons{FileNameCounter+DatabaseOffset,Ccounter};
            EventsTemp.IFI{FileNameCounter+DatabaseOffset,Ccounter}= EventsTemp.Ons{FileNameCounter+DatabaseOffset,Ccounter}(2:end)- EventsTemp.Offs{FileNameCounter+DatabaseOffset,Ccounter}(1:end-1);
        end
    else

    end






    if MergeChannels==1
        Ccounter=0;
        for nCham=1:2:size(Events.Ons,2)
            Ccounter=Ccounter+1;
            EventsTemp.RMSEventsOns{FileNameCounter+DatabaseOffset,Ccounter}=sort([Events.RMSEventsOns{FileNameCounter+DatabaseOffset,nCham}; Events.RMSEventsOns{FileNameCounter+DatabaseOffset,nCham+1}]);
            EventsTemp.RMSEventsOffs{FileNameCounter+DatabaseOffset,Ccounter}=sort([Events.RMSEventsOffs{FileNameCounter+DatabaseOffset,nCham}; Events.RMSEventsOffs{FileNameCounter+DatabaseOffset,nCham+1}]);
            EventsTemp.RMSEventsDurs{FileNameCounter+DatabaseOffset,Ccounter}=EventsTemp.RMSEventsOffs{FileNameCounter+DatabaseOffset,Ccounter}-EventsTemp.RMSEventsOns{FileNameCounter+DatabaseOffset,Ccounter};
            EventsTemp.RMSEventsnEvents{FileNameCounter+DatabaseOffset,Ccounter}=zeros(size(EventsTemp.RMSEventsOns{FileNameCounter+DatabaseOffset,Ccounter}));
            for i=1:length(EventsTemp.RMSEventsOns{FileNameCounter+DatabaseOffset,Ccounter})
                EventsTemp.RMSEventsnEvents{FileNameCounter+DatabaseOffset,Ccounter}(i)= sum(EventsTemp.Ons{FileNameCounter+DatabaseOffset,Ccounter}>=EventsTemp.RMSEventsOns{FileNameCounter+DatabaseOffset,Ccounter}(i)&EventsTemp.Ons{FileNameCounter+DatabaseOffset,Ccounter}<=EventsTemp.RMSEventsOffs{FileNameCounter+DatabaseOffset,Ccounter}(i));
            end
        end
    else

    end

    clear IndRMSDiffFoundEvents
    if BonsaiStyleActivityBouts
        BonsaiAnalysis;
    end
    %% RawData Figures
    % ACTIVITY BOUTS
    %     Events.SpillQuality(FileNameCounter+DatabaseOffset,64)=nan;
%     Events.RawDataOnActBouts{FileNameCounter+DatabaseOffset,64}=[];

    for i=1:size(Events.RMSEventsOns,2)
        numelements=numel(Events.RMSEventsOns{FileNameCounter+DatabaseOffset,i});
        Events.SpillQuality{FileNameCounter+DatabaseOffset,i}=(sum(test(:,i)>=4095))./size(test,1);
%         if numelements>0
%
%             for fig=1:numelements
%
%                 on=Events.RMSEventsOns{FileNameCounter+DatabaseOffset,i}(fig);
%
%                 if on+(secRecording*100)<Dur
%                     Events.RawDataOnActBouts{FileNameCounter+DatabaseOffset,i}(fig,:)=CapData(i,on:on+(secRecording*100));
%                 end
%
%
%             end
%         end
    end

    if MergeChannels==1
        counter=0;
        for nCham=1:2:size(Events.SpillQuality,2)
            counter=counter+1;
            EventsTemp.SpillQuality{FileNameCounter+DatabaseOffset,counter}=max([Events.SpillQuality{FileNameCounter+DatabaseOffset,nCham} Events.SpillQuality{FileNameCounter+DatabaseOffset,nCham+1}]);
        end
    end
    %% SIP FORMS

%     Events.SipForms{FileNameCounter+DatabaseOffset,64}=[];
%
%     WindowSip= Window+PreSipForm+PostSipForm;
%
%     for i=1:size(Events.Ons,2)
%         numelements=numel(Events.Ons{FileNameCounter+DatabaseOffset,i});
%         if numelements>0
%             for n=1:numelements
%
%                 if Events.Ons{FileNameCounter+DatabaseOffset,i}(n)>0
%                     on=Events.Ons{FileNameCounter+DatabaseOffset,i}(n);
%                     off=Events.Offs{FileNameCounter+DatabaseOffset,i}(n);
%                 else
%                     break
%                 end
%
%                 SipFormsVector=NaN(WindowSip+1,1);
%                 try
%                     SipFormsVector(1:PreSipForm+1+off+PostSipForm-on)=test(on-PreSipForm:off+PostSipForm,i);
%                 catch
%                     SipFormsVector(1:PreSipForm+1+off-on)=test(on-PreSipForm:off,i);
%                 end
%
%                 Events.SipForms{FileNameCounter+DatabaseOffset,i}(n,:)=SipFormsVector';
%             end
%         end
%     end

end

if MergeChannels==1&&isfield(Events,'CatchTrial')
    for FileNameCounter=1:size(Events.CatchTrial,1)
        Ccounter=0;
        for nCham=1:2:size(Events.Ons,2)
            Ccounter=Ccounter+1;
            EventsTemp.CatchTrial{FileNameCounter+DatabaseOffset,Ccounter}=sort([Events.CatchTrial{FileNameCounter+DatabaseOffset,nCham}; Events.CatchTrial{FileNameCounter+DatabaseOffset,nCham+1}]);
            EventsTemp.DigitalEventsOns{FileNameCounter+DatabaseOffset,Ccounter}=sort([Events.DigitalEventsOns{FileNameCounter+DatabaseOffset,nCham}; Events.DigitalEventsOns{FileNameCounter+DatabaseOffset,nCham+1}]);
            EventsTemp.DigitalEventsOffs{FileNameCounter+DatabaseOffset,Ccounter}=sort([Events.DigitalEventsOffs{FileNameCounter+DatabaseOffset,nCham}; Events.DigitalEventsOffs{FileNameCounter+DatabaseOffset,nCham+1}]);
            EventsTemp.ConditioningTrials{FileNameCounter+DatabaseOffset,Ccounter}=sort([Events.ConditioningTrials{FileNameCounter+DatabaseOffset,nCham}; Events.ConditioningTrials{FileNameCounter+DatabaseOffset,nCham+1}]);

        end
    end
else

end


if MergeChannels==1
    for i=1:length(Events.Condition)
        EventsTemp.Condition{i}=Events.Condition{i}(1:2:end);
        EventsTemp.Substrate{i}=Events.Substrate{i}(1:2:end);
        EventsTemp.ToRemove{i}=Events.ToRemove{i}(1:2:end);
%         EventsTemp.Condition_Substrate{i}=Events.Condition_Substrate{i}(1:2:end);
    end
    EventsTemp.ConditionLabel=Events.ConditionLabel;
    EventsTemp.SubstrateLabel=Events.SubstrateLabel;
%     EventsTemp.ExperimentData=Events.ExperimentData;
%     EventsTemp.Diff_Subs_Labels=Events.Diff_Subs_Labels;

    EventsTemp2=Events;
    clear Events
    Events=EventsTemp;
    clear EventsTemp
end




cd
% stop
%     Settings=['Dur','RemoveSubstrateNoneaters','RemoveGlobalNoneaters','removeDrift','BonsaiStyleActivityBouts','TimeWindow','NonEaterThreshold','RemoveSpillQuality','RemoveSpillQualityThreshold','ConditionsToTake','sipThreshold','MergeChannels'];

save(DataFilename2,'Events','Dur','RemoveSubstrateNoneaters','RemoveGlobalNoneaters','removeDrift','BonsaiStyleActivityBouts','TimeWindow','NonEaterThreshold','RemoveSpillQuality','RemoveSpillQualityThreshold','ConditionsToTake','sipThreshold','MergeChannels','Different_Subs','-mat','-v7.3')
close all
"""
