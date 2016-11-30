%% Encounters

ranges=[1 30000;30001 90000;90001 150000;150001 210000;210001 270000;270001 360000];%
% ranges=[1 15000;15001 45000;45001 105000;105001 165000;165001 225000;225001 285000;285001 345000];%
if ranges(end)>params.MinimalDuration
    last_idx=find(ranges(:,2)>= params.MinimalDuration,1,'first');
    ranges=ranges(1:last_idx,:);
    ranges(last_idx,2)=params.MinimalDuration;
end

Head_thr=2.5;

MaxRad=4;%%
X_range=1:.5:MaxRad;%
X_range2=X_range(1:2:end);



[~,Binary_Head] = Head_mm_fun(FlyDB,Heads_Sm,...
    Walking_vec,InSpot,params,Etho_Speed,Head_thr);
[DurInH,CumTimeH] = Binary2DurInCumTime(FlyDB,Binary_Head_mm,InSpot,params.Subs_Numbers);