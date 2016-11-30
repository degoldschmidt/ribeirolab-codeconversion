function [DurInV,CumTimeV,NumBoutsV] = Binary2DurInCumTime_V(FlyDB,Binary_V,Binary_Head_mm,InSpot,subs)
%[DurIn,CumTime] = Binary2DurInCumTime(Binary_vec)
% Binary_vec is a matrix with nrows=nframes and mcols=number of flies.
numsubs=length(subs);

Duration=size(Binary_V,1);

DurInV=cell(size(Binary_V,2),1);


for lfly=1:size(Binary_V,2)
    display(lfly)
    Geometry = FlyDB(lfly).Geometry;
    
    DurInV{lfly}=nan(1000,5); % 5 cols: [lsubs, frame_start, frame_end, spot, duration(frames)]

    F_starts=find(conv(double(Binary_V(:,lfly)~=0),[1 -1])==1);
    F_ends=find(conv(double(Binary_V(:,lfly)~=0),[1 -1])==-1)-1;
    
    if ~isempty(F_starts)
        for lFbout=1:length(F_starts)
            fr_start=F_starts(lFbout);
            fr_end=F_ends(lFbout);
            
            Spots=InSpot(fr_start:fr_end,lfly);
            Spots=Spots(logical(Binary_Head_mm(fr_start:fr_end,lfly)));
            Spots=Spots(Spots~=0);
            if length(unique(Spots))>1
                warning('More than 2 spots')
            end
%             dbstop if warning
            [counts,xbins]=hist(Spots,1:19);
            current_spot=xbins(max(counts)==counts);%InSpot(eng_fr_1,lfly);
            current_spot=current_spot(1);
            lsubs=Geometry(current_spot);
            
            % DurIn --> 5 cols: [lsubs, frame_start, frame_end, spot, duration(fr)]
            DurInV{lfly}(lFbout,:)=[lsubs,fr_start,fr_end,current_spot,...
                (fr_end-fr_start+1)];
            
        end
        DurInV{lfly}=DurInV{lfly}(1:length(F_starts),:);
    else
        DurInV{lfly}=[];
    end
end

%% Cumulative Time
CumTimeV=cell(numsubs,1);%s
NumBoutsV=nan(numsubs,size(Binary_V,2));

for llsubs=subs
    CumTimeV{llsubs==subs}=zeros(Duration,size(DurInV,1));
end

for llfly=1:size(Binary_V,2)
    display(llfly)
    
    %% Number of Bouts & Cumulative Time
    for llsubs=subs
        if ~isempty(DurInV{llfly})
            NumBoutsV(llsubs==subs,llfly)=sum(DurInV{llfly}(:,1)==llsubs);
            bouts_sub=find(DurInV{llfly}(:,1)==llsubs);
            for lbout=bouts_sub'
                framestart=DurInV{llfly}(lbout,2);
                frameend=DurInV{llfly}(lbout,3);
                CumTimeV{llsubs==subs}(framestart:frameend,llfly)=...
                    ones(frameend-framestart+1,1);%frames
                if ((frameend-framestart+1))~=DurInV{llfly}(lbout,5)
                    display(['start' num2str(framestart) ', end: ',...
                        num2str(frameend),...
                        ', dur: ' num2str(DurInV{llfly}(lbout,5))])
                    error('Not match in durations')
                end
                %% Sanity check: All visits must have at least 1 head mm
                if sum(Binary_Head_mm(framestart:frameend,llfly))==0
                    error('There are visits without hmm')
                end
            end
        else
            NumBoutsV(llsubs==subs,llfly)=0;
        end
    end
end



