%% Defining what to plot
delay=30;%frames20;%30;%if larger than zero will show dynamic plot
dur_sec=20;%25;%sec
startpoint=40;%sec
Vartoplot='YFeedingEvents';
% Info.YFeedingEvents=...
%     [56086+startpoint*50 56086+(startpoint+dur_sec)*50 1 8];%[56086+40*50 56086+60*50 1 8];%[56086 65469 1 8];%
Info.YFeedingEvents=...
    [15688 16264 1 32;...
    24351 25189 1 31;...
    12922 13288 1 31;...
    71004 71343 1 1;...
    30690 31997 1 30;...
    112600 115200 9 1;...
    146500 150200 1 89;...
    32100 35617 1 97;...
    34381 36082 1 119;...
    54055 55393 1 119;...
    54055 55653 1 120;...
    73757 76068 1 119;...
    150300 151962 1 119;...
    150300 151962 1 120;...
    158291 159200 1 119;...
    158291 159600 1 120;...
    34381 36080 1 120;...
    29350 32553 1 97;...
    29350 33294 1 96;...
    51837 54011 1 3];

for lrow=6%14:size(Info.YFeedingEvents,1)
    frames2test=Info.YFeedingEvents(lrow,1:2);
    lfly=Info.(Vartoplot)(lrow,4);
    Geometry=FlyDB(lfly).Geometry;
    
    sameimage=0;
    if sameimage==0
        prev_filename='0';
    end
    %% Video parameters
    Heads_SteplengthDir=[DataSaving_dir_temp Exp_num '\Heads_Steplength\'];
    videoPath =['F:\Videos\Exp ' Exp_num '\'];%['F:\PROJECT INFO\Videos\Exp ' Exp_num '\'];%
    figname=[Vartoplot 'Visits - Fly ' num2str(lfly),...
        ', ' num2str(frames2test(1)-delay) ' to ' num2str(frames2test(end)+delay) ' ' date];
    
    RecordVideo=0;%1;%Set to 1 to save video
    fps=25;%20;%40;%15
    fixedframe=0;
    
    if RecordVideo==1
        saving_dir=[DataSaving_dir_temp Exp_num '\Plots\Videos\'];
        SaveVideoPath=[saving_dir figname '_fps' num2str(fps) 'd50_20s.avi'];
        vidObj=VideoWriter(SaveVideoPath);
        vidObj.FrameRate=fps;
        vidObj.Quality=100;
        open(vidObj);
    end
    %% Figure parameters
    save_plot=0;
    merged=1;
    FtSz=12;%20;
    FntName='arial';
    LineW=2;
    AxisWidth=2;
    
    x=0.07;y=0.07;dy=0.07;%x=0.18;y=0.11;dy=0.03;
    heightsubplot=(1-2*y-4*dy)/4;
    widthsubplot2=.5;
    widthsubplot=1-1.5*x-widthsubplot2-0.05;
    
    % Subplot_positions=[x y+3*heightsubplot+4*dy widthsubplot heightsubplot;...
    %     x y+2*heightsubplot+3*dy widthsubplot heightsubplot;...
    %     x y+2*heightsubplot/2+2*dy widthsubplot heightsubplot;...
    %     x y+heightsubplot/2+dy widthsubplot heightsubplot/2;...
    %     x y widthsubplot heightsubplot/2;...
    %     x+widthsubplot+0.05 y widthsubplot2 1-1.5*y];
    Subplot_positions=[x+widthsubplot2+0.05 y+3*heightsubplot+4*dy widthsubplot heightsubplot;...
        x+widthsubplot2+0.05 y+2*heightsubplot+3*dy widthsubplot heightsubplot;...
        x+widthsubplot2+0.05 y+2*heightsubplot/2+2*dy widthsubplot heightsubplot;...
        x+widthsubplot2+0.05 y+heightsubplot/2+dy widthsubplot heightsubplot/2;...
        x+widthsubplot2+0.05 y widthsubplot heightsubplot/2;...
        x-0.03 y widthsubplot2 1-1.5*y];
    
    %% Other parameters
    %%% Colors, format parameters
    [Color, Colorpatch]=Colors(3);
    
    WalkingEtho_Colors=[Color(3,:);[1 1 1];[0.5 0.5 0.5]];%[blue, white, gray]
    Param_color=[235 135 15]/255;
    ShadeColor=[192 110 139]/255;
    
    if ~exist('Etho_Speed_new','var')
        [Etho_Speed_new,Etho_colors_new,Etho_Colors_Labels] = Etho_Speed2New(params.MinimalDuration,Etho_Speed,merged);
    end
    
    Etho_H_Speed=Etho_Speed_new;
    Etho_H_Speed(Etho_H==9)=6;%YHmm
    Etho_H_Speed(Etho_H==10)=7;%SHmm
    EthoH_Colors=[Etho_colors_new;...
        [240 228 66]/255;...%6 - Yellow (Yeast micromovement)
        0 0 0];%7 - Sucrose
    
    %% Preparing video plot
    delta=50;
    filename=FlyDB(lfly).Filename; %'0003A02R02Cam02P0WT-CantonS.avi';
    
    if isempty(strfind(prev_filename,filename))
        load([Heads_SteplengthDir 'DB-Heads ' filename(1:end-9) '.mat'],'Center')
    end
    arenaside=FlyDB(lfly).Arena;
    
    Cents_tmp=[Centroids_Sm{lfly}(:,1)+Center(arenaside,1),...
        Center(arenaside,2)-Centroids_Sm{lfly}(:,2)];
    
    Heads_tmp=[Heads_Sm{lfly}(:,1)+Center(arenaside,1),...
        Center(arenaside,2)-Heads_Sm{lfly}(:,2)];
    Tails_tmp=[Tails_Sm{lfly}(:,1)+Center(arenaside,1),...
        Center(arenaside,2)-Tails_Sm{lfly}(:,2)];
    
    if isempty(strfind(prev_filename,filename))
        if strfind(filename,'P2')
            filename(17)='1';
        end
            MovieObj=VideoReader([videoPath filename(1:end-5)]);
    end
    CmapSubs=[238 96 8;0 0 0]/255;
    YSpots=find(FlyDB(lfly).Geometry==1);
    SSpots=find(FlyDB(lfly).Geometry==2);
    WellPos(:,1)=FlyDB(lfly).WellPos(:,1)+Center(arenaside,1);
    WellPos(:,2)=Center(arenaside,2)-FlyDB(lfly).WellPos(:,2);
    
    clear Rawimage Rawimage2
    Rawimage=read(MovieObj,[frames2test(1) frames2test(end)]);
    Rawimage2=Rawimage(:,:,1,:);
    %% Calculating Distance to spots
    Wholerange=frames2test(1):frames2test(2);
    
    Spots=Info.(Vartoplot)(1,3);
    lsubs=Geometry(Spots);
%     AlldistsSpots=nan(length(Wholerange)+delay,19);
    AlldistsSpots=nan(length(Wholerange),19);
%     Realrange=[Wholerange frames2test(2)+1:frames2test(2)+delay];
    for n=1:19
        Dist2Spots_temp=sqrt(sum(((Heads_Sm{lfly}(Wholerange,:)-...Realrange
            repmat(FlyDB(lfly).WellPos(n,:),...
            length(Wholerange),1)).^2),2));%Realrange
        AlldistsSpots(:,n)=Dist2Spots_temp;
    end
    Dist2Spots=min(AlldistsSpots,[],2);
    %% Plotting
    close all
    fig=figure('Position',[50 50 1408 768],'Color','w','PaperUnits','centimeters',...
        'PaperPosition',[1 1 9 9],'Name',figname);%
    
    x_label='Time (s)';
    x_lim=[frames2test(1) frames2test(2)];
    Xtick=(0:5:(frames2test(2)-frames2test(1))/50)*50+frames2test(1);
    Xticklabel=cellfun(@(x)num2str(x),num2cell((0:5:(frames2test(2)-frames2test(1))/50)),'uniformoutput',0);
    
    %% Figure
    for lframe=Wholerange(1:2:end)%Wholerange(delay+1:2:end)
        clf
        range=frames2test(1):lframe;
        headingframes=range(1:10:end);
        
        framestart=lframe-delay;
        if framestart<frames2test(1),framestart=frames2test(1);end
        rangedelay=framestart:lframe;
        framestart2=lframe-5*50;
        if framestart2<frames2test(1),framestart2=frames2test(1);end
        rangedelay2=framestart2:lframe;
        %% Dist 2 closest Spot
        lplot=1;
        subplot('Position',Subplot_positions(lplot,:))% To be on top
        
        hold on
        clear X
        X=Dist2Spots*params.px2mm;
        
        var_label={'Distance';'to closest patch';'(mm)'};
        titleplot=['Fly ' num2str(lfly) ' - ' params.LabelsShort{params.ConditionIndex(lfly)},...
            ' Frames: ' num2str(frames2test(1)) '-' num2str(frames2test(2))];
        lowthr=2.5;%2.3;%2.2;%1.9;
        uppthr=5;%3;
        plot_kinetic(X,1:length(range),range,lowthr,uppthr,LineW,'k');
        font_style(titleplot,[],var_label,'bold',FntName,FtSz)
        xlim(x_lim)
        %     rangedist=lframe-frames2test(1)+1-150:lframe-frames2test(1)+1;
        y_lim=[min(X)-...
            0.1*abs(min(X)) max(X)+0.1*abs(max(X))];%
        ylim(y_lim);
        set(gca,'XTick',Xtick,'XTickLabel',Xticklabel,'Linewidth',AxisWidth,'FontWeight','bold')%Bottom part of axis
        %     xlabel([])
        
        
        %% Steplength
        lplot=lplot+1;
        subplot('Position',Subplot_positions(lplot,:))%if only dist on top
        
        hold on
        clear X
        X=Steplength_Sm_h{lfly}*params.px2mm*params.framerate;
        %%%
        plot([range(1) range(end)],[.2 .2],'--','Color',[.7 .7 .7])
        
        var_label={'Speed';'(mm/s)'};
        figname=[];
        lowthr=0.2;uppthr=2;%lowthr=0.05;uppthr=nan;%
        
        h1=plot_kinetic(X,range,range,lowthr,uppthr,LineW,[0 114 178]/255);
        
        font_style(figname,[],var_label,'bold',FntName,FtSz)
        
        h2=plot(range,Steplength_Sm_c{lfly}(range)*params.px2mm*params.framerate,'--',...
            'LineWidth',LineW,'Color','k');
        
        xlabel([])
        legend([h1,h2],{'Head';'Body'},'Position',...
            [x+.9*widthsubplot y+2.8*heightsubplot+3*dy .005 .02],'FontSize',FtSz-1)
        legend('boxoff')
        
        xlim(x_lim)
        y_lim=[min(X(rangedelay2))-0.1*abs(min(X(rangedelay2))) max(X(rangedelay2))+0.1*abs(max(X(rangedelay2)))];%
        ylim(y_lim);
        set(gca,'XTick',Xtick,'XTickLabel',Xticklabel,'Linewidth',AxisWidth,'FontWeight','bold')
        
        %% Angular speed
        lplot=lplot+1;
        subplot('Position',Subplot_positions(lplot,:))%0.26 Y
        hold on
        clear X
        if ~exist('HeadingDiff','var'),flies_idx=params.IndexAnalyse;
            [~,~,HeadingDiff] =Heading_WalkingDir(Heads_Sm,Tails_Sm,Centroids_Sm);
        end
        X=(HeadingDiff{lfly})*params.framerate;%WalkingDirDiff{lfly};
        
        var_label={'Angular';'Speed';'(º/s)'};%{'Change in Walk Dir';'(º/0.02 s)'};
        figname=[];
        lowthr=-125;uppthr=125;
        plot_kinetic(X,range,range,lowthr,uppthr,LineW,'k');
        font_style(figname,[],var_label,'bold',FntName,FtSz)
        xlim(x_lim)
        y_lim=[min(X(Wholerange))-0.1*abs(min(X(Wholerange))) max(X(Wholerange))+0.1*abs(max(X(Wholerange)))];%
        ylim(y_lim);
        set(gca,'XTick',Xtick,'XTickLabel',Xticklabel,'Linewidth',AxisWidth,'FontWeight','bold')
        
        %% Ethogram
        lplot=lplot+1;
        subplot('Position',Subplot_positions(lplot,:))
        
        image(Etho_H_Speed(lfly,range))
        colormap(EthoH_Colors);
        freezeColors
        hold on
        font_style([],...
            [],{'Etho-';'gram'},'bold',FntName,FtSz)
        xlim([0 Wholerange(end)-Wholerange(1)])
        set(gca,'YTickLabel',[],'YTick',[],'XTick',Xtick-frames2test(1),'XTickLabel',Xticklabel,'Box','off','Linewidth',AxisWidth,'FontWeight','bold')
        
        %% Visits Binary Raster plot
        lplot=lplot+1;
        AxVisits=axes('Position',Subplot_positions(lplot,:));
        BinaryYSVisits=CumTimeV{1}(range,lfly);
        BinaryYSVisits(BinaryYSVisits==0)=3;
        BinaryYSVisits(CumTimeV{2}(range,lfly)==1)=2;
        
        image(BinaryYSVisits','Parent',AxVisits)
        [~,~,~,VisitsColor]=ColorsPaper5cond_fun;
        colormap(AxVisits,[VisitsColor;1 1 1]);%170 170 170
        Visit_Labels={'Yeast','Sucrose','Not visit'};
        %     hcb=colorbar;set(hcb,'YTick',(1:3),...
        %          'YTickLabel',Visit_Labels,'FontName',FntName,'FontSize',FtSz,...
        %          'Position',[x+.9*widthsubplot y+.1*heightsubplot .02 .1])
        freezeColors
        y_limetho=get(gca,'Ylim');
        hold on
        font_style([],...
            'Time (s)','Visits','bold',FntName,FtSz)
        set(gca,'XTick',Xtick-frames2test(1),'XTickLabel',Xticklabel,...
            'Box','off','YTickLabel',[],'YTick',[],'Linewidth',AxisWidth,'FontWeight','bold')
        xlim([0 Wholerange(end)-Wholerange(1)])
        
        
        %% Video
        framecenter=lframe;
        lplot=lplot+1;
        axVid=axes('Position',Subplot_positions(lplot,:));
        freezeColors
        imshow(Rawimage2(:,:,1,Wholerange==lframe),'Parent',axVid)
        axes_lim=[1115 1115+140 152 152+140];
        p=0.9;
        hold on
        
        inspot=0;
        lsubs=0;
        spotrad=1.5;%1.5;%
        %%% Plotting Spots
        for nspot=YSpots
            [c,xc,yc]=circle_([WellPos(nspot,1),...
                WellPos(nspot,2)],...
                spotrad/params.px2mm,100,'-b');
            set(c,'Color',CmapSubs(1,:),'LineWidth',LineW,'Parent',axVid)
            if nspot==Spots
                [c]=circle_([WellPos(nspot,1),...
                    WellPos(nspot,2)],...
                    2.5/params.px2mm,100,'--b');
                set(c,'Color',CmapSubs(1,:),'LineWidth',0.5,'Parent',axVid)
            end
            
            if fixedframe==1
                conditional=(WellPos(nspot,1)>axes_lim(1))&&...
                    (WellPos(nspot,2)>axes_lim(3))&&...
                    (WellPos(nspot,1)<axes_lim(2))&&...
                    (WellPos(nspot,2)<axes_lim(4));
            else
                
                conditional=(WellPos(nspot,1)>Heads_tmp(framecenter,1)-p*delta)&&...
                    (WellPos(nspot,2)>Heads_tmp(framecenter,2)-p*delta)&&...
                    (WellPos(nspot,1)<Heads_tmp(framecenter,1)+p*delta)&&...
                    (WellPos(nspot,2)<Heads_tmp(framecenter,2)+p*delta);
            end
            
            if conditional
                t=text(WellPos(nspot,1), WellPos(nspot,2),'Yeast',...
                    'FontWeight','bold','FontName',FntName,'FontSize',FtSz);
                set(t,'HorizontalAlignment','center','Parent',axVid)
            end
        end
        for nspot=SSpots
            [c,xc,yc]=circle_([WellPos(nspot,1),...
                WellPos(nspot,2)],...
                spotrad/params.px2mm,100,'-r');
            set(c,'Color',CmapSubs(2,:),'LineWidth',LineW,'Parent',axVid)
            if fixedframe==1
                conditional=(WellPos(nspot,1)>axes_lim(1))&&...
                    (WellPos(nspot,2)>axes_lim(3))&&...
                    (WellPos(nspot,1)<axes_lim(2))&&...
                    (WellPos(nspot,2)<axes_lim(4));
            else
                
                conditional=(WellPos(nspot,1)>Heads_tmp(framecenter,1)-p*delta)&&...
                    (WellPos(nspot,2)>Heads_tmp(framecenter,2)-p*delta)&&...
                    (WellPos(nspot,1)<Heads_tmp(framecenter,1)+p*delta)&&...
                    (WellPos(nspot,2)<Heads_tmp(framecenter,2)+p*delta);
            end
            if conditional
                t=text(WellPos(nspot,1), WellPos(nspot,2),'Sucrose',...
                    'FontWeight','bold','FontName',FntName,'FontSize',FtSz);
                set(t,'HorizontalAlignment','center','Parent',axVid)
            end
        end
        
        
        
        %%% Plot line and marker for Head centroid
        plot(Heads_tmp(rangedelay,1),...
            Heads_tmp(rangedelay,2),'-w','LineWidth',3)
        plot(Heads_tmp(rangedelay,1),...
            Heads_tmp(rangedelay,2),'ow','MarkerFaceColor','w','MarkerSize',2)
        %%% Plotting Etho trajectory
        colormap_segments=EthoH_Colors;%Etho_Tr_Colors;%
        etho_segments=Etho_H_Speed(lfly,:);%Etho_Tr(lfly,:);%
        plot_traj_etho_video(Heads_tmp,rangedelay,etho_segments,colormap_segments,...
            2,Cents_tmp,Tails_tmp)
        plot_traj_etho_video2(Heads_tmp,frames2test(1):lframe,etho_segments,colormap_segments,...
            2)
        %%% Getting axis
        axis equal
        axis on
        set(gca,'Xtick',[],'YTick',[],'LineWidth',AxisWidth)
        
        if fixedframe==1
            axis(axes_lim)
        else
            axis([floor(Heads_tmp(framecenter,1))-delta,...
                floor(Heads_tmp(framecenter,1))+delta,...
                floor(Heads_tmp(framecenter,2))-delta,...
                floor(Heads_tmp(framecenter,2))+delta])
        end
        %%
        if RecordVideo==1
            F1=getframe(fig);
            writeVideo(vidObj,F1);
        else
            pause(0.1)
        end
    end
    
    if RecordVideo==1,
        close(vidObj);
    end
    
    %% Saving a summary image of the video
    set(gcf,'PaperUnits','centimeters',...
    'PaperPosition',[1 1 35 20])
    savefig_withname(0,'300','png',DataSaving_dir_temp,Exp_num,Exp_letter,...
        'Videos')
end
