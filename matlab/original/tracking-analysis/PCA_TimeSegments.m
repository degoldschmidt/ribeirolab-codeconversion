%% %% PCA for 11 variables in 5 Time Segments %% %%

%% Labels for the 55 points per fly

% 	1. Num of visits per min
% 	2. Av duration of visits
% 	3. % Yeast time (Head mm) per min of period
% 	4. YPI (time)
% 	5. YPI (nº)
% 	6. Av Speed outside visits
% 	7. Average IyVI distance
% 	8. Average Spot distance
% 	9. Nº of different spots visited
% 	10. Nº breaks/min period
% 	11. % Time on Edge

numparams=11;
flies_idx=params.IndexAnalyse;
ranges=[1 15000;15001 45000;90001 105000;105001 195000;195001 345000];%


variables=struct('YLabel',cell(numparams,1));

variables(1).YLabel='Nº Y Vis/min ';
variables(2).YLabel='Av Dur Y ';
variables(3).YLabel='t_F_o_o_d/t_T ';
variables(4).YLabel='YPI (Duration) ';
variables(5).YLabel='YPI (Nº) ';
variables(6).YLabel='Speed_c not v ';
variables(7).YLabel='Av IyVDist ';
variables(8).YLabel='Av Y Spot dist ';
variables(9).YLabel='Nº different Y ';
variables(10).YLabel='Nº Breaks/min ';
variables(11).YLabel='t_e_d_g_e/t_T ';%

%%% Time Segments Labels
n_rounded=nan(1,size(ranges,1));
n2_rounded=nan(1,size(ranges,1));
xticklabels=cell(1,size(ranges,1));
PCA_params_labels=cell(size(ranges,1)*numparams,1);
labelcounter=0;
for lparam=1:numparams
    for lrange=1:size(ranges,1)
        if lparam==1
            n=((ranges(lrange,2)-ranges(lrange,1))/2+ranges(lrange,1))/50/60;
            n2=(ranges(lrange,2))/50/60;
            n_rounded(lrange) = round(n*(10^2))/(10^2);
            n2_rounded(lrange)= round(n2*(10^2))/(10^2);
            if lrange==1
                xticklabels{lrange}=['0-' num2str(n2_rounded(lrange))];
            else
                xticklabels{lrange}=[num2str(n2_rounded(lrange-1)) '-' num2str(n2_rounded(lrange))];
            end
        end
        labelcounter=labelcounter+1;
        PCA_params_labels{labelcounter}=[variables(lparam).YLabel xticklabels{lrange}];
    end
end

%% Calculating variables and input vector
InputPCAData=nan(length(flies_idx),size(ranges,1)*numparams);

lflycounter=0;
    for lfly=fliestoplot
        lfly
        lflycounter=lflycounter+1;
      
        %%
        for lrange=1:size(ranges,1)
            range=ranges(lrange,1):ranges(lrange,2);
            %             display(['time range: ' num2str(range(1)) ' - ' num2str(range(end)) ' (fr)'])
            
            %% Distance Covered
%             variables(1).Data(lrange,lflycounter)=nansum(Steplength_Sm_c{lfly}(range))*params.px2mm/1000;%m
            %% Thigmotaxis - % of time on edge
            lparam=11;
            [Binary_Edge] = Edge_Explor(Heads_Sm,lfly,params);
            InputPCAData(lflycounter,size(ranges,1)*lparam-size(ranges,1)+lrange)=nansum(Binary_Edge(range))/length(range);%Fraction of time on edge
            %% Outside Visits: Area and Speed
            lparam=6;
            logicaloutsidevisits=~(Binary_V(range,lfly)');
            if sum(logicaloutsidevisits)==0
                variables(8).Data(lrange,lflycounter)=0;% Area outside visits
                variables(2).Data(lrange,lflycounter)=nan;% Speed outside visits
                
            else
                %% Area covered outside visits
%                 Heads_temp=Heads_Sm{lfly}(range,:);%
%                 count_fly2= hist3([Heads_temp(logicaloutsidevisits,2),...
%                     Heads_temp(logicaloutsidevisits,1)],{xrange xrange});
%                 variables(8).Data(lrange,lflycounter)=nansum(nansum(count_fly2~=0))/1000;% Area outside v
                %% Average Speed outside visits
                Speed_temp=Steplength_Sm_c{lfly}(range);
                Speed_NoVisits=Speed_temp(logicaloutsidevisits)*params.px2mm*params.framerate;
                variables(2).Data(lrange,lflycounter)=nanmean(Speed_NoVisits);%mm/s
                
            end
            %% Visits parameters - Visits that started in the previous period will be included
            %%% In the case the visit starts in the previous time segment and
            %%% finishes in the current time segment
            clear DurInV_Segm boutstart boutstart1 boutend1 boutend Head_Segm
            boutstart1=find(DurInV{lfly}(:,2)<=range(1),1,'last');
            if isempty(boutstart1)||(DurInV{lfly}(boutstart1,3)<=range(1))
                boutstart1=find(DurInV{lfly}(:,2)>=range(1),1,'first');
            end
            
            if DurInV{lfly}(boutstart1,2)<=range(end)
                boutstart=boutstart1;
                boutend1=find(DurInV{lfly}(:,3)<=range(end),1,'last');
                
                if isempty(boutend1)
                    boutend=boutstart;
                elseif (boutend1~=size(DurInV{lfly},1))&&(DurInV{lfly}(boutend1+1,2)<=range(end))
                    boutend=boutend1+1;
                else
                    boutend=boutend1;
                end
                
            else
                boutstart=[];
            end
            
            if isempty(boutstart)
                variables(3).Data(lrange,lflycounter)=0;%tFood/Total time
                variables(5).Data(lrange,lflycounter)=0;% Nº Visits/Distance
                variables(6).Data(lrange,lflycounter)=nan;% YPI
                variables(7).Data(lrange,lflycounter)=0;% Area Y visit
                variables(9).Data(lrange,lflycounter)=0;%Y Av Dur
                variables(10).Data(lrange,lflycounter)=0;%S Av Dur
                variables(11).Data(lrange,lflycounter)=0;%Nº Y visits
                variables(12).Data(lrange,lflycounter)=0;%Nº S Visits
            else
                if (isempty(boutend))||(boutend<boutstart)
                    error('boutend is empty or smaller than boutstart')
                    % boutend=boutstart;
                end
                DurInV_Segm=DurInV{lfly}(boutstart:boutend,:);
                AllVisit_frames=DurInV{lfly}(boutstart,2):DurInV{lfly}(boutend,3);
                visitrange1=min([AllVisit_frames(1),range(1)]);
                visitrange2=min([AllVisit_frames(end),range(end)]);
                %% Number of visits
                variables(11).Data(lrange,lflycounter)=sum(DurInV_Segm(:,1)==1);% Nº Y visits
                variables(12).Data(lrange,lflycounter)=sum(DurInV_Segm(:,1)==2);% Nº S visits
                %% Nº Visits %/ Distance
                variables(5).Data(lrange,lflycounter)=...
                    size(DurInV_Segm,1);%/(nansum(Steplength_Sm_c{lfly}(range))*params.px2mm/1000);%1/m
                %% Average duration of visits
                tY=DurInV_Segm(DurInV_Segm(:,1)==1,5);%fr YEAST
                tS=DurInV_Segm(DurInV_Segm(:,1)==2,5);%fr SUCROSE
                if isempty(tY), tY=0;end
                if isempty(tS), tS=0;end
                variables(9).Data(lrange,lflycounter)=mean(tY)/params.framerate/60;%min YEAST
                variables(10).Data(lrange,lflycounter)=mean(tS)/params.framerate/60;%min SUCROSE
                %% YPI (time on visits)
                variables(6).Data(lrange,lflycounter)=(sum(tY)-sum(tS))/(sum(tY)+sum(tS));
                %% YPI (Nº of visits)
                variables(16).Data(lrange,lflycounter)=(sum(DurInV_Segm(:,1)==1)-sum(DurInV_Segm(:,1)==2))/(sum(DurInV_Segm(:,1)==1)+sum(DurInV_Segm(:,1)==2));
                %% Time on Food/Total time. Within the range, how many frames on food
                variables(3).Data(lrange,lflycounter)=...
                    nansum(Binary_V(range,lfly))/length(range);
                
                
                    
                %% Average distance between next yeast or sucrose
                for lsubs=1:2
                    SpotNumbers=find(FlyDB(lfly).Geometry==lsubs);
                    Wellpos=FlyDB(lfly).WellPos;
                    V_Num_log=ismember(DurInV_Segm(:,4)', SpotNumbers);
                    V_Num=DurInV_Segm(V_Num_log,4);%Numbers of spots visited
                    if size(V_Num,1)>1
                        distspots_temp=nan(size(V_Num,1)-1,1);
                        for lspot=1:size(V_Num,1)-1
                            distspots_temp(lspot)=sqrt(sum((Wellpos(V_Num(lspot+1),:)-...
                                Wellpos(V_Num(lspot),:)).^2));

                        end
                        variables(12+lsubs).Data(lrange,lflycounter)=mean(distspots_temp)*params.px2mm;
                    else
                        % Only 1 visiy
                        variables(12+lsubs).Data(lrange,lflycounter)=nan;
                    end
                    
                    
                end
                %% Average distance covered between next yeast or sucrose
%                 for lsubs=1:2
%                     SpotNumbers=find(FlyDB(lfly).Geometry==lsubs);
%                     Wellpos=FlyDB(lfly).WellPos;
%                     V_Num_log=ismember(DurInV_Segm(:,4)', SpotNumbers);
%                     V_row=find(V_Num_log)';
%                     if size(V_row,1)>1
%                         distcovered_temp=nan(size(V_row,1)-1,1);
%                         for lspot=1:size(V_row,1)-1
%                             distcovered_temp(lspot)=...
%                                 nansum(Steplength_Sm_c{lfly}...
%                                 (DurInV_Segm(V_row(lspot),3):DurInV_Segm(V_row(lspot+1),2)))*params.px2mm;%mm
%                         end
%                         variables(12+lsubs).Data(lrange,lflycounter)=nanmean(distcovered_temp)*params.px2mm;
%                     else
%                         % Only 1 visiy
%                         variables(12+lsubs).Data(lrange,lflycounter)=nan;
%                     end
%                 end
                %% Nº of breaks
% % %                 lsubs=1;
% % %                 clear breakstart breaksend
% % %                 Breaktemp=Breaks{lsubs}(Breaks{lsubs}(:,4)==lfly,1:2);
% % %                 breakstart=find(Breaktemp(:,1)>=AllVisit_frames(1),1,'first');
% % %                 if isempty(breakstart)||Breaktemp(breakstart,1)>=AllVisit_frames(end)
% % %                     variables(15).Data(lrange,lflycounter)=0;
% % %                 else
% % %                     breaksend=find(Breaktemp(:,2)<=AllVisit_frames(end),1,'last');
% % %                     if breaksend<breakstart,error('Break end smaller than Break start'),end
% % %                     %%% Number of breaks per visit
% % %                     variables(15).Data(lrange,lflycounter)=...
% % %                         (breaksend-breakstart+1)/sum(DurInV_Segm(:,1)==lsubs);
% % %                 end
                %% Area covered during Y visit
                lsubs=1;%Calculate area covered of yeast spots
                visit_rows=find(DurInV_Segm(:,1)==lsubs)';
                Ar_Cov_temp=nan(length(visit_rows),1);
                Breaktemp=Breaks{lsubs}(Breaks{lsubs}(:,4)==lfly,1:3);
                NBreak=nan(length(visit_rows),1);
                visitcounter=0;
                for lvisit=visit_rows
                    visitcounter=visitcounter+1;
                    Visitframes=DurInV_Segm(lvisit,2):DurInV_Segm(lvisit,3);
                    Heads_temp=Heads_Sm{lfly}(Visitframes,:);%
                    %%% Area covered
                    count_fly= hist3([Heads_temp(:,2) Heads_temp(:,1)],{xrange xrange});
%                     Ar_Cov_temp(visitcounter)=nansum(nansum(count_fly~=0));
                    Ar_Cov_temp(visitcounter)=nansum(nansum(count_fly~=0))/(DurInV_Segm(lvisit,5)/params.framerate/60);%px/min
                    
                    %%% Breaks per minute of visit
                    NBreak(visitcounter)=sum(ismember(Breaktemp(:,1),Visitframes))/(DurInV_Segm(lvisit,5)/params.framerate/60);%NºBreaks/min
                    %%% Sanity check of Breaks
                    if unique(Breaktemp(ismember(Breaktemp(:,1),Visitframes),3))~=DurInV_Segm(lvisit,4)
                        error('Breaks counted belong to other spot')
                    end
                end
                variables(7).Data(lrange,lflycounter)=nanmean(Ar_Cov_temp);%/1000;%Average px/min of visit
                variables(15).Data(lrange,lflycounter)=nanmean(NBreak);%Average NºBreaks/min of visit
            end
        end
    end
