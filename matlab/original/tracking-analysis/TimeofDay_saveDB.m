%% Loading Time information for all experiments
Vid_info_dir='E:\Dropbox (Behavior&Metabolism)\Personal\Experiments Videos Info.xlsx';
[~,Filenames_ALL]=xlsread(Vid_info_dir,'Experiment Info','A80:A1000');
[~,Dates_ALL]=xlsread(Vid_info_dir,'Experiment Info','B80:B1000');

%%% Converting date into MATLAB date number
DatesNums=cell2mat(cellfun(@(x)datenum(x),Dates_ALL,'uniformoutput',false));
%%% Creating cell array with time of the day strings
Times=(cellfun(@(x)x(13:end),Dates_ALL,'uniformoutput',false));
%%% Converting time of the day in MATLAB number
TimesNum=cell2mat(cellfun(@(x)datenum(x,'HH:MM:SS'),Times,'uniformoutput',false));
%%% Obtaining the time string back again (might be useful)
% datestr(TimesNum(ltime),'HH:MM')

%% Saving Date and time info into FlyDataBase
for lfly=1:length(FlyDB)
    display(lfly)
    fly_idx=find(cell2mat(cellfun(@(x)~isempty(strfind(x,FlyDB(lfly).Filename)),Filenames_ALL,'uniformoutput',false)));
    FlyDB(lfly).Date=Dates_ALL{fly_idx};
    FlyDB(lfly).Time=Times{fly_idx};
    FlyDB(lfly).DateNumber=DatesNums(fly_idx);
    FlyDB(lfly).TimeNumber=TimesNum(fly_idx);
end
save([DataSaving_dir_temp Exp_num '\Variables\FlyDataBase',...
            Exp_num Exp_letter ' ' date '.mat'],'FlyDB','Allfilenames',...
            'Movies_idx','DB_idx','Note','remove')
display('Dates have been updated in Data Base')
