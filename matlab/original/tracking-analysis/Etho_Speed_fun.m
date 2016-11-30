function [Etho_Speed,Thresholds]=...
    Etho_Speed_fun(Steplength_Sm_h,Walking_vec,HeadingDiff,params)
%% Microdisplacement vs Grooming during micromovement
%%% Grooming and Feeding usually occur under 1mm/s. I've observed that when
%%% flies feed from spilled yeast, they don't stay in place as they do when
%%% grooming. Therefore, to distinguish grooming from microdisplacements
%%% I'll evaluate the area covered (in px) when fly is below 1 mm/s in the
%%% annotated yeast bouts when fly d>2 mm and when grooming. Do they have a
%%% different signature?
%%% Behavioural classification:
%%% 1 Resting
%%% 2 Slow-micromovement
%%% 3 Fast-micromovement
%%% 4 Slow walk
%%% 5 Walking
%%% 6 Turn
%%% 7 Jump
%%% 8 Activity Bout
%%% 9 Yeast
%%% 10 Sucrose
%%%
%%% Etho_Colors=[...
%%% [0.6 0.6 0.6]*255;...%5->1 - Gray (Resting)
%%% 179 83 181;...%1->2 - Purple (slow micromovement)
%%% 204 140 206;...%2->3 - Light Purple (fast-micromovement)
%%% 124 143 222;...%3->4 -  Blueish violet (Slow walk)
%%% 91 212 255;...%4->5 - Light Blue (Walking)
%%% 0 200 0;...%6->6 - Green (Turn)
%%% 255 0 0;...%7->7 - Red (Jump)
%%% 250 244 0;...%8 Yellow (Activity Bout)
%%% 238 96 8;...%9 - Orange(Yeast head slow micromovement)
%%% 0 0 0;...%10 - Black (Exploiting sucrose (Feeding))
%%% 
%%% STEP 1: Use two-threshold method [Martin 2004] to distinguish 
%%% walking from not walking bouts. Walk_Thr=4mm/s &
%%% Micromov_thr_upper=2mm/s.
%%% STEP 2: Classify the non-walking bouts as slow walk vs
%%% micromovement. Micromov_thr_upper=2 mm/s & Micromov_thr_lower=1mm/s
%%% STEP 3: Micromovements will have fast and slow micromovements
%%% whose structure will classify them into stop, groom, exploit,
%%% food-bout in the "Step 5"  using a single threshold. Micromov_thr_lower=1mm/s
%%% STEP 4: Classifying rest bouts using the Inact_High
%%% STEP 5: Classifying slow micromovements

Thresholds.Micromov_upper=2;%mm/s
Thresholds.Micromov_lower=1;%0.8 mm/s
Thresholds.Fast_micromov=0.8;% mm/s
Thresholds.Inact_High=0.2;%mm/s
Thresholds.Inact_Low=0.05;
Thresholds.Sharp_turn=2.5;%degree/frame
Thresholds.Jump=35;%mm/s

flies_idx=params.IndexAnalyse;
Etho_Speed=cell(size(Steplength_Sm_h));




display('---Calculating Micromovement bouts----')
for lfly=flies_idx
    display(lfly)
    X=Steplength_Sm_h{lfly}*params.px2mm*params.framerate;
    %% Find local maxima
    temp=diff(X);
    temp(temp>0)=1;
    temp(temp<0)=-1;
    localmaxima=find(diff(temp)==-2);%frames locating local maxima in speed
    localminima=find(diff(temp)==2);%frames locating local minima in speed    
    Etho_Speed{lfly}=zeros(length(X),1);% zeros are unclassified segments
    
    %% STEP 1: Introduce walking vs non-walking periods from Walking_vec
    Etho_Speed{lfly}(Walking_vec{lfly}==1)=5;% Fives are walking segments
    
    %% STEP 2: Classifying non-walking bouts as slow walk (3) vs micromovement (13)
    % Place 13 when micromovement: speeds lower or equal than Micromov_thr_lower mm/s
    LowMm=(X<=Thresholds.Micromov_lower)&(Etho_Speed{lfly}==0); 
    Etho_Speed{lfly}(LowMm)=13;%Micromovement
    
    % Place 4 when fly is walking slow: speeds greater or equal than Micromov_thr_upper mm/s
    HiMm=(X>=Thresholds.Micromov_upper)&(Etho_Speed{lfly}==0); 
    Etho_Speed{lfly}(HiMm)=4;%Slow-walk
    
    % Everything that crosses the upper micromovement threshold is fast
    % micromovement
    FastMm=(X<Thresholds.Micromov_upper)&(Etho_Speed{lfly}==0); 
    Etho_Speed{lfly}(FastMm)=3;%Fast-micromovement
    
    %%% Next lines until line 111 don't make much sense after addition of
    %%% previous 2 lines.. but well..
    
%     %%% Find all undefined events:
%     temp_conv=conv(double((Etho_Speed{lfly}==0)),[1 -1]);
%     Undef_starts=find(temp_conv==1);
%     Undef_ends=find(temp_conv==-1)-1;
%     
%     if Undef_starts(1)==1 % Don't correct the first one, since there is no reference
%         Undef_starts2=Undef_starts(2:end)';
%     elseif Undef_starts(1)>1
%         Undef_starts2=Undef_starts';
%     else
%         error('Not undefined bouts at step 2 for this fly?! --> Weird!')
%     end
%     
%     for lUndefbout=Undef_starts2
%         if Etho_Speed{lfly}(lUndefbout-1)==5
%             Etho_Speed{lfly}(lUndefbout:Undef_ends(lUndefbout==Undef_starts))=4;
%         else
%             Etho_Speed{lfly}(lUndefbout:Undef_ends(lUndefbout==Undef_starts))=Etho_Speed{lfly}(lUndefbout-1);
%         end
%     end
    %% Step 3: Classifying micromovements into fast and slow micromovements
    % Place 2 when micromovement: speeds lower or equal than Micromov_thr_lower mm/s
    LowMm=(X>=Thresholds.Fast_micromov)&(Etho_Speed{lfly}==13); 
    Etho_Speed{lfly}(LowMm)=3;%Fast micromovement
    
    % Place 3 when fly is walking slow: speeds greater or equal than Micromov_thr_upper mm/s
    HiMm=(X<Thresholds.Fast_micromov)&(Etho_Speed{lfly}==13); 
    Etho_Speed{lfly}(HiMm)=2;%Slow micromovement
    
    %% STEP 4: Introduce resting bouts from Walking_vec
    Etho_Speed{lfly}(Walking_vec{lfly}==3)=1;
    
%     inactstarts=find(conv(double(Walking_vec{lfly}==3),[1 -1])==1);
%     inactends=find(conv(double(Walking_vec{lfly}==3),[1 -1])==-1)-1;
%     
%     immobility_starts=find(conv(double(X<=Thresholds.Inact_High),[1 -1])==1);
%     immobility_ends=find(conv(double(X<=Thresholds.Inact_High),[1 -1])==-1)-1;
%     
%     if ~isempty(inactstarts)
%         for lbout=1:length(inactstarts)
%             startpoint=find(immobility_starts<=inactstarts(lbout),1,'last');
%             endpoint=find(immobility_ends>=inactends(lbout),1,'first');
%             Micro_mov{lfly}(immobility_starts(startpoint):immobility_ends(endpoint))=1;
%         end
%     end
%     %%% Merging moments with only one local maxima in-between rest bouts
%     %%% and that local maxima doesn't go over fast_micromov
%     inactstarts=find(conv(double(Micro_mov{lfly}==1),[1 -1])==1);
%     inactends=find(conv(double(Micro_mov{lfly}==1),[1 -1])==-1)-1;
%     if ~isempty(inactstarts)
%         for lbout=1:length(inactstarts)-1
%             IBI=inactends(lbout):inactstarts(lbout+1);
%             lmaxframes=find(ismember((IBI),localmaxima));
%             if (length(lmaxframes)==1)&&(X(IBI(lmaxframes))<Thresholds.Fast_micromov)
%                 Micro_mov{lfly}(inactends(lbout):inactstarts(lbout+1))=1;
%             end
%         end
%     end
    
    %% STEP 5: Sharp turns are slow walks with high angular speed
    %%% Find all slow walking events:
    temp_conv=conv(double((Etho_Speed{lfly}==4)),[1 -1]);
    swalk_starts=find(temp_conv==1);
    swalk_ends=find(temp_conv==-1)-1;
    
    if ~isempty(swalk_starts)
        for lswbout=1:length(swalk_starts)
            swframes=swalk_starts(lswbout):swalk_ends(lswbout);
            
            %%% Check that there is only 1 or 2 maxima in headspeed and
            %%% that the angular speed crosses the threshold
            log_1or2_localmax=((sum(ismember(swframes,localmaxima))==1)|...
                    sum(ismember(swframes,localmaxima))==2);
            log_angularspeed=sum(abs(HeadingDiff{lfly}(swframes))>=Thresholds.Sharp_turn)>=1;
            if log_1or2_localmax && log_angularspeed
                Etho_Speed{lfly}(swframes)=6;% Classify as sharp turn
            end
                
        end
    end
    
    %% STEP 6: Jumps are moments where speed > Thresholds.Jump
    Jump=(X>=Thresholds.Jump)&(Etho_Speed{lfly}==5); 
    Etho_Speed{lfly}(Jump)=7;%Jump
    
    %%% Jump will go from minima to minima that borders the maxima that
    %%% went over Thresholds.Jump
    %%% Find all Jump events:
    temp_conv=conv(double((Etho_Speed{lfly}==7)),[1 -1]);
    jump_starts=find(temp_conv==1);
    jump_ends=find(temp_conv==-1)-1;
    
    if ~isempty(jump_starts)
        for ljumpbout=1:length(jump_starts)
            startpoint=find(localminima<=jump_starts(ljumpbout),1,'last');
            endpoint=find(localminima>=jump_ends(ljumpbout),1,'first');
            Etho_Speed{lfly}(localminima(startpoint):localminima(endpoint))=7;% Classify as Jump
        end
    end
    
end
