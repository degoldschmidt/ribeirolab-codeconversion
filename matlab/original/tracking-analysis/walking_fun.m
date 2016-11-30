function Walking_vec=walking_fun(Steplength_Sm_c,Steplength_Sm180_h,params)
ColorsSpeed=Colors(3);
%[1:blue(Walking), 2:white(~Walking), 3:gray(Inactive)]
WalkingEtho_Colors=[ColorsSpeed(3,:);[1 1 1];[0.5 0.5 0.5]];
%% Walking binary vector
Walking_vec=cell(size(Steplength_Sm_c));
Micromov_thr_upper=2;%1;%
Walk_Thr=4;%2;%

Inact_Low=0.05;
Inact_High=0.2;
for lfly=params.IndexAnalyse
    display(lfly)
    
    %% Defining walking vs non-walking periods
    Walking_vec{lfly}=3*ones(size(Steplength_Sm_c{lfly}));
%     figure,image(Walking_log{lfly});colormap(WalkingEtho_Colors);
    
    % Place two when fly is not walking: speeds lower or equal than 2 mm/s
    Leq2mms=Steplength_Sm_c{lfly}*params.px2mm*params.framerate<=Micromov_thr_upper; 
    Walking_vec{lfly}(Leq2mms)=2;%Not Walking
%     figure,image(Walking_log{lfly});colormap(WalkingEtho_Colors);
    
    % Place ones when fly is walking: speeds greater or equal than 4 mm/s
    Geq4mms=Steplength_Sm_c{lfly}*params.px2mm*params.framerate>=Walk_Thr; 
    Walking_vec{lfly}(Geq4mms)=1;%Walking
%     figure,image(Walking_log{lfly});colormap(WalkingEtho_Colors);
    
    %%% Find all undefined events:
    temp_conv=conv(double((Walking_vec{lfly}==3)),[1 -1]);
    Undef_starts=find(temp_conv==1);
    Undef_ends=find(temp_conv==-1)-1;
    
    if Undef_starts(1)==1 % Don't correct the first one, since there is no reference
        Undef_starts2=Undef_starts(2:end)';
    elseif Undef_starts(1)>1
        Undef_starts2=Undef_starts';
    else
        error('Not undefined walking bouts for this fly?! --> Weird!')
    end
    
    for lUndefbout=Undef_starts2
        Walking_vec{lfly}(lUndefbout:Undef_ends(lUndefbout==Undef_starts))=Walking_vec{lfly}(lUndefbout-1);
    end
%     figure,image(Walking_log{lfly});colormap(WalkingEtho_Colors);
    
    %% Defining inactivity bouts
    %%% Number notation --> 4: Undefined; 5: Inactivity; 6: Activity
    
    Temp_Inact=4*ones(size(Steplength_Sm_c{lfly}));
    
% % %     %%% OLD INACTIVITY USING SMOOTH 180 WINDOW
% % %     % Place 5 when fly is not moving: speeds lower or equal than Inact_Low mm/s
% % %     Leq2mms=Steplength_Sm180_h{lfly}*params.px2mm*params.framerate<=Inact_Low; 
% % %     Temp_Inact(Leq2mms)=5;%Inactive
    
    %%% 1) Place 5 when fly is not moving: speeds lower or equal than Inact_Low mm/s
    Leq2mms=Steplength_Sm180_h{lfly}*params.px2mm*params.framerate<=Inact_Low; 
    Temp_Inact(Leq2mms)=5;%Inactive
    
    %%% 2) Place 6 when fly is moving: speeds greater or equal than Inact_High mm/s
    Geq4mms=Steplength_Sm180_h{lfly}*params.px2mm*params.framerate>=Inact_High; 
    Temp_Inact(Geq4mms)=6;%Active
    
    %%% Find all undefined events:
    temp_conv=conv(double((Temp_Inact==4)),[1 -1]);
    Undef_starts=find(temp_conv==1);
    Undef_ends=find(temp_conv==-1)-1;
    
    if Undef_starts(1)==1 % Don't correct the first one, since there is no reference
        Undef_starts2=Undef_starts(2:end)';
    elseif Undef_starts(1)>1
        Undef_starts2=Undef_starts';
    else
        error('Not undefined inactivity bouts for this fly?! --> Weird!')
    end
    
    for lUndefbout=Undef_starts2
        Temp_Inact(lUndefbout:Undef_ends(lUndefbout==Undef_starts))=Temp_Inact(lUndefbout-1);
    end
    
    %%% Periods of inactivity below 0.5 sec don't count as inactivity -->
    %%% This number comes from the FlyPAD parameter to define activity
    %%% bouts: The window for the RMS is 50 samples, meaning 0.5 sec
    %%% 1) Find all inactivity events:
    temp_conv=conv(double((Temp_Inact==5)),[1 -1]);
    Inact_starts=find(temp_conv==1);
    Inact_ends=find(temp_conv==-1)-1;
    
    if ~isempty(Inact_starts)
        if Inact_starts(1)==1 % Don't correct the first one, since there is no reference
            Inact_starts2=Inact_starts(2:end)';
        else
            Inact_starts2=Inact_starts';
        end
        for lInactbout=Inact_starts2
            %%% 2) If it lasts less than 0.5 sec, convert it into what was
            %%% before
            if (Inact_ends(lInactbout==Inact_starts)-lInactbout)<=(params.framerate)/2
                Temp_Inact(lInactbout:Inact_ends(lInactbout==Inact_starts))=Temp_Inact(lInactbout-1);
            end
        end
    else
        display('Not inactivity bouts for this fly?! --> Weird!')
    end
      
    %% Incorporate the inactivity bouts in the Walking_vec
    Walking_vec{lfly}(Temp_Inact==5)=3;
end
display('Walking logical calculation has finished')