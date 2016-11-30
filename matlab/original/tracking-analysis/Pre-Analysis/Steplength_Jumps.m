%% Calculation and plotting of Steplength and Flips
%%% Script called by Heading.m

% Allfilenames={'0003A02R01Cam01P0WT-CantonS.avi'};
scrsz = get(0,'ScreenSize');
sidelabel={'Left';'Centre';'Right'};
px2mm=1/6.4353; % mm in 1 px
framerate=50;
% Heads_SteplengthDir='C:\Users\Vero\Documents\Analysis Data\Experiment 3\Heads_Steplength\';
% Movies_idx=find(Toprocess)';


for lfile=Movies_idx%1:length(Files)
    %% Calculating direction and Steplength of the fly using Head.
%     filename='0003A01R02Cam02P0WT-CantonS.avi';
    filename=Allfilenames{lfile}
    load([Heads_SteplengthDir 'DB-' typeofheads ' ' filename(1:end-4) '.mat'],'DB')
%     DB=rmfield(DB,'AngleDiff');
    DiffHxTx=cell(3,1);DiffHyTy=cell(3,1);Heading_temp=cell(3,1);FLipFr=cell(3,1);
    Thrshold_dist=15;
    for arenaside=1:3
        arenaside
        %% Heading (º)
        DiffHxTx{arenaside,1}=DB(arenaside).hBon(:,1)-DB(arenaside).tBon(:,1);
        DiffHyTy{arenaside,1}=DB(arenaside).hBon(:,2)-DB(arenaside).tBon(:,2);
        
        Heading_temp{arenaside,1}=atand(DiffHyTy{arenaside,1}./DiffHxTx{arenaside,1});
        
        %%% Correction given the quadrant: Transform Heading from [-90º,90º] to
        %%% [0º,360º]
        logicalII_IIIQ=(DiffHxTx{arenaside,1}<0);
        logicalIVQ=(DiffHxTx{arenaside,1}>0)&(DiffHyTy{arenaside,1}<0);
        
        Heading_temp{arenaside,1}(logicalII_IIIQ)=180+Heading_temp{arenaside,1}(logicalII_IIIQ); % Correction for vectors in II and III quandrant
        Heading_temp{arenaside,1}(logicalIVQ)=360+Heading_temp{arenaside,1}(logicalIVQ);  % Correction for vectors in IV quandrant
        Heading_temp{arenaside,1}=Heading_temp{arenaside,1}-floor(Heading_temp{arenaside,1}./360)*360; % Angle in degrees=[0,360]
        Heading_temp{arenaside,1}(Heading_temp{arenaside,1}>180)=Heading_temp{arenaside,1}(Heading_temp{arenaside,1}>180)-360; % Angle in degrees=[-180,180]
        DB(arenaside).Heading=Heading_temp{arenaside,1};
        
        %% Walking direction (º)
        frames_diff=diff(DB(arenaside).cBon);
        WalkingDir=atand(frames_diff(:,2)./frames_diff(:,1));
        %%% Correction for other quadrants and conversion from [0,360] to [-180,180]
        logicalII_IIIQ=(frames_diff(:,1)<0);
        logicalIVQ=(frames_diff(:,1)>0)&(frames_diff(:,2)<0);
        WalkingDir(logicalII_IIIQ)=180+WalkingDir(logicalII_IIIQ); % Correction for vectors in II and III quandrant
        WalkingDir(logicalIVQ)=360+WalkingDir(logicalIVQ);  % Correction for vectors in IV quandrant
        WalkingDir=WalkingDir-floor(WalkingDir./360)*360; % Angle in degrees=[0,360]
        WalkingDir(WalkingDir>180)=WalkingDir(WalkingDir>180)-360;
        DB(arenaside).WalkDir=WalkingDir;
        
        %% Calculating Heading differences/Flips
        DB(arenaside).HeadingDiff=CircleDiff(Heading_temp{arenaside,1}(1:end-1),Heading_temp{arenaside,1}(2:end));
        FLipFr{arenaside,1}=find(abs(DB(arenaside).HeadingDiff)>80);
        
        %% Calculating Steplength and Jumps
        frames_diff=diff(DB(arenaside).cBon);%cols:diffx,diffy. Rows:frames-1.
        DB(arenaside).Steplength=sqrt(sum((frames_diff).^2,2))*px2mm*framerate;%mm/s. v(1) is velocity of frame(1)
%         DB(arenaside).Jumps=find(DB(arenaside).Steplength>Thrshold_dist)';
        %% Smoothing Steplength
%         nl=floor(framerate*0.35);%(Window Size)/2
        [X_Y_corr]=Nan_Removal(DB(arenaside).Steplength,1);
        DB(arenaside).Vel_Filt=fastsmooth(X_Y_corr,3,1);
    end
    
    save([Heads_SteplengthDir 'DB-Heads ' filename(1:end-4) '.mat'],'DB')
end    
    %% PLotting Angle Differences/Flips
% figure('Position',[100 50 scrsz(3)-650 scrsz(4)-150])
% h=nan(4,1);
% legends={'\Delta Heading [º]';'Velocity (Raw) [mm/s]';...
%             'Velocity (Smoothed) [mm/s]';'Jump threshold'};
% for lfile=Movies_idx%1:length(Files)
%     %% Calculating direction and Steplength of the fly using Head.
%     %     filename=Files{lfile};%'0007C03R02Cam01P0WT-CantonS.avi'
% %     filename='0003A02R02Cam02P0WT-CantonS.avi';
%     filename=Allfilenames{lfile}
% %     load([Heads_SteplengthDir 'DB-Heads ' filename(1:end-4) '.mat'])
%     
% %     scrsz = get(0,'ScreenSize');
% %     figure('Position',[100 50 scrsz(3)-50 scrsz(4)-50])
%     clf    
%     cmap1=hsv(3);%[0 0 1];%
%     for arenaside=1:3
% %         arenaside=2
%         subplot(3,1,arenaside)
%         h(1)=plot(DB(arenaside).HeadingDiff,'Color',cmap1(arenaside,:));hold on
%         font_style([filename(1:end-14) sidelabel{arenaside}],'Frame Nº',['Heading Diff (º)'],'normal','calibri',16)
%         axeslimits=[0 size(DB(arenaside).HeadingDiff,1) -180 180];%[246700 247000 -40 40];%
%         axis(axeslimits)
%     end
%     
%     %% Plotting Steplength to detect jumps
%     % figure
%     cmap1=hsv(3);
%     for arenaside=1:3
%         subplot(3,1,arenaside)
% % arenaside=2
%         hold on
%         h(2)=plot(DB(arenaside).Steplength/framerate/px2mm,'-k','LineWidth',2);
%         hold on
%         font_style(filename(1:end-4),'Frame Nº','Steplength (px)','normal','calibri',16)
%         %         axis([0 size(DB(arenaside).HeadingDiff,1) -180 180])
%         %     axis([0 Finalframe 0 80])
%         %     plot([0 Finalframe],[Thrshold_dist Thrshold_dist],'-r','LineWidth',2)
%         %     text(0.5e5,70,['Nº events d>' num2str(Thrshold_dist) ' px = ' num2str(sum(DB(arenaside).Steplength>Thrshold_dist))],'FontName','calibri','FontSize',16)
%         h(3)=plot(DB(arenaside).Vel_Filt/framerate/px2mm,'-r','LineWidth',3);
%         ylim([-90 90])
% %         axis([0.6e4 2.1e4 -90 90])
%         AvWalkingSpeed=nanmean(DB(arenaside).Vel_Filt(DB(arenaside).Vel_Filt>StopVel))/framerate/px2mm;
%         h(4)=plot([0 350000],[4*AvWalkingSpeed 4*AvWalkingSpeed],'--m');
% %         plot([0 350000],[3*AvWalkingSpeed 3*AvWalkingSpeed],'-r')
%         axis(axeslimits)
% %         legend(h(h>0),legends(h>0))
%     end
%     
% %     saveas(gcf,['C:\Users\Vero\Documents\Analysis Data\Heading\Flips&Jumps ' filename(1:end-4) '.bmp'],'bmp')
%         
% %     pause
% end