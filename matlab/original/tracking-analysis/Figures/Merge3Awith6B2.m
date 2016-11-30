%% Merge Data from 3A with 6B DataBase
DB1='0003A';
Exp_num_DB2='0006'; Exp_letter_DB2='B';
Exp_num_new='0003';
Exp_letter_new='D';
FilenameDB2='OnlyMVYaa';
CondtomergeDB2=[3 4];%Mated and Virgin Yaa
%% To run when data from DB2=6B is loaded
% logi_temp=params.ConditionIndex==CondtomergeDB2(1);
% if length(CondtomergeDB2)>1
%     for lcond=CondtomergeDB2(2:end)
%         logi_temp=or(logi_temp,params.ConditionIndex==lcond);
%     end
% end
% FlyDB2=FlyDB(logi_temp);
% H=Heads_Sm(logi_temp);
% T=Tails_Sm(logi_temp);
% C=Centroids_Sm(logi_temp);
% S180=Steplength_Sm180_h(logi_temp);
% Sc=Steplength_Sm_c(logi_temp);
% Sh=Steplength_Sm_h(logi_temp);
% Etho_Speed2=Etho_Speed(logi_temp);
% Walking_vec2=Walking_vec(logi_temp);
% InSpot2=InSpot(:,logi_temp);
% save([Variablesfolder FilenameDB2 Exp_num_DB2 Exp_letter_DB2 ' ' date '.mat'],'FlyDB2','H','T',...
%     'C','S180','Sc','Sh','Etho_Speed2','Walking_vec2','InSpot2','-v7.3')
%% To run when data from DB1=3A is loaded
% load(['E:\Analysis Data\Experiment ' Exp_num_DB2 '\Variables\' FilenameDB2 Exp_num_DB2 Exp_letter_DB2 ' ' date '.mat'])
lastfly1=length(FlyDB);
numfliesDB2=length(FlyDB2);
names=fieldnames(FlyDB);
for lname=1:length(names)
    if ~isfield(FlyDB2,names{lname})
        
        [FlyDB2(:).(names{lname})]=deal([]);
    end
end

FlyDB(lastfly1+1:lastfly1+numfliesDB2)=FlyDB2;
Heads_Sm(lastfly1+1:lastfly1+numfliesDB2)=H;
Tails_Sm(lastfly1+1:lastfly1+numfliesDB2)=T;
Centroids_Sm(lastfly1+1:lastfly1+numfliesDB2)=C;
Steplength_Sm180_h(lastfly1+1:lastfly1+numfliesDB2)=S180;
Steplength_Sm_c(lastfly1+1:lastfly1+numfliesDB2)=Sc;
Steplength_Sm_h(lastfly1+1:lastfly1+numfliesDB2)=Sh;
Etho_Speed(lastfly1+1:lastfly1+numfliesDB2)=Etho_Speed2;
Walking_vec(lastfly1+1:lastfly1+numfliesDB2)=Walking_vec2;
maxframeDB1=size(InSpot,1);maxframeDB2=size(InSpot2,1);
maxnewframe=min(maxframeDB1,maxframeDB2);
InSpot=InSpot(1:maxnewframe,:);
InSpot(:,lastfly1+1:lastfly1+numfliesDB2)=InSpot2;

for lfly=1:length(FlyDB)
    lfly
    FlyDB(lfly).Filename=[FlyDB(lfly).Filename Exp_num_new Exp_letter_new];
end


save([Variablesfolder 'FlyDataBase' Exp_num_new Exp_letter_new ' ' date '.mat'],'FlyDB')
save([Variablesfolder 'Centroids&Heads_GaussSm' Exp_num_new Exp_letter_new ' ' date '.mat'],'Heads_Sm','Tails_Sm','Centroids_Sm','-v7.3')
save([Variablesfolder 'Steplength_GaussSmoothed' Exp_num_new Exp_letter_new ' ' date '.mat'],'Steplength_Sm180_h','Steplength_Sm_c','Steplength_Sm_h','-v7.3')
save([Variablesfolder 'Micromov&WalkingVecSm180_' Exp_num_new Exp_letter_new ' ' date '.mat'],'Walking_vec','Etho_Speed','-v7.3')
save([Variablesfolder 'Inspot' Exp_num_new Exp_letter_new ' ' date '.mat'],'InSpot','-v7.3')
