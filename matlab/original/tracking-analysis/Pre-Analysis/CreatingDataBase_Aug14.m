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

% from=419;until=442;% EXP 9A%from=198;until=227;%EXP4Afrom=80;until=127;%EXP3A  from=368;until=391;%EXP8A 
% [~,Allfilenames]=xlsread(Vid_info_dir,'Tracking',['A' num2str(from) ':A' num2str(until)]);

Geometry_ALL = xlsread(Vid_info_dir,'Experiment Info',['K' num2str(from) ':AC' num2str(until)]);
Concentrations_ALL = xlsread(Vid_info_dir,'Experiment Info',['AD' num2str(from) ':AV' num2str(until)]);
MetabState_ALL = xlsread(Vid_info_dir,'Experiment Info',['E' num2str(from) ':E' num2str(until)]);
Sex_ALL = xlsread(Vid_info_dir,'Experiment Info',['G' num2str(from) ':G' num2str(until)]);
Mating_ALL = xlsread(Vid_info_dir,'Experiment Info',['H' num2str(from) ':H' num2str(until)]);
Genotype_ALL=xlsread(Vid_info_dir,'Experiment Info',['D' num2str(from) ':D' num2str(until)]);
    
% Movies_idx=find(Toprocess==1)';%
%% Definining Quality constraints %%
QualityMeasureCentroids=0.1; % Max percentage allowed of missing frames.
Fliespervideo=3;

%%% Initialising Structure with size=length(filenames)%%%

FlyDB=struct('Filename',[],'Arena',cell(1,length(Movies_idx)),'Genotype',[],...
    'MetabState',[],'Mating',[],'Sex',[],'Geometry',[],'Concentrations',[],...
    'BodyCentroids',[],'WellPos',[],'SetUpNumber',[]);
% load(['C:\Users\Vero\Documents\Analysis Data\Experiment 2\FlyDataBase 27-Sep-2012.mat'],'FlyDataBase')

filecounter=1;
for filenumber=Movies_idx%1:length(filenames)
    filename=Allfilenames{filenumber} % Remember this Index of file inside filenames is also used when evaluating quality constraints.
    
    %% FOOD WELL POSITIONS & INFORMATION FROM EXCEL SPREADSHEET %%

    Geometry = Geometry_ALL(filenumber,:);
    Concentrations = Concentrations_ALL(filenumber,:);
    MetabState = MetabState_ALL(filenumber,:);
    Sex = Sex_ALL(filenumber,:);
    Mating = Mating_ALL(filenumber,:);
    Genotype= Genotype_ALL(filenumber,:);
    load([Heads_SteplengthDir 'DB-Heads ' filename(1:end-4) '.mat'])
    for arenaside=1:3
        
    %%% Evaluating quality constraints %%%
        if ((sum(sum(isnan(DB(arenaside).hBon))))/(size(DB(arenaside).hBon,1)*2))<QualityMeasureCentroids 
            FlyDB(3*filecounter+arenaside-3).Filename=filename; 
            FlyDB(3*filecounter+arenaside-3).Arena=arenaside;
            FlyDB(3*filecounter+arenaside-3).Genotype=Genotype;
            FlyDB(3*filecounter+arenaside-3).MetabState=MetabState;
            FlyDB(3*filecounter+arenaside-3).Mating=Mating;
            FlyDB(3*filecounter+arenaside-3).Sex=Sex;
            FlyDB(3*filecounter+arenaside-3).Geometry=Geometry;
            FlyDB(3*filecounter+arenaside-3).Concentrations=Concentrations;
        else 
            display('DID NOT MEET QUALITY CRITERIA!')
        end
    end
filecounter=filecounter+1;
end
%%
save([DataSaving_dir_temp Exp_num '\Variables\FlyDataBase' Exp_num ' ' date '.mat'],'FlyDB','Allfilenames')
display(length(Allfilenames))
display(length([FlyDB.MetabState]))
%% NOTE on how to use FlyDataBase array %%
% Remember that [FlyDataBase.bla], will concatenate bla vectors
% horizontally, meaning adding the next in a new column. Therefore, if I
% want to sum all values of all flies, I should store vectors as
% row-vectors. If I want the mean of a vector for all flies, I concatenate
% the column vectors, and then apply mean on the second dimension.

%%
% for filenumber=1:length(filenames)
%     filename=filenames{filenumber};
% 
% for arenaside=1:3
%     if Percentage_TotalMissing(filenumber,2*arenaside)>QualityMeasureCentroids
%         display(filename)
%         display(arenaside)
%         display(filenumber)
%         display(Percentage_TotalMissing(filenumber,2*arenaside))
%         display(3*filenumber+arenaside-3)
%         
%     end
% end
% end

%% Getting value from users
% for lfly=1:length(FlyDB4)
%     HF=input([FlyDB4(lfly).Filename '-arena' num2str(FlyDB4(lfly).Arena) ': HF?']);
%     FlyDB4(lfly).HeadFixed=HF;
%     display(FlyDB4(lfly))
%     pause
% end
%% Finding a particular video in the database
% filename='0003A01R02Cam04P0WT-CantonS.avi';
% logical=cellfun(@(x)~isempty(strfind(x,filename)),{FlyDB.Filename},'uniformoutput',false);
% Database_number=find(cell2mat(logical))

