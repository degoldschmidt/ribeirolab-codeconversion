function [Binary_vec_output,ALERT_IBI] = Remove_jitter_lfly(Binary_vec_input, Heads_Sm_lfly, Walking_vec_lfly,lfly)
%%% Make sure that Binary_vec_input is one column! and has the same Nº of frames (rows) as
%%% Heads_Sm_lfly and remember always to check if all long merges are grooming: by writing in
%%% Plot_KinemParams_Inside (March'15): ManualAnnotation.YFeedingEvents=ALERT_IBI(ALERT_IBI(:,5)>100,1:4);
% display('-Removing Jitter-')
ALERT_IBI=nan(10000,5);
alertcounter=0;

F_starts=find(conv(double(Binary_vec_input~=0),[1 -1])==1);
F_ends=find(conv(double(Binary_vec_input~=0),[1 -1])==-1)-1;
prev_frame_end=0;

if length(F_starts)>1
    for lFbout=1:length(F_starts)
        fr_start=F_starts(lFbout);
        fr_end=F_ends(lFbout);
        if lFbout==2
            min_X_Y=min(Heads_Sm_lfly(prev_frame_end:fr_start,:));
            max_X_Y=max(Heads_Sm_lfly(prev_frame_end:fr_start,:));
            if (sum((max_X_Y-min_X_Y)<=2)==2)&&(sum(Walking_vec_lfly(prev_frame_end:fr_start)==3)==0)

                %%% Merging:
                Binary_vec_input(prev_frame_end:fr_start)=1;
                alertcounter=alertcounter+1;
                ALERT_IBI(alertcounter,:)=[prev_frame_end,fr_start,current_spot,lfly,...
                    (fr_start-prev_frame_end+1)];

            end
        end
        prev_frame_end=fr_end;

    end

end

ALERT_IBI=ALERT_IBI(1:alertcounter,:);

Binary_vec_output=Binary_vec_input;
% display('-Finished removing Jitter-')