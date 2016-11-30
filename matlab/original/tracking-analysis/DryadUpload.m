%%% Preparing DATA to upload in Dryad  %%%
Conditions=[6 4 5 1 3];% EXP 3D [2 1 3];% Exp 8B
expe_prefix='CANS';%'ORCO';
folder='E:\One Drive\OneDrive\PhD Project\Paper\Data\';%'D:\OneDrive\PhD Project\Paper\Data\';
%% Checking for nans
for lfly=1:params.numflies
    nanscentroids=sum(isnan(Centroids_Sm{lfly}(:,1))|isnan(Centroids_Sm{lfly}(:,2)));
    nansheads=sum(isnan(Heads_Sm{lfly}(:,1))|isnan(Heads_Sm{lfly}(:,2)));
    if nanscentroids~=0 || nansheads~=0
        display(lfly)
    end
end

%% Transforming General Info to have only the wanted flies
NewConditionIndex=nan(length(ConditionIndex),1);
lcondcounter=0;
for lcond=Conditions
    lcondcounter=lcondcounter+1;
    NewConditionIndex(ConditionIndex==lcond)=lcondcounter;
    
end
selectedflies=~isnan(NewConditionIndex);
NewConditionIndex=NewConditionIndex(selectedflies);
newLabels=Labels(Conditions);

GeneralInfo.num_flies=length(NewConditionIndex);
GeneralInfo.condition_index=NewConditionIndex;
GeneralInfo.condition_labels=newLabels;

Originalflyindexofselected=1:params.numflies;
Originalflyindexofselected=Originalflyindexofselected(selectedflies);
struct2csv(GeneralInfo,[folder expe_prefix '_General_Info.csv'])
save([folder expe_prefix '_General_Info.mat'],'GeneralInfo')

%% Saving centroids as .csv file
Xcentroids_temp=nan(params.MinimalDuration,GeneralInfo.num_flies);
Xcentroids=[1:GeneralInfo.num_flies;Xcentroids_temp];
Ycentroids_temp=nan(params.MinimalDuration,GeneralInfo.num_flies);
Ycentroids=[1:GeneralInfo.num_flies;Ycentroids_temp];

Xheads_temp=nan(params.MinimalDuration,GeneralInfo.num_flies);
Xheads=[1:GeneralInfo.num_flies;Xheads_temp];
Yheads_temp=nan(params.MinimalDuration,GeneralInfo.num_flies);
Yheads=[1:GeneralInfo.num_flies;Yheads_temp];

lflycounter=0;
for lfly=find(selectedflies')
    lflycounter=lflycounter+1;
    
    Xcentroids(2:end,lflycounter)=Centroids_Sm{lfly}(1:params.MinimalDuration,1);
    
    Ycentroids(2:end,lflycounter)=Centroids_Sm{lfly}(1:params.MinimalDuration,2);
    
    Xheads(2:end,lflycounter)=Heads_Sm{lfly}(1:params.MinimalDuration,1);
    
    Yheads(2:end,lflycounter)=Heads_Sm{lfly}(1:params.MinimalDuration,2);
end


dlmwrite([folder expe_prefix '_BodyXCentroids.csv'],Xcentroids,'delimiter',';')
display('Saved X cetroids')
dlmwrite([folder expe_prefix '_BodyYCentroids.csv'],Ycentroids,'delimiter',';')
display('Saved Y cetroids')
dlmwrite([folder expe_prefix '_HeadXCentroids.csv'],Xheads,'delimiter',';')
display('Saved X heads')
dlmwrite([folder expe_prefix '_HeadYCentroids.csv'],Yheads,'delimiter',';')
display('Saved Y heads')
%% New FlyDB
NewFlyDB=FlyDB;
f = fieldnames(FlyDB);
v = struct2cell(FlyDB);
f{strmatch('Filename',f,'exact')} = 'Videofilename';
f{strmatch('Geometry',f,'exact')} = 'SubstrateType';
f{strmatch('WellPos',f,'exact')} = 'PatchPositions';

NewFlyDB = cell2struct(v,f);
NewFlyDB = rmfield( NewFlyDB , 'Sensory');
NewFlyDB = rmfield( NewFlyDB , 'Concentrations');
NewFlyDB = rmfield( NewFlyDB , 'RadiiWells');

if any(strcmp(fieldnames(NewFlyDB),'Time'))
    NewFlyDB = rmfield( NewFlyDB , 'Time');
end

if any(strcmp(fieldnames(NewFlyDB),'DateNumber'))
    NewFlyDB = rmfield( NewFlyDB , 'DateNumber');
end

if any(strcmp(fieldnames(NewFlyDB),'TimeNumber'))
    NewFlyDB = rmfield( NewFlyDB , 'TimeNumber');
end

Vid_info_dir='I:\PhD Project\Personal folder in Dropbox\Experiments Videos Info.xlsx';%'F:\PROJECT INFO\Experiments and Info related\Experiments Videos Info.xlsx'; 
[~,Filenames_ALL]=xlsread(Vid_info_dir,'Experiment Info','A80:A1000');
[~,Dates_ALL]=xlsread(Vid_info_dir,'Experiment Info','B80:B1000');

for lfly=1:length(FlyDB)
    display(lfly)
    fly_idx=find(cell2mat(cellfun(@(x)~isempty(strfind(x,FlyDB(lfly).Filename(1:20))),Filenames_ALL,'uniformoutput',false)));
    NewFlyDB(lfly).Date=Dates_ALL{fly_idx};
    NewFlyDB(lfly).SubstrateType=FlyDB(lfly).Geometry';
    NewFlyDB(lfly).Videofilename=[FlyDB(lfly).Filename(1:15) '.avi'];
    if NewFlyDB(lfly).Genotype==9
        NewFlyDB(lfly).Genotype=2;
    elseif NewFlyDB(lfly).Genotype==10
        NewFlyDB(lfly).Genotype=3;
    elseif NewFlyDB(lfly).Genotype==15
        NewFlyDB(lfly).Genotype=4;
    end
    
    if NewFlyDB(lfly).Metabolic==7
        NewFlyDB(lfly).Metabolic=3;
    end
end
NewFlyDB=NewFlyDB(selectedflies);
save([folder expe_prefix '_Info_Allflies.mat'],'NewFlyDB')
%% Saving csv for each fly
for lnewfly=1:GeneralInfo.num_flies
    clear singleflyDB
    singleflyDB=NewFlyDB(lnewfly);
    struct2csv(singleflyDB,[folder expe_prefix '_Info_fly_' sprintf('%03d',lnewfly) '.csv'])
end
%% Comparing centroids and conditions before and after
 close all
colors=Colors(2);
FontSz=10;
LW=1;
figure
for lfly=Originalflyindexofselected(randi(GeneralInfo.num_flies,1,10))
    display(lfly)
    lcond=ConditionIndex(lfly);
    range=100000:130000;
    subplot(1,2,1)
    
    h=plot_tracks_single(FlyDB,Centroids_Sm{lfly},lfly,0,params,1,colors(1,:),...
        range,FontSz,1,LW);
    hold on
    h=plot_tracks_single(FlyDB,Heads_Sm{lfly},lfly,0,params,1,colors(2,:),...
        range,FontSz,1,LW);
%     title(['fly: ' num2str(lfly) ', ' params.LabelsShort{lcond}]);
   
    subplot(1,2,2)
    newflyidx=find(Originalflyindexofselected==lfly);
    lnewcond1=NewConditionIndex(newflyidx);
    
    h=plot_tracks_single2(NewFlyDB,[Xcentroids(2:end,newflyidx) Ycentroids(2:end,newflyidx)],newflyidx,0,GeneralInfo,1,colors(1,:),...
        range,FontSz,1,LW);
    hold on
    h=plot_tracks_single2(NewFlyDB,[Xheads(2:end,newflyidx) Yheads(2:end,newflyidx)],newflyidx,0,GeneralInfo,1,colors(2,:),...
        range,FontSz,1,LW);
%     title(['fly: ' num2str(newflyidx) ', ' newLabels{lnewcond1}]);
    pause
    clf
    
   
    
end
%% Correcting centroids with errors
% close all
% colors=Colors(2);
% FontSz=10;
% LW=1;
% figure
% for lfly=45:60%params.numflies
%     dists=sqrt(sum(((Heads_Sm{lfly}-...
%             Centroids_Sm{lfly}).^2),2));
%     range_log=dists>(prctile(dists,95)*1.1);
%     range=find(range_log);
%     plot(1:params.MinimalDuration,dists(1:params.MinimalDuration),'-b')
%     hold on
%     plot([1 351000],[prctile(dists,95)*1.1 prctile(dists,95)*1.1],':r')
%     if ~isempty(range)
%         plus='YES'
%     else
%         plus=''
%     end
%     title(['fly: ' num2str(lfly) ', ' plus]);
%     pause
%     %%
%     clf
%     if ~isempty(range)
%     h=plot_tracks_single(FlyDB,Centroids_Sm{lfly},lfly,0,params,1,colors(1,:),...
%         range,FontSz,1,LW);
%     hold on
%     h=plot_tracks_single(FlyDB,Heads_Sm{lfly},lfly,0,params,1,colors(2,:),...
%         range,FontSz,1,LW);
%     pause
%     clf
%     end
%     %%
%     
% end