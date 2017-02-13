import fnmatch
import os
from glob import glob
import numpy as np
from datetime import datetime as dt
import scipy as sp
from scipy import signal
from fastrms import fastrms

import matplotlib.pyplot as plt

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

def get_data_channels(filename, events, remove_ch, diff_subs):
    events["Condition"].append(filled(nch, np.nan))                             # condition in channel vector
    events["ConditionSubstrate"].append(filled(nch, np.nan))                    # condition substrate in channel vector
    events["Substrate"].append(filled(nch, np.nan))                             # substrate in channel vector
    events["ToRemove"].append(np.zeros(nch))                                    # to remove in channel vector
    for icond, condition in enumerate(events["ConditionLabel"]):                # check whether condition is in current file
        condstr = "C"+"{0:02d}".format(icond+1)                                 # build string for condition indicator
        if condstr in filename:
            ##### Get Condition
            ch = []
            ch.append(int(filename.split(condstr,1)[1][1:3]))                   # take start channel from 2nd and 3rd position after condstr
            ch.append(int(filename.split(condstr,1)[1][4:6]))                   # take end channel from 5th and 6th position after condstr
            events["Condition"][-1][ch[0]-1:ch[1]] = icond                      # write which condition corresponds to channel
            ##### Get Substrate
            ### [FLAG]: What does this really do? What is Condition Substrate
            if diff_subs == 1 or diff_subs == 2:
                events["ConditionSubstrate"][-1][ch[0]-1:ch[1]:2] \
                = 2 * icond - 1
                events["ConditionSubstrate"][-1][ch[0]-1:ch[1]:2] \
                = 2 * icond
            events["Substrate"][-1][0:64:2]=1;                                  # even channels
            if events["SubstrateLabel"][0] \
            == events["SubstrateLabel"][1]:                                     # if both labels are the same
                events["Substrate"][-1][1:65:2] = 0                             # uneven channels
            else:
                events["Substrate"][-1][1:65:2] = 1                             # uneven channels
            ##### Get channels to remove
            events["ToRemove"][-1][sorted(remove_ch)] = 1                       # which channels to remove
            ### [FLAG]: find out, if and why this is needed ==> DatabaseOffset
            #Events.ChannelsToRemove{FileNameCounter+DatabaseOffset}=ChannelsToRemove;
            #Events.Time{FileNameCounter+DatabaseOffset,1}=time;
    return events

def filled(m, val):
    X = np.empty(m)
    X[:] = val
    return X

def process_data(filepath, events, parameters):
    """
    Parameters:
    ===========
        filepath:
        duration:
        events:
        remove_ch:
        different_subs: (default: 0)
    """
    duration       = parameters["Duration"]                                     # duration to analyze
    print(duration)
    remove_ch      = parameters["remove_ch"]                                    # channels to remove
    diff_subs      = parameters["different_subs"]                               # Default is 0 (No comparison between channels).
    RMSThresh      = parameters["RMSThresh"]                                    # RMS threshold for bout detection
    RMSWindow      = parameters["RMSWindow"]                                    # window size for root-mean-square
    events["Condition"] = []                                                    # list of condition vectors (len=#channels) per file            TODO: make this a class type
    events["ConditionSubstrate"] = []                                           # list of condition substrate vectors (len=#channels) per file
    events["Substrate"] = []                                                    # list of substrate vectors (len=#channels) per file
    events["ToRemove"] = []                                                     # list of "to remove" vectors (len=#channels) per file
    events["Timestamp"] = []                                                    # list of timestamps per file
    events["Filename"] = []                                                     # list of file names

    for filename in getAllFilepathsWith(filepath, 'CapacitanceData'):           # for all files in filepath containing 'CapacitanceData'
        print(basename(filename))
        events["Filename"].append(basename(filename))                           # save file name without path

        with open(filename, 'rb') as f:                                         # with opening
            cap_data = np.fromfile(f, dtype=np.ushort)                          # read binary data into numpy ndarray (1-dim.)
            rows = cap_data.shape[0]                                            # to shorten next line
            cap_data = (cap_data.reshape(nch, rows/nch,order='F').copy()).T     # reshape array into 64-dim. matrix and take the transpose (rows = time, cols = channels)
            if np.isfinite(duration) and duration < cap_data.shape[0]:
                cap_data = cap_data[:duration,:]                                # cut off data longer than duration
                this_duration = duration                                        # actual duration of experiment
            else:
                if duration > cap_data.shape[0]:                                # warning
                    print("Warning: data shorter than given duration")
                this_duration = cap_data.shape[0]                               # duration is equal to number of rows in data
            cap_data[cap_data==-1]=0
            timestamp = dt.strptime(filename[-19:], '%Y-%m-%dT%H_%S_%M')        # timestamp of file
            events["Timestamp"].append(timestamp)                               # timestamp in channel vector

            ##### Get Conditions and Substrates func
            events = get_data_channels(filename, events, remove_ch, diff_subs)  # see func above

            ##### Filtering
            filtered_traces=np.full(cap_data.shape, np.nan);
            krnlsz = 7                                                          # kernel size of the applied filter TODO: = 6
            for ind in range(cap_data.shape[1]):                                # for each channel
                cap_data[:, ind] = sp.signal.medfilt(cap_data[:, ind], krnlsz)  # apply median filter from scipy
            c=0
            for ind in range(cap_data.shape[1]):                                # for each channel
                #print(ind)                                                     # print out which channel is currently filtered (TODO: progress bar)
                this_ch = cap_data[:, ind]                                      # current channel capacitance data time series
                ### defining a window for additional convolution of signal
                span = 50                                                       # span of convolving window
                window = np.ones(span) / span                                   # uniform window
                filtered_traces[:, ind] = np.convolve(this_ch, window, 'same')  # convolving time series with window
            delta_filt = cap_data - filtered_traces                             # difference between filtered capacitance data and additionally convolved traces

            ### remove the edges
            delta_filt[:span+1,:] = delta_filt[-span:,:] = 0
            cap_data[:span+1,:]   = cap_data[-span:,:]   = 0

            ### get the root-mean-square power of the signal
            cap_data_RMS = fastrms(delta_filt, RMSWindow, 1, 0)
            ### use Quiroga`s method to find the RMS threshold


            # Find positive events
            RMSThrEvents = np.zeros(cap_data_RMS.shape)
            for ind in range(cap_data_RMS.shape[1]):
                RMSThrEvents[:, ind] = cap_data_RMS[:, ind] > RMSThresh         # Array of timesteps when capacitance RMS is above threshold
            dRMSThrEvents = np.diff(RMSThrEvents, axis=0)
            RMSPosEvents = np.zeros(dRMSThrEvents.shape)
            RMSNegEvents = np.zeros(dRMSThrEvents.shape)
            #for ind in range(cap_data.shape[1]):
            #    plt.plot(RMSThrEvents[:, ind], 'b-')
            #plt.show()
            eventsInd, indPosEvents, indNegEvents, distEvents = [],[],[],[]     # empty lists
            for ind in range(RMSThrEvents.shape[1]):
                eventsInd.append( np.nonzero(RMSThrEvents[:, ind])[0] )         # indices of RMS events above Threshold
                RMSPosEvents[:, ind] = dRMSThrEvents[:, ind] > 0                # positive changes (event)
                RMSNegEvents[:, ind] = dRMSThrEvents[:, ind] < 0                # negative changes (event)
                indPosEvents.append( np.nonzero(RMSPosEvents[:, ind])[0] )      # index of positive event
                indNegEvents.append( np.nonzero(RMSNegEvents[:, ind])[0] )      # index of negative event
                distEvents.append( indNegEvents[-1] - indPosEvents[-1] )        # length from negative to positive event

            FDerivative = np.diff(delta_filt)                                   # derivative of delta_filt
            ## use Quiroga`s method to find the signal
            #clear thrPos thrNeg PosEvents NegEvents
            notRMSPos = np.zeros_like(delta_filt)                               # needs to be same shape as delta_filt (pad zeros before)
            notRMSPos[1:notRMSPos.shape[0]+1,:notRMSPos.shape[1]] \
                                = np.logical_not(RMSPosEvents).astype(int)      # this fills all rows after the first one with the logical not of RMSPosEvents
            IBIS = delta_filt * notRMSPos

            ## const threshold
            for ind in range(FDerivative.shape[1]):
                FDerivativePos=FDerivative[:,n]
                FDerivativeNeg=FDerivative(:,n);
                c=1;
                Count=0;
                ConstThresPOS=max(diff(IBIS(:,n)));
                ConstThresNEG=min(diff(IBIS(:,n)));
                PosEvents(n,:)=FDerivative(:,n)>ConstThresPOS;
                NegEvents(n,:)=FDerivative(:,n)<ConstThresNEG;
            break                                                               # break after one file [DEBUGGGGG]
            """
            ##


            ##
            TimeStamps=(1:size(RRfilteredTraces,1))./100;

            ## Assign zeros to all signals that are not defined as events
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


            #

    #np.savez('events.npz', **events)

"""
"""
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
                indNeg=0;
                indPos=0;
                EventDuration=0;
                Events.Ons{FileNameCounter+DatabaseOffset,nChannels}=[];
                Events.Offs{FileNameCounter+DatabaseOffset,nChannels}= [];
                Events.Durations{FileNameCounter+DatabaseOffset,nChannels}= [];
                Events.IFI{FileNameCounter+DatabaseOffset,nChannels}= [];

            end

        else
            indNeg=0;
            indPos=0;
            EventDuration=0;
            Events.Ons{FileNameCounter+DatabaseOffset,nChannels}=[];
            Events.Offs{FileNameCounter+DatabaseOffset,nChannels}= [];
            Events.Durations{FileNameCounter+DatabaseOffset,nChannels}= [];
            Events.IFI{FileNameCounter+DatabaseOffset,nChannels}= [];

        end

    end

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
    end

    if MergeChannels==1
        counter=0;
        for nCham=1:2:size(Events.SpillQuality,2)
            counter=counter+1;
            EventsTemp.SpillQuality{FileNameCounter+DatabaseOffset,counter}=max([Events.SpillQuality{FileNameCounter+DatabaseOffset,nCham} Events.SpillQuality{FileNameCounter+DatabaseOffset,nCham+1}]);
        end
    end
    %% SIP FORMS

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
