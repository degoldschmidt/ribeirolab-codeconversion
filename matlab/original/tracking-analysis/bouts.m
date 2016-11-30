function [BoutsInfo,CumTime,ALERTS]=bouts(Micro_mov,...
    Heads_Sm,Steplength_Sm_h,FlyDB,flies_idx,params,frames_range)%Centroids_Sm,Tails_Sm
display('--- Food Bouts ---')
Areacovered_Thr_conservative=1;%px/sec
Areacovered_Thr_loose=0.5;%px/sec
spot_thr=2.2; %mm
% Spot_rad=1.5;%mm
Merge_Thr=0.5;%s
% TurnDur_Thr=3;%s
% Visit_Thr=9;%mm
food_spill_thr=3;%mm
x=-33:params.px2mm:33;% pixel-sized grid lines
BoutsInfo.frames_range=frames_range;
BoutsInfo.flies_idx=flies_idx;

%% Default geometry in case there is no food in the spots
logicComp1=cell2mat(cellfun(@(x)~isempty(strfind(x,'4A')),{FlyDB.Filename},'uniformoutput',false));
Geometry_temp=[1,2,1,2,1,2,1,2,1,2,1,2,2,1,2,1,2,1];%3];% Geometry used in EXPs 3 & 4BC
% Geometry_temp=[2,2,2,1,1,1,2,2,2,2,2,1,2,1,1,1,1,1];%3];% Geometry used in EXPs 3 & 4BC

Geometry=[Geometry_temp,3]; %Follow same geometry as other experiments.

%% Bout Durations cell array
DurIn=cell(params.numflies,1);
RawRevisits=cell(params.numflies,1);
InSpot=zeros(params.MinimalDuration,params.numflies);
ALERTS=cell(4,1);
ALERTS{4}={'Merged for more dist covered as spilled';...
    'Merged as food spilled';'Merged for head on the edge and not grooming'};
for l=1:length(ALERTS)-1
    ALERTS{l}=[];
end

Temp_Food=zeros(params.MinimalDuration,params.numflies);

for lfly=flies_idx
    display(lfly)
    
    DurIn{lfly}=nan(1000,5); % 5 cols: [lsubs, frame_start, frame_end, spot, duration(sec)]
    RawRevisits{lfly}=nan(1000,2);% 2 cols: [Revisit duration, Substrate]
    
    
    if logicComp1(lfly)~=1
        Geometry = FlyDB(lfly).Geometry;
    end
    
    %% Distance to spots
    spots_idxs=1:18;%find(Geometry==lsubs);
    f_spot=FlyDB(lfly).WellPos(spots_idxs,:);
    
    for n=1:size(f_spot,1)
        Diff2fSpot=Heads_Sm{lfly}(1:params.MinimalDuration,:)-...
            repmat(f_spot(n,:),...
            params.MinimalDuration,1);
        
        Dist2fSpot=sqrt(sum(((Diff2fSpot).^2),2)).*params.px2mm;
        
        %         DistC2fSpot=sqrt(sum(((Centroids_Sm{lfly}(1:params.MinimalDuration,:)-...
        %                     repmat(f_spot(n,:),...
        %                     params.MinimalDuration,1)).^2),2)).*params.px2mm;
        %         DistT2fSpot=sqrt(sum(((Tails_Sm{lfly}(1:params.MinimalDuration,:)-...
        %                     repmat(f_spot(n,:),...
        %                     params.MinimalDuration,1)).^2),2)).*params.px2mm;
        
        InSpot((Dist2fSpot)<4.7,lfly)=spots_idxs(n);%% Be careful if
        % there is a different geometry, that the spots don't overlap
        
        Temp_Food(Dist2fSpot<=spot_thr,lfly)=1/params.framerate;%s
        %         Temp_Food(DistC2fSpot<=Spot_rad,lfly)=1/params.framerate;%s
        %         Temp_Food(DistT2fSpot<=Spot_rad,lfly)=1/params.framerate;%s
        
    end
    %% Yeast Bouts
    %%% For each bout:
    %%% 1) Check if there is a micromovement bout at the beginning or at
    %%% the end and merge if any of the following is met:
    %%%     a) Head is all the time below Spot_thr+.1 and area coverage
    %%%         is over the Areacovered_Thr_loose
    %%%     b) Most of the micromovement bout is inside the spot and head
    %%%     is inside Food_spill_Thr
    %%%     c) Area coverage is over Areacovered_Thr_conservative and head
    %%%     is inside Food_spill_Thr
    %%% 2) If it's a revisit: Check the trajectory inter-bout right
    %%% before it and merge if:
    %%%     a) Duration is < 0.5s.
    %%%     b) Centroid or tail are all the time inside the spot
    %%%     a) If all the micromovement bouts in it are over or equal to
    %%%     Areacovered_Thr, consider the whole chunk a yeast bout if
    %%%     there are no walking bouts and distance lower than
    %%%     Food_spill_Thr.
    %%%     b) If at least one is below Areacovered_Thr, consider as
    %%%     grooming outside the spot --> Not yeast from 2mm thr.
    %%%     c) If there are no micromovement bouts, check if there is a
    %%%     walking bout --> No yeast, save in ALERT1: Raw revisit with walk
    %%%     and no micromovement, save and plot distance and duration.
    %%%     If there are no walking bouts, then check if distance is below
    %%%     Food_spill_Thr, if it's not, check that centroid or tail are in
    %%%     the spot (ALERT2: Presumed turn lower than Food_spill_Thr or on spot),
    %%%     Mark as turn and food bout and confirm later. Plot distance,
    %%%     and trajectory, paint in annotation).
    %%%     If not, ALERT3: Presumed turns over Food_spill_Thr, no food bout.
    %%%     Save and plot max distance and duration.
    %%% Summary for plot annotation: Trajectory in purple, Y bouts in
    %%% orange, turns in blue
    
    %%% Micromovement bouts
    microstarts=find(conv(double(Micro_mov{lfly}==1),[1 -1])==1);
    microends=find(conv(double(Micro_mov{lfly}==1),[1 -1])==-1)-1;
    
    %% PART 1: Going through each pre-bout (d<= Spot_thr).
    %%% If micromovement bouts at beginning or end, merge if most of it is
    %%% inside.
    F_starts=find(conv(double(Temp_Food(:,lfly)~=0),[1 -1])==1);
    F_ends=find(conv(double(Temp_Food(:,lfly)~=0),[1 -1])==-1)-1;
    
    if ~isempty(F_starts)
        
        for lFbout=1:length(F_starts)
            fr_start=F_starts(lFbout);
            fr_end=F_ends(lFbout);
            %%% Sanity check: Multiple spots in a pre-selected bout?
            Spots=InSpot(fr_start:fr_end,lfly);
            Spots=Spots(Spots~=0);
            if numel(unique(Spots))>1
                display('WARNING: More than one spot in this bout :O')
                return
            end
            current_spot=unique(Spots);
            
            %% Micromovement bouts
            bout_micromovstart=find(microstarts<fr_start,1,'last');
            bout_micromovend=find(microends>fr_end,1,'first');
            for lmicrobout=bout_micromovstart:bout_micromovend
                framesmicro=microstarts(lmicrobout):microends(lmicrobout);
                framesmicro(framesmicro>params.MinimalDuration)=[];
                if ~isempty(framesmicro)
                    %% Micromovement at the beginning or end?:
                    %%% Include both extremes if most of the bout is
                    %%% inside, or the bout is unlikely to be grooming
                    %%% (it's area coverage is over Areacovered_Thr) and
                    %%% it doesn't go over Food_spill_Thr.
                    counts=hist3(Heads_Sm{lfly}(framesmicro,:)*params.px2mm,...
                        'Edges',{x,x});
                    areacovered=(sum(sum(counts~=0)));
                    pxspersec=areacovered/(length(framesmicro)/params.framerate);
                    
                    if ((framesmicro(1)<fr_start)&& (framesmicro(end)>fr_end))||...
                            ((framesmicro(1)<=fr_start) &&...
                            (framesmicro(end)>fr_start)&&(framesmicro(end)<=fr_end))||...
                            ((framesmicro(1)>=fr_start)&&...
                            (framesmicro(1)<=fr_end)&&(framesmicro(end)>fr_end))
                        
                        Dist2fSpot=sqrt(sum(((Heads_Sm{lfly}(framesmicro,:)-...
                            repmat(f_spot(current_spot,:),...
                            length(framesmicro),1)).^2),2)).*params.px2mm;
                        
                        if ((sum(Dist2fSpot>=food_spill_thr)==0)&&...
                                (((sum(Dist2fSpot<=spot_thr)/...
                                length(framesmicro))>0.5)||(pxspersec>=Areacovered_Thr_conservative)))||...
                                (sum(pxspersec>=Areacovered_Thr_loose)==length(pxspersec))&&...
                                (sum(Dist2fSpot>(spot_thr+0.1))==0)
                            
                            Temp_Food(framesmicro,lfly)=1/params.framerate;%s
                        end
                    end
                end
            end
        end
    end
    
    %% PART2: If It's a revisit, check the Inter-bout interval
    F_starts=find(conv(double(Temp_Food(:,lfly)~=0),[1 -1])==1);
    F_ends=find(conv(double(Temp_Food(:,lfly)~=0),[1 -1])==-1)-1;
    
    if ~isempty(F_starts)
        prev_spot=0;
%         prev_fr_end=156786;
        for lFbout=1:length(F_starts)
            fr_start=F_starts(lFbout);
            fr_end=F_ends(lFbout);
            %%% Sanity check: Multiple spots in a pre-selected bout?
            Spots=InSpot(fr_start:fr_end,lfly);
            Spots=Spots(Spots~=0);
            if numel(unique(Spots))>1
                display('WARNING: More than one spot in this bout :P')
                return
            end
            current_spot=unique(Spots);
            %% When Revisit:
            if current_spot==prev_spot
                Dist2fSpot=sqrt(sum(((Heads_Sm{lfly}(prev_fr_end:fr_start,:)-...
                    repmat(f_spot(current_spot,:),...
                    length(prev_fr_end:fr_start),1)).^2),2)).*params.px2mm;
                %                 DistC2fSpot=sqrt(sum(((Centroids_Sm{lfly}(prev_fr_end:fr_start,:)-...
                %                     repmat(f_spot(current_spot,:),...
                %                     length(prev_fr_end:fr_start),1)).^2),2)).*params.px2mm;
                %                 DistT2fSpot=sqrt(sum(((Tails_Sm{lfly}(prev_fr_end:fr_start,:)-...
                %                     repmat(f_spot(current_spot,:),...
                %                     length(prev_fr_end:fr_start),1)).^2),2)).*params.px2mm;
                
                if ((fr_start-prev_fr_end)/params.framerate)<=Merge_Thr
                    %% If duration of IBI < Merge_Thr, merge!
                    Temp_Food(prev_fr_end:fr_start,lfly)=1/params.framerate;%s
                    
                    %                 elseif (sum((DistC2fSpot<=Spot_rad)|...
                    %                        (DistT2fSpot<=Spot_rad))==length(prev_fr_end:fr_start))
                    %                     %% Merge if fly is in contact with food at all times
                    %                     %%% ALERT1: 'Merged because centroid and tail inside'
                    %                     Temp_Food(prev_fr_end:fr_start,lfly)=1/params.framerate;%s
                    %                     ALERTS{1}=[ALERTS{1};...
                    %                         [prev_fr_end,fr_start,current_spot,lfly,...
                    %                         (fr_start-prev_fr_end+1)/params.framerate,max(Dist2fSpot)]];
                else
                    %% Evaluating Micromovement bouts within the IBI
                    bout_micromovstart=find(microstarts>=prev_fr_end,1,'first');
                    bout_micromovend=find(microends<=fr_start,1,'last');
                    
                    if bout_micromovend>=bout_micromovstart
                        pxspersec=nan(bout_micromovend+1-bout_micromovstart,1);
                        micromovcounter=1;
                        %% px covered per mm in each micromovement bout
                        for lmicrobout=bout_micromovstart:bout_micromovend
                            framesmicro=microstarts(lmicrobout):microends(lmicrobout);
                            
                            counts=hist3(Heads_Sm{lfly}...
                                (framesmicro,:)*params.px2mm,...
                                'Edges',{x,x});
                            areacovered=(sum(sum(counts~=0)));
                            
                            pxspersec=areacovered/...
                                (length(framesmicro)/params.framerate);
                            
                            micromovcounter=micromovcounter+1;
                        end
                        %% Consider food spilled (merge as food bout)
                        %%% If all micromovement bouts are over or equal than
                        %%% Areacovered_Thr, and the fly head stays below
                        %%% Food_spill_Thr and most of it is a micromovement bout,
                        %%% consider whole chunk as bout (food spilled).
                        %%% If not, do nothing: Don't merge.
                        distcovered_micro=sum(Steplength_Sm_h{lfly}...
                            (find(Micro_mov{lfly}(prev_fr_end:fr_start)==1)+prev_fr_end-1));
                        
                        if (sum(pxspersec>=Areacovered_Thr_conservative)==length(pxspersec))&&...
                                (sum(Dist2fSpot>food_spill_thr)==0)&&...
                                ((distcovered_micro/sum(Steplength_Sm_h{lfly}(prev_fr_end:fr_start)))>0.5)
                            Temp_Food(prev_fr_end:fr_start,lfly)=1/params.framerate;%s
                            %%% ALERT2: 'Merged as food spilled'
                            ALERTS{2}=[ALERTS{2};...
                                [prev_fr_end,fr_start,current_spot,lfly,...
                                (fr_start-prev_fr_end+1)/params.framerate,max(Dist2fSpot)]];
                        elseif (sum(pxspersec>=Areacovered_Thr_loose)==length(pxspersec))&&...
                                (sum(Dist2fSpot>(spot_thr+0.1))==0)
                            Temp_Food(prev_fr_end:fr_start,lfly)=1/params.framerate;%s
                            %%% ALERT3: 'Merged for head on the edge and not grooming'
                            ALERTS{3}=[ALERTS{3};...
                                [prev_fr_end,fr_start,current_spot,lfly,...
                                (fr_start-prev_fr_end+1)/params.framerate,max(Dist2fSpot)]];
                        end
                    else % --> When there are no micromovements, apply same rule
                        %%% of more distance covered incase of spill
                        Dist2fSpot=sqrt(sum(((Heads_Sm{lfly}(1:params.MinimalDuration,:)-...
                            repmat(f_spot(current_spot,:),...
                            params.MinimalDuration,1)).^2),2)).*params.px2mm;
                        insidestarts=find(conv(double(Dist2fSpot<=spot_thr),[1 -1])==1);
                        insideends=find(conv(double(Dist2fSpot<=spot_thr),[1 -1])==-1)-1;
                        if ~((sum(insidestarts==fr_start)==1)&&(sum(insideends==prev_fr_end)==1))
                            temp1=find(insideends<=prev_fr_end,1,'last');
                            temp2=find(insidestarts>=fr_start,1,'first');
                            if (~isempty(temp1) && ~isempty(temp2))
                                if (sum(Steplength_Sm_h{lfly}(prev_fr_end:fr_start))/...
                                        sum(Steplength_Sm_h{lfly}(insideends(temp1):insidestarts(temp2))))<0.5
                                    Temp_Food(prev_fr_end:fr_start,lfly)=1/params.framerate;%s
                                    %%% ALERT1: 'Merged for more dist covered as spilled'
                                    ALERTS{1}=[ALERTS{1};...
                                        [prev_fr_end,fr_start,current_spot,lfly,...
                                        (fr_start-prev_fr_end+1)/params.framerate,max(Dist2fSpot)]];
                                end
                            end
                        end
                    end
                end
            end
            prev_spot=current_spot;
            prev_fr_end=fr_end;
            
        end
        
    end
    %% Saving information in BoutsInfo
    F_starts=find(conv(double(Temp_Food(:,lfly)~=0),[1 -1])==1);
    F_ends=find(conv(double(Temp_Food(:,lfly)~=0),[1 -1])==-1)-1;
    
    if ~isempty(F_starts)
        prev_spot=0;
        for lFbout=1:length(F_starts)
            fr_start=F_starts(lFbout);
            fr_end=F_ends(lFbout);
            %%% Sanity check: Multiple spots in a pre-selected bout?
            Spots=InSpot(fr_start:fr_end,lfly);
            Spots=Spots(Spots~=0);
            [counts,xbins]=hist(Spots,1:19);
            current_spot=xbins(max(counts)==counts);%InSpot(eng_fr_1,lfly);
            current_spot=current_spot(1);
            lsubs=Geometry(current_spot);
            
            if numel(unique(Spots))>1
                display({'WARNING: More than one spot in this bout';...
                    'Press any key to continue...'})
                pause
            end
            
            % DurIn --> 5 cols: [lsubs, frame_start, frame_end, spot, duration(sec)]
            DurIn{lfly}(lFbout,:)=[lsubs,fr_start,fr_end,current_spot,...
                (fr_end-fr_start+1)/params.framerate];
            if current_spot==prev_spot
                % RawRevisits --> 2 cols: [Revisit duration, Substrate]
                RawRevisits{lfly}(lFbout,:)=[(fr_start-prev_fr_end+1)/params.framerate,lsubs];
            else
                RawRevisits{lfly}(lFbout,:)=nan(1,2);
            end
            prev_spot=current_spot;
            prev_fr_end=fr_end;
        end
        DurIn{lfly}=DurIn{lfly}(1:length(F_starts),:);
        RawRevisits{lfly}=RawRevisits{lfly}(1:length(F_starts),:);
    else
        DurIn{lfly}=[];
        RawRevisits{lfly}=[];
    end
    
    
    
end
BoutsInfo.DurIn=DurIn;%s
BoutsInfo.RawRevisits=RawRevisits;%s
[BoutsInfo,CumTime]=bouts_p(BoutsInfo,params,flies_idx);
display('Bouts calculation finished')
%%

    function [BoutsInfo,CumTime]=bouts_p(BoutsInfo,params,flies_idx)
        %% CumTime is in seconds
        NumBouts=nan(length(params.Subs_Names),size(BoutsInfo.DurIn,1));
        CumTime=cell(length(params.Subs_Names),1);%s
        DurInOld=cell(length(params.Subs_Names),1);%s


        for llsubs=1:length(params.Subs_Names)
            CumTime{llsubs}=zeros(params.MinimalDuration,size(BoutsInfo.DurIn,1));
            DurInOld{llsubs}=cell(size(BoutsInfo.DurIn));
        end

        for llfly=flies_idx
            %     display(llfly)

            %% Number of Bouts & Cumulative Time
            for llsubs=1:length(params.Subs_Names)
                NumBouts(llsubs,llfly)=sum(BoutsInfo.DurIn{llfly}(:,1)==llsubs);
                bouts_sub=find(BoutsInfo.DurIn{llfly}(:,1)==llsubs);
                for lbout=bouts_sub'
                    framestart=BoutsInfo.DurIn{llfly}(lbout,2);
                    frameend=BoutsInfo.DurIn{llfly}(lbout,3);
                    CumTime{llsubs}(framestart:frameend,llfly)=...
                        ones(frameend-framestart+1,1)/params.framerate;%s
                    if ((frameend-framestart+1)/params.framerate)~=BoutsInfo.DurIn{llfly}(lbout,5)
                        display(['start' num2str(framestart) ', end: ' num2str(frameend),...
                            ', dur: ' num2str(BoutsInfo.DurIn{llfly}(lbout,5))])
                        error('Not match in durations')
                    end
                end
                DurInOld{llsubs}{llfly}=BoutsInfo.DurIn{llfly}(bouts_sub,5);
                if max(DurInOld{llsubs}{llfly})>20*60,
                    display(['max dur in ' params.Subs_Names{llsubs} ': ',...
                        num2str(max(DurInOld{llsubs}{llfly}))])
                end
            end
        end

        BoutsInfo.NumBouts=NumBouts;
        BoutsInfo.DurInOld=DurInOld;
    end
end