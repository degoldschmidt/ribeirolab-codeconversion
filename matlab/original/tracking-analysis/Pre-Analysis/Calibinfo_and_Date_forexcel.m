%% Getting All the Video filenames
Exp_num='0011';
Exp_letter='A';
num_arenas=3;
%% Directories information
Videos_path=['H:\FLY TRACKER PROJECT\TRACKING AND VIDEO ANALYSIS\Videos\Exp ' Exp_num '\'];
Vid_info_dir='C:\Users\Vero\Dropbox\Personal\Experiments Videos Info.xlsx';
[~,Allfilenames_temp]=xlsread(Vid_info_dir,'Tracking','A2:A1000');
logic_videos=cell2mat(cellfun(@(x)~isempty(strfind(x,[Exp_num Exp_letter])),Allfilenames_temp,'uniformoutput',false));
from=find(logic_videos,1,'first')+1; until=find(logic_videos,1,'last')+1;
% from=419;until=442;%
[~,Allfilenames]=xlsread(Vid_info_dir,'Tracking',['A' num2str(from) ':A' num2str(until)]);
%% Creating Column with 1 when file has Calib and 0 when it doesn't
%%% Copy-paste this column in Col 'C' of excel file sheet:'Experiment Info'
Calibfile=zeros(length(Allfilenames),1);
for lfile=1:length(Allfilenames)
    D=dir([Videos_path Allfilenames{lfile}(1:end-4) '*']);
    
    if ~isempty(D)
        Calib_idx=strfind(D(1).name,'Calib');
        if ~isempty(Calib_idx)
            Calibfile(lfile)=1;
        end
    end
end
%% Creating column with dates of file creation (end of the movie)
%%% Copy-paste this column in Col 'B' of excel sheet: 'Experiment Info' and
%%% modify the time to start of the movie using the info from the lab book
D=dir([Videos_path Exp_num Exp_letter '*']);
Allvideosindir={D.name}';
Calib_logic=cell2mat(cellfun(@(x)~isempty(strfind(x,'Calib')),Allvideosindir,'uniformoutput',false));
Allvideos_Calibremoved=Allvideosindir(~Calib_logic); %List of videos in dir (excluding Calib videos)
Alldates={D.date}';
Alldates_Calibremoved=Alldates(~Calib_logic)
%%% Find if all files are present
presentfile=zeros(length(Allfilenames),1);
for lfile=1:length(Allfilenames)
    presentfile(lfile)=sum(cell2mat(cellfun(@(x)~isempty(strfind(x,Allfilenames{lfile})),...
        Allvideos_Calibremoved,'uniformoutput',false)));
end
Abscentfiles=Allfilenames(find(~presentfile));
%% Triplicate filenames, dates and calib file info
Allfilenames3=Allfilenames(ceil((1:num_arenas*size(Allfilenames,1))/num_arenas),:)
[~,Alldates]=xlsread(Vid_info_dir,'Experiment Info',['B' num2str(from) ':B' num2str(until)]);
Alldates3=Alldates(ceil((1:num_arenas*size(Alldates,1))/num_arenas),:)
[AllCalib]=xlsread(Vid_info_dir,'Experiment Info',['C' num2str(from) ':C' num2str(until)]);
AllCalib3=AllCalib(ceil((1:num_arenas*size(AllCalib,1))/num_arenas),:);
Arena3=repmat((1:num_arenas)',length(Allfilenames),1);