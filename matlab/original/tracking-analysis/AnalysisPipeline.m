%% Analysis Pipeline
%%%%% Script created February 27th, 2014 by Veronica Corrales
% INDEX:
% %% Loading variables
% %% Defining useful constant parameters for the analysis
% %% Defining flies to analyse (IndexAnalyse)
% %% Definning Conditions Structure: CondIndex = #cols*row_n - #cols + col_n
% %% LABELS
% %% Smoothing trajectories
% %% Plotting trajectories
% %% Time spent per unit of area (time density) - Definning nutrient radius
% %% Heading vector
% %% Activity
% %% Edge Activity
% %% 2D Histograms
% %% Nutrient Bouts
%% Extracting info from FlyDataBase
clear all
close all
clc
format compact
beep off

%% User inputs: Experiment, Folders and Features for conditions
Exp_num='0003'; Exp_letter='D';
params.Features4Cond={'Mating';'Metabolic'};%;'Genotype' {Col, Row, Pages} {'Genotype';'Metabolic'};%{'Metabolic'};%
%%% Note that: Feature_names={'Arena';'Genotype';'Metabolic';'Mating';'Sex';...
%%% 'Substrates';'Concentrations';'Sensory'};

Comp=3;%6 is home, 3 is CCU open lab, 2 is behavior room
if Comp==3
    DataSaving_dir_temp='E:\Analysis Data\Experiment ';
    Dropbox_choicestrategies='E:\Dropbox (Behavior&Metabolism)\choice strategies\Plots\Exp ';
elseif Comp==6
    DataSaving_dir_temp='D:\Analysis Data\Experiment ';
    Dropbox_choicestrategies='D:\Dropbox (Behavior&Metabolism)\choice strategies\Plots\Exp ';
elseif Comp==2
    DataSaving_dir_temp='C:\Users\Vero\Documents\Analysis Data\Experiment ';
    Dropbox_choicestrategies='C:\Users\Vero\Dropbox (Behavior&Metabolism)\choice strategies\Plots\Exp ';
end

%% Loading Variables for experiment
Variablesfolder=[DataSaving_dir_temp Exp_num '\Variables\'];
Variablesnames={...
    strcat('FlyDataBase',Exp_num,Exp_letter,'*.mat');...1
    strcat('LabelsDataBase',Exp_num,Exp_letter,'*.mat');...2
    strcat('Centroids&Heads_GaussSm',Exp_num,Exp_letter,'*.mat');...3
    strcat('Steplength_GaussSmoothed',Exp_num,Exp_letter,'*.mat');...4
    strcat('Micromov&WalkingVecSm180_',Exp_num,Exp_letter,'*.mat');...5
    strcat('Inspot',Exp_num,Exp_letter,'*.mat');...6
    strcat('HeadBouts&CumulativeTimeH&EthoH',Exp_num,Exp_letter,'*.mat');...7
    strcat('Visits&CumulativeTimeV5mm',Exp_num,Exp_letter,'*.mat');...8
    strcat('Ethogram',Exp_num,Exp_letter,'*.mat');...9
    strcat('Time_Density',Exp_num,Exp_letter,'*.mat');...10
    strcat('RawMjAxes_',Exp_num, Exp_letter,'*.mat');...11
    strcat('OverlappingBubbles&CumulativeTime',Exp_num, Exp_letter,'*.mat');...12
    };
varstoload=[1:8]% 5 6 7 8];%1:length(Variablesnames);%
for lvarname=varstoload
    Latest_file=getlatestfile(Variablesfolder,Variablesnames{lvarname})
    load(strcat(Variablesfolder,Latest_file))
end
%% Defining useful constant parameters for the analysis
params.scrsz = get(0,'ScreenSize');
params.framerate=50;
params.px2mm=1/6.4353; % mm in 1 px
% % % % params.MinimalDuration=345000;% 60 min 345000;%115 min  360000;% Minimal length of video = 120 min.
params.Feedingradious=2.5/params.px2mm;%2.5 mm %19; %In px
params.OuterVicinityRadious=(1.5/params.px2mm)*3.3; %px. Outer limit for vicinity
params.OuterRingRadious=25;%mm /params.px2mm; % px. Line that divides the outer area, and the edge of inner plate
params.Stop_Vel=0.1;%mm/s
params.Microm_Vel=2;%mm/s
params.Walk_Vel=4;%mm/s

%% 
if (~isempty(strfind([Exp_num Exp_letter],'0006A')))||(~isempty(strfind([Exp_num Exp_letter],'0006B')))
    logical_exp=(LabelsDB.Substrates{1}~=3)&(LabelsDB.Substrates{1}~=4);
else
    logical_exp=(LabelsDB.Substrates{1}~=3);
end

params.Subs_Names=LabelsDB.Substrates{2}(logical_exp);%{'Yeast 18%','Sucrose 18%'};%{'Agarose 0.75%'};%
params.Subs_Numbers=LabelsDB.Substrates{1}(logical_exp)';

%%  Defining flies to analyse (IndexAnalyse)
%%% Selecting Specific Feature in Filename (For all, write Experiment #):
%%% Create logical matrixes with the constraints, e.g. 'R03', then merge them
%%% in 'logicalmat' using and()/or() functions.
Filenames={FlyDB.Filename};
logicComp1=cell2mat(cellfun(@(x)~isempty(strfind(x,[Exp_num Exp_letter])),Filenames,'uniformoutput',false));
logicComp2=cell2mat(cellfun(@(x)~isempty(x),Heads_Sm,'uniformoutput',false));
%%% Selecting one particular condition:
% logicComp4=(cell2mat((cellfun(@(x)~isempty(find(x==1|x==2,1)),...
%     {FlyDB(:).Mating},'UniformOutput',false)))); %Mating=1 or 2: ~isempty(find(x==1|x==2,1));
% logicComp5=(cell2mat((cellfun(@(x)~isempty(find(x==2,1)),...
%     {FlyDB(:).MetabState},'UniformOutput',false)))); %Mating=1 or 2;

logicalmat=and(logicComp1,logicComp2');%logicComp1;%or(logicComp2,logicComp3);%and(or(logicComp2,logicComp3),logicComp1);
IndexAnalyse=find(logicalmat);

display(Filenames(IndexAnalyse)')

params.IndexAnalyse=IndexAnalyse;
params.numflies=length(IndexAnalyse);
flies_idx=params.IndexAnalyse;
%% Find fly index for a given video
% filenames_row=find(ismember(Filenames,'0003A01R03Cam03P0WT-CantonS.avi')==1)
maxframe=nan(length(flies_idx),1);
for lfly=flies_idx
    maxframe(lfly)=size(Centroids_Sm{lfly},1);
end
minframes=min(maxframe);
display(['MinimalDuration: ' num2str(minframes/50/60) 'min'])
params.MinimalDuration=minframes-1;
%% Definning Conditions Structure: CondIndex = #cols*row_n - #cols + col_n
[ConditionIndex,Labels_Features4Cond,Labels,LabelsShort] = LABELS(params,FlyDB,LabelsDB,flies_idx);
params.ConditionIndex=ConditionIndex;
Conditions=unique(params.ConditionIndex);

params.Labels=Labels;
params.colLabels=Labels_Features4Cond{1};
params.rowLabels=Labels_Features4Cond{2};
params.pagLabels=Labels_Features4Cond{3};
params.LabelsShort=LabelsShort;
% save([Variablesfolder 'params_' Exp_num Exp_letter ' ' date '.mat'],'params')
%% Defining General info for Dryad
GeneralInfo.framerate=50;
GeneralInfo.px2mm=1/6.4353; % mm in 1 px
GeneralInfo.max_frame=params.MinimalDuration;
GeneralInfo.arena_outer_radius=33/GeneralInfo.px2mm;
GeneralInfo.patch_radius=1.5/GeneralInfo.px2mm;
GeneralInfo.patch_feeding_radius=2.5/GeneralInfo.px2mm;
GeneralInfo.edge_inner_radius=25/GeneralInfo.px2mm;

%% Heading vector
% flies_idx=params.IndexAnalyse;
% [Heading,WalkDir,HeadingDiff,WalkingDirDiff] =...
%             Heading_WalkingDir(Heads_Sm,Tails_Sm,Centroids_Sm);
%% Plotting trajectories
% Plot_Trajectories
%% Time Density and Number of Crosses - Time spent per unit of area (time density) - Defining nutrient radius
% FeedingRadii=[1:0.15:4.8;(1:0.15:4.8)-1];%mm
% % flies_idx=params.IndexAnalyse;
% SubFolder_name='Crossings and Time Density';
% share=0;% Share this plot with Carlos in Dropbox
% % [time_density, num_cross,Intimes]=...
% %     TimeDensity(FlyDB,Heads_Sm,Steplength_Sm_h,FeedingRadii,flies_idx,[1:3],...Conditions
% %         params,SubFolder_name,DataSaving_dir_temp,Exp_num,Exp_letter,share,Dropbox_choicestrategies);

%% Activity
% clear Centroids Heads Tails
% flies_idx=params.IndexAnalyse;

% % Activity % Plots Speed histogram
% % % EdgeActivity

%% 2D Histograms
% flies_idx=params.IndexAnalyse;
% for lparameter=3%[]%5%[]%5%
%    switch lparameter
%        case 1
%         %% Polar Coordinates (ARENA REFERENCE FRAME) 
%         histparams.paramname='Polar';
%         histparams.X_range=-180:2*180/149:180;%0:120/149:120;%0:120/149:120;%-pi:2*pi/149:pi;% %Theta range in degrees
%         histparams.Y_range=0:66/2/149:66/2;%params.OuterRingRadious:(66/2-params.OuterRingRadious)/99:66/2;% Radious range in mm
%         histparams.xlabel='\theta, Angle [º]';%
%         histparams.ylabel='\rho, Radious [mm]';%
%         Steplength = Steplength_fun(Centroids_Sm);
%         Y=cell(length(flies_idx),1);
%         X=cell(length(flies_idx),1);
%         for lfly=flies_idx
%             [Th,R]=cart2pol(Centroids_Sm{lfly}(:,1),Centroids_Sm{lfly}(:,2));
%             log_temp=(Steplength{lfly}*params.px2mm*params.framerate>params.StopVel)&...
%                 (R(1:end-1)>=params.OuterRingRadious/params.px2mm);%Walking flies in the edge
%             X{lfly}=Th(log_temp)/pi*180;
%             Y{lfly}=R(log_temp)*params.px2mm;
%         end
%         
%        case 2 
%         %% Velocity and Gamma: Steplength & Turning Angle (SELF REFERENCE FRAME)
%         histparams.paramname='Vel_G';
%         histparams.X_range=-60:60*2/199:60;%-180:180*2/149:180;% Gamma range in degrees
%         histparams.Y_range=0:(30)/199:30; % Velocity range in mm/s
%         histparams.xlabel='Turning Angle [º]';
%         histparams.ylabel='Speed [mm/s]';
%         
% %         Steplength = Steplength_fun(Centroids);
% %         [Heading,WalkDir,HeadingDiff,WalkingDirDiff] =...
% %             Heading_WalkingDir(Heads_Sm,Tails_Sm,Centroids_Sm);
%         [~,~,~,WalkingDirDiff] =...
%             Heading_WalkingDir(Heads_Sm,Tails_Sm,Centroids_Sm);
% 
%         Y=cell(length(flies_idx),1);
%         X=cell(length(flies_idx),1);
%         for lfly=flies_idx
%             [~,R]=cart2pol(Centroids_Sm{lfly}(1:params.MinimalDuration,1),...
%                 Centroids_Sm{lfly}(1:params.MinimalDuration,2));
%             log_temp=...(Steplength_Sm_h{lfly}(1:end-1)*params.px2mm*params.framerate>params.Walk_Vel)&...
%                 (R(1:end-2)>=params.OuterRingRadious/params.px2mm);%Walking flies in the edge
%             X{lfly}=WalkingDirDiff{lfly}(log_temp);%(1:params.MinimalDuration);%;%;
%             Y{lfly}=Steplength_Sm_c{lfly}(log_temp)*params.px2mm*params.framerate;%(1:params.MinimalDuration)
%         end
%         plotting=2;
%         [VarHist] = hist2D(X,Y,histparams,Conditions,plotting,params);
%        case 3
%         %% Beta and Distance 
%         histparams.paramname='Orientation to Food';
%         histparams.X_range=-180:180/149:180;% Beta range in degrees
%         histparams.Y_range=0:10/149:10;%0:33/149:33;% Distance to Spot range in mm.
%         histparams.xlabel='Orientation to sucrose (º)';
%         histparams.ylabel='Distance from sucrose (mm)';
%         plotting=2;
% %         [Heading,WalkDir,HeadingDiff,WalkingDirDiff] =...
% %     Heading_WalkingDir(Heads_Sm,Tails_Sm,Centroids_Sm);
% %         [VarHistBetaY] = hist2D_Beta_Dist(Heads_Sm,Heading,FlyDB,histparams,Conditions,plotting,params);
%         [VarHistBetaY] = hist2D_Beta_Dist(Heads_Sm,Heading,FlyDB,histparams,Conditions,plotting,params);
%         %%
%         savefig_withname(1,'600','png',DataSaving_dir_temp,Exp_num,Exp_letter,...
%                 'Thesis')
%        case 4        
%         %% Cartesian coordinates
%         histparams.paramname='X_Y p';
%         histparams.X_range=-66/2:66/99:66/2;% Beta range in degrees
%         histparams.Y_range=-66/2:66/99:66/2;% Distance to Spot range in mm.
%         histparams.xlabel='X positions (mm)';
%         histparams.ylabel='Y positions (mm)';
%         figure('Position',[100 50 params.scrsz(3)-750 params.scrsz(4)-150],'Color','w')
%         X=Heads_Sm{119}(1:60000,1)*params.px2mm;
%         Y=Heads_Sm{119}(1:60000,2)*params.px2mm;
%         n= hist3([Y  X],{histparams.Y_range histparams.X_range});
%         Jointfr=n./sum(sum(n));
% 
%     imagesc(histparams.X_range,histparams.Y_range,(Jointfr),[0 8e-4])%);%,);%For VelGamma,clims);% or log(Condfr)) %
%     colorbar
%     font_style([],histparams.xlabel,histparams.ylabel,'bold','calibri',30)
%     set(gca,'YDir','normal')
%      axis([xlim_ ylim_])
%         case 5
%         %% Velocity and Distance from Yeast Spots
%         %%% Remember to change f_spot inside hist2D_Dist function and the
%         %%% logical vector that selects the conditions to be evaluated
%         %%% (line 49)
%         histparams.paramname='Vel_Dist';
%         histparams.X_range=0:4.8/59:4.8;%0:4.8/149:4.8;% Distance to Spot range in mm.
%         histparams.Y_range=0:(2)/99:2;%0:(4)/99:4;%4:(25-4)/149:25; %0:25/149:25;%  Velocity range in mm/s
%         histparams.ylabel='Speed [mm/s]';
%         histparams.Substrate=1;
%         histparams.xlabel=['Distance from ',...
%             LabelsDB.Substrates{2}{LabelsDB.Substrates{1}==histparams.Substrate} ' spots (mm)'];
%         
% %         Steplength = Steplength_fun(Heads_Sm);
%         Y=cell(length(flies_idx),1);
%         for lfly=flies_idx
%             Y{lfly}=Steplength_Sm_h{lfly}*params.px2mm*params.framerate;
%         end
%         plotting=3;
%         [VarHistY] = hist2D_Vel_Dist(Heads_Sm,Y,FlyDB,histparams,Conditions,plotting,params);
%         case 6
%         %% Area and Distance from Yeast Spots
%         %%% Remember to change f_spot inside hist2D_Dist function and the
%         %%% logical vector that selects the conditions to be evaluated
%         %%% (line 49)
%         histparams.paramname='Area_Dist';
%         histparams.X_range=0:4.8/99:4.8;%0:4.8/149:4.8;% Distance to Spot range in mm.
%         histparams.Y_range=-10:1:10;%4:(25-4)/149:25; %0:25/149:25;%  Velocity range in mm/s
%         histparams.ylabel='Area [px]';
%         histparams.xlabel='Distance from Yeast spots (mm)';
% %         Y=cell(length(flies_idx),1);
% %         for lfly=flies_idx
% %             Y{lfly}=diff(Area{lfly});
% %         end
%         plotting=2;
%         [VarHistY] = hist2D_Dist(Heads_Sm,Y,FlyDB,histparams,Conditions,plotting,params);
%    end
% % %%
%             
% end
%% Nutrient-Activity Bouts
% NutrientBouts

%% Ethogram
% Ethogram
%% Clustering Flies
% Clustering_flies
% SpeedOutsideVisits
%% Modelling
% HMM_flies
%% Figures
% Fig1_PlottingTraj_KinemParams
% Fig3A_TrajectoryandParamsVisit
% Fig2B_Composition_of_visits_merged
% Fig2C_Area_coverage_2DHist
% Fig3_Plot_TimeSegments
%% Time Segment Analysis (Population dynamics)
% Plot_TimeSegments_Allflies
% Plot_TimeSegments_Allflies_Radii
% Fig3_Plot_TimeSegments
% Plot_TimeSegments_2
%% Correlation with Time of the Day
%%% Add Time of the day into the FlyDB:
% TimeofDay_saveDB
%%% Plot ethogram with Time of the day and correlations with Speed
% TimeofDay
%% Macrostructure
% Macrostructure
%% Extracting information from Annotated Events (Feeding, Walking, Grooming, etc)
% Plot_tracks_from_annotated_events
%% Lag phase
% Lagphase
%% saving
% subfolder='Thesis';
% savefig_withname(1,'600','png',DataSaving_dir_temp,Exp_num,Exp_letter,...
%     subfolder)
%%
% savefig_withname(0,'600','eps',DataSaving_dir_temp,Exp_num,Exp_letter,...
%     subfolder)