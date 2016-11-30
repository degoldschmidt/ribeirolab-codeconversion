%%
% range_temp=[...80 90;
%     200 400;...
%     450 650;...
%     810 880;...
%     950 1100;...
%     3020 4005;...
%     5600 5900];
% Visits_test=[...1 70 100;
%     1 210 300;...
%     1 400 500;...
%     1 600 700;...
%     1 800 900;...
%     1 1000 1200;...
%     1 3000 3010;...
%     1 4000 4010;...
%     1 5000 5500;...
%     1 6000 6500];
%% Test Visits
% for l=1:size(range_temp,1)
%     range=range_temp(l,:);
%     clear DurInV_Segm boutstart boutstart1 boutend1 boutend Head_Segm
%     boutstart1=find(Visits_test(:,2)<=range(1),1,'last');
%     if isempty(boutstart1)||(Visits_test(boutstart1,3)<=range(1))
%         boutstart1=find(Visits_test(:,2)>=range(1),1,'first');
%     end
%
%     if Visits_test(boutstart1,2)<range(end)
%         boutstart=boutstart1;
%         boutend1=find(Visits_test(:,3)<range(end),1,'last');
%
%         if isempty(boutend1)
%             boutend=boutstart;
%         elseif (boutend1~=size(Visits_test,1))&&(Visits_test(boutend1+1,2)<range(end))
%             boutend=boutend1+1;
%         else
%             boutend=boutend1;
%         end
%
%     else
%         boutstart=[];
%     end
%
%     if isempty(boutstart)
%         display('isempty boutstart')
%     else
%         if (isempty(boutend))||(boutend<boutstart)
%             error('boutend is empty or smaller than boutstart')
%             % boutend=boutstart;
%         end
%     end
%     display('---')
%     display(l)
%     display(boutstart)
%     display(boutend)
%
% end
%% Test Excursions (Truncating breaks when the interval limits fall inside an excursion)
% Excurstemp=Visits_test(:,2:3);
% for l=1:size(range_temp,1)
%     range=range_temp(l,1):range_temp(l,2);
%     clear Excurboutstart Excurstemp3
%     Excurboutstart=find(Excurstemp(:,1)<range(1),1,'last');
%     if isempty(Excurboutstart)||Excurstemp(Excurboutstart,2)<=range(1)
%         Excurboutstart=find(Excurstemp(:,1)>=range(1),1,'first');
%         if ~isempty(Excurboutstart)&&Excurstemp(Excurboutstart,1)<range(end)
%             %% The excursion starts after the interval
%             Excurstemp2=Excurstemp(Excurboutstart:end,:);
%             Excurstemp3=excursion_start_end_interval(Excurstemp2,range);
%         elseif ~isempty(Excurboutstart)&&Excurstemp(Excurboutstart,1)>=range(end)
%             %% No excursions inside the interval
%             Excurstemp3=[];
%         end
%     elseif ~isempty(Excurboutstart)&&(Excurstemp(Excurboutstart,2)>range(1))
%         %% The excursion starts before the interval
%         Excurstemp2=Excurstemp(Excurboutstart:end,:);
%         Excurstemp2(1,1)=range(1);
%         Excurstemp3=excursion_start_end_interval(Excurstemp2,range);
%     else
%         %% The excursion starts and ends before the interval (not considered at all)
%         Excurstemp3=[];
%
%     end
%     display('---')
%     display(l)
%     display(Excurstemp3)
%
% end
%% Test Spot distance calculation
%%% See Notebook 4, page 121. Date: 29/Spet/2015
lfly=7;
Seq2test=cell(6,3);
Seq2test{1,1}=[1 5 6];%Y Y S
Seq2test{2,1}=[7 13 9];%Y S Y
Seq2test{3,1}=[11 16];%Y Y
Seq2test{4,1}=[4 15];%S S
Seq2test{5,1}=[18 16 7 4 8 12 14 15];%Y Y Y S S S Y S
Seq2test{6,1}=[1 5 6 15];%Y Y S S
Wellpos=FlyDB(lfly).WellPos;
Seq2test{1,2}=[sqrt(sum((Wellpos(1,:)-Wellpos(5,:)).^2));...
    sqrt(sum((Wellpos(5,:)-Wellpos(6,:)).^2))];
Seq2test{2,2}=[sqrt(sum((Wellpos(7,:)-Wellpos(13,:)).^2));...
    sqrt(sum((Wellpos(9,:)-Wellpos(13,:)).^2))];
Seq2test{3,2}=sqrt(sum((Wellpos(11,:)-Wellpos(16,:)).^2));
Seq2test{4,2}=sqrt(sum((Wellpos(4,:)-Wellpos(15,:)).^2));
Seq2test{5,2}=[sqrt(sum((Wellpos(18,:)-Wellpos(16,:)).^2));...
    sqrt(sum((Wellpos(16,:)-Wellpos(7,:)).^2));...
    sqrt(sum((Wellpos(7,:)-Wellpos(4,:)).^2));...
    sqrt(sum((Wellpos(4,:)-Wellpos(8,:)).^2));...
    sqrt(sum((Wellpos(8,:)-Wellpos(12,:)).^2));...
    sqrt(sum((Wellpos(12,:)-Wellpos(14,:)).^2));...
    sqrt(sum((Wellpos(15,:)-Wellpos(14,:)).^2))];
Seq2test{6,2}=[sqrt(sum((Wellpos(1,:)-Wellpos(5,:)).^2));...
    sqrt(sum((Wellpos(5,:)-Wellpos(6,:)).^2));...
    sqrt(sum((Wellpos(6,:)-Wellpos(15,:)).^2))];
Seq2test{2,3}=sqrt(sum((Wellpos(7,:)-Wellpos(9,:)).^2));
Seq2test{5,3}=[sqrt(sum((Wellpos(7,:)-Wellpos(14,:)).^2));...
    sqrt(sum((Wellpos(12,:)-Wellpos(15,:)).^2))];
%%
Wellpos=FlyDB(lfly).WellPos;
for lrange=1:size(Seq2test,1)
    display(['%%%% CASE: ' num2str(lrange) ' %%%%'])
    DurInV_Segm=[nan(size(Seq2test{lrange,1},2),3) Seq2test{lrange,1}'];
    for lsubs=1:2
        display(['---- ' num2str(lsubs) ' -----'])
        SpotNumbers=find(FlyDB(lfly).Geometry==lsubs);
        V_Num_log=ismember(DurInV_Segm(:,4)', SpotNumbers);
        V_Num=DurInV_Segm(V_Num_log,4);%Numbers of spots visited
        %% Y-Y or S-S Spot distance
        display('Y-Y or S-S dist')
        if size(V_Num,1)>1 %If there are at least two visits
            distspots_temp=nan(size(V_Num,1)-1,1);
            for lspot=1:size(V_Num,1)-1
                distspots_temp(lspot)=sqrt(sum((Wellpos(V_Num(lspot+1),:)-...
                    Wellpos(V_Num(lspot),:)).^2));
                
            end
            
            distspots_temp
        else
            nan
        end
        %% YS-Y or SS-S Spot distance
        display('YS-Y or YS-S dist')
        DurInVidx=find(V_Num_log);%Indexes of spots in Segment vector
        if ~isempty(DurInVidx)
            %%% If the first of the analysed spot is not the first visit
            if (DurInVidx(1)>=2) || ((DurInVidx(1)==1)&&size(V_Num,1)>1)
                if DurInVidx(1)>=2 %When there are visits before
                    V_Numidx=1:size(V_Num,1);
                else % When is the first visit, start from the second
                    V_Numidx=2:size(V_Num,1);
                end
                
                distspots_temp=nan(size(V_Numidx,2),1);
                for lspot=V_Numidx
                    prev_spot=DurInV_Segm(DurInVidx(lspot)-1,4);
                    distspots_temp(lspot==V_Numidx)=sqrt(sum((Wellpos(V_Num(lspot),:)-...
                        Wellpos(prev_spot,:)).^2));
                    
                end
                distspots_temp
            else
                nan
            end
        else
            nan
        end
    end
end