function [TimeSegmentsParams,CondFlyIdx]=timesegmentsparams(ranges,FlyDB,params,...
    Heads_Sm,Steplength_Sm_c,Steplength_Sm_h,DurInV,CumTimeV,Binary_V,...
    Breaks,Etho_Tr,Etho_Tr2, Walking_vec,Etho_Speed,InSpot,HEAD_YN)
%% TimeSegmentsVar is a cell variable with as many entries as conditions or
%%% unique(params.ConditionIndex). The Fly index is the fly index inside the
%%% condition, not the DataBase fly index. CondFlyIdx has 2 columns: Col1 is
%%% the DataBase fly index, Col2 is the fly index inside the condition.
%%% To access condition_n, parameter_x, in range_y and flycondidx_z write:
%%% TimeSegmentsVar{condition_n}(parameter_x).Data(range_y,flycondidx_z)
%%%
%%% %% Parameters Calculated (to see details of calculation, refer to
%%% electronic lab book, Analysis Algorithm>Parameters extracted from each
%%% experiment>Time segment parameters):
% 1.	Distance covered (1)
% 2.	Speed outside visits (2)
% 3.	% Time on food (3)
% 4.	% Time on edge (4)
% 5.	Total Nº of visits (5)
% 6.	YPI (time) (6)
% 7.	Average YAreavisit/Ytimevisit
% 8.	Area outside visits
% 9.	Average duration Y (7)
% 10.	Average duration S (8)
% 11.	Nº visits Y (9)
% 12.	Nº visits S (10)
% 13.	Average Y-Y Spot distance
% 14.	Average S-S spot distance
% 15.	Nº of excursions/min on yeast (11): Yeast visit or yeast micromovement?
% 16.	YPI (Nº) (12)
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
% 40.   Average Minimum distance to yeast during 4.5 bout
% 41.	Average Minimum distance to sucrose during 4.5 bout



% 32.	Mean distance from Yeast (at any time)
% 33.	Mean distance from Sucrose (at any time)
% 34.	Engagement rate for Yeast
% 35.	Engagement rate for Sucrose
% 36.	Time spent in Voronoi, but not in visit, for Y
% 37.	Time spent in Voronoi, but not in visit, for S

display('CALCULATING TIME SEGMENT PARAMETERS')
xrange=-33/params.px2mm:33/params.px2mm;
MaxRad=4.5;%%
Spot_thrs=1:.5:MaxRad;%
Spot_thrs2=Spot_thrs(1:2:end);

Conditions=unique(params.ConditionIndex);
CondFlyIdx=nan(size(params.ConditionIndex,2),2);


TimeSegmentsParams=cell(length(Conditions),1);

% variables1=struct('YLabel',cell(numparams,1),...
%     'ColorAxes',num2cell(repmat(ColorAx1,numparams,1),2),...
%     'XAxes',num2cell(repmat([ranges(1)/params.framerate/60 ranges(end)/params.framerate/60],numparams,1),2),...
%     'YAxes',cell(numparams,1));
%% CREATING STRUCTURE
clear var_struct
var_struct(1).YLabel={'Dist covered';'(m)'};var_struct(1).YAxes=[0 10];
var_struct(2).YLabel={'Speed_c';'not v(mm/s)'};var_struct(2).YAxes=[0 11];
var_struct(3).YLabel='t_F_o_o_d/t_T';var_struct(3).YAxes=[0 .9];
var_struct(4).YLabel='t_e_d_g_e/t_T';var_struct(4).YAxes=[0 .7];
var_struct(5).YLabel={'Total Nº';'of visits'};var_struct(5).YAxes=[0 30];
var_struct(6).YLabel={'YPI';'(Time visits)'};var_struct(6).YAxes=[-1 1];
var_struct(7).YLabel={['Av Area per min ' params.Subs_Names{1}(1) 'v'],'(px/min)'};var_struct(7).YAxes=[0 0];
var_struct(8).YLabel={'Area not v','(px) (x1000)'};var_struct(8).YAxes=[0 30];
var_struct(9).YLabel={[params.Subs_Names{1}(1) ' Av Dur'];'(min)'};var_struct(9).YAxes=[0 0];
var_struct(10).YLabel={'S Av Dur';'(min)'};var_struct(10).YAxes=[0 0.15];
var_struct(11).YLabel={['Nº ' params.Subs_Names{1}(1)],'Visits'};var_struct(11).YAxes=[0 0];
var_struct(12).YLabel={'Nº S','Visits'};var_struct(12).YAxes=[0 0];
var_struct(13).YLabel={['Av ' params.Subs_Names{1}(1) '-' params.Subs_Names{1}(1) ' Spot'],'dist (mm)'};var_struct(13).YAxes=[0 35];
var_struct(14).YLabel={'Av S-S Spot','dist (mm)'};var_struct(14).YAxes=[0 35];
var_struct(15).YLabel={'Nº Excurs.';['per min ' params.Subs_Names{1}(1) 'v']};var_struct(15).YAxes=[0 0];
var_struct(16).YLabel={'YPI';'(Nº visits)'};var_struct(16).YAxes=[-1 1];
var_struct(17).YLabel={'Tr Pr (%)';['To close ' params.Subs_Names{1}(1)]};var_struct(17).YAxes=[0 0];
var_struct(18).YLabel={'Tr Pr (%)';['To far ' params.Subs_Names{1}(1)]};var_struct(18).YAxes=[0 0];
var_struct(19).YLabel={'Tr Pr (%)';'To close S'};var_struct(19).YAxes=[0 0];
var_struct(20).YLabel={'Tr Pr (%)';'To far S'};var_struct(20).YAxes=[0 0];
var_struct(21).YLabel={'Av max dist';'on excurs. (mm)'};var_struct(21).YAxes=[0 0];
var_struct(22).YLabel={['Av Grassing ' params.Subs_Names{1}(1)];'(d_h - d_c)'};var_struct(22).YAxes=[0 0];
var_struct(23).YLabel={'Av YS-Y Spot','dist (mm)'};var_struct(23).YAxes=[0 0];
var_struct(24).YLabel={'Av YS-S Spot','dist (mm)'};var_struct(24).YAxes=[0 0];
var_struct(25).YLabel={'Av YS-Y Inter','dist covered (mm)'};var_struct(25).YAxes=[0 0];
var_struct(26).YLabel={'Av YS-S Inter','dist covered (mm)'};var_struct(26).YAxes=[0 0];
var_struct(27).YLabel={['Total' params.Subs_Names{1}(1) 'Ar/Total' params.Subs_Names{1}(1) 't'],'(px/min)'};var_struct(27).YAxes=[0 0];
var_struct(28).YLabel={['Av dist from ' params.Subs_Names{1}(1)],'during visit (mm)'};var_struct(28).YAxes=[0 0];
var_struct(29).YLabel={'Av dist from S','during visit (mm)'};var_struct(29).YAxes=[0 0];
var_struct(30).YLabel={['Av ' params.Subs_Names{1}(1) ' minim'];'dist in visit (mm)'};var_struct(30).YAxes=[0 0];
var_struct(31).YLabel={'Av S minim';'dist in visit(mm)'};var_struct(31).YAxes=[0 0];
var_struct(32).YLabel=['Nº ' params.Subs_Names{1}(1) 'Excursions'];var_struct(32).YAxes=[0 0];
var_struct(33).YLabel={'Nº of different ',[ params.Subs_Names{1}(1) 'Spots']};var_struct(33).YAxes=[0 0];
var_struct(34).YLabel={'Tr Pr (%)';['To same ' params.Subs_Names{1}(1)]};var_struct(34).YAxes=[0 0];
var_struct(35).YLabel={'Tr Pr (%)';'To same S'};var_struct(35).YAxes=[0 0];
var_struct(36).YLabel={'Tr Pr (%)';['To adj ' params.Subs_Names{1}(1)]};var_struct(36).YAxes=[0 0];
var_struct(37).YLabel={'Tr Pr (%)';'To adj S'};var_struct(37).YAxes=[0 0];
var_struct(38).YLabel={'Tr Pr (%)';['To far ' params.Subs_Names{1}(1)]};var_struct(38).YAxes=[0 0];
var_struct(39).YLabel={'Tr Pr (%)';'To far S'};var_struct(39).YAxes=[0 0];
var_struct(40).YLabel={['Min dist to ' params.Subs_Names{1}(1)],'not v, r = 4.5mm'};var_struct(40).YAxes=[0 0];
var_struct(41).YLabel={'Min dist to S','not v, r = 4.5mm'};var_struct(41).YAxes=[0 0];

last_param=41;
if HEAD_YN
    lthrcounter=0;
    for lHThr=Spot_thrs
        lthrcounter=lthrcounter+1;
        %% Y Nº bouts at different radii - 42:49
        lparam=last_param+lthrcounter;
        var_struct(lparam).YLabel={['Nº ' params.Subs_Names{1}(1) ' bouts'];...
            ['r = ' num2str(Spot_thrs(lthrcounter)) 'mm']};
        var_struct(lparam).YAxes=[0 0];
        
        %% Y Av duration at different radii - 58:65
        lparam=last_param+2*length(Spot_thrs)+lthrcounter;
        var_struct(lparam).YLabel={['Av Dur ' params.Subs_Names{1}(1) ' bouts'];...
            ['r = ' num2str(Spot_thrs(lthrcounter)) 'mm']};
        var_struct(lparam).YAxes=[0 0];%min YEAST
        
        %% Nº of Y bouts with micromovements at different radii - 82:89
        lparam=last_param+5*length(Spot_thrs)+lthrcounter;
        var_struct(lparam).YLabel={['Nº of ' params.Subs_Names{1}(1) 'bouts'];...
            ['w/mm r = ' num2str(Spot_thrs(lthrcounter)) 'mm']};
        var_struct(lparam).YAxes=[0 0];%mm YEAST
        
        %% Rate of Y engagement at different radii - 98:105
        lparam=last_param+7*length(Spot_thrs)+lthrcounter;
        var_struct(lparam).YLabel={['Rate of ' params.Subs_Names{1}(1) ' Eng'];...
            ['r = ' num2str(Spot_thrs(lthrcounter)) 'mm']};%p(Engage|bout) YEAST
        var_struct(lparam).YAxes=[0 0];
        
        %% %% %% SUCROSE %% %% %%
        if size(params.Subs_Numbers,2)>1
            %% S Nº bouts at different radii - 50:57
            lparam=last_param+length(Spot_thrs)+lthrcounter;
            var_struct(lparam).YLabel=...
                {'Nº S bouts';['r = ' num2str(Spot_thrs(lthrcounter)) 'mm']};% Nº S visits
            var_struct(lparam).YAxes=[0 0];
            %% S Av Duration at different radii - 66:73
            lparam=last_param+3*length(Spot_thrs)+lthrcounter;
            var_struct(lparam).YLabel=...
                {'Av Dur S bouts';['r = ' num2str(Spot_thrs(lthrcounter)) 'mm']};%min SUCROSE
            var_struct(lparam).YAxes=[0 0];
            %% Nº of S bouts with micromovements at different radii - 90:97
            lparam=last_param+6*length(Spot_thrs)+lthrcounter;
            var_struct(lparam).YLabel=...
                {'Nº of S bouts';['w/mm r = ' num2str(Spot_thrs(lthrcounter)) 'mm']};%Nº SUCROSE
            var_struct(lparam).YAxes=[0 0];
            %% Rate of S engagement at different radii - 106:113
            lparam=last_param+8*length(Spot_thrs)+lthrcounter;
            var_struct(lparam).YLabel={['Rate of S Eng'];...
                ['r = ' num2str(Spot_thrs(lthrcounter)) 'mm']};%p(Engage|bout) SUCROSE
            var_struct(lparam).YAxes=[0 0];
            
        end
        %% YPI at different radii - 74:81
        if size(params.Subs_Numbers,2)==2
            lparam=last_param+4*length(Spot_thrs)+lthrcounter;
            var_struct(lparam).YLabel={'YPI bouts';...
                ['r = ' num2str(Spot_thrs(lthrcounter)) 'mm']};
            var_struct(lparam).YAxes=[0 0];
        end
    end
    
end
%% CALCULATING BinaryHeads for each HeadThr
if HEAD_YN
    DurInHCell=cell(length(Spot_thrs),1);
    lthrcounter=0;
    for lHThr=Spot_thrs
        lthrcounter=lthrcounter+1;
        display(['--- BIG CELL HEAD Threshold: ' num2str(lHThr) 'mm----'])
        %% Find DurInB Segment
        [~,Binary_Head_2] = Head_mm_fun(FlyDB,Heads_Sm,Walking_vec,InSpot,params,Etho_Speed,lHThr);
        [DurInH_2] = Binary2DurInCumTime(FlyDB,Binary_Head_2,InSpot,params.Subs_Numbers);
        DurInHCell{lthrcounter}=DurInH_2;
    end
end

%% CALCULATION STARTS PER CONDITION>FLY of condition>RANGE
lcondcounter=0;
for lcond=Conditions
    lcondcounter=lcondcounter+1;
    display(['----- ' params.LabelsShort{lcond} ' ------- Time Segments'])
    
    flies_cond=find(params.ConditionIndex==lcond);%Flies_cluster{lcond}(1:find(Flies_cluster{lcond}==clusterdividers{lcond}(1)))';%
    % fliestoplot=Flies_cluster{lcond}(find(Flies_cluster{lcond}==clusterdividers{lcond}(1))+1:end)';
    
    %% Change the Data Matrix for this condition
    [var_struct.Data]=deal(nan(size(ranges,1),length(flies_cond)));
    
    lflycondcounter=0;
    for lfly=flies_cond
        lflycondcounter=lflycondcounter+1;
        if mod(lflycondcounter,10)==0,display(lfly),end
        CondFlyIdx(lfly==params.IndexAnalyse,:)=[lfly,lflycondcounter];
        Wellpos=FlyDB(lfly).WellPos;
        %%
        for lrange=1:size(ranges,1)
            range=ranges(lrange,1):ranges(lrange,2);
            %             display(['time range: ' num2str(range(1)) ' - ' num2str(range(end)) ' (fr)'])
            %% Distance Covered
            var_struct(1).Data(lrange,lflycondcounter)=nansum(Steplength_Sm_c{lfly}(range))*params.px2mm/1000;%m
            
            %% Thigmotaxis - % of time on edge
            [Binary_Edge] = Edge_Explor(Heads_Sm,lfly,params);
            var_struct(4).Data(lrange,lflycondcounter)=nansum(Binary_Edge(range))/length(range);%Nº edge visits
            
            %% Outside Visits: Area and Speed
            logicaloutsidevisits=~(Binary_V(range,lfly)');
            if sum(logicaloutsidevisits)==0
                var_struct(8).Data(lrange,lflycondcounter)=nan;% Area outside visits
                var_struct(2).Data(lrange,lflycondcounter)=nan;% Speed outside visits
            else
                %% Area covered outside visits
                Heads_temp=Heads_Sm{lfly}(range,:);%
                count_fly2= hist3([Heads_temp(logicaloutsidevisits,2),...
                    Heads_temp(logicaloutsidevisits,1)],{xrange xrange});
                var_struct(8).Data(lrange,lflycondcounter)=nansum(nansum(count_fly2~=0))/1000;% Area outside v
                %% Average Speed outside visits
                Speed_temp=Steplength_Sm_c{lfly}(range);
                Speed_NoVisits=Speed_temp(logicaloutsidevisits)*params.px2mm*params.framerate;
                var_struct(2).Data(lrange,lflycondcounter)=nanmean(Speed_NoVisits);%mm/s
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
                var_struct(5).Data(lrange,lflycondcounter)=0;% Nº Visits/Distance
                var_struct(6).Data(lrange,lflycondcounter)=nan;% YPI
                var_struct(7).Data(lrange,lflycondcounter)=0;% Area Y visit
                var_struct(9).Data(lrange,lflycondcounter)=0;%Y Av Dur
                var_struct(10).Data(lrange,lflycondcounter)=0;%S Av Dur
                var_struct(11).Data(lrange,lflycondcounter)=0;%Nº Y visits
                var_struct(12).Data(lrange,lflycondcounter)=0;%Nº S Visits
                var_struct(22).Data(lrange,lflycondcounter)=nan;%Grassing
                var_struct(30).Data(lrange,lflycondcounter)=0;%Y Max Dur
                var_struct(31).Data(lrange,lflycondcounter)=0;%S Max Dur
            else
                if (isempty(boutend))||(boutend<boutstart)
                    error('boutend is empty or smaller than boutstart')
                    % boutend=boutstart;
                end
                DurInV_Segm=DurInV{lfly}(boutstart:boutend,:);
                
                %% Number of visits of substrate 1 and subtrate 2
                var_struct(11).Data(lrange,lflycondcounter)=sum(DurInV_Segm(:,1)==params.Subs_Numbers(1));% Nº Y visits
                if length(params.Subs_Numbers)>1
                    var_struct(12).Data(lrange,lflycondcounter)=sum(DurInV_Segm(:,1)==params.Subs_Numbers(2));% Nº S visits
                else
                    var_struct(12).Data(lrange,lflycondcounter)=nan;% Nº S visits
                end
                
                %% Total Nº Visits
                var_struct(5).Data(lrange,lflycondcounter)=...
                    size(DurInV_Segm,1);
                % Sanity check
                if length(params.Subs_Numbers)==2
                    if (sum(DurInV_Segm(:,1)==params.Subs_Numbers(1))+sum(DurInV_Segm(:,1)==params.Subs_Numbers(2)))...
                            ~=size(DurInV_Segm,1)
                        error('Error: NºY+NºS is different from total Nº visits')
                    end
                end
                %% Nº of different subs1 visits
                var_struct(33).Data(lrange,lflycondcounter)=...
                    sum(unique(DurInV_Segm(DurInV_Segm(:,1)==params.Subs_Numbers(1),4)));
                %% Average duration of visits
                tY=DurInV_Segm(DurInV_Segm(:,1)==params.Subs_Numbers(1),5);%fr YEAST
                if isempty(tY), tY=0;end
                var_struct(9).Data(lrange,lflycondcounter)=mean(tY)/params.framerate/60;%min YEAST
                if length(params.Subs_Numbers)>1
                    tS=DurInV_Segm(DurInV_Segm(:,1)==params.Subs_Numbers(2),5);%fr SUCROSE
                    
                    if isempty(tS), tS=0;end
                    
                    var_struct(10).Data(lrange,lflycondcounter)=mean(tS)/params.framerate/60;%min SUCROSE
                else
                    tS=nan;
                    var_struct(10).Data(lrange,lflycondcounter)=nan;
                end
                
                %% Maximum duration of visit
                %                 var_struct(30).Data(lrange,lflycondcounter)=max(tY)/params.framerate/60;%min YEAST
                %                 var_struct(31).Data(lrange,lflycondcounter)=max(tS)/params.framerate/60;%min SUCROSE
                
                %% YPI
                if size(params.Subs_Names,1)==2%% This code only works for 2 substrates
                    %% YPI (Time on visits)
                    var_struct(6).Data(lrange,lflycondcounter)=(sum(CumTimeV{1}(range,lfly))-sum(CumTimeV{2}(range,lfly)))/...
                        (sum(CumTimeV{1}(range,lfly))+sum(CumTimeV{2}(range,lfly)));
                    %% YPI (Nº of visits)
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
                                for lspot=V_Numidx
                                    prev_spot=DurInV_Segm(DurInVidx(lspot)-1,4);
                                    %% Average YS-Y or SS-S Spot distance
                                    distspots_temp(lspot==V_Numidx)=sqrt(sum((Wellpos(V_Num(lspot),:)-...
                                        Wellpos(prev_spot,:)).^2));
                                    %% Average YS-Y or SS-S distance covered
                                    distcovered_temp(lspot)=...
                                        nansum(Steplength_Sm_c{lfly}...
                                        (DurInV_Segm(DurInVidx(lspot)-1,3):DurInV_Segm(DurInVidx(lspot),2)))*params.px2mm;%mm
                                end
                                var_struct(22+find(lsubs==params.Subs_Numbers)).Data(lrange,lflycondcounter)=nanmean(distspots_temp)*params.px2mm;
                                var_struct(24+find(lsubs==params.Subs_Numbers)).Data(lrange,lflycondcounter)=nanmean(distcovered_temp)*params.px2mm;
                            else % There is only 1 visit
                                var_struct(22+find(lsubs==params.Subs_Numbers)).Data(lrange,lflycondcounter)=nan;
                                var_struct(24+find(lsubs==params.Subs_Numbers)).Data(lrange,lflycondcounter)=nan;
                            end
                            
                            
                        else % There are no visits to this substrate
                            var_struct(22+find(lsubs==params.Subs_Numbers)).Data(lrange,lflycondcounter)=nan;
                            var_struct(24+find(lsubs==params.Subs_Numbers)).Data(lrange,lflycondcounter)=nan;
                        end
                        
                    end
                else
                    var_struct(13).Data(lrange,lflycondcounter)=nan;
                    var_struct(14).Data(lrange,lflycondcounter)=nan;
                    var_struct(23).Data(lrange,lflycondcounter)=nan;
                    var_struct(24).Data(lrange,lflycondcounter)=nan;
                    var_struct(25).Data(lrange,lflycondcounter)=nan;
                    var_struct(26).Data(lrange,lflycondcounter)=nan;
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
                    Grassing=nan(length(visit_rows),1);
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
                            
                            %% Grassing: Distance covered with head - centroid
                            Grassing(visitcounter)=(nansum(Steplength_Sm_h{lfly}(range))-...
                                nansum(Steplength_Sm_c{lfly}(range)))*params.px2mm;%mm
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
                        var_struct(22).Data(lrange,lflycondcounter)=nanmean(Grassing);%mm
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
                
                %% Nº of excursions per min on Y = Total Nº excursions/Total time on Y on interval
                var_struct(15).Data(lrange,lflycondcounter)=...
                    size(Excurstemp3,1)/(sum(CumTimeV{lsubscounter}(range,lfly))/50/60);
                %% Nº of excursions = Total Nº excursions
                var_struct(32).Data(lrange,lflycondcounter)=...
                    size(Excurstemp3,1);
            else
                var_struct(21).Data(lrange,lflycondcounter)=nan;
                var_struct(15).Data(lrange,lflycondcounter)=nan;
            end
            
            %% Transition probabilities: Adjc_Same vs Non-Adj
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
            
            %% %% ABOUT ENCOUNTERS/BOUTS %% %%
            if HEAD_YN
                lthrcounter=0;
                for lHThr=Spot_thrs
                    lthrcounter=lthrcounter+1;
                    %% Find DurInB Segment
                    DurInH_2=DurInHCell{lthrcounter};
                    
                    clear DurInH_Segm boutstart boutstart1 boutend1 boutend Head_Segm
                    if ~isempty(DurInH_2{lfly})
                        boutstart1=find(DurInH_2{lfly}(:,2)<=range(1),1,'last');
                        if isempty(boutstart1)||(DurInH_2{lfly}(boutstart1,3)<=range(1))
                            boutstart1=find(DurInH_2{lfly}(:,2)>=range(1),1,'first');
                        end
                        
                        if DurInH_2{lfly}(boutstart1,2)<range(end)
                            boutstart=boutstart1;
                            boutend1=find(DurInH_2{lfly}(:,3)<range(end),1,'last');
                            
                            if isempty(boutend1)
                                boutend=boutstart;
                            elseif (boutend1~=size(DurInH_2{lfly},1))&&(DurInH_2{lfly}(boutend1+1,2)<range(end))
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
                        if size(params.Subs_Numbers,2)<2
                            for lparam=last_param+1:last_param+4*length(Spot_thrs)
                                var_struct(lparam).Data(lrange,lflycondcounter)=nan;%
                            end
                        else
                            for lparam=last_param+1:last_param+5*length(Spot_thrs)
                                var_struct(lparam).Data(lrange,lflycondcounter)=nan;%
                            end
                        end
                    else
                        if (isempty(boutend))||(boutend<boutstart)
                            error('boutend is empty or smaller than boutstart')
                            % boutend=boutstart;
                        end
                        
                        DurInH_Segm=DurInH_2{lfly}(boutstart:boutend,:);
                        %% Y Nº bouts at different radii - 42:49
                        lparam=last_param+lthrcounter;
                        var_struct(lparam).Data(lrange,lflycondcounter)=sum(DurInH_Segm(:,1)==params.Subs_Numbers(1));% Nº Y bouts
                        
                        %% Y Av duration at different radii - 58:65
                        lparam=last_param+2*length(Spot_thrs)+lthrcounter;
                        tY=DurInH_Segm(DurInH_Segm(:,1)==params.Subs_Numbers(1),5);%fr YEAST
                        if isempty(tY), tY=0;end
                        var_struct(lparam).Data(lrange,lflycondcounter)=mean(tY)/params.framerate/60;%min YEAST
                        
                        %% %% %% SUCROSE %% %% %%
                        if size(params.Subs_Numbers,2)>1
                            %% S Nº bouts at different radii - 50:57
                            lparam=last_param+length(Spot_thrs)+lthrcounter;
                            var_struct(lparam).Data(lrange,lflycondcounter)=sum(DurInH_Segm(:,1)==params.Subs_Numbers(2));% Nº S visits
                            
                            %% S Av Duration at different radii - 66:73
                            lparam=last_param+3*length(Spot_thrs)+lthrcounter;
                            tS=DurInH_Segm(DurInH_Segm(:,1)==params.Subs_Numbers(2),5);%fr SUCROSE
                            if isempty(tS), tS=0;end
                            var_struct(lparam).Data(lrange,lflycondcounter)=mean(tS)/params.framerate/60;%min SUCROSE
                        else
                            var_struct(last_param+length(Spot_thrs)+lthrcounter).Data(lrange,lflycondcounter)=nan;
                            var_struct(last_param+3*length(Spot_thrs)+lthrcounter).Data(lrange,lflycondcounter)=nan;
                        end
                        %% YPI at different radii - 72:79
                        if size(params.Subs_Numbers,2)==2
                            lparam=last_param+4*length(Spot_thrs)+lthrcounter;
                            var_struct(lparam).Data(lrange,lflycondcounter)=...
                                (sum(DurInH_Segm(:,1)==params.Subs_Numbers(1))-sum(DurInH_Segm(:,1)==params.Subs_Numbers(2)))/...
                                (sum(DurInH_Segm(:,1)==params.Subs_Numbers(1))+sum(DurInH_Segm(:,1)==params.Subs_Numbers(2)));
                        end
                        
                        %% Per bout parameters
                        
                        %%% Warning: Only optmised for Subs1 and Sbs2
                        if size(params.Subs_Numbers,2)==1,
                            Subs_Idx=params.Subs_Numbers(1);
                        elseif size(params.Subs_Numbers,2)==2
                            Subs_Idx=params.Subs_Numbers(1:2);
                        end
                        
                        for lsubs=Subs_Idx%Calculate area covered of yeast spots
                            bout_rows=find(DurInH_Segm(:,1)==lsubs)';
                            Min_dist=nan(length(bout_rows),1);
                            Wmm=nan(length(bout_rows),1);%% With micromovements
                            WHmm=nan(length(bout_rows),1);%% With head micromovements
                            
                            boutcounter=0;
                            for lbout=bout_rows
                                boutcounter=boutcounter+1;
                                Boutframes=DurInH_Segm(lbout,2):DurInH_Segm(lbout,3);
                                
                                %% Nº bouts with micromovements at different radii - 82:89
                                Wmm(boutcounter)=logical(sum((Etho_Speed{lfly}(Boutframes)==2)|(Etho_Speed{lfly}(Boutframes)==3)));
                                
                                %% Nº bouts with micromovements at different radii - 82:89
                                WHmm(boutcounter)=logical(sum(Binary_Head_mm(Boutframes,lfly)));
                                
                                %% Average minimum distance to yeast outside visits in radius=4.5mm
                                if lthrcounter==length(Spot_thrs)% Only for the 4.5mm radius
                                    Novisitboutframes=Boutframes(~logical(CumTimeV{lsubs==params.Subs_Numbers}(Boutframes,lfly)));
                                    Heads_temp=Heads_Sm{lfly}(Novisitboutframes,:);%
                                    %% Average min distance from Spot outside visit
                                    Diff_temp=repmat(Wellpos(DurInH_Segm(lbout,4),:),size(Heads_temp,1),1) -...
                                        Heads_temp;%
                                    
                                    Dist2fSpot=sqrt(sum(((Diff_temp).^2),2)).*params.px2mm;
                                    Min_dist(boutcounter)=min(Dist2fSpot);
                                end
                            end
                            if lthrcounter==length(Spot_thrs)
                                var_struct(39+find(lsubs==params.Subs_Numbers)).Data(lrange,lflycondcounter)=nanmean(Min_dist);%mm
                            end
                            %% Nº of bouts with micromovements at different radii - 82:97
                            lparam=last_param+(4+find(lsubs==params.Subs_Numbers))*length(Spot_thrs)+lthrcounter;
                            var_struct(lparam).Data(lrange,lflycondcounter)=nansum(Wmm);
                            %% Rate of Y engagement at different radii - 98:113
                            lparam=last_param+(6+find(lsubs==params.Subs_Numbers))*length(Spot_thrs)+lthrcounter;
                            var_struct(lparam).Data(lrange,lflycondcounter)=nansum(WHmm)/boutcounter;
                        end
                        
                    end
                end
            end
        end
        
    end
    %     title_h=suptitle(figname);set(title_h,'FontSize',FtSz,'FontName',FntName);
    TimeSegmentsParams{lcondcounter}=var_struct;
end
