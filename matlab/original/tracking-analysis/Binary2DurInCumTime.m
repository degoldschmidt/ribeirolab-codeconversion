function [DurIn,CumTime,NumBouts] = Binary2DurInCumTime(FlyDB,Binary_vec,InSpot,subs)
%[DurIn,CumTime] = Binary2DurInCumTime(Binary_vec)
% Binary_vec is a matrix with nrows=nframes and mcols=number of flies.
display('---Calculating DurIn---')
numsubs=length(subs);
Duration=size(Binary_vec,1);

DurIn=cell(size(Binary_vec,2),1);


for lfly=1:size(Binary_vec,2)
    if mod(lfly,20)==0,display(lfly),end
    Geometry = FlyDB(lfly).Geometry;
    
    DurIn{lfly}=nan(1000,5); % 5 cols: [lsubs, frame_start, frame_end, spot, duration(sec)]

    F_starts=find(conv(double(Binary_vec(:,lfly)~=0),[1 -1])==1);
    F_ends=find(conv(double(Binary_vec(:,lfly)~=0),[1 -1])==-1)-1;
    
    if ~isempty(F_starts)
        for lFbout=1:length(F_starts)
            fr_start=F_starts(lFbout);
            fr_end=F_ends(lFbout);
            
            Spots=InSpot(fr_start:fr_end,lfly);
            Spots=Spots(Spots~=0);
            [counts,xbins]=hist(Spots,1:19);
            current_spot=xbins(max(counts)==counts);%InSpot(eng_fr_1,lfly);
            current_spot=current_spot(1);
            lsubs=Geometry(current_spot);
            
            % DurIn --> 5 cols: [lsubs, frame_start, frame_end, spot, duration(sec)]
            DurIn{lfly}(lFbout,:)=[lsubs,fr_start,fr_end,current_spot,...
                (fr_end-fr_start+1)];
            
        end
        DurIn{lfly}=DurIn{lfly}(1:length(F_starts),:);
    else
        DurIn{lfly}=[];
    end
end

%% Cumulative Time
display('---Calculating CumTime---')
CumTime=cell(numsubs,1);%s
NumBouts=nan(numsubs,size(Binary_vec,2));

for llsubs=subs
    CumTime{llsubs==subs}=zeros(Duration,size(DurIn,1));
end

for llfly=1:size(Binary_vec,2)
    if mod(llfly,20)==0,display(llfly),end
    
    %% Number of Bouts & Cumulative Time
    for llsubs=subs
        if ~isempty(DurIn{llfly})
            NumBouts(llsubs==subs,llfly)=sum(DurIn{llfly}(:,1)==llsubs);
            bouts_sub=find(DurIn{llfly}(:,1)==llsubs);
            for lbout=bouts_sub'
                framestart=DurIn{llfly}(lbout,2);
                frameend=DurIn{llfly}(lbout,3);
                CumTime{llsubs==subs}(framestart:frameend,llfly)=...
                    ones(frameend-framestart+1,1);%frames
                if ((frameend-framestart+1))~=DurIn{llfly}(lbout,5)
                    display(['start' num2str(framestart) ', end: ' num2str(frameend),...
                        ', dur: ' num2str(DurIn{llfly}(lbout,5))])
                    error('Not match in durations')
                end
            end
        else
            NumBouts(llsubs==subs,llfly)=0;
        end
    end
end
display('---Finished calculating DurIn and CumTime---')
