function [TimeSegmentsParams,CondFlyIdx,Spot_thrs,VisitDurs_TS]=timesegmentsparams(ranges,FlyDB,params,...
    Heads_Sm,Steplength_Sm_c,Steplength_Sm_h,DurInV,CumTimeV,Binary_V,...
    Breaks,Etho_Tr,Etho_Tr2, Walking_vec,Etho_Speed,InSpot,HEAD_YN,Binary_Head_mm,CumTimeH,HeadingDiff,eachflyrange,DurInVRV)
%% TimeSegmentsParams is a cell variable with as many entries as conditions or
%%% unique(params.ConditionIndex). The Fly index is the fly index inside the
%%% condition, not the DataBase fly index. CondFlyIdx has 2 columns: Col1 is
%%% the DataBase fly index, Col2 is the fly index inside the condition.
%%% To access condition_n, parameter_x, in range_y and flycondidx_z write:
%%% TimeSegmentsVar{condition_n}(parameter_x).Data(range_y,flycondidx_z)
%%% If eachflyrange==0, then "ranges" is a mx2 matrix with m=num of ranges,
%%% each row indicates the beginning and end of each range.
%%% If eachflyrange==1, then "ranges" must be a cell with length=params.numflies, each entry
%%% is the ranges matrix for each fly: a mx2 matrix with m=num of ranges,
%%% each row indicates the beginning and end of each range for each fly
%
%
%%% %% Parameters Calculated (to see details of calculation, refer to
%%% electronic lab book, Analysis Algorithm>Parameters extracted from each
%%% experiment>Time segment parameters):
% 1.	Distance covered (1)
% 2.	Speed outside visits (2)
% 3.	% Time on food (3)
% 4.	% Time on edge (4)
% 5.	Total N� of visits (5)
% 6.	YPI (time) (6)
% 7.	Average YAreavisit/Ytimevisit
% 8.	Area outside visits (px/min)
% 9.	Average duration Y (7)
% 10.	Average duration S (8)
% 11.	N� visits Y (9)
% 12.	N� visits S (10)
% 13.	Average Y-Y Spot distance
% 14.	Average S-S spot distance
% 15.	N� of excursions/min on yeast (11): Yeast visit or yeast micromovement?
% 16.	YPI (N�) (12)
% 17.	Transition Probabilities to close Y (13)
% 18.	Transition Probabilities to far Y (14)
% 19.	Transition Probabilities to close S
% 20.	Transition Probabilities to far S
% 21.	Average maximum distance to centre of spot during excursions
% 22.	Average Grassing Yeast (Distance Head-Distance body)
% 23.	Average YS-Y Spot distance (15)
% 24.	Average YS-S Spot distance (16)
% 25.	Average YS-Y inter visit distance covered
% 26.	Average YS-S inter visit distance covered
% 27.	TotalYArea in interval/TotalYtime in interval
% 28.	Average distance from Yeast, during visit
% 29.	Average distance from Sucrose, during visit
% 30.   Average minimum distance from the centre of Yeast (mm)
% 31.   Average minimum distance from the centre of Sucrose (mm)
% 32.   Number of excursions
% 33.   Number of different YSpots visited
% 34.	Transition Probabilities to the Same Subs1
% 35.	Transition Probabilities to the Same Subs2
% 36.	Transition Probabilities to the Adj Subs1
% 37.	Transition Probabilities to the Adj Subs2
% 38.	Transition Probabilities to the Far Subs1
% 39.	Transition Probabilities to the Far Subs2
% 40.   Average Minimum distance to yeast during 4.5mm bout, outside visit
% 41.	Average Minimum distance to sucrose during 4.5mm bout, outside visit
% 42.   Time spent in 4.5mm Y bout, but not in visit
% 43.   Time spent in 4.5mm S bout, but not in visit
% 44.   N� of Head mm for Y
% 45.   N� of Head mm for S
% 46.   Total duration of Hmm for Y
% 47.   Total duration of Hmm for S
% 48.   Total duration of Visits to Y
% 49.   Total duration of Visits to S
% 50.   Average YS-Y Inter time (s)
% 51.   Average YS-S Inter time (s)
% 52.	N� visits Y per min
% 53.	N� visits S per min
% 54.   % of time walking outside visits
% 55.   Av Angular Speed outside visits
% 56.   N� of visits to edge/Time moving
% 57.   Speedh during visits
% 58.   Speedc during visits
% 59.   Av Angular Speed during Yeast visits
% 60.   Area Substrate 1
% 61.   N� Y visits including revisits
% 62.   N� S visits including revisits
% 63.   YPI of N� of visits including revisits
% 64.   YPI N� of bouts at 3mm with revisits
% 65.   N� of Y bouts at 3mm with revisits
% 66.   N� of S bouts at 3mm with revisits
% 67.	Average YS-Y inter visit distance covered per min
% 68.	Average YS-S inter visit distance covered per min
% 69.   Av Angular Speed during sucrose visits
% 70.	Transition Probabilities to the Same Subs1 (subs1 only)
% 71.	Transition Probabilities to the Adj Subs1 (subs1 only)
% 72.	Transition Probabilities to the Far Subs1 (subs1 only)
% 73.   Total time walking outside visits (min)
% 74.   MSDR - max Speed to Duration ration in all waking bouts (fast&slow)
% n+1:n+nthr   1) Y N� bouts at different radii
% 50:57   2) S N� bouts at different radii
% 58:65   3) Y Av duration at different radii
% 66:73   4) S Av Duration at different radii
% 74:81   5) YPI at different radii
% 82:89   6) N� of Y bouts with micromovements at different radii
% 90:97   7) N� of S bouts with micromovements at different radii
% 98:105  8) Rate of Y engagement at different radii
% 106:113 9) Rate of S engagement at different radii -
% 10) Y N� bouts over time at different radii
% 11) S N� bouts over time at different radii
% 12) Y N� bouts over time walking outside visits at different radii
% 13) S N� bouts over time walking outside visits at different radii


display('CALCULATING TIME SEGMENT PARAMETERS')
xrange=-33/params.px2mm:33/params.px2mm;
MaxRad=4.5;%%
Spot_thrs=1:.5:MaxRad;%
Specific_thr=[3 4.5];
Conditions=unique(params.ConditionIndex);
CondFlyIdx=nan(size(params.ConditionIndex,2),2);


TimeSegmentsParams=cell(length(Conditions),1);

% variables1=struct('YLabel',cell(numparams,1),...
%     'ColorAxes',num2cell(repmat(ColorAx1,numparams,1),2),...
%     'XAxes',num2cell(repmat([ranges(1)/params.framerate/60 ranges(end)/params.framerate/60],numparams,1),2),...
%     'YAxes',cell(numparams,1));
%% CREATING STRUCTURE
clear var_struct
var_struct(1).YLabel={'Dist covered';'(m)'};var_struct(1).YAxes=[0 0];
var_struct(2).YLabel={'Speed_c';'not v(mm/s)'};var_struct(2).YAxes=[0 0];
var_struct(3).YLabel='t_F_o_o_d/t_T';var_struct(3).YAxes=[0 0];
var_struct(4).YLabel='t_e_d_g_e/t_T';var_struct(4).YAxes=[0 0];
var_struct(5).YLabel={'Total N�';'of visits'};var_struct(5).YAxes=[0 0];
var_struct(6).YLabel={'YPI';'(Time visits)'};var_struct(6).YAxes=[-1.1 1.5];
var_struct(7).YLabel={['Av Area per min ' params.Subs_Names{1}(1) 'v'];'(px/min)'};var_struct(7).YAxes=[0 0];
var_struct(8).YLabel={'Area not v';'(px/min)'};var_struct(8).YAxes=[0 0];
var_struct(9).YLabel={[params.Subs_Names{1}(1) ' Av Dur'];'(min)'};var_struct(9).YAxes=[0 0];
var_struct(10).YLabel={'S Av Dur';'(min)'};var_struct(10).YAxes=[0 0];
var_struct(11).YLabel={['N� ' params.Subs_Names{1}(1)],'Visits'};var_struct(11).YAxes=[0 0];
var_struct(12).YLabel={'N� S';'Visits'};var_struct(12).YAxes=[0 0];
var_struct(13).YLabel={['Av ' params.Subs_Names{1}(1) '-' params.Subs_Names{1}(1) ' Spot'];'dist (mm)'};var_struct(13).YAxes=[0 0];
var_struct(14).YLabel={'Av S-S Spot';'dist (mm)'};var_struct(14).YAxes=[0 0];
var_struct(15).YLabel={'N� Excurs.';['per min ' params.Subs_Names{1}(1) 'v']};var_struct(15).YAxes=[0 0];
var_struct(16).YLabel={'YPI';'(N� visits)'};var_struct(16).YAxes=[-1.1 1.5];
var_struct(17).YLabel={'Tr Pr (%)';['To close ' params.Subs_Names{1}(1)]};var_struct(17).YAxes=[0 0];
var_struct(18).YLabel={'Tr Pr (%)';['To far ' params.Subs_Names{1}(1)]};var_struct(18).YAxes=[0 0];
var_struct(19).YLabel={'Tr Pr (%)';'To close S'};var_struct(19).YAxes=[0 0];
var_struct(20).YLabel={'Tr Pr (%)';'To far S'};var_struct(20).YAxes=[0 0];
var_struct(21).YLabel={'Av max dist';'on excurs. (mm)'};var_struct(21).YAxes=[0 0];
var_struct(22).YLabel={['Av Grassing ' params.Subs_Names{1}(1)];'(d_h - d_c)'};var_struct(22).YAxes=[0 0];
var_struct(23).YLabel={'Av YS-Y Spot';'dist (mm)'};var_struct(23).YAxes=[0 0];
var_struct(24).YLabel={'Av YS-S Spot';'dist (mm)'};var_struct(24).YAxes=[0 0];
var_struct(25).YLabel={'Av YS-Y Inter';'dist covered (mm)'};var_struct(25).YAxes=[0 0];
var_struct(26).YLabel={'Av YS-S Inter';'dist covered (mm)'};var_struct(26).YAxes=[0 0];
var_struct(27).YLabel={['Total' params.Subs_Names{1}(1) 'Ar/Total' params.Subs_Names{1}(1) 't'],'(px/min)'};var_struct(27).YAxes=[0 0];
var_struct(28).YLabel={['Av dist from ' params.Subs_Names{1}(1)];'during visit (mm)'};var_struct(28).YAxes=[0 0];
var_struct(29).YLabel={'Av dist from S';'during visit (mm)'};var_struct(29).YAxes=[0 0];
var_struct(30).YLabel={['Av ' params.Subs_Names{1}(1) ' minim'];'dist in visit (mm)'};var_struct(30).YAxes=[0 0];
var_struct(31).YLabel={'Av S minim';'dist in visit(mm)'};var_struct(31).YAxes=[0 0];
var_struct(32).YLabel=['N� ' params.Subs_Names{1}(1) 'Excursions'];var_struct(32).YAxes=[0 0];
var_struct(33).YLabel={'N� of different ',[ params.Subs_Names{1}(1) 'Spots']};var_struct(33).YAxes=[0 0];
var_struct(34).YLabel={'Tr Pr (%)';['To same ' params.Subs_Names{1}(1)]};var_struct(34).YAxes=[0 0];
var_struct(35).YLabel={'Tr Pr (%)';'To same S'};var_struct(35).YAxes=[0 0];
var_struct(36).YLabel={'Tr Pr (%)';['To adj ' params.Subs_Names{1}(1)]};var_struct(36).YAxes=[0 0];
var_struct(37).YLabel={'Tr Pr (%)';'To adj S'};var_struct(37).YAxes=[0 0];
var_struct(38).YLabel={'Tr Pr (%)';['To far ' params.Subs_Names{1}(1)]};var_struct(38).YAxes=[0 0];
var_struct(39).YLabel={'Tr Pr (%)';'To far S'};var_struct(39).YAxes=[0 0];
var_struct(40).YLabel={['Min dist to ' params.Subs_Names{1}(1)];'not v, r = 4.5mm'};var_struct(40).YAxes=[0 0];
var_struct(41).YLabel={'Min dist to S';'not v, r = 4.5mm'};var_struct(41).YAxes=[0 0];
var_struct(42).YLabel={['Time on ' params.Subs_Names{1}(1) '(min)'];'not v, r = 4.5mm'};var_struct(42).YAxes=[0 0];
var_struct(43).YLabel={'Time on S (min)';'not v, r = 4.5mm'};var_struct(43).YAxes=[0 0];
var_struct(44).YLabel=['N� Head mm ' params.Subs_Names{1}(1)];var_struct(44).YAxes=[0 0];
var_struct(45).YLabel='N� Head mm S';var_struct(45).YAxes=[0 0];
var_struct(46).YLabel={['Total Dur ' params.Subs_Names{1}(1)];'Hmm (min)'};var_struct(46).YAxes=[0 0];
var_struct(47).YLabel={'Total Dur S';'Hmm (min)'};var_struct(47).YAxes=[0 0];
var_struct(48).YLabel={['Total Dur ' params.Subs_Names{1}(1)];'Visits (min)'};var_struct(48).YAxes=[0 0];
var_struct(49).YLabel={'Total Dur S';'Visits (min)'};var_struct(49).YAxes=[0 0];
var_struct(50).YLabel={'Av YS-Y Inter';'time (s)'};var_struct(50).YAxes=[0 0];
var_struct(51).YLabel={'Av YS-S Inter';'time (s)'};var_struct(51).YAxes=[0 0];
var_struct(52).YLabel={['N� ' params.Subs_Names{1}(1)];'Visits (per min)'};var_struct(52).YAxes=[0 0];
var_struct(53).YLabel={'N� S';'Visits (per min)'};var_struct(53).YAxes=[0 0];
var_struct(54).YLabel={'t_w_a_l_k/t_T';'not v'};var_struct(54).YAxes=[0 0];
var_struct(55).YLabel={'Av Ang Speed';'not v (|�|/0.02s)'};var_struct(55).YAxes=[0 0];
var_struct(56).YLabel={'N� Edge ';'visits (visits/s)'};var_struct(56).YAxes=[0 0];
var_struct(57).YLabel={'Speed_h ';[params.Subs_Names{1}(1) 'visits (mm/s)']};var_struct(57).YAxes=[0 0];
var_struct(58).YLabel={'Speed_c ';[params.Subs_Names{1}(1) 'visits (mm/s)']};var_struct(58).YAxes=[0 0];
var_struct(59).YLabel={'Ang Speed ';[params.Subs_Names{1}(1) 'visits (|�|/0.02s)']};var_struct(59).YAxes=[0 0];
var_struct(60).YLabel={['Av Area ' params.Subs_Names{1}(1) 'v'];'(px)'};var_struct(60).YAxes=[0 0];
var_struct(61).YLabel={['N� ' params.Subs_Names{1}(1)];'VisitsRV'};var_struct(61).YAxes=[0 0];
var_struct(62).YLabel={'N� S';'VisitsRV'};var_struct(62).YAxes=[0 0];
var_struct(63).YLabel={'YPIRV';'(N� visits)'};var_struct(63).YAxes=[-1.1 1.5];
var_struct(64).YLabel={'YPI bouts';'N�withRV3mm'};var_struct(64).YAxes=[-1.1 1.5];
var_struct(65).YLabel={['N�' params.Subs_Names{1}(1) ' bouts'];'RV 3mm'};var_struct(65).YAxes=[0 0];
var_struct(66).YLabel={'N�S bouts';'RV 3mm'};var_struct(66).YAxes=[0 0];
var_struct(67).YLabel={'Av YS-Y Inter';'dist covered (mm)'};var_struct(67).YAxes=[0 0];
var_struct(68).YLabel={'Av YS-S Inter';'dist covered (mm)'};var_struct(68).YAxes=[0 0];
var_struct(69).YLabel={'Ang Speed ';'S visits (|�|/0.02s)'};var_struct(69).YAxes=[0 0];
var_struct(70).YLabel={'Tr Pr Y(%)';['To same ' params.Subs_Names{1}(1)]};var_struct(70).YAxes=[0 0];
var_struct(71).YLabel={'Tr Pr Y(%)';['To adj ' params.Subs_Names{1}(1)]};var_struct(71).YAxes=[0 0];
var_struct(72).YLabel={'Tr Pr Y(%)';['To far ' params.Subs_Names{1}(1)]};var_struct(72).YAxes=[0 0];
var_struct(73).YLabel={'t_w_a_l_k';'not v (min)'};var_struct(73).YAxes=[0 0];
var_struct(74).YLabel={'MSDR';'(mm/s^2)'}; var_struct(74).YAxes=[0 0];

last_param=length(var_struct);
if HEAD_YN, lthrs=Spot_thrs; else lthrs=Specific_thr; end
correctedbouts=1;%if 1 means that every inter-bout event that didn't cross the break threshold is still the same encounter.

lthrcounter=0;
for lHThr=lthrs
    lthrcounter=lthrcounter+1;
    %% Y N� bouts at different radii - 42:49
    lparam=last_param+lthrcounter;
    var_struct(lparam).YLabel={['N� ' params.Subs_Names{1}(1) ' bouts'];...
        ['r = ' num2str(lthrs(lthrcounter)) 'mm']};
    var_struct(lparam).YAxes=[0 0];
    %% S N� bouts at different radii - 50:57
    lparam=last_param+length(lthrs)+lthrcounter;
    var_struct(lparam).YLabel=...
        {'N� S bouts';['r = ' num2str(lthrs(lthrcounter)) 'mm']};% N� S visits
    var_struct(lparam).YAxes=[0 0];
    
    %% Y Av duration at different radii - 58:65
    lparam=last_param+2*length(lthrs)+lthrcounter;
    var_struct(lparam).YLabel={['Av Dur ' params.Subs_Names{1}(1) ' bouts'];...
        ['r = ' num2str(lthrs(lthrcounter)) 'mm']};
    var_struct(lparam).YAxes=[0 0];%min YEAST
    
    %% S Av Duration at different radii - 66:73
    lparam=last_param+3*length(lthrs)+lthrcounter;
    var_struct(lparam).YLabel=...
        {'Av Dur S bouts';['r = ' num2str(lthrs(lthrcounter)) 'mm']};%min SUCROSE
    var_struct(lparam).YAxes=[0 0];
    
    %% YPI at different radii - 74:81
    lparam=last_param+4*length(lthrs)+lthrcounter;
    var_struct(lparam).YLabel={'YPI bouts';...
        ['r = ' num2str(lthrs(lthrcounter)) 'mm']};
    var_struct(lparam).YAxes=[-1.1 1.5];
    
    %% N� of Y bouts with micromovements at different radii - 82:89
    lparam=last_param+5*length(lthrs)+lthrcounter;
    var_struct(lparam).YLabel={['N� ' params.Subs_Names{1}(1) 'bouts w/mm'];...
        ['r = ' num2str(lthrs(lthrcounter)) 'mm']};
    var_struct(lparam).YAxes=[0 0];%mm YEAST
    
    %% N� of S bouts with micromovements at different radii - 90:97
    lparam=last_param+6*length(lthrs)+lthrcounter;
    var_struct(lparam).YLabel=...
        {'N� S bouts w/mm';[' r = ' num2str(lthrs(lthrcounter)) 'mm']};%N� SUCROSE
    var_struct(lparam).YAxes=[0 0];
    
    %% Rate of Y engagement at different radii - 98:105
    lparam=last_param+7*length(lthrs)+lthrcounter;
    var_struct(lparam).YLabel={['Rate of ' params.Subs_Names{1}(1) ' Eng'];...
        ['r = ' num2str(lthrs(lthrcounter)) 'mm']};%p(Engage|bout) YEAST
    var_struct(lparam).YAxes=[0 0];
    
    %% Rate of S engagement at different radii - 106:113
    lparam=last_param+8*length(lthrs)+lthrcounter;
    var_struct(lparam).YLabel={['Rate of S Eng'];...
        ['r = ' num2str(lthrs(lthrcounter)) 'mm']};%p(Engage|bout) SUCROSE
    var_struct(lparam).YAxes=[0 0];
    %% N� of Y bouts over time at different radii
    lparam=last_param+9*length(lthrs)+lthrcounter;
    var_struct(lparam).YLabel={['N� ' params.Subs_Names{1}(1) 'bouts per min'];...
        ['r = ' num2str(lthrs(lthrcounter)) 'mm']};
    var_struct(lparam).YAxes=[0 0];%mm YEAST
    
    %% N� of S bouts over time at different radii
    lparam=last_param+10*length(lthrs)+lthrcounter;
    var_struct(lparam).YLabel=...
        {'N� S bouts per min';[' r = ' num2str(lthrs(lthrcounter)) 'mm']};%N� SUCROSE
    var_struct(lparam).YAxes=[0 0];
    
    %% N� of Y bouts over time walking outside visits at different radii
    lparam=last_param+11*length(lthrs)+lthrcounter;
    var_struct(lparam).YLabel={['N� ' params.Subs_Names{1}(1) 'bouts per min w'];...
        ['r = ' num2str(lthrs(lthrcounter)) 'mm']};
    var_struct(lparam).YAxes=[0 0];%mm YEAST
    %% N� of S bouts over time walking outside visits at different radii
    lparam=last_param+12*length(lthrs)+lthrcounter;
    var_struct(lparam).YLabel={['N� S bouts per min w'];...
        ['r = ' num2str(lthrs(lthrcounter)) 'mm']};
    var_struct(lparam).YAxes=[0 0];%mm Sucrose
        
end
%% Calculating Binary bouts with revisits
[~,~,Binary_EncRV] = Head_bout_fun(FlyDB,Heads_Sm,Walking_vec,InSpot,params,3);
[DurInEncRV] = Binary2DurInCumTime(FlyDB,Binary_EncRV,InSpot,params.Subs_Numbers);
%% CALCULATING BinaryHeads for each HeadThr
if HEAD_YN, lthrs=Spot_thrs; else lthrs=Specific_thr; end
DurInHCell=cell(length(lthrs),1);
lthrcounter=0;
for lHThr=lthrs
    lthrcounter=lthrcounter+1;
    display(['--- BIG CELL HEAD Threshold: ' num2str(lHThr) 'mm----'])
    %% Find DurInB Segment
    [Binary_Head_2,Binary_Encounter] = Head_bout_fun(FlyDB,Heads_Sm,Walking_vec,InSpot,params,lHThr);
    [DurInH_2] = Binary2DurInCumTime(FlyDB,Binary_Head_2,InSpot,params.Subs_Numbers);
    [DurInEncounter] = Binary2DurInCumTime(FlyDB,Binary_Encounter,InSpot,params.Subs_Numbers);
    
    if correctedbouts==1
        DurInHCell{lthrcounter}=DurInEncounter;    
    else
        DurInHCell{lthrcounter}=DurInH_2;
    end
end

%% Allocating
if eachflyrange==1
    ranges_fly=ranges;
    ranges=ranges_fly{1};
    for lfly=1:params.numflies
        temp=ranges_fly{lfly};
        last_idx=find(temp(:,2)>= params.MinimalDuration,1,'first');
        if ~isempty(last_idx)
            temp=temp(1:last_idx,:);
            temp(last_idx,2)=params.MinimalDuration;
        end
        ranges_fly{lfly}=temp;
    end
end
VisitDurs_TS=cell(size(ranges,1),1);
for lrange=1:size(ranges,1)
    VisitDurs_TS{lrange}=cell(params.numflies,1);
end


%% CALCULATION STARTS PER CONDITION, then per FLY of condition, then per RANGE
lcondcounter=0;
for lcond=Conditions
    lcondcounter=lcondcounter+1;
    display(['----- ' params.LabelsShort{lcond} ' ------- Time Segments'])
    
    flies_cond=find(params.ConditionIndex==lcond);
    if eachflyrange==1
        maxranges=max(cell2mat(cellfun(@(x) size(x,1),ranges_fly(flies_cond),'uniformoutput',0)));
    else
        maxranges=size(ranges,1);
    end
    %% Change the Data Matrix for this condition
    [var_struct.Data]=deal(nan(maxranges,length(flies_cond)));
    
    lflycondcounter=0;
    for lfly=flies_cond
        lflycondcounter=lflycondcounter+1;
        if mod(lflycondcounter,10)==0,display(lfly),end
        CondFlyIdx(lfly==params.IndexAnalyse,:)=[lfly,lflycondcounter];
        Wellpos=FlyDB(lfly).WellPos;
        [Binary_Edge] = Edge_Explor(Heads_Sm,lfly,params);
        if eachflyrange==1
            ranges=ranges_fly{lfly};
        end
        %%
        for lrange=1:size(ranges,1)
            range=ranges(lrange,1):ranges(lrange,2);
            if range(end)<=params.MinimalDuration
                
                %             display(['time range: ' num2str(range(1)) ' - ' num2str(range(end)) ' (fr)'])
                Etho_Speed_range=Etho_Speed{lfly}(range);
                %% Distance Covered
                var_struct(1).Data(lrange,lflycondcounter)=nansum(Steplength_Sm_c{lfly}(range))*params.px2mm/1000;%m
                
                %% Thigmotaxis - % of time on edge
                var_struct(4).Data(lrange,lflycondcounter)=nansum(Binary_Edge(range))/length(range);%N� edge visits
                %% Edge Exploration - N� visits/time moving
                [BinaryEdge_nojitter] = Remove_jitter_lfly(Binary_Edge(range),...
                    Heads_Sm{lfly}(range,:),Walking_vec{lfly}(range),lfly);
                NEdgevisits=sum(conv(double(BinaryEdge_nojitter),[1 -1])==1);
                Timemoving=sum((Etho_Speed_range==4)|(Etho_Speed_range==5))/params.framerate;%s
                var_struct(56).Data(lrange,lflycondcounter)=NEdgevisits/Timemoving;%N� edge visits/second moving
                %% Outside Visits: Area and Speed
                Speedc_temp=Steplength_Sm_c{lfly}(range);
                Speedh_temp=Steplength_Sm_h{lfly}(range);
                AngSpeed_temp=HeadingDiff{lfly}(range);
                logicaloutsidevisits=~(Binary_V(range,lfly)');
                if sum(logicaloutsidevisits)==0
                    var_struct(8).Data(lrange,lflycondcounter)=nan;% Area outside visits
                    var_struct(2).Data(lrange,lflycondcounter)=nan;% Speed outside visits
                    var_struct(54).Data(lrange,lflycondcounter)=nan;% % time walking outside visits
                    var_struct(55).Data(lrange,lflycondcounter)=nan;% Angular Speed outside visits
                    var_struct(73).Data(lrange,lflycondcounter)=nan;% total time walking outside visits
                else
                    %% Area covered outside visits
                    Heads_temp=Heads_Sm{lfly}(range,:);%
                    count_fly2= hist3([Heads_temp(logicaloutsidevisits,2),...
                        Heads_temp(logicaloutsidevisits,1)],{xrange xrange});
                    var_struct(8).Data(lrange,lflycondcounter)=nansum(nansum(count_fly2~=0))/(sum(logicaloutsidevisits)/params.framerate/60);% Area outside v
                    %% Average Speed outside visits
                    
                    Speed_NoVisits=Speedc_temp(logicaloutsidevisits)*params.px2mm*params.framerate;
                    var_struct(2).Data(lrange,lflycondcounter)=nanmean(Speed_NoVisits);%mm/s
                    %% % Time moving outside visits
                    
                    var_struct(54).Data(lrange,lflycondcounter)=...
                        (sum((Etho_Speed_range(logicaloutsidevisits)==4)|...
                        (Etho_Speed_range(logicaloutsidevisits)==5)))/(sum(logicaloutsidevisits));
                    %% Total Time moving outside visits
                    var_struct(73).Data(lrange,lflycondcounter)=...
                        (sum((Etho_Speed_range(logicaloutsidevisits)==4)|...
                        (Etho_Speed_range(logicaloutsidevisits)==5)))/params.framerate/60;%min
                    %% Average Angular speed outside visits
                    
                    Speed_NoVisits2=AngSpeed_temp(logicaloutsidevisits);
                    var_struct(55).Data(lrange,lflycondcounter)=nanmean(abs(Speed_NoVisits2));%�/f
                end
                %% All Substrate 1 time parameters
                logicalinsideSubs1=CumTimeV{1}(range,lfly)==1;
                if sum(logicalinsideSubs1)==0
                    var_struct(22).Data(lrange,lflycondcounter)=nan;%mm
                    var_struct(57).Data(lrange,lflycondcounter)=nan;%mm/s
                    var_struct(58).Data(lrange,lflycondcounter)=nan;%mm/s
                    var_struct(59).Data(lrange,lflycondcounter)=nan;%�/fr
                else
                    %% Grassing: Distance covered with head - centroid
                    var_struct(22).Data(lrange,lflycondcounter)=nanmean((nansum(Speedh_temp(logicalinsideSubs1))-...
                        nansum(Speedc_temp(logicalinsideSubs1)))*params.px2mm);%mm
                    %% Average Speed head during substrate 1 visits
                    var_struct(57).Data(lrange,lflycondcounter)=nanmean(Speedh_temp(logicalinsideSubs1)*params.px2mm*params.framerate);%mm/s
                    %% Average Speed head during substrate 1 visits
                    var_struct(58).Data(lrange,lflycondcounter)=nanmean(Speedc_temp(logicalinsideSubs1)*params.px2mm*params.framerate);%mm/s
                    %% Average Angular Speed during substrate 1 visits
                    var_struct(59).Data(lrange,lflycondcounter)=nanmean(abs(AngSpeed_temp(logicalinsideSubs1)));%�/fr
                end
                %% All Substrate 2 time parameters
                if length(params.Subs_Numbers)>1
                    logicalinsideSubs2=CumTimeV{2}(range,lfly)==1;
                    if sum(logicalinsideSubs2)==0
                        var_struct(69).Data(lrange,lflycondcounter)=nan;%�/fr
                    else
                        %% Average Angular Speed during substrate 2 visits
                        var_struct(69).Data(lrange,lflycondcounter)=nanmean(abs(AngSpeed_temp(logicalinsideSubs2)));%�/fr
                    end
                end
                %% MSDR
                InOutWalk=conv(double((Etho_Speed_range==4)|(Etho_Speed_range==5)),[1 -1]);
                InWalk=find(InOutWalk==1);
                OutWalk=find(InOutWalk==-1)-1;
                
                if ~isempty(InWalk)
                    MSDR_bout=nan(length(InWalk),1);
                    for lFbout=1:length(InWalk)
                        fr_start=InWalk(lFbout);
                        fr_end=OutWalk(lFbout);
                        if ((fr_end-fr_start)>50)
                        MSDR_bout(lFbout)=max(Speedc_temp(fr_start:fr_end)*...
                            params.px2mm*params.framerate)/...
                            ((fr_end-fr_start)/params.framerate);
                        else
                            MSDR_bout(lFbout)=nan;
                        end
                    end
                    var_struct(74).Data(lrange,lflycondcounter)=nanmean(MSDR_bout);
                    
                else
                    var_struct(74).Data(lrange,lflycondcounter)=nan;
                end
                %% VISIT PARAMETERS - Visits that started in the previous period will be included
                %%% In the case the visit starts in the previous time segment and
                %%% finishes in the current time segment. See Notebook 4, page
                %%% 121, 25/Sep/2015
                clear DurInV_Segm boutstart boutstart1 boutend1 boutend Head_Segm
                if ~isempty(DurInV{lfly})
                    boutstart1=find(DurInV{lfly}(:,2)<=range(1),1,'last');
                    if isempty(boutstart1)||(DurInV{lfly}(boutstart1,3)<=range(1))
                        boutstart1=find(DurInV{lfly}(:,2)>=range(1),1,'first');
                    end
                    
                    if DurInV{lfly}(boutstart1,2)<range(end)
                        boutstart=boutstart1;
                        boutend1=find(DurInV{lfly}(:,3)<range(end),1,'last');
                        
                        if isempty(boutend1)
                            boutend=boutstart;
                        elseif (boutend1~=size(DurInV{lfly},1))&&(DurInV{lfly}(boutend1+1,2)<range(end))
                            boutend=boutend1+1;
                        else
                            boutend=boutend1;
                        end
                        
                    else
                        boutstart=[];
                    end
                else
                    boutstart=[];
                end
                
                if isempty(boutstart)
                    var_struct(3).Data(lrange,lflycondcounter)=0;%tFood/Total time
                    var_struct(5).Data(lrange,lflycondcounter)=0;% N� Visits/Distance
                    var_struct(6).Data(lrange,lflycondcounter)=nan;% YPI
                    var_struct(7).Data(lrange,lflycondcounter)=0;% Area Y visit
                    var_struct(60).Data(lrange,lflycondcounter)=0;% Area Y visit
                    var_struct(9).Data(lrange,lflycondcounter)=0;%Y Av Dur
                    var_struct(10).Data(lrange,lflycondcounter)=0;%S Av Dur
                    var_struct(11).Data(lrange,lflycondcounter)=0;%N� Y visits
                    var_struct(12).Data(lrange,lflycondcounter)=0;%N� S Visits
                    var_struct(22).Data(lrange,lflycondcounter)=nan;%Grassing
                    var_struct(30).Data(lrange,lflycondcounter)=0;%Y Max Dur
                    var_struct(31).Data(lrange,lflycondcounter)=0;%S Max Dur
                    var_struct(44).Data(lrange,lflycondcounter)=0;%N� of Y Head mm
                    var_struct(45).Data(lrange,lflycondcounter)=0;%N� of S Head mm
                    var_struct(46).Data(lrange,lflycondcounter)=0;%Total dur of Y Head mm
                    var_struct(47).Data(lrange,lflycondcounter)=0;%Total dur S Head mm
                    var_struct(48).Data(lrange,lflycondcounter)=0;%Total dur Y Visits
                    var_struct(49).Data(lrange,lflycondcounter)=0;%Total durS Visits
                    var_struct(52).Data(lrange,lflycondcounter)=0;%N� Y visits per min
                    var_struct(53).Data(lrange,lflycondcounter)=0;%N� S Visits per min
                    var_struct(61).Data(lrange,lflycondcounter)=0;%N� Y Visits including revisits in visits
                    var_struct(62).Data(lrange,lflycondcounter)=0;%N� S Visits including revisits in visits
                    var_struct(63).Data(lrange,lflycondcounter)=nan;%YPI (N� Visits including RV)
                    VisitDurs_TS{lrange}{lfly}=[];
                else
                    if (isempty(boutend))||(boutend<boutstart)
                        error('boutend is empty or smaller than boutstart')
                        % boutend=boutstart;
                    end
                    DurInV_Segm=DurInV{lfly}(boutstart:boutend,:);
                    VisitDurs_TS{lrange}{lfly}=DurInV_Segm;
                    
                    
                    %% Number of visits of substrate 1 and subtrate 2
                    var_struct(11).Data(lrange,lflycondcounter)=sum(DurInV_Segm(:,1)==params.Subs_Numbers(1));% N� Y visits
                    var_struct(52).Data(lrange,lflycondcounter)=sum(DurInV_Segm(:,1)==params.Subs_Numbers(1))/(length(range)/params.framerate/60);%N� Y visits per min of range
                    if length(params.Subs_Numbers)>1
                        var_struct(12).Data(lrange,lflycondcounter)=sum(DurInV_Segm(:,1)==params.Subs_Numbers(2));% N� S visits
                        var_struct(53).Data(lrange,lflycondcounter)=sum(DurInV_Segm(:,1)==params.Subs_Numbers(2))/(length(range)/params.framerate/60);% N� S visits per min of range
                    else
                        var_struct(12).Data(lrange,lflycondcounter)=nan;% N� S visits
                        var_struct(53).Data(lrange,lflycondcounter)=nan;% N� S visits
                    end
                    
                    %% Total N� Visits
                    var_struct(5).Data(lrange,lflycondcounter)=...
                        size(DurInV_Segm,1);
                    % Sanity check
                    if length(params.Subs_Numbers)==2
                        if (sum(DurInV_Segm(:,1)==params.Subs_Numbers(1))+sum(DurInV_Segm(:,1)==params.Subs_Numbers(2)))...
                                ~=size(DurInV_Segm,1)
                            error('Error: N�Y+N�S is different from total N� visits')
                        end
                    end
                    %% N� of different subs1 visits
                    var_struct(33).Data(lrange,lflycondcounter)=...
                        length(unique(DurInV_Segm(DurInV_Segm(:,1)==params.Subs_Numbers(1),4)));
                    
                    %% Average duration of visits
                    tY=DurInV_Segm(DurInV_Segm(:,1)==params.Subs_Numbers(1),5);%fr YEAST
                    if isempty(tY), tY=0;end
                    var_struct(9).Data(lrange,lflycondcounter)=mean(tY)/params.framerate/60;%min YEAST
                    var_struct(48).Data(lrange,lflycondcounter)=sum(tY)/params.framerate/60;%min YEAST
                    if length(params.Subs_Numbers)>1
                        tS=DurInV_Segm(DurInV_Segm(:,1)==params.Subs_Numbers(2),5);%fr SUCROSE
                        
                        if isempty(tS), tS=0;end
                        
                        var_struct(10).Data(lrange,lflycondcounter)=mean(tS)/params.framerate/60;%min SUCROSE
                        var_struct(49).Data(lrange,lflycondcounter)=sum(tS)/params.framerate/60;%min SUCROSE
                    else
                        tS=nan;
                        var_struct(10).Data(lrange,lflycondcounter)=nan;
                        var_struct(49).Data(lrange,lflycondcounter)=nan;
                    end
                    
                    %% Maximum duration of visit
                    %                 var_struct(30).Data(lrange,lflycondcounter)=max(tY)/params.framerate/60;%min YEAST
                    %                 var_struct(31).Data(lrange,lflycondcounter)=max(tS)/params.framerate/60;%min SUCROSE
                    
                    %% YPI
                    if size(params.Subs_Names,1)==2%% This code only works for 2 substrates
                        %% YPI (Time on visits)
                        var_struct(6).Data(lrange,lflycondcounter)=(sum(CumTimeV{1}(range,lfly))-sum(CumTimeV{2}(range,lfly)))/...
                            (sum(CumTimeV{1}(range,lfly))+sum(CumTimeV{2}(range,lfly)));
                        %% YPI (N� of visits)
                        var_struct(16).Data(lrange,lflycondcounter)=...
                            (sum(DurInV_Segm(:,1)==params.Subs_Numbers(1))-sum(DurInV_Segm(:,1)==params.Subs_Numbers(2)))/...
                            (sum(DurInV_Segm(:,1)==params.Subs_Numbers(1))+sum(DurInV_Segm(:,1)==params.Subs_Numbers(2)));
                    else
                        var_struct(6).Data(lrange,lflycondcounter)=nan;
                        var_struct(16).Data(lrange,lflycondcounter)=nan;
                    end
                    
                    %% Time on Food/Total time. Within the range, how many frames on food
                    var_struct(3).Data(lrange,lflycondcounter)=...
                        nansum(Binary_V(range,lfly))/length(range);
                    %% N� of Head micromovements
                    var_struct(44).Data(lrange,lflycondcounter)=sum(conv(double(CumTimeH{1}(range,...
                        lfly)),[1 -1])==1);
                    if length(params.Subs_Numbers)>1
                        var_struct(45).Data(lrange,lflycondcounter)=sum(conv(double(CumTimeH{2}(range,...
                            lfly)),[1 -1])==1);
                    else
                        var_struct(45).Data(lrange,lflycondcounter)=nan;
                    end
                    
                    %% Total duration of Head micromovements
                    var_struct(46).Data(lrange,lflycondcounter)=sum(CumTimeH{1}(range,lfly))/params.framerate/60;%min
                    if length(params.Subs_Numbers)>1
                        var_struct(47).Data(lrange,lflycondcounter)=sum(CumTimeH{2}(range,lfly))/params.framerate/60;%min
                    else
                        var_struct(47).Data(lrange,lflycondcounter)=nan;
                    end
                    
                    %% Average distance between next yeast or sucrose spots
                    if size(params.Subs_Numbers,2)<=2%% This code only works for subs1=Yeast and
                        %%%% Subs2=Sucrose
                        %                     Wellpos=FlyDB(lfly).WellPos;
                        if size(params.Subs_Numbers,2)==1,
                            Subs_Idx=params.Subs_Numbers(1);
                        else
                            Subs_Idx=params.Subs_Numbers(1:2);
                        end
                        for lsubs=Subs_Idx
                            SpotNumbers=find(FlyDB(lfly).Geometry==lsubs);
                            V_Num_log=ismember(DurInV_Segm(:,4)', SpotNumbers);
                            V_Num=DurInV_Segm(V_Num_log,4);%Numbers of spots visited
                            %% Y-Y or S-S Spot distance
                            if size(V_Num,1)>1 %If there are at least two visits
                                distspots_temp=nan(size(V_Num,1)-1,1);
                                for lspot=1:size(V_Num,1)-1
                                    distspots_temp(lspot)=sqrt(sum((Wellpos(V_Num(lspot+1),:)-...
                                        Wellpos(V_Num(lspot),:)).^2));
                                    
                                end
                                var_struct(12+find(lsubs==params.Subs_Numbers)).Data(lrange,lflycondcounter)=nanmean(distspots_temp)*params.px2mm;
                            else
                                % Only 1 visit
                                var_struct(12+find(lsubs==params.Subs_Numbers)).Data(lrange,lflycondcounter)=nan;
                            end
                            %% Average YS-Y or SS-S Spot distance and distance covered
                            DurInVidx=find(V_Num_log)';%Indexes of spots in Segment vector
                            if ~isempty(DurInVidx)
                                
                                %%% If the first of the analysed spot is not the first visit
                                if (DurInVidx(1)>=2) || ((DurInVidx(1)==1)&&size(V_Num,1)>1)
                                    if DurInVidx(1)>=2 %When there are visits before
                                        V_Numidx=1:size(V_Num,1);
                                    else % When is the first visit, start from the second
                                        V_Numidx=2:size(V_Num,1);
                                    end
                                    
                                    distspots_temp=nan(size(V_Numidx,2),1);
                                    distcovered_temp=nan(size(V_Numidx,2),1);
                                    inter_time=nan(size(V_Numidx,2),1);
                                    for lspot=V_Numidx
                                        prev_spot=DurInV_Segm(DurInVidx(lspot)-1,4);
                                        %% Average YS-Y or SS-S Spot distance
                                        distspots_temp(lspot==V_Numidx)=sqrt(sum((Wellpos(V_Num(lspot),:)-...
                                            Wellpos(prev_spot,:)).^2));
                                        %% Average YS-Y or SS-S distance covered
                                        distcovered_temp(lspot)=...
                                            nansum(Steplength_Sm_c{lfly}...
                                            (DurInV_Segm(DurInVidx(lspot)-1,3):DurInV_Segm(DurInVidx(lspot),2)))*params.px2mm;%mm
                                        %% Average YS-Y or SS-S time
                                        inter_time(lspot)=(DurInV_Segm(DurInVidx(lspot),2)-DurInV_Segm(DurInVidx(lspot)-1,3)+1)/params.framerate;%s
                                        
                                    end
                                    var_struct(22+find(lsubs==params.Subs_Numbers)).Data(lrange,lflycondcounter)=nanmean(distspots_temp)*params.px2mm;
                                    var_struct(24+find(lsubs==params.Subs_Numbers)).Data(lrange,lflycondcounter)=nanmean(distcovered_temp)*params.px2mm;
                                    var_struct(66+find(lsubs==params.Subs_Numbers)).Data(lrange,lflycondcounter)=nanmean(distcovered_temp)*params.px2mm/(length(range)/params.framerate/60);
                                    var_struct(49+find(lsubs==params.Subs_Numbers)).Data(lrange,lflycondcounter)=nanmean(inter_time);
                                else % There is only 1 visit
                                    var_struct(22+find(lsubs==params.Subs_Numbers)).Data(lrange,lflycondcounter)=nan;
                                    var_struct(24+find(lsubs==params.Subs_Numbers)).Data(lrange,lflycondcounter)=nan;
                                    var_struct(49+find(lsubs==params.Subs_Numbers)).Data(lrange,lflycondcounter)=nan;
                                end
                                
                                
                            else % There are no visits to this substrate
                                var_struct(22+find(lsubs==params.Subs_Numbers)).Data(lrange,lflycondcounter)=nan;
                                var_struct(24+find(lsubs==params.Subs_Numbers)).Data(lrange,lflycondcounter)=nan;
                                var_struct(49+find(lsubs==params.Subs_Numbers)).Data(lrange,lflycondcounter)=nan;
                            end
                            
                        end
                    else
                        var_struct(13).Data(lrange,lflycondcounter)=nan;
                        var_struct(14).Data(lrange,lflycondcounter)=nan;
                        var_struct(23).Data(lrange,lflycondcounter)=nan;
                        var_struct(24).Data(lrange,lflycondcounter)=nan;
                        var_struct(25).Data(lrange,lflycondcounter)=nan;
                        var_struct(26).Data(lrange,lflycondcounter)=nan;
                        var_struct(50).Data(lrange,lflycondcounter)=nan;
                        var_struct(51).Data(lrange,lflycondcounter)=nan;
                        var_struct(67).Data(lrange,lflycondcounter)=nan;
                        var_struct(68).Data(lrange,lflycondcounter)=nan;
                    end
                    
                    %% PER VISIT PARAMETERS
                    %%% Warning: Only optmised for Subs1 and Sbs2
                    if size(params.Subs_Numbers,2)==1,
                        Subs_Idx=params.Subs_Numbers(1);
                    elseif size(params.Subs_Numbers,2)==2
                        Subs_Idx=params.Subs_Numbers(1:2);
                    end
                    
                    for lsubs=Subs_Idx%Calculate area covered of yeast spots
                        visit_rows=find(DurInV_Segm(:,1)==lsubs)';
                        Ar_Cov_temp=nan(length(visit_rows),1);
                        Ar_Cov_temp2=nan(length(visit_rows),1);
                        Min_dist=nan(length(visit_rows),1);
                        Alldists=[];
                        
                        visitcounter=0;
                        for lvisit=visit_rows
                            visitcounter=visitcounter+1;
                            Visitframes=DurInV_Segm(lvisit,2):DurInV_Segm(lvisit,3);
                            Heads_temp=Heads_Sm{lfly}(Visitframes,:);%
                            if lsubs==params.Subs_Numbers(1)
                                %% Area covered during each visit
                                count_fly= hist3([Heads_temp(:,2) Heads_temp(:,1)],{xrange xrange});
                                %                     Ar_Cov_temp(visitcounter)=nansum(nansum(count_fly~=0));
                                Ar_Cov_temp(visitcounter)=nansum(nansum(count_fly~=0))/(DurInV_Segm(lvisit,5)/params.framerate/60);%px/min
                                Ar_Cov_temp2(visitcounter)=nansum(nansum(count_fly~=0));%px/min
                            end
                            %% Average distance from Spot during visit (parameters 28 and 29)
                            %%% Pool distances from all visits and average at the
                            %%% end
                            Diff_temp=repmat(Wellpos(DurInV_Segm(lvisit,4),:),DurInV_Segm(lvisit,5),1) -...
                                Heads_Sm{lfly}(DurInV_Segm(lvisit,2):DurInV_Segm(lvisit,3),:);%
                            
                            Dist2fSpot=sqrt(sum(((Diff_temp).^2),2)).*params.px2mm;
                            Alldists=[Alldists;Dist2fSpot];
                            Min_dist(visitcounter)=min(Dist2fSpot);
                        end
                        if lsubs==params.Subs_Numbers(1)
                            var_struct(7).Data(lrange,lflycondcounter)=nanmean(Ar_Cov_temp);%/1000;%Average px/min of visit
                            var_struct(60).Data(lrange,lflycondcounter)=nanmean(Ar_Cov_temp2);%Average px/min of visit
                        end
                        var_struct(27+find(lsubs==params.Subs_Numbers)).Data(lrange,lflycondcounter)=nanmean(Alldists);%mm
                        var_struct(29+find(lsubs==params.Subs_Numbers)).Data(lrange,lflycondcounter)=nanmean(Min_dist);%mm
                    end
                    %% Total Area covered / Total Y time (parameter 27)
                    %%% Note, this is just to compare between them, this is
                    %%% pooled and previous is average across visits and this
                    %%% one only uses the info inside the interval (truncates
                    %%% visits that are divided by the interval)
                    lsubscounter=1;
                    Heads_temp=Heads_Sm{lfly}(range,:);%
                    if sum(CumTimeV{lsubscounter}(range,lfly))~=0
                        count_fly= hist3([Heads_temp(CumTimeV{lsubscounter}(range,lfly)==1,2),...
                            Heads_temp(CumTimeV{lsubscounter}(range,lfly)==1,1)],{xrange xrange});
                        var_struct(27).Data(lrange,lflycondcounter)=...
                            nansum(nansum(count_fly~=0))/(sum(CumTimeV{lsubscounter}(range,lfly))/params.framerate/60);%px/min
                    else%No Yeast visit
                        var_struct(27).Data(lrange,lflycondcounter)=nan;
                    end
                    
                end
                
                %% -- %% END OF PARAMETERS RELATED TO VISITS %% -- %%
                
                %% Average max distance from spot during excursion (parameter 21):
                %%% Preparing the starts and ends of the excursions: Truncate
                %%% when excursion starts before or ends after interval
                lsubscounter=1;
                Excurstemp=Breaks{lsubscounter}(Breaks{lsubscounter}(:,4)==lfly,1:3);
                clear Excurboutstart Excurstemp3
                Excurboutstart=find(Excurstemp(:,1)<range(1),1,'last');
                if isempty(Excurboutstart)||Excurstemp(Excurboutstart,2)<=range(1)
                    Excurboutstart=find(Excurstemp(:,1)>=range(1),1,'first');
                    %%% The excursion starts after the interval
                    if ~isempty(Excurboutstart)&&Excurstemp(Excurboutstart,1)<range(end)
                        Excurstemp2=Excurstemp(Excurboutstart:end,:);
                        Excurstemp3=excursion_start_end_interval(Excurstemp2,range);
                        %%% No excursions inside the interval
                    elseif ~isempty(Excurboutstart)&&Excurstemp(Excurboutstart,1)>=range(end)
                        Excurstemp3=[];
                        %%% No excursions inside the interval
                    else
                        Excurstemp3=[];
                    end
                    
                    %%% The excursion starts before the interval
                elseif ~isempty(Excurboutstart)&&(Excurstemp(Excurboutstart,2)>range(1))
                    Excurstemp2=Excurstemp(Excurboutstart:end,:);
                    Excurstemp2(1,1)=range(1);
                    Excurstemp3=excursion_start_end_interval(Excurstemp2,range);
                    
                    %%% The excursion starts and ends before the interval (not considered at all)
                else
                    Excurstemp3=[];
                end
                
                %%% Calculation of Distance from spot during excursion
                if ~isempty(Excurstemp3)
                    %                     Wellpos=FlyDB(lfly).WellPos;
                    MaxDistExcurs=nan(size(Excurstemp3,1),1);
                    for lexcursion=1:size(Excurstemp3,1)
                        
                        Diff_temp=repmat(Wellpos(Excurstemp3(lexcursion,3),:),Excurstemp3(lexcursion,2)-Excurstemp3(lexcursion,1)+1,1) -...
                            Heads_Sm{lfly}(Excurstemp3(lexcursion,1):Excurstemp3(lexcursion,2),:);%
                        
                        Dist2fSpot=sqrt(sum(((Diff_temp).^2),2)).*params.px2mm;
                        MaxDistExcurs(lexcursion)=max(Dist2fSpot);
                    end
                    
                    var_struct(21).Data(lrange,lflycondcounter)=nanmean(MaxDistExcurs);
                    
                    %% N� of excursions per min on Y = Total N� excursions/Total time on Y on interval
                    var_struct(15).Data(lrange,lflycondcounter)=...
                        size(Excurstemp3,1)/(sum(CumTimeV{lsubscounter}(range,lfly))/50/60);
                    %% N� of excursions = Total N� excursions
                    var_struct(32).Data(lrange,lflycondcounter)=...
                        size(Excurstemp3,1);
                else
                    var_struct(21).Data(lrange,lflycondcounter)=nan;
                    var_struct(15).Data(lrange,lflycondcounter)=nan;
                end
                
                %% Transition probabilities: Adjc&Same vs Non-Adj
                if size(params.Subs_Numbers,2)<=2%% It only goes until 2 because of the
                    %%% pre-allocated numbers for each parameter in the
                    %%% var_struct, but in case of more substrates, they could
                    %%% be easily added at the end of the structure
                    temp_tr=nan(length(size(params.Subs_Numbers,2)+1:3*size(params.Subs_Numbers,2)),1);
                    %%% Note: type help TransitionProb to see number notation
                    ltrcounter=0;
                    for ltr=size(params.Subs_Numbers,2)+1:3*size(params.Subs_Numbers,2)
                        ltrcounter=ltrcounter+1;
                        temp_tr(ltrcounter)=sum(conv(double(Etho_Tr(lfly,...
                            range(1):range(end))==ltr),[1 -1])==1);
                        %                 Nvisits_TrPr(lrange,1)=sum(conv(double(Etho_Tr(lfly,...
                        %                     range(1):range(end))==1),[1 -1])==1);
                        %                 Nvisits_TrPr(lrange,2)=sum(conv(double(Etho_Tr(lfly,...
                        %                     range(1):range(end))==2),[1 -1])==1);
                        % %                 variables.TrPr(lrange,ltrcounter)=sum(conv(double(Etho_Tr(lfly,...
                        % %                     Visit_frames(1)-1:Visit_frames(end))==ltr),[1 -1])==1);
                    end
                    
                    %%% Sanity check transitions: There is almost always one more
                    %%% transition than the number of visits correspondent to the
                    %%% last IBI when the fly leaves the last food.
                    if abs(sum(temp_tr)-sum(var_struct(5).Data(lrange,lflycondcounter)))>1
                        error('Total number of transitions doesn''t match number of visits')
                    end
                    if sum(temp_tr)==0
                        var_struct(17).Data(lrange,lflycondcounter)=nan;
                        var_struct(18).Data(lrange,lflycondcounter)=nan;
                        var_struct(19).Data(lrange,lflycondcounter)=nan;
                        var_struct(20).Data(lrange,lflycondcounter)=nan;
                    else
                        var_struct(17).Data(lrange,lflycondcounter)=temp_tr(1)./sum(temp_tr)*100;% Transition to same or adj Subs1
                        var_struct(18).Data(lrange,lflycondcounter)=temp_tr(size(params.Subs_Numbers,2)+1)./sum(temp_tr)*100;
                        if size(params.Subs_Numbers,2)>1
                            var_struct(19).Data(lrange,lflycondcounter)=temp_tr(1+1)./sum(temp_tr)*100;% Transition to same or adj Subs2
                            var_struct(20).Data(lrange,lflycondcounter)=temp_tr(size(params.Subs_Numbers,2)+1+1)./sum(temp_tr)*100;
                        else
                            var_struct(19).Data(lrange,lflycondcounter)=nan;
                            var_struct(20).Data(lrange,lflycondcounter)=nan;
                        end
                    end
                else
                    var_struct(17).Data(lrange,lflycondcounter)=nan;
                    var_struct(18).Data(lrange,lflycondcounter)=nan;
                    var_struct(19).Data(lrange,lflycondcounter)=nan;
                    var_struct(20).Data(lrange,lflycondcounter)=nan;
                end
                %% Transition probabilities_2: Adjc, Same vs Non-Adj
                if size(params.Subs_Numbers,2)<=2%% It only goes until 2 because of the
                    %%% pre-allocated numbers for each parameter in the
                    %%% var_struct, but in case of more substrates, they could
                    %%% be easily added at the end of the structure
                    ltransitions=size(params.Subs_Numbers,2)+1:4*size(params.Subs_Numbers,2);
                    temp_tr=nan(length(ltransitions),1);
                    %%% Note: type help TransitionProb to see number notation
                    ltrcounter=0;
                    for ltr=ltransitions
                        ltrcounter=ltrcounter+1;
                        temp_tr(ltrcounter)=sum(conv(double(Etho_Tr2(lfly,...
                            range(1):range(end))==ltr),[1 -1])==1);
                        %                 Nvisits_TrPr(lrange,1)=sum(conv(double(Etho_Tr(lfly,...
                        %                     range(1):range(end))==1),[1 -1])==1);
                        %                 Nvisits_TrPr(lrange,2)=sum(conv(double(Etho_Tr(lfly,...
                        %                     range(1):range(end))==2),[1 -1])==1);
                        % %                 variables.TrPr(lrange,ltrcounter)=sum(conv(double(Etho_Tr(lfly,...
                        % %                     Visit_frames(1)-1:Visit_frames(end))==ltr),[1 -1])==1);
                    end
                    
                    %%% Sanity check transitions: There is almost always one more
                    %%% transition than the number of visits correspondent to the
                    %%% last IBI when the fly leaves the last food.
                    if abs(sum(temp_tr)-sum(var_struct(5).Data(lrange,lflycondcounter)))>1
                        error('Total number of transitions doesn''t match number of visits')
                    end
                    if sum(temp_tr)==0
                        var_struct(34).Data(lrange,lflycondcounter)=nan;
                        var_struct(35).Data(lrange,lflycondcounter)=nan;
                        var_struct(36).Data(lrange,lflycondcounter)=nan;
                        var_struct(37).Data(lrange,lflycondcounter)=nan;
                        var_struct(38).Data(lrange,lflycondcounter)=nan;
                        var_struct(39).Data(lrange,lflycondcounter)=nan;
                    else
                        var_struct(34).Data(lrange,lflycondcounter)=temp_tr(1)./sum(temp_tr)*100;% Transition to same Subs1
                        var_struct(36).Data(lrange,lflycondcounter)=temp_tr(size(params.Subs_Numbers,2)+1)./sum(temp_tr)*100;% Transition to adj Subs1
                        var_struct(38).Data(lrange,lflycondcounter)=temp_tr(2*size(params.Subs_Numbers,2)+1)./sum(temp_tr)*100;% Transition to far Subs1
                        if size(params.Subs_Numbers,2)>1
                            var_struct(35).Data(lrange,lflycondcounter)=temp_tr(2)./sum(temp_tr)*100;% Transition to same Subs2
                            var_struct(37).Data(lrange,lflycondcounter)=temp_tr(size(params.Subs_Numbers,2)+2)./sum(temp_tr)*100;% Transition to adj Subs2
                            var_struct(39).Data(lrange,lflycondcounter)=temp_tr(2*size(params.Subs_Numbers,2)+2)./sum(temp_tr)*100;% Transition to far Subs2
                        else
                            var_struct(35).Data(lrange,lflycondcounter)=nan;
                            var_struct(37).Data(lrange,lflycondcounter)=nan;
                            var_struct(39).Data(lrange,lflycondcounter)=nan;
                        end
                    end
                else
                    var_struct(34).Data(lrange,lflycondcounter)=nan;
                    var_struct(35).Data(lrange,lflycondcounter)=nan;
                    var_struct(36).Data(lrange,lflycondcounter)=nan;
                    var_struct(37).Data(lrange,lflycondcounter)=nan;
                    var_struct(38).Data(lrange,lflycondcounter)=nan;
                    var_struct(39).Data(lrange,lflycondcounter)=nan;
                end
                %% Transition probabilities_3: Adjc, Same vs Non-Adj ONLY YEAST VISITS
                ltransitions=size(params.Subs_Numbers,2)+1:length(params.Subs_Numbers):4*size(params.Subs_Numbers,2);%[same, close, far]
                temp_tr=nan(length(ltransitions),1);
                %%% Note: type help TransitionProb to see number notation
                ltrcounter=0;
                for ltr=ltransitions
                    ltrcounter=ltrcounter+1;
                    temp_tr(ltrcounter)=sum(conv(double(Etho_Tr2(lfly,...
                        range(1):range(end))==ltr),[1 -1])==1);
                end

                %%% Sanity check transitions: 
                if abs(sum(temp_tr)-sum(var_struct(11).Data(lrange,lflycondcounter)))>1
                    error('Total number of transitions doesn''t match number of visits')
                end
                if sum(temp_tr)==0
                    var_struct(70).Data(lrange,lflycondcounter)=nan;
                    var_struct(71).Data(lrange,lflycondcounter)=nan;
                    var_struct(72).Data(lrange,lflycondcounter)=nan;
                else
                    var_struct(70).Data(lrange,lflycondcounter)=temp_tr(1)./sum(temp_tr)*100;% Transition to same Subs1
                    var_struct(71).Data(lrange,lflycondcounter)=temp_tr(2)./sum(temp_tr)*100;% Transition to adj Subs1
                    var_struct(72).Data(lrange,lflycondcounter)=temp_tr(3)./sum(temp_tr)*100;% Transition to far Subs1
                end

                %% %% ABOUT ENCOUNTERS/BOUTS %% %%
                if HEAD_YN==1, lthrs=Spot_thrs; else lthrs=Specific_thr; end
                lthrcounter=0;
                for lHThr=lthrs
                    lthrcounter=lthrcounter+1;
                    %% Find DurInB Segment
                    DurInBout=DurInHCell{lthrcounter};
                    
                    clear DurInH_Segm boutstart boutstart1 boutend1 boutend Head_Segm
                    if ~isempty(DurInBout{lfly})
                        boutstart1=find(DurInBout{lfly}(:,2)<=range(1),1,'last');
                        if isempty(boutstart1)||(DurInBout{lfly}(boutstart1,3)<=range(1))
                            boutstart1=find(DurInBout{lfly}(:,2)>=range(1),1,'first');
                        end
                        
                        if DurInBout{lfly}(boutstart1,2)<range(end)
                            boutstart=boutstart1;
                            boutend1=find(DurInBout{lfly}(:,3)<range(end),1,'last');
                            
                            if isempty(boutend1)
                                boutend=boutstart;
                            elseif (boutend1~=size(DurInBout{lfly},1))&&(DurInBout{lfly}(boutend1+1,2)<range(end))
                                boutend=boutend1+1;
                            else
                                boutend=boutend1;
                            end
                            
                        else
                            boutstart=[];
                        end
                    else
                        boutstart=[];
                    end
                    
                    if isempty(boutstart)
                        for lparam=last_param+1:last_param+9*length(lthrs)
                            var_struct(lparam).Data(lrange,lflycondcounter)=nan;%
                        end
                    else
                        if (isempty(boutend))||(boutend<boutstart)
                            error('boutend is empty or smaller than boutstart')
                            % boutend=boutstart;
                        end
                        
                        DurInH_Segm=DurInBout{lfly}(boutstart:boutend,:);
                        %% Y N� bouts at different radii - 42:49
                        lparam=last_param+lthrcounter;
                        var_struct(lparam).Data(lrange,lflycondcounter)=sum(DurInH_Segm(:,1)==params.Subs_Numbers(1));% N� Y bouts
                        
                        %% Y Av duration at different radii - 58:65
                        lparam=last_param+2*length(lthrs)+lthrcounter;
                        tY=DurInH_Segm(DurInH_Segm(:,1)==params.Subs_Numbers(1),5);%fr YEAST
                        if isempty(tY), tY=0;end
                        var_struct(lparam).Data(lrange,lflycondcounter)=mean(tY)/params.framerate/60;%min YEAST
                        
                        %% Y N� bouts over time at different radii - 
                        lparam=last_param+9*length(lthrs)+lthrcounter;
                        var_struct(lparam).Data(lrange,lflycondcounter)=sum(DurInH_Segm(:,1)==params.Subs_Numbers(1))/(length(range)/params.framerate/60);%;% N� Y bouts
                        
                        %% Y N� bouts over time walking outside visits at different radii - 
                        lparam=last_param+11*length(lthrs)+lthrcounter;
                        var_struct(lparam).Data(lrange,lflycondcounter)=...
                            sum(DurInH_Segm(:,1)==params.Subs_Numbers(1))/...
                            ((sum((Etho_Speed_range(logicaloutsidevisits)==4)|...
                        (Etho_Speed_range(logicaloutsidevisits)==5)))/params.framerate/60);%;% N� Y bouts
                        
                        %% %% %% SUCROSE %% %% %%
                        if size(params.Subs_Numbers,2)>1
                            %% S N� bouts at different radii - 50:57
                            lparam=last_param+length(lthrs)+lthrcounter;
                            var_struct(lparam).Data(lrange,lflycondcounter)=sum(DurInH_Segm(:,1)==params.Subs_Numbers(2));% N� S visits
                            
                            %% S Av Duration at different radii - 66:73
                            lparam=last_param+3*length(lthrs)+lthrcounter;
                            tS=DurInH_Segm(DurInH_Segm(:,1)==params.Subs_Numbers(2),5);%fr SUCROSE
                            if isempty(tS), tS=0;end
                            var_struct(lparam).Data(lrange,lflycondcounter)=mean(tS)/params.framerate/60;%min SUCROSE
                            
                            %% S N� bouts over time at different radii - 
                            lparam=last_param+10*length(lthrs)+lthrcounter;
                            var_struct(lparam).Data(lrange,lflycondcounter)=sum(DurInH_Segm(:,1)==params.Subs_Numbers(2))/(length(range)/params.framerate/60);%
                            
                            %% S N� bouts over time walking outside visits at different radii - 
                            lparam=last_param+12*length(lthrs)+lthrcounter;
                            var_struct(lparam).Data(lrange,lflycondcounter)=...
                                sum(DurInH_Segm(:,1)==params.Subs_Numbers(2))/...
                                ((sum((Etho_Speed_range(logicaloutsidevisits)==4)|...
                        (Etho_Speed_range(logicaloutsidevisits)==5)))/params.framerate/60);%
                        else
                            lparam=last_param+length(lthrs)+lthrcounter;
                            var_struct(last_param+length(lthrs)+lthrcounter).Data(lrange,lflycondcounter)=nan;
                            lparam=last_param+3*length(lthrs)+lthrcounter;
                            var_struct(last_param+3*length(lthrs)+lthrcounter).Data(lrange,lflycondcounter)=nan;
                            lparam=last_param+10*length(lthrs)+lthrcounter;
                            var_struct(last_param+10*length(lthrs)+lthrcounter).Data(lrange,lflycondcounter)=nan;
                            lparam=last_param+12*length(lthrs)+lthrcounter;
                            var_struct(last_param+12*length(lthrs)+lthrcounter).Data(lrange,lflycondcounter)=nan;
                        end
                        
                        %% YPI at different radii - 72:79
                        if size(params.Subs_Numbers,2)==2
                            lparam=last_param+4*length(lthrs)+lthrcounter;
                            var_struct(lparam).Data(lrange,lflycondcounter)=...
                                (sum(DurInH_Segm(:,1)==params.Subs_Numbers(1))-sum(DurInH_Segm(:,1)==params.Subs_Numbers(2)))/...
                                (sum(DurInH_Segm(:,1)==params.Subs_Numbers(1))+sum(DurInH_Segm(:,1)==params.Subs_Numbers(2)));
                        else
                            lparam=last_param+4*length(lthrs)+lthrcounter;
                            var_struct(lparam).Data(lrange,lflycondcounter)=nan;
                        end
                        
                        %% Per bout parameters
                        %%% Warning: Only optimised for Subs1 and Sbs2
                        if size(params.Subs_Numbers,2)==1,
                            Subs_Idx=params.Subs_Numbers(1);
                            if lHThr==4.5
                                var_struct(41).Data(lrange,lflycondcounter)=nan;% Sucrose
                                var_struct(43).Data(lrange,lflycondcounter)=nan;% Sucrose
                            end
                            var_struct(last_param+6*length(lthrs)+lthrcounter).Data(lrange,lflycondcounter)=nan;
                            var_struct(last_param+8*length(lthrs)+lthrcounter).Data(lrange,lflycondcounter)=nan;
                        elseif size(params.Subs_Numbers,2)>1
                            Subs_Idx=params.Subs_Numbers(1:2);
                        else
                            Subs_Idx=[];
                        end
                        
                        for lsubs=Subs_Idx%Calculate area covered of yeast spots
                            bout_rows=find(DurInH_Segm(:,1)==lsubs)';
                            Min_dist=nan(length(bout_rows),1);
                            Time_on=nan(length(bout_rows),1);
                            Wmm=nan(length(bout_rows),1);%% With micromovements
                            WHmm=nan(length(bout_rows),1);%% With head micromovements
                            
                            boutcounter=0;
                            for lbout=bout_rows
                                boutcounter=boutcounter+1;
                                Boutframes=DurInH_Segm(lbout,2):DurInH_Segm(lbout,3);
                                
                                %% N� bouts with micromovements at different radii - 82:97
                                Wmm(boutcounter)=logical(sum((Etho_Speed{lfly}(Boutframes)==2)|(Etho_Speed{lfly}(Boutframes)==3)));
                                
                                %% N� of bouts with at least 1 Head micromovement for Rate of engagement at different radii - 98:113
                                WHmm(boutcounter)=logical(sum(Binary_Head_mm(Boutframes,lfly)));
                                
                                %% Average minimum distance to yeast outside visits in radius=4.5mm
                                if lHThr==4.5% Only for the 4.5mm radius
                                    Novisitboutframes=Boutframes(~logical(CumTimeV{lsubs==params.Subs_Numbers}(Boutframes,lfly)));
                                    Heads_temp=Heads_Sm{lfly}(Novisitboutframes,:);%
                                    if ~isempty(Heads_temp)
                                        %% Average min distance from Spot outside visit
                                        Diff_temp=repmat(Wellpos(DurInH_Segm(lbout,4),:),size(Heads_temp,1),1) -...
                                            Heads_temp;%

                                        Dist2fSpot=sqrt(sum(((Diff_temp).^2),2)).*params.px2mm;
                                        Min_dist(boutcounter)=min(Dist2fSpot);
                                        %% Time on bout outside visit
                                        Time_on(boutcounter)=length(Novisitboutframes)/params.framerate/60;%min
                                    end
                                end
                            end
                            if lHThr==4.5
                                var_struct(39+find(lsubs==params.Subs_Numbers)).Data(lrange,lflycondcounter)=nanmean(Min_dist);%mm
                                var_struct(41+find(lsubs==params.Subs_Numbers)).Data(lrange,lflycondcounter)=nanmean(Time_on);%mm
                            end
                            %% N� of bouts with micromovements at different radii - 82:97
                            lparam=last_param+(4+find(lsubs==params.Subs_Numbers))*length(lthrs)+lthrcounter;
                            var_struct(lparam).Data(lrange,lflycondcounter)=nansum(Wmm);
                            %% Rate of Y engagement at different radii - 98:113
                            lparam=last_param+(6+find(lsubs==params.Subs_Numbers))*length(lthrs)+lthrcounter;
                            var_struct(lparam).Data(lrange,lflycondcounter)=nansum(WHmm)/boutcounter;%N� bouts with at least 1 Hmm/Num bouts
                        end
                        
                    end
                end
                %% Parameters for visits that include revisits
                clear DurInV_Segm boutstart boutstart1 boutend1 boutend Head_Segm
                if ~isempty(DurInVRV{lfly})
                    boutstart1=find(DurInVRV{lfly}(:,2)<=range(1),1,'last');
                    if isempty(boutstart1)||(DurInVRV{lfly}(boutstart1,3)<=range(1))
                        boutstart1=find(DurInVRV{lfly}(:,2)>=range(1),1,'first');
                    end
                    
                    if DurInVRV{lfly}(boutstart1,2)<range(end)
                        boutstart=boutstart1;
                        boutend1=find(DurInVRV{lfly}(:,3)<range(end),1,'last');
                        
                        if isempty(boutend1)
                            boutend=boutstart;
                        elseif (boutend1~=size(DurInVRV{lfly},1))&&(DurInVRV{lfly}(boutend1+1,2)<range(end))
                            boutend=boutend1+1;
                        else
                            boutend=boutend1;
                        end
                        
                    else
                        boutstart=[];
                    end
                else
                    boutstart=[];
                end
                if ~isempty(boutstart)
                    if (isempty(boutend))||(boutend<boutstart)
                        error('boutend is empty or smaller than boutstart')
                        % boutend=boutstart;
                    end
                    DurInVRV_Segm=DurInVRV{lfly}(boutstart:boutend,:);
                    var_struct(61).Data(lrange,lflycondcounter)=sum(DurInVRV_Segm(:,1)==params.Subs_Numbers(1));% N� Y visits with RV
                    if length(params.Subs_Numbers)>1
                        var_struct(62).Data(lrange,lflycondcounter)=sum(DurInVRV_Segm(:,1)==params.Subs_Numbers(2));% N� S visits with RV
                    end
                    if size(params.Subs_Names,1)==2%% This code only works for 2 substrates
                    var_struct(63).Data(lrange,lflycondcounter)=...
                            (sum(DurInVRV_Segm(:,1)==params.Subs_Numbers(1))-sum(DurInVRV_Segm(:,1)==params.Subs_Numbers(2)))/...
                            (sum(DurInVRV_Segm(:,1)==params.Subs_Numbers(1))+sum(DurInVRV_Segm(:,1)==params.Subs_Numbers(2)));
                    end
                end
                %% Parameters for encounters at 3mm that include revisits
                clear DurInV_Segm boutstart boutstart1 boutend1 boutend Head_Segm
                if ~isempty(DurInEncRV{lfly})
                    boutstart1=find(DurInEncRV{lfly}(:,2)<=range(1),1,'last');
                    if isempty(boutstart1)||(DurInEncRV{lfly}(boutstart1,3)<=range(1))
                        boutstart1=find(DurInEncRV{lfly}(:,2)>=range(1),1,'first');
                    end
                    
                    if DurInEncRV{lfly}(boutstart1,2)<range(end)
                        boutstart=boutstart1;
                        boutend1=find(DurInEncRV{lfly}(:,3)<range(end),1,'last');
                        
                        if isempty(boutend1)
                            boutend=boutstart;
                        elseif (boutend1~=size(DurInEncRV{lfly},1))&&(DurInEncRV{lfly}(boutend1+1,2)<range(end))
                            boutend=boutend1+1;
                        else
                            boutend=boutend1;
                        end
                        
                    else
                        boutstart=[];
                    end
                else
                    boutstart=[];
                end
                if ~isempty(boutstart)
                    if (isempty(boutend))||(boutend<boutstart)
                        error('boutend is empty or smaller than boutstart')
                        % boutend=boutstart;
                    end
                    DurInEncRV_Segm=DurInEncRV{lfly}(boutstart:boutend,:);
                    var_struct(65).Data(lrange,lflycondcounter)=...
                            sum(DurInEncRV_Segm(:,1)==params.Subs_Numbers(1));%N� Y encounters 3mm with RV
                    if size(params.Subs_Names,1)==2%% This code only works for 2 substrates
                        var_struct(64).Data(lrange,lflycondcounter)=...
                            (sum(DurInEncRV_Segm(:,1)==params.Subs_Numbers(1))-sum(DurInEncRV_Segm(:,1)==params.Subs_Numbers(2)))/...
                            (sum(DurInEncRV_Segm(:,1)==params.Subs_Numbers(1))+sum(DurInEncRV_Segm(:,1)==params.Subs_Numbers(2)));
                        var_struct(66).Data(lrange,lflycondcounter)=...
                            sum(DurInEncRV_Segm(:,1)==params.Subs_Numbers(2));%N� S encounters 3mm with RV
                    end
                else
                    var_struct(64).Data(lrange,lflycondcounter)=nan; % YPI encounters 3mm with RV
                    var_struct(65).Data(lrange,lflycondcounter)=0;%N� Y encounters 3mm with RV
                    var_struct(66).Data(lrange,lflycondcounter)=0;%N� S encounters 3mm with RV
                end
            end
        end
        
    end
    %     title_h=suptitle(figname);set(title_h,'FontSize',FtSz,'FontName',FntName);
    TimeSegmentsParams{lcondcounter}=var_struct;
end
