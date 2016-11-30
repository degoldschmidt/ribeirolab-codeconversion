%%
% close all
% clear all
% clc
% format compact
% videoPath='C:\Users\Vero\Documents\Videos\Experiments\';
% Vid_info_dir='C:\Users\Vero\Dropbox (Behavior&Metabolism)\Personal\Experiments Videos Info.xlsx';
params.px2mm=1/6.4353; % mm in 1 px
from=543; until=543;
[~,Allfilenames]=xlsread(Vid_info_dir,'Tracking',['A' num2str(from) ':A' num2str(until)]);
load([DataSaving_dir_temp Exp_num '\Variables\FlyDataBase',...
            Exp_num Exp_letter ' ' date '.mat'])
        

%%
ProblemArenas=zeros(length(FlyDB),1);%Save arenas that couldn't be fitted
plot_int_outliers=0;%1;%Plot intensity outliers
plot_rad_outliers=0;%1;%Plot radius outliers
plot_innerl_rotation=0;%1;%Plot correction of inner length and rotation
plot_CenterXY=0;% Plot correction of center when 7 or 8 spots are detected
plot_edgethr=0;%Plot detected circles after edge threshold has been changed
plot_problems=1;% Plot detected spots when there is an unsolved problem
%%
Spot_File_idx=1;
for lfile=Spot_File_idx
    filename=Allfilenames{lfile};%
    log_filename_temp=cellfun(@(x)~isempty(strfind(x,filename)),{FlyDB.Filename},'uniformoutput',false);
    Database_numbers=find(cell2mat(log_filename_temp));
    Database_arenas=[FlyDB(Database_numbers).Arena];
    display(['lfile: ' num2str(lfile) ' - ' filename])
    
    %% Loading Heads info (To save afterwards)
    load([Heads_SteplengthDir 'DB-Heads ' filename(1:end-4) '.mat'])
    %% Loading movie
    try 
        flymovieCALIB=VideoReader([videoPath filename(1:end-4) ' Calib.avi']);
    catch err
        flymovieCALIB=VideoReader([videoPath filename]);
    end
    
    param.frameH2=flymovieCALIB.Height-15;
    param.frameW2=flymovieCALIB.Width;
    param.frameWL=floor(flymovieCALIB.Width/3)-10;%Width of left arena
    param.frameWC=2*floor(flymovieCALIB.Width/3);%Width center arena
    xCrop_ALL=[1 param.frameWL;param.frameWL param.frameWC;param.frameWC param.frameW2];%From the tracking
    AddCrop=25;%Additional crop, since we are only interested in the area with food
    
    dataCALIB = flymovieCALIB.read(1);
    
    gray_image=rgb2gray(dataCALIB);
    load mask.mat
    gray_image(mask==0)=median(median(gray_image));
    %% Alocating memory on important variables
    spot_idxs=cell(3,1);
    Detected=cell(3,1);
    Template=cell(3,1);
    DispAngle_All=zeros(1,3);%Iniate with default values for these parameters
    LengthInner_All=[1.27 1.27 1.27]*50;%Iniate with default values for these parameters
    WellPositions_All=zeros(19,6);
    WellPositions_All2=zeros(19,6);
    Radii_All=zeros(19,3);
    Center_temp=zeros(3,2);%Center of the cropped arenas
    Center=zeros(3,2);%Center of the arenas with respect to the full image
    
    %% Find circles in image and fit template
    
    for larena=2%Database_arenas
        sensit_thr=0.93;
        edge_thr=0.5;
        Case7_8=0;
        DBentry=Database_numbers((Database_arenas==larena));
        display(['Arena: ' num2str(larena)])
        find_spots__fit_template
    end
    
    
    %% Final plot
        close all
    figure('Position',[129 405 1652 564],'Color','w')%'Position',[2079,269,1652,564]
    imagesc(gray_image);colormap(gray);
    NOP=100;
    MSz=3;
    hold on
    for larena=2%Database_arenas
        DBentry=Database_numbers((Database_arenas==larena));
        if ProblemArenas(DBentry)==0
            

            for lcircle=find(FlyDB(DBentry).Geometry==1)
                %%% Plot detected for yeast
                [hc,xc1,yc1]=circle_(WellPositions_All(lcircle,2*larena-1:2*larena)+...
                    Center(larena,:),Radii_All(lcircle,larena),NOP);%MSz
                set(hc,'Color','c')
                %%% Plot template for yeast
                [hc,xc1,yc1]=circle_(WellPositions_All2(lcircle,2*larena-1:2*larena)+...
                    Center(larena,:),Radii_All(lcircle,larena),NOP);%MSz
                set(hc,'Color','b')
                text(WellPositions_All(lcircle,2*larena-1)+...
                    Center(larena,1)+15,WellPositions_All(lcircle,2*larena)+...
                    Center(larena,2),num2str(lcircle))
            end
            for lcircle=find(FlyDB(DBentry).Geometry==sec_subs)
                %%% Plot template for sucrose
                [hc,xc2,yc2]=circle_(WellPositions_All(lcircle,2*larena-1:2*larena)+...
                    Center(larena,:),Radii_All(lcircle,larena),NOP);%MSz
                set(hc,'Color','r')
                text(WellPositions_All(lcircle,2*larena-1)+...
                    Center(larena,1)+15,WellPositions_All(lcircle,2*larena)+...
                    Center(larena,2),num2str(lcircle))
            end

            [hc,xc3,yc3]=circle_(Center(larena,:),MSz,NOP);%0.5/params.px2mm
            set(hc,'Color','g')
            display({['Arena: ' num2str(larena)];...
                'Clic to save or press a key to skip'})
            if waitforbuttonpress % if key, include in Problems
                ProblemArenas(DBentry)=1;
            else %if clic, save
                FlyDB(DBentry).WellPos=[WellPositions_All(:,2*larena-1),...
                    -WellPositions_All(:,2*larena)];
                FlyDB(DBentry).RadiiWells=[Radii_All(:,larena)];
            end
        end
    end
    %% Saving in DB
    display(['Problems: ' num2str(ProblemArenas(Database_numbers)')])
    pause
    close all
    
%     variables={'DB','Center','DispAngle_All','LengthInner_All','WellPositions_All'};
%     save([Heads_SteplengthDir 'DB-Heads ' filename(1:end-4) '.mat'],variables{:})
%     saved=true;
    
    
    if lfile==Spot_File_idx(end)
        %% save FLYDB
        save([DataSaving_dir_temp Exp_num '\Variables\FlyDataBase',...
            Exp_num Exp_letter ' ' date '.mat'],'FlyDB','Allfilenames',...
            'Movies_idx','DB_idx','Note','remove')
        display(['Data Base has been saved with Spots. Number of Videos: ' num2str(length(DB_idx))])
    end
    
end

