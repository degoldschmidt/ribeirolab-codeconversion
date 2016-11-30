% load([DataSaving_dir_temp Exp_num '\Variables\FlyDataBase',...
%     Exp_num Exp_letter ' ' date '.mat'],'remove')

%% %% Obtain Spot_File_Idx used to create Centroids Cells - Apply only when it's not the first time creating Centroids and Heads
%     removeP1=cell2mat(cellfun(@(x)~isempty(strfind(x,'P1')),Allfilenames(Movies_idx),'uniformoutput',false));
% DB_idx=Movies_idx(~removeP1);
%     
%     lfilecounter=1;
% Spot_File_idx=nan(1,length(DB_idx));
% for lrow=1:3:length(remove)
%     if sum(remove(lrow:lrow+2))~=3
%         Spot_File_idx(lfilecounter)=DB_idx(lfilecounter);
%     end
%         
%     lfilecounter=lfilecounter+1;
% end
% Spot_File_idx(isnan(Spot_File_idx))=[];
% 
%     lfilecounter=0;
% for lfile=Spot_File_idx
%     filename=Allfilenames{lfile}
%     log_filename_temp=cellfun(@(x)~isempty(strfind(x,filename)),{FlyDB.Filename},'uniformoutput',false);
%     Database_numbers=find(cell2mat(log_filename_temp));
%     Database_arenas=[FlyDB(Database_numbers).Arena];
%     for arenaside=Database_arenas
%         lfilecounter=lfilecounter+1
%     end
% end
% removeP1=cell2mat(cellfun(@(x)~isempty(strfind(x,'P1')),Allfilenames(Movies_idx),'uniformoutput',false));
% DB_idx=Movies_idx(~removeP1);
% Files2removeP1=find(removeP1);
%%

Centroids=cell(length(Spot_File_idx),1);
Heads=cell(length(Spot_File_idx),1);
Tails=cell(length(Spot_File_idx),1);
% % Heading_WalkDir=cell(length(Spot_File_idx),1);
% % Vel_Gamma=cell(length(Spot_File_idx),1);

lfilecounter=0;
for lfile=Spot_File_idx
    %%
    filename=Allfilenames{lfile}
    log_filename_temp=cellfun(@(x)~isempty(strfind(x,filename)),{FlyDB.Filename},'uniformoutput',false);
    Database_numbers=find(cell2mat(log_filename_temp));
    Database_arenas=[FlyDB(Database_numbers).Arena];
    load([Heads_SteplengthDir 'DB-Heads ' filename(1:end-4) '.mat'],'DB','Center')
       %%
    
    for arenaside=Database_arenas
        lfilecounter=lfilecounter+1;
        if sum(Center(arenaside,:))==0,
            error('Center is missing')
        end
         
        if sum((lfile)==Movies_idx(Files2removeP1+1))==1
            %% Creating Body Centroids Cell array
            DB2=DB;
            
            Filenames_MovIdx=Allfilenames(Movies_idx);
            filename1=Filenames_MovIdx{Files2removeP1((lfile)==Movies_idx(Files2removeP1+1))};
            load([Heads_SteplengthDir 'DB-Heads ' filename1(1:end-4) '.mat'],'DB')
            %%
            Centroids{lfilecounter}=[[DB(arenaside).cBon(:,1)-Center(arenaside,1),...
                Center(arenaside,2)-DB(arenaside).cBon(:,2)];...
                [DB2(arenaside).cBon(:,1)-Center(arenaside,1),...
                Center(arenaside,2)-DB2(arenaside).cBon(:,2)]]; %Cartesian Coordinates, Origin in (0,0), units: pixels.;
            Heads{lfilecounter}=[[DB(arenaside).hBon(:,1)-Center(arenaside,1),...
                Center(arenaside,2)-DB(arenaside).hBon(:,2)];...
                [DB2(arenaside).hBon(:,1)-Center(arenaside,1),...
                Center(arenaside,2)-DB2(arenaside).hBon(:,2)]];
            Tails{lfilecounter}=[[DB(arenaside).tBon(:,1)-Center(arenaside,1),...
                Center(arenaside,2)-DB(arenaside).tBon(:,2)];...
                [DB2(arenaside).tBon(:,1)-Center(arenaside,1),...
                Center(arenaside,2)-DB2(arenaside).tBon(:,2)]];
            %%% If centroid or head or tail are outside the arena
            %%% (Distance>= 36 mm), set it to nan:
            Centroids{lfilecounter}(sqrt(sum(((Centroids{lfilecounter}).^2),2))*0.1554>=36,:)=...
                nan(sum(sqrt(sum(((Centroids{lfilecounter}).^2),2))*0.1554>=36),2);
            Heads{lfilecounter}(sqrt(sum(((Heads{lfilecounter}).^2),2))*0.1554>=36,:)=...
                nan(sum(sqrt(sum(((Heads{lfilecounter}).^2),2))*0.1554>=36),2);
            Tails{lfilecounter}(sqrt(sum(((Tails{lfilecounter}).^2),2))*0.1554>=36,:)=...
                nan(sum(sqrt(sum(((Tails{lfilecounter}).^2),2))*0.1554>=36),2);
            Heads{lfilecounter}(sqrt(sum(((Tails{lfilecounter}).^2),2))*0.1554>=36,:)=...
                nan(sum(sqrt(sum(((Tails{lfilecounter}).^2),2))*0.1554>=36),2);
            Tails{lfilecounter}(sqrt(sum(((Heads{lfilecounter}).^2),2))*0.1554>=36,:)=...
                nan(sum(sqrt(sum(((Heads{lfilecounter}).^2),2))*0.1554>=36),2);
                                   
            %%% If centroids are nan, set heads and tails to nan:
            Heads{lfilecounter}(isnan(Centroids{lfilecounter}(:,1)),:)=...
                nan(sum(isnan(Centroids{lfilecounter}(:,1))),2);
            Tails{lfilecounter}(isnan(Centroids{lfilecounter}(:,1)),:)=...
                nan(sum(isnan(Centroids{lfilecounter}(:,1))),2);
        else
            %% Creating Body Centroids Cell array
            Centroids{lfilecounter}=[DB(arenaside).cBon(:,1)-Center(arenaside,1),...
                Center(arenaside,2)-DB(arenaside).cBon(:,2)]; %Cartesian Coordinates, Origin in (0,0), units: pixels.;
            Heads{lfilecounter}=[DB(arenaside).hBon(:,1)-Center(arenaside,1),...
                Center(arenaside,2)-DB(arenaside).hBon(:,2)];
            Tails{lfilecounter}=[DB(arenaside).tBon(:,1)-Center(arenaside,1),...
                Center(arenaside,2)-DB(arenaside).tBon(:,2)];
            %%% If centroid or head or tail are outside the arena
            %%% (Distance>= 36 mm), set it to nan:
            Centroids{lfilecounter}(sqrt(sum(((Centroids{lfilecounter}).^2),2))*0.1554>=36,:)=...
                nan(sum(sqrt(sum(((Centroids{lfilecounter}).^2),2))*0.1554>=36),2);
            Heads{lfilecounter}(sqrt(sum(((Heads{lfilecounter}).^2),2))*0.1554>=36,:)=...
                nan(sum(sqrt(sum(((Heads{lfilecounter}).^2),2))*0.1554>=36),2);
            Tails{lfilecounter}(sqrt(sum(((Tails{lfilecounter}).^2),2))*0.1554>=36,:)=...
                nan(sum(sqrt(sum(((Tails{lfilecounter}).^2),2))*0.1554>=36),2);
            Heads{lfilecounter}(sqrt(sum(((Tails{lfilecounter}).^2),2))*0.1554>=36,:)=...
                nan(sum(sqrt(sum(((Tails{lfilecounter}).^2),2))*0.1554>=36),2);
            Tails{lfilecounter}(sqrt(sum(((Heads{lfilecounter}).^2),2))*0.1554>=36,:)=...
                nan(sum(sqrt(sum(((Heads{lfilecounter}).^2),2))*0.1554>=36),2);
                                   
            %%% If centroids are nan, set heads and tails to nan:
            Heads{lfilecounter}(isnan(Centroids{lfilecounter}(:,1)),:)=...
                nan(sum(isnan(Centroids{lfilecounter}(:,1))),2);
            Tails{lfilecounter}(isnan(Centroids{lfilecounter}(:,1)),:)=...
                nan(sum(isnan(Centroids{lfilecounter}(:,1))),2);
        end
       
    end
    
end

if (lfilecounter)==length(FlyDB), display ('Saving Cells: Number of flies match :)'),
else display('Saving Cells Warning: Number of flies does not match')
end
%% Saving raw centroids
save([DataSaving_dir_temp Exp_num '\Variables\Centroids&Heads',...
    Exp_num Exp_letter ' ' date '.mat'],...
    'Centroids','Heads','Tails','Spot_File_idx','Files2removeP1','-v7.3');

%% Smoothing trajectories
window=16;%3;
type_sm='gaussian';
r_zeros=1;
[Centroids_Sm,rep1_cent,probl1_cent,rep_Sm_cent,probl_Sm_cent] = Smoothing(Centroids,16,'gaussian',1);
[Heads_Sm,rep1_h,probl1_h,rep_Sm_h,probl_Sm_h] = Smoothing(Heads,16,'gaussian',1);
[Tails_Sm,rep1_t,probl1_t,rep_Sm_t,probl_Sm_t] = Smoothing(Tails,16,'gaussian',1);

%%% If distance between head and centroid is larger than 5mm
display('Sanity check: Evaluating distance Head-Centroid')
for lfly=1:lfilecounter
    lfly
    if sum(sqrt(sum(((Centroids_Sm{lfly}-Heads_Sm{lfly}).^2),2))*0.1554>=6)~=0
        error('Error: There are Heads far away from the corresponding centroids')
        %%
%         close all
%         figure
%         range=5200:5400;%5328:5333;
%         plot(Centroids_Sm{lfly}(range,1),Centroids_Sm{lfly}(range,2),'-g','LineWidth',2)
%         hold on
%         plot(Heads_Sm{lfly}(range,1),Heads_Sm{lfly}(range,2),'-m','LineWidth',2)
    end
end

save([DataSaving_dir_temp Exp_num '\Variables\Centroids&Heads_GaussSm' Exp_num Exp_letter ' ' date '.mat'],...
'Centroids_Sm','Heads_Sm','Tails_Sm','window','type_sm','r_zeros','-v7.3')
display('Centroids and Heads Smoothed Saved')
%% Smoothing Steplength
window=60;%3;
type_sm='gaussian';
r_zeros=0;
[Steplength_c] = Steplength_fun(Centroids_Sm);
[Steplength_h] = Steplength_fun(Heads_Sm);
Steplength_Sm_c=Smoothing(Steplength_c,60,'gaussian',0);
Steplength_Sm_h=Smoothing(Steplength_h,60,'gaussian',0);
Steplength_Sm180_h=Smoothing(Steplength_h,180,'gaussian',0);

save([DataSaving_dir_temp Exp_num '\Variables\Steplength',...
    Exp_num Exp_letter ' ' date '.mat'],'Steplength_c','Steplength_h')

save([DataSaving_dir_temp Exp_num '\Variables\Steplength_GaussSmoothed',...
    Exp_num Exp_letter ' ' date '.mat'],'Steplength_Sm_c','Steplength_Sm_h','Steplength_Sm180_h',...
    'window','type_sm','r_zeros','-v7.3')
display(['Steplength cells have been saved. Number of flies: ',...
    num2str(length(FlyDB))])