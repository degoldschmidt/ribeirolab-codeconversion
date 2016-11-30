%% Plotting Fly trajectory and kinematic parameters
%% Segment to plot
delay=0;%20;%30;%if larger than zero will show dynamic plot
deltaf=1;
Annotationrows=0;
close all
fig=figure('Position',[2000+150 50 1600 950],'Color','w');%


ManualAnnotation.YFeedingEvents=[25700 30565 7 32];%[332663 344999 7 1];%[65875 65944 1 32];%%[88753 89859 1 32];%[89653 89859 1 32];%[121826 134731 16 113];

Vartoplot='YFeedingEvents';%'Revisits';%'Grooming';%'Rest';%'YeastSpilledFakeRV';%'Not_engage_Y';
rows2plot=1%2:size(ManualAnnotation.(Vartoplot)(:,1),1);%[1 6 8 22 37 39 40 43];%

%% Other parameters
%%% Colors, format parameters
insec=0;%0;
ActivityBouts_Colors=[238 96 8;0 0 0;0 166 0; 255 255 255]/255;%[Orange, Black, Green, White]

[Color, Colorpatch]=Colors(3);
Etho_Colors=[...
        [0.6 0.6 0.6]*255;...%1 - Gray (Resting)
        Color(1,:)*255;...%2 - Purple (slow micromovement)
        204 140 206;...%3 - Light Purple (fast-micromovement)
        124 143 222;...%4 -  Blueish violet (Slow walk)
        Color(3,:)*255;...%5 - Light Blue (Walking)
        Color(2,:)*255;...%6 - Green (Turn)
        255 0 0;...%7 - Red (Jump)
        250 244 0;...%8 - Yellow (Activity Bout)
        238 96 8;...%9 - Orange(Yeast head slow micromovement)
        0 0 0]/255;%10 - Black (Exploiting sucrose (Feeding))


WalkingEtho_Colors=[Color(3,:);[1 1 1];[0.5 0.5 0.5]];%[blue, white, gray]
Param_color=[235 135 15]/255;
ShadeColor=[192 110 139]/255;
FtSz=7;%20;
LineW=0.8;%1.2;%Not saving
FntName='arial';
plotmanual_ann_edge=1;

%%% Video parameters
fps=20;
step=50;
Repeatloop=1;% Times to repeat display

%%% Filenames for Video
figname_pre=[Vartoplot 'Engage,Dist2Spot,Speed,Traj - Fly '];
saving_dir=[DataSaving_dir_temp Exp_num '\Plots\Presentations\'];

%% Plotting

clf
ltracecounter=0;
for lrow=rows2plot
    ltracecounter=ltracecounter+1;
    ltrace=ManualAnnotation.(Vartoplot)(lrow,1);
    display([Vartoplot ' Bout ' num2str(rows2plot(ltracecounter))])
    lfly=ManualAnnotation.(Vartoplot)(lrow,4);
    Geometry=FlyDB(lfly).Geometry;
    range=ltrace-deltaf:ManualAnnotation.(Vartoplot)(lrow,2)+deltaf;
    
    Spots=ManualAnnotation.(Vartoplot)(lrow,3);
    lsubs=Geometry(Spots);
    Dist2Spots=sqrt(sum(((Heads_Sm{lfly}-...
        repmat(FlyDB(lfly).WellPos(Spots,:),...
        length(Heads_Sm{lfly}),1)).^2),2));
    
    clf
    x_label='Time (frames)';
    if insec==1,
        framerate=params.framerate;
        timerange=range/params.framerate/60;%
        delta=deltaf/params.framerate/60;%
        x_label='Time (min)';
    else
        timerange=range;
        framerate=0;
        delta=deltaf;
    end
    
    x_lim=[timerange(1) timerange(end)];
    
    
    %% Figure
    dpx=1;
    axeslimstraj=[min(min([Heads_Sm{lfly}(range,1),Tails_Sm{lfly}(range,1)]))-dpx,...
        max(max([Heads_Sm{lfly}(range,1),Tails_Sm{lfly}(range,1)]))+dpx,...
        min(min([Heads_Sm{lfly}(range,2),Tails_Sm{lfly}(range,2)]))-dpx,...
        max(max([Heads_Sm{lfly}(range,2),Tails_Sm{lfly}(range,2)]))+dpx]*params.px2mm;
    
    
    frames=range;
    timerange2=range;
    headingframes=frames(1:10:end);
    
    
    if insec==1,timerange2=frames/framerate/60;%
    end
    
    
    clf
    
    %% Head Trajectory and dynamic body orientation with delay
    subplot('Position',[0.07 0.11 0.36 0.81])
    hold on
    
    %%% Thick and thin line for Heads
    hc(2)=plot_tracks_single(FlyDB,Heads_Sm{lfly},lfly,Spots,params,1,...
        'k',frames,FtSz,1,2*LineW);%Color(1,:)
    %%% Markers for start and end of the visit
    plot(Heads_Sm{lfly}(frames(1)+deltaf,1)*params.px2mm,...%fixed from beginning(framestart:lframe,1),...%with delay
        Heads_Sm{lfly}(frames(1)+deltaf,2)*params.px2mm,'oy','Color',Color(2,:),...
        'MarkerEdgeColor',Color(2,:),'MarkerFaceColor',Color(2,:),'MarkerSize',4)
    plot(Heads_Sm{lfly}(frames(end)-deltaf,1)*params.px2mm,...%fixed from beginning(framestart:lframe,1),...%with delay
        Heads_Sm{lfly}(frames(end)-deltaf,2)*params.px2mm,'oy','Color',Color(2,:),...
        'MarkerEdgeColor',Color(2,:),'MarkerFaceColor',Color(2,:),'MarkerSize',4)
    text(Heads_Sm{lfly}(frames(1)+deltaf,1)*params.px2mm,...
        Heads_Sm{lfly}(frames(1)+deltaf,2)*params.px2mm,{'visit';'starts'},...+.3
        'FontWeight','normal','FontName',FntName,'FontSize',FtSz,'Color',[0.5 0.5 0.5])
    text(Heads_Sm{lfly}(frames(end)-deltaf,1)*params.px2mm,...
        Heads_Sm{lfly}(frames(end)-deltaf,2)*params.px2mm,{'visit';'ends'},...
        'FontWeight','normal','FontName',FntName,'FontSize',FtSz,'Color',[0.5 0.5 0.5])
    
    %% Find behaviour bouts surrounding time segment
    for letho=1:length(Etho_Colors)
        
        starts=find(conv(double(Etho_Speed{lfly}==letho),[1 -1])==1);
        ends=find(conv(double(Etho_Speed{lfly}==letho),[1 -1])==-1)-1;
        
        bout_start1=find(starts<range(1),1,'last');
        bout_start2=find(starts<range(end),1,'last');
        bout_start=min([bout_start1,bout_start2]);
        bout_end1=find(ends>range(end),1,'first');
        bout_end2=find(ends>range(1),1,'first');
        bout_end=max([bout_end1,bout_end2]);
        Colormicromovement=Etho_Colors(letho,:);
        for lmicrobout=bout_start:bout_end
            frames_etho=starts(lmicrobout):ends(lmicrobout);
            
            frames_etho(frames_etho<frames(1))=[];
            frames_etho(frames_etho>frames(end))=[];
            if ~isempty(frames_etho)
                plot(Heads_Sm{lfly}(frames_etho,1)*params.px2mm,...
                    Heads_Sm{lfly}(frames_etho,2)*params.px2mm,...
                    'LineWidth',1.5*LineW,'Color',Colormicromovement)
                
            end
            
        end
    end
    %%
    axis(axeslimstraj)%axis([-1 19 -15 6])%YBout39
    axis off
    %% Pixel size lines
%     x=-33:params.px2mm:33;
%     plot([x;x],[repmat(-33,1,length(x));repmat(33,1,length(x))],':k',...
%         'Color',[.7 .7 .7])
%     hold on
%     plot([repmat(-33,1,length(x));repmat(33,1,length(x))],[x;x],':k',...
%         'Color',[.7 .7 .7])
    
    %% Dist 2 Spot
    %         subplot('Position',[0.5416    0.59    0.3628    0.12])% If ethogram on top
    subplot('Position',[0.5416    0.67    0.3628    0.12])% To be on top
    
    hold on
    severalplots=0;
    clear X
    X=Dist2Spots*params.px2mm;
    
    var_label={'Dist from spot';'(mm)'};
    figname=[];
    lowthr=2.5;%2.2;%1.9;
    uppthr=nan;%3;
    %     plot([range(1) range(end)],[2.2 2.2],'--')
    plot_mann_ann
    ylim(y_lim)
    set(gca,'XTickLabel',[],'XTick',[])
    xlabel([])
    text(timerange(1)+delta+0.01,y_lim(2)+0.15,{'visit';'starts'},...
        'FontWeight','normal','FontName',FntName,'FontSize',FtSz-1,'Color',[0.5 0.5 0.5])
    text(timerange(end)-delta+0.01,y_lim(2)+0.15,{'visit';'ends'},...
        'FontWeight','normal','FontName',FntName,'FontSize',FtSz-1,'Color',[0.5 0.5 0.5])
    title(['Annotated bout #',...
        num2str(rows2plot(ltracecounter))])
    %% Steplength
    %         subplot('Position',[0.5416    0.46   0.3628    0.1])%if ethogram on top [0.5416    0.21    0.3628    0.18]
    subplot('Position',[0.5416    0.54   0.3628    0.1])%if only dist on top
    
    hold on
    severalplots=1;
    clear X
    X=Steplength_Sm_h{lfly}*params.px2mm*params.framerate;
    %%%
    plot([range(1) range(end)],[.2 .2],'--','Color',[.7 .7 .7])
    %%% Plot local minima
    temp=diff(X);
    temp(temp>0)=1;
    temp(temp<0)=-1;
    localminima=find(diff(temp)==2);
    localmax=find(diff(temp)==-2);
    %             plot(localminima,X(localminima),'o','MarkerSize',3,'MarkerFaceColor','b')
    %             plot(localmax,X(localmax),'og','MarkerSize',3,'MarkerFaceColor','g')
    
    %%% Plot of shaded area where walking bout
    walkstarts=find(conv(double(Walking_vec{lfly}==1),[1 -1])==1);
    walkends=find(conv(double(Walking_vec{lfly}==1),[1 -1])==-1);
    
    %%% Find walking bouts surrounding time segment
    boutstart=find(walkstarts<range(1),1,'last');
    boutend=find(walkends>range(end),1,'first');
    for lwalkingbout=boutstart:boutend
        if insec==1
            fillhw=fill([walkstarts(lwalkingbout);walkstarts(lwalkingbout);...
                walkends(lwalkingbout); walkends(lwalkingbout)]/framerate/60,...
                [0;25;...
                25;0],...
                Colorpatch(3,:));
        else
            fillhw=fill([walkstarts(lwalkingbout);walkstarts(lwalkingbout);...
                walkends(lwalkingbout); walkends(lwalkingbout)],...
                [0;25;...
                25;0],...
                Colorpatch(3,:));
        end
        set(fillhw,'EdgeColor',Colorpatch(3,:))%,'FaceAlpha',.5,...
        %                 'EdgeAlpha',.5);
    end
    
    %%% Plot of shaded area where inactivity bout
    inactstarts=find(conv(double(Walking_vec{lfly}==3),[1 -1])==1);
    inactends=find(conv(double(Walking_vec{lfly}==3),[1 -1])==-1);
    %%% Find inactivity bouts surrounding time segment
    boutstart1=find(inactstarts<range(1),1,'last');
    boutstart2=find(inactstarts<range(end),1,'last');
    boutstart=min([boutstart1,boutstart2]);
    boutend1=find(inactends>range(end),1,'first');
    boutend2=find(inactends>range(1),1,'first');
    boutend=max([boutend1,boutend2]);
    %                 display('Inactivity moments inside this range')
    for linactbout=boutstart:boutend
        %                     display([num2str(inactstarts(linactbout)) ':' num2str(inactends(linactbout))])
        if insec==1
            fillhin=fill([inactstarts(linactbout);inactstarts(linactbout);...
                inactends(linactbout); inactends(linactbout)]/framerate/60,...
                [0;25;...
                25;0],...
                [0.9 0.9 0.9]);
        else
            fillhin=fill([inactstarts(linactbout);inactstarts(linactbout);...
                inactends(linactbout); inactends(linactbout)],...
                [0;25;...
                25;0],...
                [0.9 0.9 0.9]);
        end
        set(fillhin,'EdgeColor',[0.9 0.9 0.9],'FaceAlpha',.5,...
            'EdgeAlpha',.5);
    end
    
    
    var_label={'Speed';'(mm/s)'};
    figname=[];
    lowthr=0.8;uppthr=2;%lowthr=0.05;uppthr=nan;%
    
    h1=plot_kinetic(X,frames,timerange2,lowthr,uppthr,LineW,Color(3,:));
    plot_mann_ann
    h2=plot_kinetic(Steplength_Sm_c{lfly}*params.px2mm*params.framerate,...
        frames,timerange2,lowthr,uppthr,LineW,Color(2,:));
    set(gca,'XTickLabel',[],'XTick',[])
    xlabel([])
    legend([h1,h2],{'Head';'Centr'},'Location','Best','FontSize',FtSz-1)%'Position',[.915 0.56 .05 .05]
    legend('boxoff')
    %             ylim([0 0.8])
    %             text(timerange(1)+delta,X(frames(1)+deltaf),...
    %              num2str(X(frames(1)+deltaf)),'FontSize',15,...
    %              'FontName','calibri')
    
    %% Head Micromovement bouts
    subplot('Position',[0.5416    0.48    0.3628    0.03])
    hold on
    severalplots=0;
    clear X
    X=Binary_Head_mm(:,lfly);
    var_label={'Head';'bouts'};
    plot_kinetic(X,frames,timerange2,nan,nan,LineW,Color(3,:));
    plot_kinetic(X,frames,timerange2,nan,nan,LineW-.5*LineW,'k');
    font_style([],[],var_label,'normal',FntName,FtSz)
    xlim(x_lim)
    ylim([-.1 1.1])
    set(gca,'XTickLabel',[],'XTick',[],'Box','off')
    xlabel([])
    %% Activity Bouts
    subplot('Position',[0.5416    0.43    0.3628    0.03])
    hold on
    severalplots=0;
    clear X
    X=Binary_AB(:,lfly);
    var_label={'Act';'bouts'};
    figname=[];
    lowthr=nan;uppthr=nan;
    plot_kinetic(X,frames,timerange2,lowthr,uppthr,LineW,Color(3,:));
    plot_kinetic(X,frames,timerange2,lowthr,uppthr,LineW-.5*LineW,'k');
    font_style([],[],var_label,'normal',FntName,FtSz)
    xlim(x_lim)
    ylim([-.1 1.1])
    set(gca,'XTickLabel',[],'XTick',[],'Box','off')
    xlabel([])
    %% Speed Ethogram
    subplot('Position',[0.5416    0.35   0.3628    0.05])
    image(Etho_Speed{lfly}(frames)')
    colormap(Etho_Colors);
    y_limetho=get(gca,'Ylim');
    hold on
    font_style([],...
        [],'Ethogram','normal',FntName,FtSz)
    set(gca,'XTickLabel',[],'Box','off','XTick',[],'YTickLabel',[],'YTick',[])
    xlim([0 frames(end)-frames(1)])
%     Etho_Colors_Labels={'Slow microm','Fast microm','Slow walk','Walk','Rest',...
%         'Sharp Turn','Jump'};
%     hcb=colorbar;set(hcb,'YTick',(1:7),...
%         'YTickLabel',Etho_Colors_Labels,'FontName',FntName,'FontSize',FtSz,'Position',[.915 .37 0.02 0.1])
    %% Head Ethogram
        subplot('Position',[0.5416    0.35   0.3628    0.05])
        image(Etho_H(lfly,frames))%image(Etho_Speed{lfly}(frames)')
        colormap(Etho_Colors);
        y_limetho=get(gca,'Ylim');
        hold on
        font_style([],...
            [],'Head Etho','normal',FntName,FtSz)%'Ethogram'
        set(gca,'XTickLabel',[],'Box','off','XTick',[],'YTickLabel',[],'YTick',[])
        xlim([0 frames(end)-frames(1)])
        Etho_Colors_Labels={'Rest','Slow microm','Fast microm','Slow walk','Walk',...
            'Sharp Turn','Jump','Act Bout','Head Y','Head S'};
        hcb=colorbar;set(hcb,'YTick',(1:10),...
            'YTickLabel',Etho_Colors_Labels,'FontName',FntName,'FontSize',FtSz-1,'Position',[.915 .35 0.02 0.16])
        
    %% Angular speed
    subplot('Position',[0.5416    0.22    0.3628    0.1])%0.26 Y
    hold on
    severalplots=0;
    clear X
    X=(HeadingDiff{lfly});%WalkingDirDiff{lfly};
    
    var_label={'Angular Speed';'(º/0.02 s)'};%{'Change in Walk Dir';'(º/0.02 s)'};
    figname=[];
    lowthr=-3;uppthr=3;
    
    y_lim=[min(X(range))-0.05*min(X(range)) max(X(range))+0.05*max(X(range))];%get(gca,'YLim');
    
    plot_mann_ann
    
    
    %% Save plot
    figname=['FigS2 - ' num2str(rows2plot(ltracecounter)) ' - ' Vartoplot 'Etho,Dist,Speed,Micromov2Thr - Fly ' num2str(lfly),...
        ', ' num2str(range(1)-delay) ' to ' num2str(range(end)+delay)];
    
    if size(rows2plot,2)>1
        %             print('-dpng','-r600',[DataSaving_dir_temp Exp_num '\Plots\Presentations\',figname '.png'])%,'.png' or '-dtiff','-r600' ..
        pause
    else
        %                     print('-dpng','-r600',[DataSaving_dir_temp Exp_num '\Plots\Manual Ann\',...
        %                         figname '.png'])
    end
    
end

