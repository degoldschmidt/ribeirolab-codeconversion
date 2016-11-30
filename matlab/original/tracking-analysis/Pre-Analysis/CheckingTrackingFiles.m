%% Confirmation that I have all the tracking data
clear all

Vid_info_dir='E:\Dropbox (Behavior&Metabolism)\Personal\Experiments Videos Info.xlsx';
TrackingFolder='F:\FLY TRACKER PROJECT\TRACKING AND VIDEO ANALYSIS\Tracking Data\Exp ';%'C:\Users\Vero\Bonsai tracking\Exp ';

sidelabel = {'Left';'Centre';'Right'};

from=128;until=151;
[~,Allfilenames]=xlsread(Vid_info_dir,'Tracking',['A' num2str(from) ':A' num2str(until)]);
MATLAB2Bonsai=xlsread(Vid_info_dir,'Tracking',['Y' num2str(from) ':Y' num2str(until)]);
TrackedVideos=xlsread(Vid_info_dir,'Tracking',['V' num2str(from) ':V' num2str(until)]);

display(Allfilenames)
%%

ErrorIdx=nan(length(Allfilenames),3);
FileSize=nan(length(Allfilenames),3);
for lfile=find(TrackedVideos)'%1:length(Allfilenames)%
    
    filename=Allfilenames{lfile}
    Exp=filename(1:4);
    clear fileID
        if MATLAB2Bonsai(lfile)~=1
            %% Getting Bonsai tracking data
            A=dir([TrackingFolder Exp '\' filename(1:end-4) '.csv'])
            
            if size(A,1)==0
                ErrorIdx(lfile,1)=1;
            else 
                FileSize(lfile,1)=A.bytes;
            end
        else
            %% Getting MATLAB tracking data
            for arenaside=1:3
                A=dir([TrackingFolder Exp '\TrackingBonsaiParams-'...
                    filename(1:end-4) '-' sidelabel{arenaside} '.mat'])
                
                if size(A,1)==0
                    ErrorIdx(lfile,arenaside)=1;
                else
                    FileSize(lfile,arenaside)=A.bytes;
                end
            end
            
        end
end
ErrorIdx(10,:)
FileSize(10,:)
%% List of missing files
display('---------- Missing Files: --------')
Allfilenames((nansum(ErrorIdx,2)>0)|(sum(FileSize==0,2)>0))