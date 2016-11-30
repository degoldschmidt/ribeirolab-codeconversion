%% Creating Database %%
%%% IMPORTANT: Create the database in the same date that the Report
%%% Summary, to know

%%% One DataBase is created for each experiment.

% Report Summary for EXP4: Report Summary-17-Aug-2013.mat
% Report summary for EXP3AR01-04,3BR01-R05: Report Summary-09-Jan-2013.mat,
% Report summary for EXP3AR01-02,3BR01-03: Report Summary-18-Nov-2012.mat
% Report summary for EXP3A: Report Summary-09-Oct-2012.mat
% Report summary for EXP2: Report Summary-27-Aug-2012.mat

% DataBase EXP4, FlyDataBase4 20-Aug-2013.mat
% DataBase EXP3AR01-04,3BR01-R05: FlyDataBase3 09-Jan-2013.mat
% DataBase EXP3AR01-02,3BR01-03: FlyDataBase 12-Dec-2012.mat
% DataBase EXP2: FlyDataBase 27-Sep-2012.mat
% DataBase EXP3A,B: FlyDataBase 18-Oct-2012.mat


% close all 
% clear all
% clc
% dir2save='C:\Users\Vero\Documents\Analysis Data\Experiment 5\';
% Vid_info_dir='C:\Users\Vero\Dropbox\Personal\Experiments Videos Info.xlsx';

load([dir2save Report])% Use the same used in creation of DataBase
[~,Allfilenames]=xlsread(Vid_info_dir,'Tracking',['A' num2str(from) ':A' num2str(until)]);

Geometry_ALL = xlsread(Vid_info_dir,'Experiment Info',['K' num2str(from) ':AC' num2str(until)]);
Concentrations_ALL = xlsread(Vid_info_dir,'Experiment Info',['AD' num2str(from) ':AV' num2str(until)]);
MetabState_ALL = xlsread(Vid_info_dir,'Experiment Info',['E' num2str(from) ':E' num2str(until)]);
Sex_ALL = xlsread(Vid_info_dir,'Experiment Info',['G' num2str(from) ':G' num2str(until)]);
Mating_ALL = xlsread(Vid_info_dir,'Experiment Info',['H' num2str(from) ':H' num2str(until)]);
Genotype_ALL=xlsread(Vid_info_dir,'Experiment Info',['D' num2str(from) ':D' num2str(until)]);
    

%% Definining Quality constraints %%
QualityMeasureCentroids=0.5; % Max percentage allowed of missing frames.
MinimalDuration=357000; % Minimal length of video = 119 min.
Fliespervideo=3;

%%% Initialising Structure with size=length(filenames)%%%

FlyDB4=struct('Filename',[],'Arena',cell(1,length(filenames)),'Genotype',[],...
    'MetabState',[],'Mating',[],'Sex',[],'Geometry',[],'Concentrations',[],...
    'BodyCentroids',[],'WellPos',[],'SetUpNumber',[]);
% load(['C:\Users\Vero\Documents\Analysis Data\Experiment 2\FlyDataBase 27-Sep-2012.mat'],'FlyDataBase')


for filenumber=1:length(filenames)
    file=filenames{filenumber} % Remember this Index of file inside filenames is also used when evaluating quality constraints.
    
    load([dir2save '\Centroids\Centroids-' file(1:end-4) '.mat'])
    nFrames=nFramesforall(filenumber);


    %% FOOD WELL POSITIONS & INFORMATION FROM EXCEL SPREADSHEET %%

    filerow=find(ismember(Allfilenames,file)==1);

    Geometry = Geometry_ALL(filerow,:);
    Concentrations = Concentrations_ALL(filerow,:);
    MetabState = MetabState_ALL(filerow,:);
    Sex = Sex_ALL(filerow,:);
    Mating = Mating_ALL(filerow,:);
    Genotype= Genotype_ALL(filerow,:);
    
    for arenaside=1:3
    %%% Evaluating quality constraints %%%
        if Percentage_TotalMissing(filenumber,2*arenaside)<=QualityMeasureCentroids %&& nFrames>=MinimalDuration
            FlyDB4(3*filenumber+arenaside-3).Filename=file; 
            FlyDB4(3*filenumber+arenaside-3).Arena=arenaside;
            FlyDB4(3*filenumber+arenaside-3).Genotype=Genotype;
            FlyDB4(3*filenumber+arenaside-3).MetabState=MetabState;
            FlyDB4(3*filenumber+arenaside-3).Mating=Mating;
            FlyDB4(3*filenumber+arenaside-3).Sex=Sex;
            FlyDB4(3*filenumber+arenaside-3).Geometry=Geometry;
            FlyDB4(3*filenumber+arenaside-3).Concentrations=Concentrations;
            FlyDB4(3*filenumber+arenaside-3).BodyCentroids=[CentroidsBody(1:end,2*arenaside-1)-Center(arenaside,1),...
                Center(arenaside,2)-CentroidsBody(1:end,2*arenaside)]; %Cartesian Coordinates, Origin in (0,0), units: pixels.
            FlyDB4(3*filenumber+arenaside-3).WellPos=[wellpos(:,2*arenaside-1),-wellpos(:,2*arenaside)]; %Cartesian Coordinates, Origin in (0,0), units: pixels.
            FlyDB4(3*filenumber+arenaside-3).SetUpNumber=str2num(file(15));
        end
    end

end
%%
save([dir2save 'FlyDataBase4 ' date '.mat'],'FlyDB4','filenames')
display(length(Allfilenames))
display(length([FlyDB4.MetabState]))
%% NOTE on how to use FlyDataBase array %%
% Remember that [FlyDataBase.bla], will concatenate bla vectors
% horizontally, meaning adding the next in a new column. Therefore, if I
% want to sum all values of all flies, I should store vectors as
% row-vectors. If I want the mean of a vector for all flies, I concatenate
% the column vectors, and then apply mean on the second dimension.

%%
for filenumber=1:length(filenames)
    file=filenames{filenumber};

for arenaside=1:3
    if Percentage_TotalMissing(filenumber,2*arenaside)>QualityMeasureCentroids
        display(file)
        display(arenaside)
        display(filenumber)
        display(Percentage_TotalMissing(filenumber,2*arenaside))
        display(3*filenumber+arenaside-3)
        
    end
end
end

%% Getting value from users
% for lfly=1:length(FlyDB4)
%     HF=input([FlyDB4(lfly).Filename '-arena' num2str(FlyDB4(lfly).Arena) ': HF?']);
%     FlyDB4(lfly).HeadFixed=HF;
%     display(FlyDB4(lfly))
%     pause
% end
%% Finding a particular video in the database
% filename='0003A01R02Cam04P0WT-CantonS.avi';
logical=cellfun(@(x)~isempty(strfind(x,filename)),{FlyDB.Filename},'uniformoutput',false);
Database_number=find(cell2mat(logical))

%% February 27th, 2014:
CentroidsPath='C:\Users\Vero\Documents\Analysis Data\Experiment 4\Centroids\';
Heads_SteplengthDir='C:\Users\Vero\Documents\Analysis Data\Experiment 3\Heads_Steplength\';
DataSaving_dir_temp='C:\Users\Vero\Documents\Analysis Data\Experiment ';
load([DataSaving_dir_temp '4\FlyDataBase4 05-Sept-2013.mat'])%FlyDataBaseAll3 13-Mar-2014.mat'])%FlyDataBase3 21-Feb-2013.mat'])
FlyDB=rmfield(FlyDB,'BodyCentroids');
Filenames={FlyDB.Filename};
logicComp1=cell2mat(cellfun(@(x)~isempty(strfind(x,'4A')),Filenames,'uniformoutput',false));
IndexAnalyse_DB=find(logicComp1);

FlyDB_new=struct('Filename',[],'Arena',cell(1,length(IndexAnalyse_DB)),'Genotype',[],...
    'MetabState',[],'Mating',[],'Sex',[],'Geometry',[],'Concentrations',[],...
    'WellPos',[],'SetUpNumber',[]);

Centroids=cell(size(IndexAnalyse_DB,2),1);
Heads=cell(size(IndexAnalyse_DB,2),1);
Tails=cell(size(IndexAnalyse_DB,2),1);
Heading_WalkDir=cell(size(IndexAnalyse_DB,2),1);
Vel_Gamma=cell(size(IndexAnalyse_DB,2),1);

flycounter=1;
for filenumber=IndexAnalyse_DB
    filenumber
    filename=FlyDB(filenumber).Filename;
    load([CentroidsPath 'Centroids-' filename(1:end-4) '.mat'],'Center')
    load([Heads_SteplengthDir 'DB-Heads ' filename(1:end-4) '.mat'],'DB')
    
    arenaside=FlyDB(filenumber).Arena;
    FlyDB_new(flycounter).Filename=filename; 
    FlyDB_new(flycounter).Arena=arenaside;
    FlyDB_new(flycounter).Genotype=FlyDB(filenumber).Genotype;
    FlyDB_new(flycounter).MetabState=FlyDB(filenumber).MetabState;
    FlyDB_new(flycounter).Mating=FlyDB(filenumber).Mating;
    FlyDB_new(flycounter).Sex=FlyDB(filenumber).Sex;
    FlyDB_new(flycounter).Geometry=FlyDB(filenumber).Geometry;
    FlyDB_new(flycounter).Concentrations=FlyDB(filenumber).Concentrations;
    FlyDB_new(flycounter).WellPos=FlyDB(filenumber).WellPos; %Cartesian Coordinates, Origin in (0,0), units: pixels.
    FlyDB_new(flycounter).SetUpNumber=FlyDB(filenumber).SetUpNumber;
    
    %% Creating Body Centroids Cell array
    Centroids{flycounter}=[DB(arenaside).cBon(:,1)-Center(arenaside,1),...
        Center(arenaside,2)-DB(arenaside).cBon(:,2)]; %Cartesian Coordinates, Origin in (0,0), units: pixels.;
    Heads{flycounter}=[DB(arenaside).hBon(:,1)-Center(arenaside,1),...
        Center(arenaside,2)-DB(arenaside).hBon(:,2)];
    Tails{flycounter}=[DB(arenaside).tBon(:,1)-Center(arenaside,1),...
        Center(arenaside,2)-DB(arenaside).tBon(:,2)];
    Heading_WalkDir{flycounter}=[DB(arenaside).Heading(1:end-1),DB(arenaside).WalkDir];
    Vel_Gamma=[DB(arenaside).Steplength(1:end-1)...
        CircleDiff(DB(arenaside).WalkDir(1:end-1),DB(arenaside).WalkDir(2:end))];
    flycounter=flycounter+1;
end
%%
FlyDB=FlyDB_new;
save([DataSaving_dir_temp '4\Variables\A\Centroids&Heads 13-Mar-2014.mat'],...
    'Centroids','Heads','Tails','-v7.3');
save([DataSaving_dir_temp '4\Variables\A\FlyDataBasea4A 13-Mar-2014.mat'],'FlyDB','-v7.3');
%% Saving Area  
Area=cell(size(flies_idx,2),1);
flycounter=1;
for filenumber=flies_idx
    filenumber
    filename=FlyDB(filenumber).Filename;
    log_filename=cell2mat(cellfun(@(x)~isempty(strfind(x,filename)),Allfilenames,'uniformoutput',false));
    if MATLAB2Bonsai(log_filename)~=1
        %% Getting Bonsai tracking data
        fileID=fopen([TrackDataDir_Bonsai filename(1:end-4) '.csv']);
        C=textscan(fileID,...
            '%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f');
        % C={Xl, Yl, Orientationl, MajAxl, MinAxl, Areal,...
        %     Xc, Yc, Orc, MajAxc, MinAxc, Areac,...
        %     Xr, Yr, Orr, MajAxr, MinAxr, Arear};%Orientation in rads
        Cmat=cell2mat(C);
    else
        %% Getting MATLAB tracking data
        for arenaside=1:3
            load([TrackDataDir_Bonsai 'TrackingBonsaiParams-'...
                filename(1:end-4) '-' sidelabel{arenaside} '.mat']);
        end
        
        Cmat=[FlytracksNewL FlytracksNewC FlytracksNewR];%[xc yc or MajAx MinAx A];
        
        
        clear FlytracksNewL FlytracksNewC FlytracksNewR
    end
        
    arenaside=FlyDB(filenumber).Arena;
       
    %% Creating Body Centroids Cell array
    Area{flycounter}=Cmat(:,6*arenaside);
    
    flycounter=flycounter+1;
end