%%% PRE-ANALYSIS PIPELINE
clear all
clc
close all
format compact

%% Input the experiment to Analyse
Exp_num='0003';
Exp_letter='A';
sec_subs=2;%sucrose  4;%agarose 
num_arenas=3;

%% Directories information
TrackDataDir_Bonsai=['F:\PROJECT INFO\Tracking Data\Exp ' Exp_num '\'];%['C:\Users\Vero\Tracking Data Bonsai\Exp ' Exp_num '\'];%['G:\FLY TRACKER PROJECT\TRACKING AND VIDEO ANALYSIS\Tracking Data\Exp ' Exp_num '\'];%
Vid_info_dir='E:\Dropbox (Behavior&Metabolism)\Personal\Experiments Videos Info.xlsx';%'D:\Dropbox (Behavior&Metabolism)\Personal\Experiments Videos Info.xlsx';%
Vid_info_dir_arenas='E:\Dropbox (Behavior&Metabolism)\Personal\Experiments Videos Info_Arenas.xlsx';
videoPath =['F:\Videos\Exp ' Exp_num '\'];
%'C:\Users\Vero\Documents\Videos\Experiments\';%['G:\PROJECT INFO\Videos\Exp ' Exp_num '\'];%'D:\Videos\';%'C:\Users\Public\Videos\Recordings Fly Tracker Prject\Exp 3\';% 
DataSaving_dir_temp='E:\Analysis Data\Experiment ';
Heads_SteplengthDir=[DataSaving_dir_temp Exp_num '\Heads_Steplength\'];
%% Getting info about the distribution of conditions in the arenas
[~,Exps_labels] = xlsread(Vid_info_dir,'Arenas','A2:A50');
[Arenas_info_ALL] = xlsread(Vid_info_dir,'Arenas','B2:B50');
logic_arenas=cell2mat(cellfun(@(x)~isempty(strfind(x,[Exp_num Exp_letter])),Exps_labels,'uniformoutput',false));
Arenas_info=Arenas_info_ALL(logic_arenas)%; % 1 means all arenas have same condition
%% Getting All the Video filenames
[~,Allfilenames_temp]=xlsread(Vid_info_dir,'Tracking','A2:A1000');
logic_videos=cell2mat(cellfun(@(x)~isempty(strfind(x,[Exp_num Exp_letter])),Allfilenames_temp,'uniformoutput',false));
% logic_videos2=cell2mat(cellfun(@(x)~isempty(strfind(x,'R05')),Allfilenames_temp,'uniformoutput',false));
% logic_videos3=cell2mat(cellfun(@(x)~isempty(strfind(x,'R06')),Allfilenames_temp,'uniformoutput',false));
from=find(logic_videos,1,'first')+1; until=find(logic_videos,1,'last')+1;
% from=find(logic_videos&(logic_videos2|logic_videos3),1,'first')+1; until=find(logic_videos&(logic_videos2|logic_videos3),1,'last')+1;
% from=419;until=442;%
[~,Allfilenames]=xlsread(Vid_info_dir,'Tracking',['A' num2str(from) ':A' num2str(until)]);
Toprocess=xlsread(Vid_info_dir,'Tracking',['G' num2str(from) ':G' num2str(until)]);
Movies_idx=find(Toprocess==1)';%find(MATLAB2Bonsai==1)';%
removeP1=cell2mat(cellfun(@(x)~isempty(strfind(x,'P1')),Allfilenames(Movies_idx),'uniformoutput',false));
DB_idx=Movies_idx(~removeP1);
Files2removeP1=find(removeP1);
Filenames2analyse=Allfilenames(DB_idx);

%% Heading Script
% Modify: Movies_idx if different to all files with 1 in G of "Tracking"
%%% Labels for arenas
sidelabel = {'Left';'Centre';'Right'};
scrsz = get(0,'ScreenSize');
StopVel=4;%mm/s
px2mm=1/6.4353; % mm in 1 px
framerate=50;

Heading_fun
display(Allfilenames)
%% Creating DataBase
CreatingDataBase
%% Defining Wells and Centers automatically (manual final check)
%%% Spot_File_idx   

lfilecounter=1;
Spot_File_idx=nan(1,length(DB_idx));
for lrow=1:3:length(remove)
    if sum(remove(lrow:lrow+2))~=3
        Spot_File_idx(lfilecounter)=DB_idx(lfilecounter);
    end
        
    lfilecounter=lfilecounter+1;
end
Spot_File_idx(isnan(Spot_File_idx))=[];  

if ~(sum(Exp_num=='0004')==4)
    Spot_detection
else
    Savespots4BC
end
%% Creating Centroids, Heads, Tails... Cell arrays
Saving_Centroids_Steplength_Cell
%% Last Quality control: Comparing amount of saved frames with movie frames
diff_frames_in_movies_vs_centroids