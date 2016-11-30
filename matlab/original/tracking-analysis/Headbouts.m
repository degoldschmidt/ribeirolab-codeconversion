%% %% Head and head micromovement bouts %% %%
% [InSpot]=inspot_fun(FlyDB,Heads_Sm,flies_idx,params);
% save([Variablesfolder 'Inspot'  Exp_num Exp_letter,...
%     ' ' date '.mat'],'InSpot','params','-v7.3')
% display('Inspot has been saved')
%% Calculating Head Micromovements within ABs
Head_thr=2.5;
[Binary_Head_mm,Binary_Head,Head_thr,ALERT_IBI_H] = Head_mm_fun(FlyDB,Heads_Sm,...
    Walking_vec,InSpot,params,Etho_Speed,Head_thr);
[DurInH,CumTimeH,NumBoutsH] = Binary2DurInCumTime(FlyDB,Binary_Head_mm,InSpot,params.Subs_Numbers);
[DurInHOnly,CumTimeHOnly,NumBoutsHOnly] = Binary2DurInCumTime(FlyDB,Binary_Head,InSpot,params.Subs_Numbers);
%% Head mm sanity check
totalsum=nan(length(params.Subs_Names),1);
subscounter=0;
for lsubs=params.Subs_Numbers
    subscounter=subscounter+1;
    totalsum(subscounter)=sum(sum(CumTimeH{lsubs==params.Subs_Numbers}));
end
if sum(totalsum)~=sum(sum(Binary_Head_mm))
    display('There is a mismatch in total overlapping time :(')
else
    display('Total overlapping time is correct :)')
end

%% Ethograms Overlap Speed with AB and Speed with Head Activity Bouts
[Etho_H] =Etho_H_fun(CumTimeH,Etho_Speed,params.MinimalDuration);

save([Variablesfolder 'HeadBouts&CumulativeTimeH&EthoH'  Exp_num Exp_letter,...
    ' ' date '.mat'],'DurInH','CumTimeH','Binary_Head_mm','NumBoutsH',...
    'Binary_Head','DurInHOnly','CumTimeHOnly','NumBoutsHOnly','Etho_H','Head_thr','-v7.3')
display('Head micromovement bouts and Ethogram saved')
