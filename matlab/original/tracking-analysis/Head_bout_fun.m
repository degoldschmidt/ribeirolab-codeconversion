function [Binary_Head,Binary_Encounter,Binary_EncRV,Head_thr,ALERT_IBI_H] = Head_bout_fun(FlyDB,Heads_Sm,...
    Walking_vec,InSpot,params,Head_thr)%spot_thr_OB,Median_MjMnAx,Centroids_Sm,
if nargin==5,Head_thr=2.5;end
display('--Calculating binary head---')
px2mm=1/6.4353;

flies_idx=params.IndexAnalyse;
Binary_Head_temp=zeros(params.MinimalDuration,params.numflies);

for lfly=flies_idx%1:size(Binary_AB,2)
    if mod(lfly,20)==0,display(lfly),end
    %     Geometry = FlyDB(lfly).Geometry;
    
    spots_idxs=1:18;%find(Geometry==lsubs);
    Spots=FlyDB(lfly).WellPos(spots_idxs,:);
    
    %% Distance to spots
    Dist2all=nan(params.MinimalDuration,size(Spots,1));
    for n=1:size(Spots,1)
        Dist2Spot=sqrt(sum(((Heads_Sm{lfly}(1:params.MinimalDuration,:)-...
            repmat(Spots(n,:),params.MinimalDuration,1)).^2),2)).*px2mm;%mm
        
        Dist2all(:,n)=(Dist2Spot<=Head_thr);
    end
    
    if sum(sum(isnan(Dist2all)))~=0
        error('Missing distances to spots')
    else
        logical_Head=logical(sum(Dist2all,2));%&(Binary_AB(:,lfly));
        Binary_Head_temp(:,lfly)=logical_Head;
    end
end

[Binary_Head,ALERT_IBI_H] = Remove_jitter(Binary_Head_temp, Heads_Sm, Walking_vec,InSpot);

%% Merging Inter-bout events where the fly didn't leave more than break_thr
Break_thr=5;%mm changed 09/Feb/2016 4;%mm
Visit_thr=10;%mm
Binary_Encounter=Binary_Head;
Binary_EncRV=Binary_Head;
flycounter=0;
for lfly=1:size(Binary_Head,2)
    flycounter=flycounter+1;
    display(lfly)
    
    spots_idxs=1:18;%find(Geometry==lsubs);
    f_spot=FlyDB(lfly).WellPos(spots_idxs,:);
    
    
    F_starts=find(conv(double(Binary_Head(:,flycounter)~=0),[1 -1])==1);
    F_ends=find(conv(double(Binary_Head(:,flycounter)~=0),[1 -1])==-1)-1;
    prev_frame_end=0;
    prev_spot=0;
    
    if ~isempty(F_starts)
        for lFbout=1:length(F_starts)
            fr_start=F_starts(lFbout);
            fr_end=F_ends(lFbout);
            
            Spots=InSpot(fr_start:fr_end,lfly);
            Spots=Spots(Spots~=0);
            
            if isempty(Spots),Spots=prev_spot;end%Merged when removing jitter of AB
            
            if length(unique(Spots))>=2
                warning('AB in more than one spot at the same time :o - 1st Part')
%                 dbclear if warning
                [counts,xbins]=hist(Spots,1:19);
                current_spot=xbins(max(counts)==counts);%InSpot(eng_fr_1,lfly);
                current_spot=current_spot(1);
            else
                current_spot=unique(Spots);
            end
            %% Merge if Heads are within Break_thr
            if current_spot==prev_spot
                
                duration=(fr_start-prev_frame_end+1);
                Dist2fSpot=sqrt(sum(((Heads_Sm{lfly}(prev_frame_end:fr_start,:)-...
                    repmat(f_spot(current_spot,:),duration,1)).^2),2)).*px2mm;
                
                if sum(Dist2fSpot>Break_thr)==0
                    %%% Merging:
                    Binary_Encounter(prev_frame_end:fr_start,flycounter)=1;
                end
                if sum(Dist2fSpot>Visit_thr)==0
                    Binary_EncRV(prev_frame_end:fr_start,flycounter)=1;
                end
            end
            prev_frame_end=fr_end;
            prev_spot=current_spot;
        end
        
    end
end



display('--Finished calculating binary head---')

