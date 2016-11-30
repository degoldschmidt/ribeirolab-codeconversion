%% Creating Database %%

if Arenas_info==1 % If the same condition is on three arenas, triplicate:
    %% Save experiment info in temporary vectors from excel spreadsheet
    Genotype_ALL_temp=xlsread(Vid_info_dir,'Experiment Info',['D' num2str(from) ':D' num2str(until)]);
    Genotype_ALL_temp2=Genotype_ALL_temp(DB_idx,:);
    MetabState_ALL_temp = xlsread(Vid_info_dir,'Experiment Info',['E' num2str(from) ':E' num2str(until)]);
    MetabState_ALL_temp2=MetabState_ALL_temp(DB_idx,:);
    Mating_ALL_temp = xlsread(Vid_info_dir,'Experiment Info',['H' num2str(from) ':H' num2str(until)]);
    Mating_ALL_temp2=Mating_ALL_temp(DB_idx,:);
    Sex_ALL_temp = xlsread(Vid_info_dir,'Experiment Info',['G' num2str(from) ':G' num2str(until)]);
    Sex_ALL_temp2=Sex_ALL_temp(DB_idx,:);
    Geometry_ALL_temp = xlsread(Vid_info_dir,'Experiment Info',['K' num2str(from) ':AC' num2str(until)]);
    Geometry_ALL_temp2=Geometry_ALL_temp(DB_idx,:);
    Concentrations_ALL_temp = xlsread(Vid_info_dir,'Experiment Info',['AD' num2str(from) ':AV' num2str(until)]);
    Concentrations_ALL_temp2=Concentrations_ALL_temp(DB_idx,:);
    Sensory_ALL_temp = xlsread(Vid_info_dir,'Experiment Info',['AY' num2str(from) ':AY' num2str(until)]);
    Sensory_ALL_temp2=Sensory_ALL_temp(DB_idx,:);
    
    %% Since the info is the same in all the three arenas, triplicate each row:
    Genotype= Genotype_ALL_temp2(ceil((1:num_arenas*size(Genotype_ALL_temp2,1))/num_arenas),:);
    Metabolic= MetabState_ALL_temp2(ceil((1:num_arenas*size(MetabState_ALL_temp2,1))/num_arenas),:);
    Mating= Mating_ALL_temp2(ceil((1:num_arenas*size(Mating_ALL_temp2,1))/num_arenas),:);
    Sex= Sex_ALL_temp2(ceil((1:num_arenas*size(Sex_ALL_temp2,1))/num_arenas),:);
    Substrates= Geometry_ALL_temp2(ceil((1:num_arenas*size(Geometry_ALL_temp2,1))/num_arenas),:);
    Concentrations= Concentrations_ALL_temp2(ceil((1:num_arenas*size(Concentrations_ALL_temp2,1))/num_arenas),:);
    Sensory= Sensory_ALL_temp2(ceil((1:num_arenas*size(Sensory_ALL_temp2,1))/num_arenas),:);
    Arena=repmat((1:num_arenas)',length(DB_idx),1);
    %%% Note: To re-construct the matrix Sex_ALL use: cell2mat(Sex_ALL) or
    %%% from the DataBase: reshape([FlyDB.Concentrations],lcols,lrows)'
else
    %% Calculating the Movies_idx for the matrices in which each arena has a different condition
    Full_idx=(1:length(Allfilenames))';
    Mov_idx=DB_idx';
    Mov_idx3_temp=nan(length(Full_idx)*num_arenas,1);
    
    Mov_idx3_temp([Mov_idx*num_arenas-2;Mov_idx*num_arenas-1;Mov_idx*num_arenas])=...
        [Mov_idx*num_arenas-2;Mov_idx*num_arenas-1;Mov_idx*num_arenas];
    Mov_idx=Mov_idx3_temp(~isnan(Mov_idx3_temp))';
    %% Calculating from and until
    [~,Allfilenames_temp3]=xlsread(Vid_info_dir_arenas,'Experiment Info','A2:A1000');
    logic_videos3=cell2mat(cellfun(@(x)~isempty(strfind(x,[Exp_num Exp_letter])),Allfilenames_temp3,'uniformoutput',false));
    from3=find(logic_videos3,1,'first')+1; until3=find(logic_videos3,1,'last')+1;
    %% Save experiment info in temporary vectors from excel spreadsheet
    Genotype_ALL_temp=xlsread(Vid_info_dir_arenas,'Experiment Info',['D' num2str(from3) ':D' num2str(until3)]);
    Genotype=Genotype_ALL_temp(Mov_idx,:);
    MetabState_ALL_temp = xlsread(Vid_info_dir_arenas,'Experiment Info',['E' num2str(from3) ':E' num2str(until3)]);
    Metabolic=MetabState_ALL_temp(Mov_idx,:);
    Mating_ALL_temp = xlsread(Vid_info_dir_arenas,'Experiment Info',['H' num2str(from3) ':H' num2str(until3)]);
    Mating=Mating_ALL_temp(Mov_idx,:);
    Sex_ALL_temp = xlsread(Vid_info_dir_arenas,'Experiment Info',['G' num2str(from3) ':G' num2str(until3)]);
    Sex=Sex_ALL_temp(Mov_idx,:);
    Geometry_ALL_temp = xlsread(Vid_info_dir_arenas,'Experiment Info',['K' num2str(from3) ':AC' num2str(until3)]);
    Substrates=Geometry_ALL_temp(Mov_idx,:);
    Concentrations_ALL_temp = xlsread(Vid_info_dir_arenas,'Experiment Info',['AD' num2str(from3) ':AV' num2str(until3)]);
    Concentrations=Concentrations_ALL_temp(Mov_idx,:);
    Sensory_ALL_temp = xlsread(Vid_info_dir_arenas,'Experiment Info',['AY' num2str(from3) ':AY' num2str(until3)]);
    Sensory=Sensory_ALL_temp(Mov_idx,:);
    Arena_ALL_temp = xlsread(Vid_info_dir_arenas,'Experiment Info',['AZ' num2str(from3) ':AZ' num2str(until3)]);
    Arena=Arena_ALL_temp(Mov_idx,:);
    
end
Setup_ALL_temp=cell2mat(cellfun(@(x)str2double(x(15)),Allfilenames,'uniformoutput',false));
Setup_ALL_temp2=Setup_ALL_temp(DB_idx,:);
Setup=Setup_ALL_temp2(ceil((1:num_arenas*size(Setup_ALL_temp2,1))/num_arenas),:);


%% Create Labels structure array
Feature_names={'Arena';'Genotype';'Metabolic';'Mating';'Sex';'Substrates';'Concentrations';'Sensory'};
Excel_letter={'K';'B';'C';'E';'D';'F';'G';'M'};
Feat_Labels=cell(length(Feature_names),1);
for lFeat=1:length(Feature_names)
    if lFeat==7
        numsfeature=unique(eval(Feature_names{lFeat-1}));
    else
        numsfeature=unique(eval(Feature_names{lFeat}));
    end
    numsfeature(numsfeature==0)=[];
    [~,FeatLabels_temp]=xlsread(Vid_info_dir,'Number Code',...
        [Excel_letter{lFeat} '3:' Excel_letter{lFeat} num2str(numsfeature(end)+2)]);%always start from row 3, meaning 1.
    Feat_Labels{lFeat}=cell(2,1);%First entry for the numbers and second for the labels
    Feat_Labels{lFeat}{1}=numsfeature;
    Feat_Labels{lFeat}{2}=FeatLabels_temp(numsfeature);
end

LabelsDB=struct(Feature_names{1},Feat_Labels(1),...
    Feature_names{2},Feat_Labels(2),...
    Feature_names{3},Feat_Labels(3),...
    Feature_names{4},Feat_Labels(4),...
    Feature_names{5},Feat_Labels(5),...
    Feature_names{6},Feat_Labels(6),...
    Feature_names{7},Feat_Labels(7),...
    Feature_names{8},Feat_Labels(8));

save([DataSaving_dir_temp Exp_num '\Variables\LabelsDataBase' Exp_num Exp_letter ' ' date '.mat'],...
    'LabelsDB','Allfilenames','Feature_names','Excel_letter','Movies_idx','DB_idx')

%% Creating DataBase with all information
FlyDB=struct('Filename',Filenames2analyse(ceil((1:num_arenas*size(Filenames2analyse,1))/num_arenas),:),...
    Feature_names{1},num2cell(Arena),...
    'Setup',num2cell(Setup,2),...
    Feature_names{2},num2cell(Genotype,2),...
    Feature_names{3},num2cell(Metabolic,2),...
    Feature_names{4},num2cell(Mating,2),...
    Feature_names{5},num2cell(Sex,2),...
    Feature_names{8},num2cell(Sensory,2),...
    'Geometry',num2cell(Substrates,2),...
    Feature_names{7},num2cell(Concentrations,2),...
    'WellPos',repmat({nan(19,2)},size(Filenames2analyse,1)*num_arenas,1),...
    'RadiiWells',repmat({nan(19,1)},size(Filenames2analyse,1)*num_arenas,1));

%% Definining Quality constraints
QualityMeasureCentroids=0.1; % Max percentage allowed of missing frames.

remove=zeros(length(DB_idx)*num_arenas,1);
lfilecounter=1;
for lfile=DB_idx%1:length(filenames)
    filename=Allfilenames{lfile} % Remember this Index of file inside filenames is also used when evaluating quality constraints.
    load([Heads_SteplengthDir 'DB-Heads ' filename(1:end-4) '.mat'])
    
    for larena=1:num_arenas
        if sum((lfile)==Movies_idx(Files2removeP1+1))==1
            %% Creating Body Centroids Cell array
            DB2=DB;
            
            Filenames_MovIdx=Allfilenames(Movies_idx);
            filename1=Filenames_MovIdx{Files2removeP1((lfile)==Movies_idx(Files2removeP1+1))};
            load([Heads_SteplengthDir 'DB-Heads ' filename1(1:end-4) '.mat'],'DB')
            
            Centroids_temp=[DB(larena).hBon;...
                DB2(larena).hBon];
        else
            Centroids_temp=DB(larena).hBon;
        end
        %%% Evaluating quality constraints %%%
        if ~((sum(sum(isnan(Centroids_temp))))/(size(Centroids_temp,1)*2)<...
                QualityMeasureCentroids)||(length(Centroids_temp)<180000)%345000-Less than 115 min 180000)%Less than 60 min 
            display('DID NOT MEET QUALITY CRITERIA!')
            remove(3*lfilecounter+larena-num_arenas)=1;
        end
    end
    lfilecounter=lfilecounter+1;
end

%% Removing the entries that do not fit those constraints
FlyDB(logical(remove))=[];
% %%
Note='remove is the index of [Allfilenames(DB_idx)]*3';
save([DataSaving_dir_temp Exp_num '\Variables\FlyDataBase',...
    Exp_num Exp_letter ' ' date '.mat'],'FlyDB','Allfilenames','Movies_idx',...
    'DB_idx','Note','remove')
display(['Data Base has been saved. Number of Videos: ' num2str(length(Allfilenames))])

% %% Finding a particular video in the database
% % filename='0003A01R02Cam04P0WT-CantonS.avi';
% % log_filename=cellfun(@(x)~isempty(strfind(x,filename)),{FlyDB.Filename},'uniformoutput',false);
% % Database_number=find(cell2mat(log_filename))
%%

