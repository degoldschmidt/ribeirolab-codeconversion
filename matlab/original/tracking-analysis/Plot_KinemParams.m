%% Plotting Fly trajectory and kinematic parameters
%% Record Video or Dynamic plot?
RecordVideo=0;
delay=20;%20;%30;%if larger than zero will show dynamic plot
deltaf=0;%200;
%% Segment to plot
% load([Variablesfolder 'ManualAnnotation0003A 01-Dec-2014.mat'])

% ManualAnnotation.YFeedingEvents=[fr_start fr_end Spots(1) lfly];
% ManualAnnotation.Grooming=[56718 57288 7 32];%[332663 344999 7 1];%[65875 65944 1 32];%%[88753 89859 1 32];%[89653 89859 1 32];%[121826 134731 16 113];
ManualAnnotation.YFeedingEvents=[35899 36001 17 97];%[338200 342350 7 1];%
% ManualAnnotation.YFeedingEvents=Breaks{1};


Vartoplot='YFeedingEvents';%'Grooming';%'Revisits';%'Rest';%'Not_engage_Y';
rows2plot=1%278:size(ManualAnnotation.(Vartoplot)(:,1),1);%[1 6 8 22 37 39 40 43];%

%% Other parameters
%%% Colors, format parameters
insec=0;%0;
States_Colors=[238 96 8;0 0 0;0 166 0; 255 255 255]/255;%[Orange, Black, Green, White]
[Color, Colorpatch]=Colors(3);
WalkingEtho_Colors=[Color(3,:);[1 1 1];[0.5 0.5 0.5]];%[blue, white, gray]
Param_color=[235 135 15]/255;
FtSz=8;%20;
LineW=2;
FntName='arial';
plotmanual_ann_edge=1;


%%% Video parameters
fps=20;
step=50;
Repeatloop=1;% Times to repeat display

%%% Filenames for Video
figname_pre=[Vartoplot 'Engage,Dist2Spot,Speed,Traj - Fly '];
saving_dir=[DataSaving_dir_temp Exp_num '\Plots\Presentations\'];

% Walking_vec=walking_fun(Steplength_Sm_c,Steplength_Sm180_h,flies_idx,params);
%% Plotting
close all
fig=figure('Position',[196 0 1400 1000],'Color','w');%
ltracecounter=0;
for lrow=rows2plot
    ltrace=ManualAnnotation.(Vartoplot)(lrow,1);
    ltracecounter=ltracecounter+1;
    display([Vartoplot ' Bout ' num2str(ltracecounter)])
    lfly=ManualAnnotation.(Vartoplot)(lrow,4);
    Geometry=FlyDB(lfly).Geometry;
    
    range=ltrace-deltaf:ManualAnnotation.(Vartoplot)(lrow,2)+deltaf;
    
    figname=[figname_pre num2str(lfly),...
        ', ' num2str(range(1)-delay) ' to ' num2str(range(end)+delay)];
    SaveVideoPath=[saving_dir figname '_' num2str(fps) 'fps.avi'];
    
    
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
    frames=range;
    timerange2=timerange;%To be the same that the dynamic plot
    x_lim=[timerange(1) timerange(end)];
    
    Spots=ManualAnnotation.(Vartoplot)(lrow,3);
    lsubs=Geometry(Spots);
    
    %% Figure
    if size(rows2plot,2)>1
        clf
    end
    
    
    
    axeslimstraj=[min(Heads_Sm{lfly}(range,1)) max(Heads_Sm{lfly}(range,1)),...
        min(Heads_Sm{lfly}(range,2)) max(Heads_Sm{lfly}(range,2))]*params.px2mm;
    
    %%% --- If dynamic plot -start ----
    
    if delay>0,
        keeprunning=1;
    else
        keeprunning=Repeatloop;%Run loop once
    end
    while keeprunning<=Repeatloop
        if RecordVideo==1
            vidObj= VideoWriter(SaveVideoPath);
            vidObj.FrameRate=fps;
            vidObj.Quality=100;
            open(vidObj);
        end
        lframecounter=1;
        for lframe=range(1):step:range(end)
            
            
            if delay>0
                frames=range(1)-delay:lframe+delay;
                timerange2=frames;
                headingframes=lframe-delay:5:lframe+delay;
            else
                frames=range;
                timerange2=range;
                headingframes=frames(1:10:end);
            end
            
            if insec==1,timerange2=frames/framerate/60;%
            end
            %%% --- If dynamic plot -end ----
            
            clf
            %% Head Trajectory and dynamic body orientation with delay
            subplot('Position',[0.07 0.11 0.36 0.81]);%[0.13 0.11 0.36 0.81]
            hold on
            
            %             Spots=ManualAnnotation.(Vartoplot)(lrow,3);
            %%% Thick and thin line for Centroids
            %             hc(1)=plot_tracks_single(FlyDB,Centroids_Sm{lfly},lfly,Spots,params,1,...
            %                 Color(1,:),frames,FtSz,1,3);
            %             hold on
            % %             plot_tracks_single(FlyDB,Centroids_Sm{lfly},lfly,Spots,params,1,...
            % %                 'k',headingframes,FtSz,0,1);
            %             %%% Body Orientation
            %             range_h=frames(1:5:end);
            %             plot_heading(Centroids_Sm{lfly},Heads_Sm{lfly},Tails_Sm{lfly},1,...
            %             Colormap(1,:),params,range_h,2,0.05)
            %%% Marker on centroid
            %             plot(Centroids_Sm{lfly}(lframe,1),...
            %                 Centroids_Sm{lfly}(lframe,2),'ob','Color','k',...
            %                 'MarkerEdgeColor','k','MarkerFaceColor',Color(2,:),'MarkerSize',6)
            %%% Thick and thin line for Heads
            hc(2)=plot_tracks_single(FlyDB,Heads_Sm{lfly},lfly,Spots,params,1,...
                Color(1,:),frames,FtSz,1,LineW+1);
            
            plot_tracks_single(FlyDB,Heads_Sm{lfly},lfly,Spots,params,1,...
                'k',frames,FtSz,0,0.3);
            %             if headingframes(end)<=timerange(end)-delta && headingframes(1)>=timerange(1)+delta
            %                 %%% Red lines for engagement period
            %                 plot_tracks_single(FlyDB,Heads_Sm{lfly},lfly,Spots,params,1,...
            %                     [192 0 0]/255,(timerange(1)+delta):frames(end),FtSz,0,4);
            %                 plot_tracks_single(FlyDB,Heads_Sm{lfly},lfly,Spots,params,1,...
            %                     'k',(timerange(1)+delta):frames(end),FtSz,0,1);
            %             end
            %%% Marker on Head
            %             plot(Heads_Sm{lfly}(lframe,1)*params.px2mm,...%fixed from beginning(framestart:lframe,1),...%with delay
            %                 Heads_Sm{lfly}(lframe,2)*params.px2mm,'ob','Color','k',...
            %                 'MarkerEdgeColor','k','MarkerFaceColor',Color(1,:),'MarkerSize',6)
            
            %%% Marker on start of annotated bout
            %%
            plot(Heads_Sm{lfly}(frames(1)+deltaf,1)*params.px2mm,...%fixed from beginning(framestart:lframe,1),...%with delay
                Heads_Sm{lfly}(frames(1)+deltaf,2)*params.px2mm,'oy','Color',Color(2,:),...
                'MarkerEdgeColor',Color(2,:),'MarkerFaceColor',Color(2,:),'MarkerSize',6)
            plot(Heads_Sm{lfly}(frames(end)-deltaf,1)*params.px2mm,...%fixed from beginning(framestart:lframe,1),...%with delay
                Heads_Sm{lfly}(frames(end)-deltaf,2)*params.px2mm,'oy','Color',Color(2,:),...
                'MarkerEdgeColor',Color(2,:),'MarkerFaceColor',Color(2,:),'MarkerSize',6)
            text(Heads_Sm{lfly}(frames(1)+deltaf,1)*params.px2mm,...
                Heads_Sm{lfly}(frames(1)+deltaf,2)*params.px2mm,{'visit';'starts'},...+.3
                'FontWeight','normal','FontName',FntName,'FontSize',FtSz,'Color',[0.5 0.5 0.5])
            text(Heads_Sm{lfly}(frames(end)-deltaf,1)*params.px2mm,...
                Heads_Sm{lfly}(frames(end)-deltaf,2)*params.px2mm,{'visit';'ends'},...
                'FontWeight','normal','FontName',FntName,'FontSize',FtSz,'Color',[0.5 0.5 0.5])
%             axis([-33 33 -33 33])
            axis(axeslimstraj)%axis([-1 19 -15 6])%YBout39
            axis off
            %             grid on
            %% Pixel size lines
%             x=-33:params.px2mm:33;
%             plot([x;x],[repmat(-33,1,length(x));repmat(33,1,length(x))],':k',...
%                 'Color',[.7 .7 .7])
%             hold on
%             plot([repmat(-33,1,length(x));repmat(33,1,length(x))],[x;x],':k',...
%                 'Color',[.7 .7 .7])
            
            %% Ethogram
%             subplot('Position',[0.5416    0.66    0.3628    0.05])
%             %             display('--- frames ---')
%             %             find(Ethogram_matr{Conditions==params.ConditionIndex(lfly)}...
%             %             (params.IndexAnalyse(params.ConditionIndex==params.ConditionIndex(lfly))==lfly,frames)==1,1,'first')+frames(1)
%             % %             flycondcounter=find(params.IndexAnalyse(params.ConditionIndex==params.ConditionIndex(lfly))==lfly);
%             image(Ethogram_matr{Conditions==params.ConditionIndex(lfly)}...
%                 (params.IndexAnalyse(params.ConditionIndex==params.ConditionIndex(lfly))==lfly,frames))
%             colormap(States_Colors);
%             freezeColors
%             y_limetho=get(gca,'Ylim');
%             hold on
%             font_style(['Annotated bout #' num2str(find(ltrace==ManualAnnotation.(Vartoplot)(:,1)))],...
%                 [],'Ethogram','normal',FntName,FtSz)
%             set(gca,'XTickLabel',[],'Box','off','XTick',[],'YTickLabel',[],'YTick',[])
%             xlim([0 frames(end)-frames(1)])
%             %             display('Bout start frames:')
%             %             lboutstart=(find(BoutsInfo.DurIn{lfly}(:,2)>frames(1),1,'first'));
%             %             lboutend=(find(BoutsInfo.DurIn{lfly}(:,3)<frames(end),1,'last'));
%             %             startframes=BoutsInfo.DurIn{lfly}(lboutstart:lboutend,2)
%             %             display('Bout end frames:')
%             %             endframes=BoutsInfo.DurIn{lfly}(lboutstart:lboutend,3)
            %% Dist 2 Spot
%             subplot('Position',[0.5416    0.49    0.3628    0.12])%
%             Dist2Spots=sqrt(sum(((Heads_Sm{lfly}-...
%                 repmat(FlyDB(lfly).WellPos(Spots,:),...
%                 length(Heads_Sm{lfly}),1)).^2),2));
%             
%             hold on
%             severalplots=0;
%             clear X
%             X=Dist2Spots*params.px2mm;
%             
%             var_label={'Dist from spot';'(mm)'};
%             figname=[];
%             lowthr=2;%1.9;
%             uppthr=4;
%             plot_mann_ann
%             ylim(y_lim)
%             set(gca,'XTickLabel',[],'XTick',[])
%             xlabel([])
%             text(timerange(1)+delta+0.01,y_lim(2)+0.15,{'visit';'starts'},...
%                 'FontWeight','normal','FontName',FntName,'FontSize',FtSz-1,'Color',[0.5 0.5 0.5])
%             text(timerange(end)-delta+0.01,y_lim(2)+0.15,{'visit';'ends'},...
%                 'FontWeight','normal','FontName',FntName,'FontSize',FtSz-1,'Color',[0.5 0.5 0.5])
%             %%% Plot of shaded area where bout is present
            %% Raster plot speed
            %             subplot('Position',[0.5416    0.43    0.3628    0.05])
            % %             lcondcounter=find(Conditions==params.ConditionIndex(lfly));
            % %             flycondcounter=find(params.IndexAnalyse(params.ConditionIndex==params.ConditionIndex(lfly))==lfly);
            %             image(Walking_Etho{Conditions==params.ConditionIndex(lfly)}...
            %                 (params.IndexAnalyse(params.ConditionIndex==params.ConditionIndex(lfly))==lfly,frames))
            %             colormap(WalkingEtho_Colors);
            %             font_style([],[],'Walking','normal',FntName,FtSz)
            %             set(gca,'XTickLabel',[],'Box','off','XTick',[],'YTickLabel',[],'YTick',[])
            %             xlim([0 frames(end)-frames(1)])
            %% Steplength
%             subplot('Position',[0.5416    0.36   0.3628    0.1])%[0.5416    0.21    0.3628    0.18]
%             hold on
%             severalplots=1;
%             clear X
%             X=Steplength_Sm_h{lfly}*params.px2mm*params.framerate;
%             
%             %%% Plot of shaded area where walking bout
%             
%             walkstarts=find(conv(double(Walking_vec{lfly}==1),[1 -1])==1);
%             walkends=find(conv(double(Walking_vec{lfly}==1),[1 -1])==-1);
%             %%% Find walking bouts surrounding time segment
%             boutstart=find(walkstarts<range(1),1,'last');
%             boutend=find(walkends>range(end),1,'first');
%             for lwalkingbout=boutstart:boutend
%                 if insec==1
%                     fillhw=fill([walkstarts(lwalkingbout);walkstarts(lwalkingbout);...
%                         walkends(lwalkingbout); walkends(lwalkingbout)]/framerate/60,...
%                         [0;25;...
%                         25;0],...
%                         Colorpatch(3,:));
%                 else
%                     fillhw=fill([walkstarts(lwalkingbout);walkstarts(lwalkingbout);...
%                         walkends(lwalkingbout); walkends(lwalkingbout)],...
%                         [0;25;...
%                         25;0],...
%                         Colorpatch(3,:));
%                 end
%                 set(fillhw,'EdgeColor',Colorpatch(3,:),'FaceAlpha',.3,...
%                     'EdgeAlpha',.3);
%             end
%             
%             %%% Plot of shaded area where inactivity bout
%             inactstarts=find(conv(double(Walking_vec{lfly}==3),[1 -1])==1);
%             inactends=find(conv(double(Walking_vec{lfly}==3),[1 -1])==-1);
%             %%% Find inactivity bouts surrounding time segment
%             boutstart=find(inactstarts<range(1),1,'last');
%             boutend=find(inactends>range(end),1,'first');
%             %                 display('Inactivity moments inside this range')
%             for linactbout=boutstart:boutend
%                 %                     display([num2str(inactstarts(linactbout)) ':' num2str(inactends(linactbout))])
%                 if insec==1
%                     fillhin=fill([inactstarts(linactbout);inactstarts(linactbout);...
%                         inactends(linactbout); inactends(linactbout)]/framerate/60,...
%                         [0;25;...
%                         25;0],...
%                         [0.9 0.9 0.9]);
%                 else
%                     fillhin=fill([inactstarts(linactbout);inactstarts(linactbout);...
%                         inactends(linactbout); inactends(linactbout)],...
%                         [0;25;...
%                         25;0],...
%                         [0.9 0.9 0.9]);
%                 end
%                 set(fillhin,'EdgeColor',[0.9 0.9 0.9],'FaceAlpha',.3,...
%                     'EdgeAlpha',.3);
%             end
%             %%% Find microdisplacement bouts surrounding time segment
%             ShadeColor=[192 110 139]/255;
%             microstarts=find(conv(double(Microdispl{lfly}==1),[1 -1])==1);
%             microends=find(conv(double(Microdispl{lfly}==1),[1 -1])==-1);
%             
%             boutstart=find(microstarts<range(1),1,'last');
%             boutend=find(microends>range(end),1,'first');
%             for lmicrobout=boutstart:boutend
%                 if insec==1
%                     fillhw=fill([microstarts(lmicrobout);microstarts(lmicrobout);...
%                         microends(lmicrobout); microends(lmicrobout)]/framerate/60,...
%                         [0;25;...
%                         25;0],...
%                         ShadeColor);
%                 else
%                     fillhw=fill([microstarts(lmicrobout);microstarts(lmicrobout);...
%                         microends(lmicrobout); microends(lmicrobout)],...
%                         [0;25;...
%                         25;0],...
%                         ShadeColor);
%                 end
%                 set(fillhw,'EdgeColor',ShadeColor,'FaceAlpha',.3,...
%                     'EdgeAlpha',.3);
%             end
%             var_label={'Speed';'(mm/s)'};
%             figname=[];
%             lowthr=1;uppthr=2;%lowthr=0.05;uppthr=nan;%
%             
%             h1=plot_kinetic(X,frames,timerange2,lowthr,uppthr,1,Color(3,:));
%             plot_mann_ann
%             h2=plot_kinetic(Steplength_Sm_c{lfly}*params.px2mm*params.framerate,...
%                 frames,timerange2,lowthr,uppthr,1,Color(2,:));
%             set(gca,'XTickLabel',[],'XTick',[])
%             xlabel([])
%             legend([h1,h2],{'Head';'Centr'},'Position',[.955 0.37 .001 .05],'FontSize',FtSz-1)
%             %             ylim([0 0.8])
%             %             text(timerange(1)+delta,X(frames(1)+deltaf),...
%             %              num2str(X(frames(1)+deltaf)),'FontSize',15,...
%             %              'FontName','calibri')
            %% Engagement
            %             subplot('Position',[0.5416    0.2    0.3628    0.12])%[0.5416    0.21    0.3628    0.18]
            %             hold on
            %             severalplots=1;%1 to plot engagement for both substrates
            %             clear X
            %             X=Engagement_p(:,lfly);
            %             var_label='Engagement index';
            %             figname=[];
            %             lowthr=nan;uppthr=0;
            %             clear he
            %             if severalplots==1
            %                 %%% Engagement
            %                 he(1)=plot_kinetic(X,frames,timerange2,lowthr,uppthr,LineW,[238 96 8]/255);
            %                 %%% Engagement given distance
            %                 he(2)=plot_kinetic(Engagement_p_dist(:,lfly),frames,timerange2,lowthr,uppthr,LineW-1,'k');
            %                 %%% Engagement given speed
            %                 he(3)=plot_kinetic(Engagement_p_speed(:,lfly),frames,timerange2,lowthr,uppthr,LineW-1,'b');
            %             else
            %                 plot_kinetic(X,frames,timerange2,lowthr,uppthr,3,[238 96 8]/255);%ColorsTraj(1,:));
            %                 plot_kinetic(X,frames,timerange2,lowthr,uppthr,1,'k');
            %             end
            %             font_style(figname,x_label,var_label,'normal',FntName,FtSz)
            %             xlim(x_lim)
            %             y_lim=[0 1.1];
            %
            %
            %
            %
            %             if plotmanual_ann_edge==1;
            %                 plot([timerange(1)+delta timerange(1)+delta],y_lim,'-.k',[timerange(end)-delta,...
            %                     timerange(end)-delta],y_lim,'-.k', 'LineWidth',LineW,'Color',Color(2,:))%[192 0 0]/255)
            %
            % %                 text(timerange(1)+delta,y_lim(2)+0.15,{'visit';'starts'},...
            % %                 'FontWeight','normal','FontName',FntName,'FontSize',FtSz-3,'Color',[0.5 0.5 0.5])
            % %                 text(timerange(end)-delta,y_lim(2)+0.15,{'visit';'ends'},...
            % %                 'FontWeight','normal','FontName',FntName,'FontSize',FtSz-3,'Color',[0.5 0.5 0.5])
            %
            %             end
            %             ylim(y_lim)
            %             legend(he,{'p(E)';'p(E|d)';'p(E|s)'},'Position',[.955 0.21 .001 .07],'FontSize',FtSz-1)
            %% Area covered
%             subplot('Position',[0.5416    0.2    0.3628    0.12])%[0.5416    0.21    0.3628    0.18]
%             hold on
%             clear X
%             severalplots=0;
%             X=AreaCovered{lfly};
%             var_label={'Area covered';'[px/s]'};
%             figname=[];
%             lowthr=nan;uppthr=0;
%             Color(3,:)=[120 52 76]/255;
%             plot_mann_ann
%             [Color]=Colors(3);
%             ShadeColor=[192 110 139]/255;
%             %%% Shading non-displacement moments
%             nondisp_starts=find(conv(double(X<=2),[1 -1])==1);
%             nondisp_ends=find(conv(double(X<=2),[1 -1])==-1);
%             boutstart=find(nondisp_starts<range(1),1,'last');
%             boutend=find(nondisp_ends>range(end),1,'first');
%             for lnondisp=boutstart:boutend
%                 if (nondisp_ends(lnondisp)-nondisp_starts(lnondisp))>=100 %frames
%                     if insec==1
%                         fillhw=fill([nondisp_starts(lnondisp);nondisp_starts(lnondisp);...
%                             nondisp_ends(lnondisp); nondisp_ends(lnondisp)]/framerate/60,...
%                             [0;15;...
%                             15;0],...
%                             ShadeColor);
%                     else
%                         fillhw=fill([nondisp_starts(lnondisp);nondisp_starts(lnondisp);...
%                             nondisp_ends(lnondisp); nondisp_ends(lnondisp)],...
%                             [0;15;...
%                             15;0],...
%                             ShadeColor);
%                     end
%                     set(fillhw,'EdgeColor',ShadeColor,'FaceAlpha',.3,...
%                         'EdgeAlpha',.3);
%                 end
%             end
%             %             y_lim=[0 1.1];
%             %             ylim(y_lim)
%             
            %%
            pause(0.0001)
            lframecounter=lframecounter+1;
            if delay==0, break,end
            if RecordVideo==1
                F1=getframe(fig);
                writeVideo(vidObj,F1);
            end
        end
        if RecordVideo==1,close(vidObj);end
        %         legend(hc,{'Centroid';'Head'},'location','best','FontSize',14)%hc(2),{'Head'}
        %         %     legend(hs,{'Head';'Centroid'},'location','best','FontSize',14)
        %         legend(he,{'Yeast';'Sucrose'},'location','best','FontSize',14)
        keeprunning=keeprunning+1;
    end
    %     figname=[Vartoplot var_label(1:end-7) ' - Fly ' num2str(lfly),...
    %         ', ' num2str(range(1)-delay) ' to ' num2str(range(end)+delay)];
    figname=[num2str(ltracecounter) ' - ' Vartoplot 'Etho,Dist,Speed,Area - Fly ' num2str(lfly),...
        ', ' num2str(range(1)-delay) ' to ' num2str(range(end)+delay)];
    %     saveplots(Dropbox_choicestrategies,'Manual Ann',figname,DataSaving_dir_temp,Exp_num,0,0)
    %
    if size(rows2plot,2)>1
%                 pause
        print('-dtiff','-r200',[DataSaving_dir_temp Exp_num '\Plots\Manual Ann\',...
            figname '.tif'])%'-r600'
    else
%         pause(0.3)
%                 print('-dtiff','-r200',[DataSaving_dir_temp Exp_num '\Plots\Manual Ann\',...
%                     figname '.tif'])%'-r600'
    end
end
