%%
close all
clear all
clc
format compact

%% Input the experiment to Analyse
Exp_num='0006';
Exp_letter='A';

Comp=6;%6 is home, 3 is CCU open lab
if Comp==3
    DataSaving_dir_temp='E:\Analysis Data\Experiment ';
    videoPath='E:\Videos\';%'C:\Users\Vero\Documents\Videos\Experiments\';
elseif Comp==6
    DataSaving_dir_temp='G:\FLY TRACKER PROJECT\TRACKING AND VIDEO ANALYSIS\Data Analysis\Analysis Data\Experiment ';
     videoPath='D:\Videos\';
end
Heads_SteplengthDir=[DataSaving_dir_temp Exp_num '\Heads_Steplength\'];

params.px2mm=1/6.4353; % mm in 1 px
load([DataSaving_dir_temp Exp_num '\Variables\FlyDataBase',...
    Exp_num Exp_letter ' 27-Oct-2014.mat'])

Problemflies=zeros(length(FlyDB),1);
%%
sec_subs=2;
DBFilenames={FlyDB.Filename};
filename_prev='bla';

for lfly=4:6%1:length(FlyDB)
    filename=FlyDB(lfly).Filename;%
    display(['Fly: ' num2str(lfly)])
    
    %% Loading Heads info (To save afterwards)
    if isempty(strfind(filename_prev,filename))
        load([Heads_SteplengthDir 'DB-Heads ' filename(1:end-4) '.mat'],'Center')
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
    end
    
    
    
    %% Final plot
    close all
    figure('Position',[129 405 1652 564],'Color','w')%'Position',[2079,269,1652,564]
    imagesc(gray_image);colormap(gray);
    NOP=100;
    MSz=3;
    hold on
    larena=FlyDB(lfly).Arena;
    
    for lcircle=find(FlyDB(lfly).Geometry==1)
        %%% Plot detected for yeast
        [hc,xc1,yc1]=circle_(FlyDB(lfly).WellPos(lcircle,:).*[1 -1]+...
            Center(larena,:),1.5/params.px2mm,NOP);%MSz
        set(hc,'Color','b')
               
    end
    for lcircle=find(FlyDB(lfly).Geometry==sec_subs)
        %%% Plot template for sucrose
        [hc,xc2,yc2]=circle_(FlyDB(lfly).WellPos(lcircle,:).*[1 -1]+...
            Center(larena,:),1.5/params.px2mm,NOP);%MSz
        set(hc,'Color','r')
        
    end
    
    [hc,xc3,yc3]=circle_(Center(larena,:),MSz,NOP);%0.5/params.px2mm
    set(hc,'Color','g')
    display({['Arena: ' num2str(larena)];...
        'Clic to continue or press a key to mark a problem'})
    if waitforbuttonpress % if key, include in Problems
        Problemflies(lfly)=1;
   end
    
    
    
    filename_prev=filename;
end
