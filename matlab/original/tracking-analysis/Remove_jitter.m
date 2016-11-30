function [Binary_vec_output,ALERT_IBI] = Remove_jitter(Binary_vec_input, Heads_Sm, Walking_vec,InSpot)
%%% Remember always to check if all long merges are grooming: by writing in
%%% Plot_KinemParams_Inside (March'15): ManualAnnotation.YFeedingEvents=ALERT_IBI(ALERT_IBI(:,5)>100,1:4);
display('-Removing Jitter-')
ALERT_IBI=nan(10000,5);
alertcounter=0;
flycounter=0;
for lfly=1:size(Binary_vec_input,2)
    flycounter=flycounter+1;
    if mod(flycounter,20)==0,display(lfly),end
    
    F_starts=find(conv(double(Binary_vec_input(:,flycounter)~=0),[1 -1])==1);
    F_ends=find(conv(double(Binary_vec_input(:,flycounter)~=0),[1 -1])==-1)-1;
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
                [counts,xbins]=hist(Spots,1:19);
                current_spot=xbins(max(counts)==counts);%InSpot(eng_fr_1,lfly);
                current_spot=current_spot(1);
            else
                current_spot=unique(Spots);
            end
            
            %% Merge when area covered with head during IBI is less than 1 px
            if current_spot==prev_spot
                min_X_Y=min(Heads_Sm{lfly}(prev_frame_end:fr_start,:));
                max_X_Y=max(Heads_Sm{lfly}(prev_frame_end:fr_start,:));
                if (sum((max_X_Y-min_X_Y)<=2)==2)&&(sum(Walking_vec{lfly}(prev_frame_end:fr_start)==3)==0)
                    
                    %%% Merging:
                    Binary_vec_input(prev_frame_end:fr_start,flycounter)=1;
                    alertcounter=alertcounter+1;
                    ALERT_IBI(alertcounter,:)=[prev_frame_end,fr_start,current_spot,lfly,...
                        (fr_start-prev_frame_end+1)];
                     
                end
            end
            prev_frame_end=fr_end;
            prev_spot=current_spot;
        end
        
    end
end
ALERT_IBI=ALERT_IBI(1:alertcounter,:);

Binary_vec_output=Binary_vec_input;
display('-Finished removing Jitter-')