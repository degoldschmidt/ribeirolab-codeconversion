function [Binary_V,Binary_VRV,Breaks,Binary_Break,Thr_V,ALERT_IHI_V] = Visit_fun(FlyDB,Binary_Head_mm, Heads_Sm, InSpot,Steplength_Sm_c,subs)
%%% Remember always to check if all long merges are grooming: by writing in
%%% Plot_KinemParams_Inside (March'15): ManualAnnotation.YFeedingEvents=ALERT_IBI(ALERT_IBI(:,5)>100,1:4);
numsubs=length(subs);
px2mm=1/6.4353;
Visit_thr=10;%mm
Break_thr=5;%mm MOdified 03-Feb-2016 (used to be 4mm)

Binary_V=Binary_Head_mm;
Binary_VRV=Binary_Head_mm;
Binary_Break=zeros(size(Binary_Head_mm));
ALERT_IHI_V=cell(numsubs,1);
Breaks=cell(numsubs,1);
for lsubs=subs
    ALERT_IHI_V{lsubs==subs}=nan(10000,6);
    Breaks{lsubs==subs}=nan(10000,8);
end

alertcounter=zeros(1,numsubs);
breakcounter=zeros(1,numsubs);
flycounter=0;
for lfly=1:size(Binary_Head_mm,2)
    flycounter=flycounter+1;
    display(lfly)
    
    spots_idxs=1:18;%find(Geometry==lsubs);
    f_spot=FlyDB(lfly).WellPos(spots_idxs,:);
    
    
    F_starts=find(conv(double(Binary_Head_mm(:,flycounter)~=0),[1 -1])==1);
    F_ends=find(conv(double(Binary_Head_mm(:,flycounter)~=0),[1 -1])==-1)-1;
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
            lsubs=FlyDB(lfly).Geometry(current_spot);
            %% Merge if Heads are within Visit_thr
            if current_spot==prev_spot
                
                duration=(fr_start-prev_frame_end+1);
                distance=sum(Steplength_Sm_c{lfly}(prev_frame_end:fr_start))*px2mm/10;%cm
                Dist2fSpot=sqrt(sum(((Heads_Sm{lfly}(prev_frame_end:fr_start,:)-...
                    repmat(f_spot(current_spot,:),duration,1)).^2),2)).*px2mm;
                
                if sum(Dist2fSpot>Visit_thr)==0
                    %%% Merging:
                    Binary_V(prev_frame_end:fr_start,flycounter)=1;
                    %%% Don't get alarmed.. I then undo all mergings in which
                    %%% the fly crossed the Break_thr. In other words...
                    %%% this code merges head micromovements in which the
                    %%% fly didn't cross the Break_thr.
                    alertcounter(lsubs==subs)=alertcounter(lsubs==subs)+1;
                    ALERT_IHI_V{lsubs==subs}(alertcounter(lsubs==subs),:)=[prev_frame_end,fr_start,current_spot,lfly,...
                        duration distance];
                    if sum(Dist2fSpot>=Break_thr)~=0
                        [maxdistfromspot,fr_idx]=max(Dist2fSpot);
                        breakcounter(lsubs==subs)=breakcounter(lsubs==subs)+1;
                        Breaks{lsubs==subs}(breakcounter(lsubs==subs),:)=[prev_frame_end,fr_start,current_spot,lfly,...
                            duration distance maxdistfromspot prev_frame_end+fr_idx-1];
                        Binary_Break(prev_frame_end:fr_start,flycounter)=1;
                        %%% Do not include Breaks as part of the visit
                        Binary_V(prev_frame_end:fr_start,flycounter)=0;
                    end
                    Binary_VRV(prev_frame_end:fr_start,flycounter)=1;% Merging revisits as part of the visit
                    
                end
                
            end
            prev_frame_end=fr_end;
            prev_spot=current_spot;
        end
        
    end
end

for lsubs=subs
    ALERT_IHI_V{lsubs==subs}=ALERT_IHI_V{lsubs==subs}(1:alertcounter(lsubs==subs),:);
    Breaks{lsubs==subs}=Breaks{lsubs==subs}(1:breakcounter(lsubs==subs),:);
end

Thr_V.Break_thr=Break_thr;
Thr_V.Visit_thr=Visit_thr;