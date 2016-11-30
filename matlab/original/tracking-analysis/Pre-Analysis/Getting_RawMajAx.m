%% Obtaining raw MjAx
Vid_info_dir='E:\Dropbox (Behavior&Metabolism)\Personal\Experiments Videos Info.xlsx';%'D:\Dropbox (Behavior&Metabolism)\Personal\Experiments Videos Info.xlsx';%
TrackDataDir_Bonsai=['F:\PROJECT INFO\Tracking Data\Exp ' Exp_num '\'];%
sidelabel = {'Left';'Centre';'Right'};

[~,Allfilenames_temp]=xlsread(Vid_info_dir,'Tracking','A2:A1000');

logic_videos=cell2mat(cellfun(@(x)~isempty(strfind(x,[Exp_num Exp_letter])),...
    Allfilenames_temp,'uniformoutput',false));
% logic_videos2=cell2mat(cellfun(@(x)~isempty(strfind(x,'R05')),Allfilenames_temp,'uniformoutput',false));
% logic_videos3=cell2mat(cellfun(@(x)~isempty(strfind(x,'R06')),Allfilenames_temp,'uniformoutput',false));
from=find(logic_videos,1,'first')+1;% find(logic_videos&(logic_videos2|logic_videos3),1,'first')+1;
until=find(logic_videos,1,'last')+1;%find(logic_videos&(logic_videos2|logic_videos3),1,'last')+1;

% from=find(logic_videos,1,'first')+1; until=find(logic_videos,1,'last')+1;
%%
[~,Allfilenames]=xlsread(Vid_info_dir,'Tracking',['A' num2str(from) ':A' num2str(until)]);
MATLAB2Bonsai=xlsread(Vid_info_dir,'Tracking',['Y' num2str(from) ':Y' num2str(until)]);

MjAx=cell(size(params.IndexAnalyse,2),1);
MnAx=cell(size(params.IndexAnalyse,2),1);
Orientation=cell(size(params.IndexAnalyse,2),1);

prev_lfile=0;

for lfly=params.IndexAnalyse
    lfly
    filename=FlyDB(lfly).Filename;
    
    lfile=find(cell2mat(cellfun(@(x)~isempty(strfind(x,filename)),...
        Allfilenames,'uniformoutput',false)));
    
    if lfile~=prev_lfile
        if MATLAB2Bonsai(lfile)~=1
            %% Getting Bonsai tracking data
            fileID=fopen([TrackDataDir_Bonsai filename(1:end-4) '.csv']);
            C=textscan(fileID,...
                '%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f');
            % C={Xl, Yl, Orientationl, MajAxl, MinAxl, Areal,...
            %     Xc, Yc, Orc, MajAxc, MinAxc, Areac,...
            %     Xr, Yr, Orr, MajAxr, MinAxr, Arear};%Orientation in rads
            minsize=nan(18,1);
            for lcol=1:18
                minsize(lcol)=size(C{lcol},1);
            end
            for lcol=1:18
                C{lcol}=C{lcol}(1:min(minsize));
            end
            Cmat=cell2mat(C);
            
            if strfind(filename,'P2')
                Cmat2=Cmat;
                filename1=filename;
                filename1(17)='1';
                fileID=fopen([TrackDataDir_Bonsai filename1(1:end-4) '.csv']);
                C=textscan(fileID,...
                    '%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f');
                minsize=nan(18,1);
                for lcol=1:18
                    minsize(lcol)=size(C{lcol},1);
                end
                for lcol=1:18
                    C{lcol}=C{lcol}(1:min(minsize));
                end
                Cmat=cell2mat(C);
                Cmat=[Cmat;Cmat2];
            end
        else
            %% Getting MATLAB tracking data
            for arenaside=1:3
                load([TrackDataDir_Bonsai 'TrackingBonsaiParams-'...
                    filename(1:end-4) '-' sidelabel{arenaside} '.mat']);
            end
            
            TransfMatrix1=[-1 -1 0 0 0 0];
            TransfMatrix2=[1 1 -pi()/180 1 1 1];
            Cmat=[FlytracksNewL FlytracksNewC FlytracksNewR]+repmat(TransfMatrix1,size(FlytracksNewL,1),3);%[xc yc or MajAx MinAx A];
            Cmat=Cmat.*repmat(TransfMatrix2,size(FlytracksNewL,1),3);%[xc yc or MajAx MinAx A];
            
            if strfind(filename,'P2')
                Cmat2=Cmat;
                filename1=filename;
                filename1(17)='1';
                
                for arenaside=1:3
                    load([TrackDataDir_Bonsai 'TrackingBonsaiParams-'...
                        filename1(1:end-4) '-' sidelabel{arenaside} '.mat']);
                end
                
                TransfMatrix1=[-1 -1 0 0 0 0];
                TransfMatrix2=[1 1 -pi()/180 1 1 1];
                Cmat=[FlytracksNewL FlytracksNewC FlytracksNewR]+repmat(TransfMatrix1,size(FlytracksNewL,1),3);%[xc yc or MajAx MinAx A];
                Cmat=Cmat.*repmat(TransfMatrix2,size(FlytracksNewL,1),3);%[xc yc or MajAx MinAx A];
                Cmat=[Cmat;Cmat2];
            end
            
            clear FlytracksNewL FlytracksNewC FlytracksNewR
        end
    end
    arena=FlyDB(lfly).Arena;
    
    
    switch arena
        case 1
            FlytracksB=Cmat(:,1:6);
            
        case 2
            FlytracksB=Cmat(:,7:12);
            
        case 3
            FlytracksB=Cmat(:,13:18);
            
    end
    
    
    MjAx{lfly}=FlytracksB(1:params.MinimalDuration,4);
    MnAx{lfly}=FlytracksB(1:params.MinimalDuration,5);
    Orientation{lfly}=FlytracksB(1:params.MinimalDuration,3);
    
    prev_lfile=lfile;
end

% save([Variablesfolder 'RawMjAxes_' Exp_num Exp_letter ' ' date '.mat'],...
%     'MjAx','MnAx','Orientation','-v7.3')

%% Median MJAxis and Minor Axis
[MjAx_Sm2] = Smoothing(MjAx,16,'gaussian',1);
[MnAx_Sm2] = Smoothing(MnAx,16,'gaussian',1);
Median_MjMnAx=nan(size(params.IndexAnalyse,2),2);%two-col:[MjAx MnAx]
for lfly=params.IndexAnalyse
    Median_MjMnAx(lfly,1)=median(MjAx_Sm2{lfly});
    Median_MjMnAx(lfly,2)=median(MnAx_Sm2{lfly});
end
save([Variablesfolder 'RawMjAxes_' Exp_num Exp_letter ' ' date '.mat'],...
    'MjAx','MnAx','Orientation','Median_MjMnAx','-v7.3')

%% Compare MjAxes
% % MjAx_Sm=sqrt(sum(((Heads_Sm{lfly}(1:params.MinimalDuration,:)-...
% %                             Tails_Sm{lfly}(1:params.MinimalDuration,:)).^2),2));
%
% close all
% figure
% range=1:params.MinimalDuration;
% plot(range,MjAx{lfly}(range),'.-r')
%
% hold on
% plot(range,MjAx_Sm(range),'.-')
% plot(range,MjAx_Sm2{lfly}(range),'.-k')
