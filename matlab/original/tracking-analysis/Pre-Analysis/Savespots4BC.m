%%
% load([DataSaving_dir_temp Exp_num '\FlyDataBase4 05-Sept-2013.mat'],'FlyDB')%,'remove'
% load([DataSaving_dir_temp Exp_num '\Variables\FlyDataBase8A 25-Sep-2014.mat'],'FlyDB')
% load([DataSaving_dir_temp Exp_num '\Variables\FlyDataBaseAll3 13-Mar-2014.mat'])
% load([DataSaving_dir_temp Exp_num '\Variables\FlyDataBase0003 13-Mar-2014.mat'])
load([DataSaving_dir_temp Exp_num '\Variables\A\FlyDataBasea4A 13-Mar-2014.mat'])
FlyDBold=FlyDB;

load([DataSaving_dir_temp Exp_num '\Variables\FlyDataBase',...
            Exp_num Exp_letter ' ' date '.mat'])

%%
lflycounter=1;
for lfile=Spot_File_idx%Movies_idx
    filename=Allfilenames{lfile};%'0011A01R01Cam02P0CantonSTbH.avi';%'0004C02R01Cam04P0WT-CantonS.avi';%
    log_filename_temp=cellfun(@(x)~isempty(strfind(x,filename)),{FlyDB.Filename},'uniformoutput',false);
    Database_numbers=find(cell2mat(log_filename_temp));
    Database_arenas=[FlyDB(Database_numbers).Arena];
    display(['lfile: ' num2str(lfile) ' - ' filename])
       
    %% Save well positions of old DataBase in new one
    log_filename=cellfun(@(x)~isempty(strfind(x,filename)),{FlyDBold.Filename},'uniformoutput',false);
    OldDatabase_numbers=find(cell2mat(log_filename));
    OldDBArenas=[FlyDBold(OldDatabase_numbers).Arena];
    
    %% For remove index
    log_filename_temp=cellfun(@(x)~isempty(strfind(x,filename)),Allfilenames(DB_idx),'uniformoutput',false);
    removefilecounter=find(cell2mat(log_filename_temp));
    
    
    for larena=Database_arenas
        if ismember(larena,OldDBArenas)==0
            %% Remove entry in new DB when missing in the old
            remove(3*removefilecounter+larena-3)=1;
            FlyDB(Database_numbers(Database_arenas==larena))=[];
        else
            WellPositions=FlyDBold(OldDatabase_numbers(OldDBArenas==larena)).WellPos;
            FlyDB(Database_numbers(Database_arenas==larena)).WellPos=WellPositions;
            FlyDB(Database_numbers(Database_arenas==larena)).Geometry=...
                FlyDBold(OldDatabase_numbers(OldDBArenas==larena)).Geometry;
            lflycounter=lflycounter+1;
        end
    end
    
      
    
    %% Save center in Steplength mat file
    clear Center
    load(['C:\Users\Vero\Documents\Analysis Data\Experiment ' Exp_num '\Centroids\Centroids-',...
        filename(1:end-4) '.mat'],'Center')
    
    variables={'DB','Center'};
    load([Heads_SteplengthDir 'DB-Heads ' filename(1:end-4) '.mat'])
    save([Heads_SteplengthDir 'DB-Heads ' filename(1:end-4) '.mat'],variables{:})
        
    if lfile==Spot_File_idx(end)
        save([DataSaving_dir_temp Exp_num '\Variables\FlyDataBase',...
            Exp_num Exp_letter ' ' date '.mat'],'FlyDB','Allfilenames',...
            'Movies_idx','DB_idx','Note','remove')
        
    end
end

if (lflycounter-1)==sum(~remove), display ('Spot detection: Indexes of removed flies match :)'),
else display('Spot detection Warning: Index of removed flies does not match')
end
display(['Data Base has been saved with Spots. Number of Videos: ' num2str(length(Spot_File_idx))])


%%


