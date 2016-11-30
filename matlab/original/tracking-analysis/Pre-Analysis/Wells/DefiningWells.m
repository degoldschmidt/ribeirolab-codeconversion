%%%%%% Script to re-check wellpos inside DataBase. Created: 07Feb2013
%%% 1)Set filenumber=filenumber to be analysed-1.
%%% 2)Run the cell "Show wellpos in DB" and modify individual spots by
%%% running only that section
%%% 3) To re-confirm, run the cell "Re confirmation - Big foodwells"
%%% 4) If wells are ok, uncomment loop to re-write in the database
%%% 5) Run the full script again for next video
%%% 6) Save database when done.

%%% To find Database number of a video:
% arenaside=1
% filenames_row=find(ismember(filenames,'0003A02R02Cam03P0WT-CantonS.avi')==1);
% Database_num= 3*filenames_row+arenaside-3;
% filenumber=22

% clear all
close all
% clc
% Geometry_ALL = xlsread(Vid_info_dir,'Experiment Info',['K' num2str(from) ':AC' num2str(until)]);%This variable comes from CreatingDataBase.m 
Calibs = xlsread(Vid_info_dir,'Experiment Info',['C' num2str(from) ':C' num2str(until)]); %H2:H29
% load(['C:\Users\FaisalLab\Documents\Veronica\Data Analysis\Analysis Data\Experiment 3\FlyDataBase3 12-Feb-2013.mat'])
DBexistence=false;
lfile_idx=0; % Uncomment to run the script with F5 for the first time
%%
lfile_idx=lfile_idx+1; % Use this cell (Alt+Enter) to continue the for loop after a full stop but with the same "filenames"
% for lfile_idx=3:length(Movies_idx)
filename=Allfilenames{Movies_idx(lfile_idx)}

if DBexistence
    if isempty(FlyDB(3*lfile_idx+arenaside-3).Filename)
        display(lfile_idx)
        break
    end
    for arenaside=1:3
        wellpos(:,2*arenaside-1:2*arenaside)=(FlyDB(3*lfile_idx+arenaside-3).WellPos).*repmat([1 -1],19,1);
    end
end
clear Center
load([Heads_SteplengthDir 'DB-Heads ' filename(1:end-4) '.mat'])

frame=1;

if Calibs(Movies_idx(lfile_idx))==1
    flymovieCALIB=VideoReader([videoPath filename(1:end-4) ' Calib.avi'])%file])%
    flymoviedataCALIB = flymovieCALIB.read(frame);
else
    flymovieCALIB=VideoReader([videoPath filename])%file])%
    flymoviedataCALIB = flymovieCALIB.read(frame);
end

Geometry = Geometry_ALL(Movies_idx(lfile_idx),:)';

if exist('Center','var')
    display(Center)
else%if Calibs(Movies_idx(lfile_idx))==1
    imshow(flymoviedataCALIB)
    [Center1x,Center1y]=ginput;
    Center=[Center1x Center1y]
%     if str2num(file(15))==1 % file(15) for Exp3 and file(16) for Exp2
%         Center(:,1)=[217.6;706.5;1185.1];Center(:,2)=[238.9;238.4;235.2];
%     end
% else
%     %%% When there is no Calib file: Use this average center for each camera
%     if str2num(filename(15))==1 % file(15) for Exp3 and file(16) for Exp2
%         Center(:,1)=[217.6;706.5;1185.1];Center(:,2)=[238.9;238.4;235.2];
%     elseif str2num(filename(15))==2
%         Center(:,1)=[212;700;1190];Center(:,2)=[240;243;246];
%     elseif str2num(filename(15))==3
%         Center(:,1)=[215;700;1186];Center(:,2)=[243;241;241];
%     else
%         Center=[220.3 239.5;696.2 242.8;1179.6 245.9];
%     end
end

%% Changing wellpos parameters
if ~DBexistence
    if str2num(filename(15))==1
        DispAngle=[0 0.5 -.50]%[0.1 0.5 1.8]
        LengthInner=[1.265 1.27 1.26]*50%[1.26 1.27 1.27]*50
    elseif str2num(filename(15))==2
        DispAngle=[0 1 0.5]%[-1 1.2 0]
        LengthInner=[1.26 1.28 1.285]*50%[1.245 1.28 1.285]*50
    elseif str2num(filename(15))==3
        DispAngle=[1.5 0 1]%[-0.5 .3 0.8]
        LengthInner=[1.235 1.26 1.27]*50%[1.25 1.27 1.26]*50
    else
        DispAngle=[1 0 -.5]%[1 0 -1]
        LengthInner=[1.25 1.26 1.26]*50%[1.25 1.27 1.27]*50
    end
    
    [wellpos]=wellpositions(LengthInner,DispAngle);
end
%% Show wellpos
clf
%%% Write the spot number that needs to be modified in the following
%%% variables, correspondent to the modification
imshow(flymoviedataCALIB)
arena=3;
tomodifyR=[];
tomodifyL=[];
tomodifyD=[];
tomodifyU=[];
Center(arena,:)=Center(arena,:)+[-.0 -0];

wellpos(tomodifyR,2*arena-1)=wellpos(tomodifyR,2*arena-1)+0.5; %right
wellpos(tomodifyL,2*arena-1)=wellpos(tomodifyL,2*arena-1)-0.5; %left
wellpos(tomodifyD,2*arena)=wellpos(tomodifyD,2*arena)+0.5; %down
wellpos(tomodifyU,2*arena)=wellpos(tomodifyU,2*arena)-0.5; %up

Cam=filename(15);
display(Cam)
Symbols={'ob','or','ow','og'};
Subs=[1 2];%[4];%
Subs_pos=nan([size(wellpos) length(Subs)]);
subscounter=1;
hold on
for lsubs=Subs
    Subs_pos_tmp=nan(size(wellpos));
    Subs_pos_tmp(repmat(Geometry,1,6)==lsubs)=wellpos(repmat(Geometry,1,6)==lsubs);
    Subs_pos(:,:,subscounter)=Subs_pos_tmp;
    
    for arenaside=1:3
        plot(Subs_pos(:,2*arenaside-1,subscounter)+Center(arenaside,1),Subs_pos(:,2*arenaside,subscounter)+Center(arenaside,2), Symbols{lsubs},'MarkerSize',3)
        plot(Center(arenaside,1),Center(arenaside,2), 'ok','MarkerSize',3)
        
        for well=1:19
            text(wellpos(well,2*arenaside-1)+Center(arenaside,1)+15,wellpos(well,2*arenaside)+Center(arenaside,2),num2str(well))
        end
    end
    subscounter=subscounter+1;
end

    %% Re confirmation - Big foodwells
clf
imshow(flymoviedataCALIB)
hold on
for arenaside=1:3
    subscounter=1;
    for lsubs=Subs
        plot(Subs_pos(:,2*arenaside-1,subscounter)+Center(arenaside,1),Subs_pos(:,2*arenaside,subscounter)+Center(arenaside,2), Symbols{lsubs},'MarkerSize',12)%,'MarkerFaceColor','c')%'oc','MarkerSize',12,'LineWidth',1)
        subscounter=subscounter+1;
    end
    for well=1:19
        text(wellpos(well,2*arenaside-1)+Center(arenaside,1)+15,wellpos(well,2*arenaside)+Center(arenaside,2),num2str(well))
    end
end
pause
for arenaside=1:3
    plot(CentroidsBody(:,2*arenaside-1)-1,CentroidsBody(:,2*arenaside), '-y')
end
display(lfile_idx)

if ~waitforbuttonpress
    for arenaside=1:3
        FlyDB(3*lfile_idx+arenaside-3).WellPos=[wellpos(:,2*arenaside-1),-wellpos(:,2*arenaside)];
    end
        
    
    variables={'DB','Center','DispAngle','LengthInner','wellpos'};
    save([Heads_SteplengthDir 'DB-Heads ' filename(1:end-4) '.mat'],variables{:})
    saved=true
end

if lfile_idx==length(Movies_idx)
    save([DataSaving_dir_temp Exp_num '\Variables\FlyDataBase' Exp_num ' ' date '.mat'],'FlyDB','Allfilenames')
end
% end
