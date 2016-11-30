%% New latency defined as (Root et al. 2011): Latency is defined as the elapsed
% % % time before an individual fly spends more than 5 seconds within a distance 
% % % of 5 mm from the odor source, which minimizes false positives due to random entry into the odor zone”
% lHThr=3;%2.5;%
% [~,Binary_Encounter] = Head_bout_fun(FlyDB,Heads_Sm,Walking_vec,InSpot,params,lHThr);
% [DurInEncounter,CumTimeEnc] = Binary2DurInCumTime(FlyDB,Binary_Encounter,InSpot,params.Subs_Numbers);
% save('CumTimeEnc09-May-2016.mat','CumTimeEnc')
latency_root=nan(params.numflies,1);
for lfly=1:params.numflies
%     temp=DurInEncounter{lfly}(DurInEncounter{lfly}(:,1)==1,:);
    if ~isempty(DurInV{lfly})
        temp=DurInV{lfly}(DurInV{lfly}(:,1)==1,:);%Frames
        row=find(temp(:,5)>=30*50,1,'first');%30 seconds
        if ~isempty(row)
            latency_root(lfly)=temp(row,2);%frames
        end
    end
end
% hist_bout_duration(DurInV,Conditions,params,5,15,[15 15],'Visit durations');
%% Calculating lagphase for each fly
NonEaterThr=60;%s
ranges_str='lagphase+4r_until115';%'lagphase+113r_until115_5w_1st';%'lagphase+1r_until115';%
slidingwindow=0;
windowsize=5;%min
windowstep=1;%min
AllConditions=unique(params.ConditionIndex);

if slidingwindow==1
    lastframe=params.MinimalDuration;
    ranges_temp=[(1:windowstep*50*60:lastframe-windowsize*60*50);...
        (1:windowstep*50*60:lastframe-windowsize*60*50)+windowsize*60*50]';
else
%     ranges_temp=[1 15000;15001 30000;30001 90000;90001 180000;180001 360000];
    ranges_temp=[1 30000;30001 90000;90001 180000;180001 360000];%[-10 -30 -60 -120]
%     ranges_temp=[1 15000;15001 45000;45001 105000];%[-5 -15 -35]
%     ranges_temp=[1 360000];% To use with 'lagphase+1r_until115';%
end
lags=nan(params.numflies,2);
ranges_fly=cell(params.numflies,1);
for lfly=params.IndexAnalyse
    lfly
    lat_fly=latency_root(lfly);%Frames
    if lat_fly>1
        ranges_fly{lfly}=[1 lat_fly-1;...
        lat_fly-1+ranges_temp];
        
    else
        ranges_fly{lfly}=[1 5*50*60;...
        5*50*60+ranges_temp];
    end
%     CumVfly=find(cumsum(CumTimeV{1}(:,lfly))/50>=NonEaterThr,1,'first');%min
%     if CumVfly>1
%         visitstarts=find(conv(CumTimeV{1}(:,lfly),[1 -1])==1);
%         CumVfly2=visitstarts(find(visitstarts<=CumVfly,1,'last'));
%         if CumVfly2>1
%         ranges_fly{lfly}=[1 CumVfly2-1;...
%             CumVfly2-1+ranges_temp];
%             lags(lfly,1)=CumVfly2;
%             lags(lfly,2)=CumVfly;
%         else
%             ranges_fly{lfly}=[1 2;...
%             2+ranges_temp];
%             lags(lfly,2)=CumVfly;
%         end
%     else
%         ranges_fly{lfly}=[1 2;...
%             2+ranges_temp];
%     end 
    
end
ranges=[1 5*50*60;ranges_temp];
