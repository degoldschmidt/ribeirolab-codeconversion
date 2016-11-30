%% Merge Data from Mated Yaa 8B into the 6A DataBase
% FlyDB3B=FlyDB(params.ConditionIndex==4);
% 
% Heads_Sm3B=Heads_Sm(params.ConditionIndex==4);
% Tails_Sm3B=Tails_Sm(params.ConditionIndex==4);
% Centroids_Sm3B=Centroids_Sm(params.ConditionIndex==4);
% Steplength_Sm180_h3B=Steplength_Sm180_h(params.ConditionIndex==4);
% Steplength_Sm_c3B=Steplength_Sm_c(params.ConditionIndex==4);
% Steplength_Sm_h3B=Steplength_Sm_h(params.ConditionIndex==4);
% Etho_Speed3B=Etho_Speed(params.ConditionIndex==4);
% Walking_vec3B=Walking_vec(params.ConditionIndex==4);
% InSpot3B=InSpot(:,params.ConditionIndex==4);
% save([Variablesfolder 'OnlyMYaa' Exp_num Exp_letter ' ' date '.mat'],'FlyDB3B','Heads_Sm3B','Tails_Sm3B',...
%     'Centroids_Sm3B','Steplength_Sm180_h3B','Steplength_Sm_c3B','Steplength_Sm_h3B','Etho_Speed3B','Walking_vec3B','InSpot3B','-v7.3')

% load('E:\Analysis Data\Experiment 0008\Variables\OnlyMYaa0008B 30-Nov-2015.mat')
% 
% FlyDB(60:70)=FlyDB3B;
% Heads_Sm(60:70)=Heads_Sm3B;
% Tails_Sm(60:70)=Tails_Sm3B;
% Centroids_Sm(60:70)=Centroids_Sm3B;
% Steplength_Sm180_h(60:70)=Steplength_Sm180_h3B;
% Steplength_Sm_c(60:70)=Steplength_Sm_c3B;
% Steplength_Sm_h(60:70)=Steplength_Sm_h3B;
% Etho_Speed(60:70)=Etho_Speed3B;
% Walking_vec(60:70)=Walking_vec3B;
% InSpot=InSpot(1:351070,:);
% InSpot(:,60:70)=InSpot3B;
% 
% for lfly=1:length(FlyDB)
%     lfly
%     FlyDB(lfly).Filename=[FlyDB(lfly).Filename '0006B'];
% end
% 
% 
% Exp_num='0006';
% Exp_letter='B';
% save([Variablesfolder 'FlyDataBase' Exp_num Exp_letter ' ' date '.mat'],'FlyDB')
% save([Variablesfolder 'Centroids&Heads_GaussSm' Exp_num Exp_letter ' ' date '.mat'],'Heads_Sm','Tails_Sm','Centroids_Sm','-v7.3')
% save([Variablesfolder 'Steplength_GaussSmoothed' Exp_num Exp_letter ' ' date '.mat'],'Steplength_Sm180_h','Steplength_Sm_c','Steplength_Sm_h','-v7.3')
% save([Variablesfolder 'Micromov&WalkingVecSm180_' Exp_num Exp_letter ' ' date '.mat'],'Walking_vec','Etho_Speed','-v7.3')
% save([Variablesfolder 'Inspot' Exp_num Exp_letter ' ' date '.mat'],'InSpot','-v7.3')
