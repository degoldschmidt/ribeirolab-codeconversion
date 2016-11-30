%% Plotting over frames
Heads_SteplengthDir=[DataSaving_dir_temp Exp_num '\Heads_Steplength\'];
videoPath =['F:\PROJECT INFO\Videos\Exp ' Exp_num '\'];%'E:\Videos\';%;%['F:\FLY TRACKER PROJECT\TRACKING AND VIDEO ANALYSIS\Videos\Exp ' Exp_num '\'];
CmapSubs=[238 96 8;0 0 0]/255;
CmapSubs_Patch=[250 234 176;240 240 240]/255;%
FntSize=20;%14 to save with exportfig
N_of_fram=10;
fps=40;%15
Ann_counter=1;

RecordVideo=0;%1;%Set to 1 to save video
frames2plot=[50000 50001];%[332960 333030];%
fliestoplot=flies_idx(29:32);%
plotOverlappingBubbles=0;
sameimage=0;
if sameimage==0
    prev_filename='0';
end
%%
 close all
 fig=figure('Position',[100 50 params.scrsz(3)-150 params.scrsz(4)-450],'Color',[1 1 1]);%100
for lfly=fliestoplot
    display(lfly)
    figname=['Activity bouts - Fly ' num2str(lfly),...'Kynemat params
        ', ' num2str(frames2plot(1)) ' to ' num2str(frames2plot(end))];
    saving_dir=[DataSaving_dir_temp Exp_num '\Plots\Presentations\'];
    %'D:\Dropbox (Behavior&Metabolism)\Experiment 3\Plots\Engage\Manual Ann\';
    SaveVideoPath=[saving_dir figname '_fps' num2str(fps) '.avi'];
    %% frames2plot
    %     if N_of_fram<size(frames2plot,1)
    %       frames2plot=frames2plot(randperm(size(frames2plot,1),N_of_fram),:);
    %     end
    
    
    if plotOverlappingBubbles==1
        load([DataSaving_dir_temp Exp_num '\Variables\RawMjAxes_0003A 07-Jan-2015.mat'])
        load([DataSaving_dir_temp Exp_num '\Variables\OverlappingBubbles&CumulativeTime0003A 16-Mar-2015.mat'])
%         spot_thr_OB=1.6;
        if ~exist('Heading','var')
           [Heading] = Heading_WalkingDir(Heads_Sm,Tails_Sm,Centroids_Sm); 
        end
        dist_Centr_Heads=sqrt(sum((Heads_Sm{lfly}-Centroids_Sm{lfly}).^2,2));
        
        Cx=Centroids_Sm{lfly}(:,1)+0.25*dist_Centr_Heads.*cosd(Heading{lfly});%Centroids_Sm{lfly}(:,1);
        Cy=Centroids_Sm{lfly}(:,2)+0.25*dist_Centr_Heads.*sind(Heading{lfly});%Centroids_Sm{lfly}(:,2);
        
        Cbubbles_px=[Cx+Center(arenaside,1),Center(arenaside,2)-Cy];
    end
    f_spot=FlyDB(lfly).WellPos(FlyDB(lfly).Geometry==1,:);%Yeast spots
    
    filename=FlyDB(lfly).Filename %'0003A02R02Cam02P0WT-CantonS.avi';
    
    
    
    if isempty(strfind(prev_filename,filename))
        load([Heads_SteplengthDir 'DB-Heads ' filename(1:end-4) '.mat'],'DB','Center')
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
       MovieObj=VideoReader([videoPath filename]);
    end
    
    YSpots=find(FlyDB(lfly).Geometry==1);
    SSpots=find(FlyDB(lfly).Geometry==2);
    WellPos(:,1)=FlyDB(lfly).WellPos(:,1)+Center(arenaside,1);
    WellPos(:,2)=Center(arenaside,2)-FlyDB(lfly).WellPos(:,2);
    
    %% Dist2Spots
    range=frames2plot(1):frames2plot(end);
    Dist2S2=sqrt(sum(((Heads_Sm{lfly}(range,:)-...
        repmat(FlyDB(lfly).WellPos(2,:),...
        length(Heads_Sm{lfly}(range)),1)).^2),2));
    Dist2Y16=sqrt(sum(((Heads_Sm{lfly}(range,:)-...
        repmat(FlyDB(lfly).WellPos(16,:),...
        length(Heads_Sm{lfly}(range)),1)).^2),2));
    %% Dist from Edge
    Dist2Edge=29/params.px2mm-sqrt(sum(((Heads_Sm{lfly}).^2),2));
    %% Plotting on top of frames
   
    
    [Color,Color_patch]=Colors(3);
    if RecordVideo==1
        vidObj= VideoWriter(SaveVideoPath);
        vidObj.FrameRate=fps;
        vidObj.Quality=100;
        open(vidObj);
    end
    
    
    for llframe=frames2plot(:,1)'
        frames2test=llframe:frames2plot(frames2plot(:,1)==llframe,2);
        display(['start:' num2str(frames2test(1)) ', end:' num2str(frames2test(end))])
        % %             if length(frames2test)>50, frames2test=llframe:llframe+15;end
        if isempty(strfind(prev_filename,filename))
            clear Rawimage
            Rawimage=read(MovieObj,[frames2test(1) frames2test(end)]);%[1 frames2test(end)]);%BEcause there is a bug
        end
        %%
        delay=0;%20;%frames2plot(2)-frames2plot(1);% This to plot everything%
        framecounter=delay+1;
        for lframe=frames2test(delay+1:2:end)%frames2test(end)%For picture
            
            
%             subplot(3,4,[1,2,5,6,9,10],'replace')
            %                 subplot(2,1,1,'replace')
            %                 clf %uncomment when no subplots
            clf
%             hold off
%             imshow(Rawimage(:,:,1,framecounter))%,1))% For not moving image %lframe))
            imagesc(Rawimage(:,:,1,frames2test==lframe))
            colormap(gray)
%             imshow(Rawimage(:,:,1,frames2test==lframe))
%             set(gca,'YDir','normal');
            hold on
            %% Plotting Food Spots
            inspot=0;
            lsubs=0;
            if plotOverlappingBubbles==1
                spotrad=spot_thr_OB;
            else
                spotrad=1.5;
            end
            for nspot=YSpots
                
                [c,xc,yc]=circle_([WellPos(nspot,1),...
                    WellPos(nspot,2)],...
                    spotrad/params.px2mm,100,'-.b');
                set(c,'Color',CmapSubs(1,:),'LineWidth',1)
                Dist2spot=sqrt(sum(((Centroids_Sm{lfly}(lframe,:)-...
                    FlyDB(lfly).WellPos(nspot,:)).^2),2))*params.px2mm;
                if Dist2spot<=4.8
                    inspot=nspot;
                end
%                 if nspot==7%16
%                     set(c,'LineStyle','-.','LineWidth',2)
%                 end
            end
            
            for nspot=SSpots
                
                [c,xc,yc]=circle_([WellPos(nspot,1),...
                    WellPos(nspot,2)],...
                    spotrad/params.px2mm,100,'-.r');
                set(c,'Color',CmapSubs(2,:),'LineWidth',1)
                Dist2spot=sqrt(sum(((Centroids_Sm{lfly}(lframe,:)-...
                    FlyDB(lfly).WellPos(nspot,:)).^2),2))*params.px2mm;
                if Dist2spot<=4.8
                    inspot=nspot;
                end
%                 if nspot==2
%                     set(c,'LineStyle','-','LineWidth',3)
%                 end
                
            end
            %%% Cropping the area around the fly
            delta=40;%30;
            framecenter=lframe;%27824;%150000;%
            %% Plotting Centroids
            framestart=lframe-delay;%frames2test(1);%
            
            
            %%% Plot arrows of body orientation
            framesquiver=framestart:4:lframe;
            quiver(Cents_tmp(framesquiver,1),...
                Cents_tmp(framesquiver,2),...
                (Heads_tmp(framesquiver,1)-Tails_tmp(framesquiver,1))/2.5,...%/2,...
                (Heads_tmp(framesquiver,2)-Tails_tmp(framesquiver,2))/2.5,0,...%/2,0,...
                'y','LineWidth',2,'MaxHeadSize',0.5,'Color',Color(2,:))%'MaxHeadSize',0.2,'Color',Color(2,:))
            %%% Plot Marker on centroid
            plot(Cents_tmp(lframe,1),...%fixed from beginning(framestart:lframe,1),...%with delay
                Cents_tmp(lframe,2),'ob','Color','k','MarkerFaceColor',Color(2,:),'MarkerSize',6)
            %%% Plot thin line for centroids
            plot(Cents_tmp(framestart:lframe,1),...
                Cents_tmp(framestart:lframe,2),'-k','LineWidth',3,'Color',Color(2,:))
            %%% Plot thick and thin line for heads
%             plot(Heads_tmp(frames2test(1):lframe,1),...%fixed from beginning(framestart:lframe,1),...%with delay
%                 Heads_tmp(frames2test(1):lframe,2),'-b','LineWidth',3,'Color',Color(1,:))%(framestart:lframe,2)
%             plot(Heads_tmp(frames2test(1):lframe,1),...%fixed from beginning(framestart:lframe,1),...%with delay
%                 Heads_tmp(frames2test(1):lframe,2),'-b','LineWidth',1,'Color','k')%(framestart:lframe,2)
            %%% Plot marker for head
%             plot(Heads_tmp(lframe,1),...%fixed from beginning(framestart:lframe,1),...%with delay
%                 Heads_tmp(lframe,2),'ob','Color','k','MarkerFaceColor',Color(1,:),'MarkerSize',6)
            if plotOverlappingBubbles==1
                %%% Plot circle around body
                [c,xc,yc]=circle_([Cbubbles_px(lframe,1),...
                        Cbubbles_px(lframe,2)],...
                Median_MjMnAx(lfly,1)/1.5,100,'-b');
                set(c,'Color',Color(2,:),'LineWidth',2)
                if inspot~=0
                    lsubs=FlyDB(lfly).Geometry(inspot);
                    if CumTimeOB{lsubs}(lframe,lfly)~=0
    %                     patch(xc,yc,CmapSubs_Patch(lsubs,:),'EdgeColor',Color(2,:),'FaceAlpha',0.5)%
                          set(c,'Color',CmapSubs(lsubs,:),'LineWidth',2)
                    end
                else
                    if (CumTimeOB{1}(lframe,lfly)~=0)||(CumTimeOB{2}(lframe,lfly)~=0)
                        error('Error: There is an activity bout when the fly is not even in the spot area')
                    end
                end
            end
            
            %% Getting axis
            %                 X_lim=get(gca,'Xlim');Y_lim=get(gca,'Ylim');
%                             axis([119 347 162 390])
            axis equal
            axis off
            if arenaside==1, axis([20 450 20 450]);
            elseif arenaside==2, axis([470 940 20 450]);
            else axis([960 1430 20 450]);
            end
            
            %%
            
            timerange=(1:length(range))/params.framerate;%(range(1):range(end));%s
            %%% Plotting what is being considered as activity on food
            Param_color=Color(3,:);
            inact_thr=0.1;
            %                 if Steplength_Sm_h{lfly}(range(framecounter)-10)*params.px2mm*params.framerate>inact_thr
            %                     plot(X_lim(1)+2,Y_lim(1)+2,'o','Color',Param_color,'MarkerFaceColor',Param_color,'MarkerSize',10)
            %                 end
            
%             axis([floor(Heads_tmp(framecenter,1))-delta,...
%                 floor(Heads_tmp(framecenter,1))+delta,...
%                 floor(Heads_tmp(framecenter,2))-delta,...
%                 floor(Heads_tmp(framecenter,2))+delta])
            %                 if RecordVideo==1
            %                     F1=getframe;
            %                     writeVideo(vidObj,F1);
            %                 end
            %     end
            %     axis([0 1400 0 478])
            %% Plotting Head Steplength --> If uncomment, put legend!
%             % % %                 subplot(2,1,2,'replace')
%             subplot(3,4,3,'replace')
%             hold off
%             
%             x_lim=[1 length(range)]/params.framerate;
%             % %                 plot(timerange(1:framecounter),...
%             % %                     Steplength_h{lfly}(range(1)-10:range(framecounter)-10)*params.px2mm*params.framerate,...
%             % %                     'LineWidth',1,'Color',Param_color)
%             % %                 hold on
%             % %
%             % %                 hs(1)=plot(timerange(1:framecounter),...
%             % %                     Steplength_Sm_h{lfly}(range(1)-10:range(framecounter)-10)*params.px2mm*params.framerate,...
%             % %                     'LineWidth',3,'Color',Param_color);
%             %% Plotting Centroid Steplength
%             %                  plot(timerange(1:framecounter),...
%             %                     Steplength_c{lfly}(range(1)-10:range(framecounter)-10)*params.px2mm*params.framerate,...
%             %                     'LineWidth',1,'Color',Color(2,:))
%             hold on
%             
%             hs(2)=plot(timerange(1:framecounter),...
%                 Steplength_Sm_c{lfly}(range(1):range(framecounter))*params.px2mm*params.framerate,...
%                 'LineWidth',3,'Color',Color(2,:));
%             
%             %%
%             %                 plot(x_lim,[inact_thr inact_thr],'--b')
%             %                 plot(x_lim,[5 5],'--b')
%             figname=[];%=['Edge - Speed Fly ' num2str(lfly),', ' num2str(range(1)) ' to ' num2str(range(end))];
%             font_style(figname,'Time (s)','Speed [mm/s]','normal','calibri',FntSize)
%             xlim(x_lim)
%             ylim([0 max(Steplength_Sm_c{lfly}(range)*params.px2mm*params.framerate)])
%             set(gca, 'box','off')
%             %% Dist 2 Edge
%             subplot(3,4,4,'replace')
%             plot(timerange(1:framecounter),...
%                 Dist2Edge(range(1):range(framecounter))*params.px2mm,...
%                 'LineWidth',3,'Color',Color(2,:));
%             font_style(figname,'Time (s)','Distance from edge [mm]','normal','calibri',FntSize)
%             xlim(x_lim)
%             ylim([0 max(Dist2Edge(range)*params.px2mm)])
%             set(gca, 'box','off')
%             %% Change in Moving Direction (old Turning Angle)
%             subplot(3,4,7,'replace')
%             plot(timerange(1:framecounter),...
%                 WalkingDirDiff{lfly}(range(1):range(framecounter)),...*params.framerate,...
%                 'LineWidth',3,'Color',Color(2,:));
%             font_style(figname,'Time (s)','\Delta Moving Dir [º]','normal','calibri',FntSize)%[º/s]
%             xlim(x_lim)
%             ylim([-180 180])%([min(WalkingDirDiff{lfly}(range)) max(WalkingDirDiff{lfly}(range))])%*params.framerate)
%             set(gca, 'box','off')
%             %% Head Orientation
%             subplot(3,4,8,'replace')
%             plot(timerange(1:framecounter),...
%                 Heading{lfly}(range(1):range(framecounter)),...
%                 'LineWidth',3,'Color',Color(2,:));
%             font_style(figname,'Time (s)','Orientation [º]','normal','calibri',FntSize)
%             xlim(x_lim)
%             ylim([-180 180])%ylim([min(Heading{lfly}(range)) max(Heading{lfly}(range))])
%             set(gca, 'box','off')
%             %% Dist 2 S2
%             subplot(3,4,11,'replace')
%             plot(timerange(1:framecounter),...
%                 Dist2S2((1):(framecounter))*params.px2mm,...
%                 'LineWidth',3,'Color',CmapSubs(2,:))%Color(2,:));
%             font_style(figname,'Time (s)','Distance from S2 [mm]','normal','calibri',FntSize)
%             xlim(x_lim)
%             ylim([0 max(Dist2S2*params.px2mm)])
%             set(gca, 'box','off')
%             %% Dist 2 Y16
%             subplot(3,4,12,'replace')
%             plot(timerange(1:framecounter),...
%                 Dist2Y16((1):(framecounter))*params.px2mm,...
%                 'LineWidth',3,'Color',CmapSubs(1,:))%Color(2,:));
%             font_style(figname,'Time (s)','Distance from Y16 [mm]','normal','calibri',FntSize)
%             xlim(x_lim)
%             ylim([0 max(Dist2Y16*params.px2mm)])
%             set(gca, 'box','off')
%             %%

            framecounter=framecounter+1;
            if RecordVideo==1
                F1=getframe;%(fig);
                writeVideo(vidObj,F1);
            else
                 pause(0.1)
            end
         
        end
        if RecordVideo==1,
            close(vidObj);
        end
        % clf
        % imshow(ones(479,479,3))
        % axis([0 60 0 60])
        % F1.cdata=uint8(ones(479,479,3));%getframe;
        % F1.colormap=[];
        % writeVideo(vidObj1,F1);
        
                    
%         Ann_counter=Ann_counter+1
        
    end
    % %         legend(hs,{'Head Speed';'Centroid Speed'})
    %     end
    prev_filename=filename;
    if lfly~=fliestoplot(end)
        pause
    end
end
