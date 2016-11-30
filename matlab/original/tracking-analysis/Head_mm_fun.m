function [Binary_Head_mm,Binary_Head,Head_thr,ALERT_IBI_H] = Head_mm_fun(FlyDB,Heads_Sm,...
    Walking_vec,InSpot,params,Etho_Speed,Head_thr)%spot_thr_OB,Median_MjMnAx,Centroids_Sm,
if nargin==6,Head_thr=2.5;end
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
Binary_Head_mm=Binary_Head;
%% Removing no-micromovement moments from Binary_Head_mm
display('Removing no-micromovements from Head bouts')
for lfly=flies_idx
    NoMicrom_logical=~((Etho_Speed{lfly}(1:size(Binary_Head_mm,1))==2)|(Etho_Speed{lfly}(1:size(Binary_Head_mm,1))==3));
    Binary_Head_mm(NoMicrom_logical,lfly)=0;
end
display('--Finished calculating binary head---')

