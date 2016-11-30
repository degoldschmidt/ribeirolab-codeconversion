%% Plotting Fly trajectory and kinematic parameters
%% Segment to plot
delay=0;%20;%30;%if larger than zero will show dynamic plot
deltaf=1;
save_plot=0;
merged=1;
FtSz=8;%20;
if save_plot==1
    LineW=0.8;
else
    LineW=1.5;
end
FntName='arial';
% Annotationrows=[12 16 32 33 47 49 54 55 58 57 65 67 74 94 98 102 129];%1:139;
Annotationrows=0;%12:140;%find(cell2mat(cellfun(@(x)~isempty(x),{Annotation_micromovements(1:139).Resting}','uniformoutput',false)))';
% load([Variablesfolder 'Annotation_micromovements_0003A 26-Feb-2015.mat'])
% load([Variablesfolder 'ManualAnnotation0003A 07-Jan-2015.mat'])

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
%     Etho_Colors_Labels={'1-Slow mm','2-Fast mm','3-Slow walk','4-Walk','5-Rest',...
%         '6-Turn','7-Jump','8-Yeast','9-Sucrose'};
%     Etho_Colors_Labels={'Slow microm','Fast microm','Slow walk','Walk','Rest',...
%         'Sharp Turn','Jump'};
%     figure;image((1:11)');colormap(Etho_Colors);hcb=colorbar;set(hcb,'YTick',(1:11),...
%         'YTickLabel',Etho_Colors_Labels,'FontName','Arial','FontSize',14)

WalkingEtho_Colors=[Color(3,:);[1 1 1];[0.5 0.5 0.5]];%[blue, white, gray]
Param_color=[235 135 15]/255;
ShadeColor=[192 110 139]/255;

if ~exist('Etho_Speed_new','var')
    [Etho_Speed_new,Etho_colors_new,Etho_Colors_Labels] = Etho_Speed2New(params.MinimalDuration,Etho_Speed,merged);
end

Etho_H_Speed=Etho_Speed_new;
Etho_H_Speed(Etho_H==9)=6;%YHmm
Etho_H_Speed(Etho_H==10)=7;%SHmm
Etho_Colors=[Etho_colors_new;...
[250 244 0]/255;...%6 - Yellow (Yeast micromovement)
    0 0 0];%7 - Sucrose



plotmanual_ann_edge=1;

%%% Video parameters
fps=20;
step=50;
Repeatloop=1;% Times to repeat display

close all
fig=figure('Position',[2050 50 1600 950],'Color','w');%
for annotation_row=Annotationrows
    
    ManualAnnotation.YFeedingEvents=[150000 167300 12 119];%[58385 62277 1 1];%[332663 344999 7 1];%[65875 65944 1 32];%%[88753 89859 1 32];%[89653 89859 1 32];%[121826 134731 16 113];
    %         ManualAnnotation.YFeedingEvents=[fr_start fr_end 9 lfly];%
    %         ManualAnnotation.YFeedingEvents=ALERT_IBI_V(ALERT_IBI_V(:,6)>2,1:4);%ALERT_IBI_V(ALERT_IBI_V(:,5)>100,1:4);
    % ManualAnnotation.YFeedingEvents=[BoutsInfo.DurIn{76}(6,2:4),76];
    if annotation_row~=0
        ManualAnnotation.YFeedingEvents=Annotation_micromovements(annotation_row).Info;%[33490 33491 7 32];%--> grooming at 0.7
    end
    
    Vartoplot='YFeedingEvents';%'Revisits';%'Grooming';%'Rest';%'YeastSpilledFakeRV';%'Not_engage_Y';
    rows2plot=1%40:size(ManualAnnotation.(Vartoplot)(:,1),1);%[1 6 8 22 37 39 40 43];%
    
    
    
    % Walking_vec=walking_fun(Steplength_Sm_c,Steplength_Sm180_h,flies_idx,params);
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
        
        %     outside_starts=find(conv(double(Dist2Spots*params.px2mm>=2),[1 -1])==1);
        %     outside_ends=find(conv(double(Dist2Spots*params.px2mm>=2),[1 -1])==-1);
        %     boutoutsidestart=find(outside_starts>range1(1),1,'first');
        %     boutoutsideend=find(outside_ends>range1(end),1,'first');
        
        %     if outside_starts(boutoutsidestart)<=range1(end)
        % %         for lboutout=boutoutsidestart:boutoutsideend
        % %
        clf
        %             range=outside_starts(lboutout):outside_ends(lboutout);
        %             if (range(end)-range(1))<=25, continue, end
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
%         subplot('Position',[0.07 0.15 0.36 0.81]);%[0.13 0.11 0.36 0.81]
%         hold on
%         
%         %%% Thick and thin line for Heads
% %         hc(2)=plot_tracks_single(FlyDB,Heads_Sm{lfly},lfly,Spots,params,1,...
% %             'k',frames,FtSz,1,2*LineW);%Color(1,:)
%         hc(2)=plot_tracks_single(FlyDB,Heads_Sm{lfly},lfly,Spots,params,1,...
%             'k',frames,FtSz,1,2.2*LineW);%Color(1,:)
%         
%         %         plot_tracks_single(FlyDB,Heads_Sm{lfly},lfly,Spots,params,1,...
%         %             'k',frames,FtSz,0,LineW);
%         
%         %%% Plot centroid and tail
%         %     plot_tracks_single(FlyDB,Centroids_Sm{lfly},lfly,Spots,params,1,...
%         %         Color(2,:),frames,FtSz,0,LineW+.5);
%         %             plot_tracks_single(FlyDB,Tails_Sm{lfly},lfly,Spots,params,1,...
%         %                 Color(3,:),frames,FtSz,0,2*LineW);
%         
%         % X=Steplength_Sm_h{lfly}(range)*params.px2mm*params.framerate;
%         %     temp=diff(X);
%         %     temp(temp>0)=1;
%         %     temp(temp<0)=-1;
%         %     localminima=find(diff(temp)==2);
%         %     plot(Heads_Sm{lfly}(localminima+range(1)-1,1)*params.px2mm,...%fixed from beginning(framestart:lframe,1),...%with delay
%         %         Heads_Sm{lfly}(localminima+range(1)-1,2)*params.px2mm,'oy','Color',Color(3,:),...
%         %         'MarkerEdgeColor',Color(3,:),'MarkerFaceColor',Color(3,:),'MarkerSize',6)
%         
%         %%% Markers for start and end of the visit
%         plot(Heads_Sm{lfly}(frames(1)+deltaf,1)*params.px2mm,...%fixed from beginning(framestart:lframe,1),...%with delay
%             Heads_Sm{lfly}(frames(1)+deltaf,2)*params.px2mm,'oy','Color','k',...Color(2,:)
%             'MarkerEdgeColor','k','MarkerFaceColor','k','MarkerSize',4)%Color(2,:)
%         plot(Heads_Sm{lfly}(frames(end)-deltaf,1)*params.px2mm,...%fixed from beginning(framestart:lframe,1),...%with delay
%             Heads_Sm{lfly}(frames(end)-deltaf,2)*params.px2mm,'oy','Color','k',...Color(2,:)
%             'MarkerEdgeColor','k','MarkerFaceColor','k','MarkerSize',4)%Color(2,:)
%         text(Heads_Sm{lfly}(frames(1)+deltaf,1)*params.px2mm,...
%             Heads_Sm{lfly}(frames(1)+deltaf,2)*params.px2mm,'Start',...+.3{'visit';'starts'}
%             'FontWeight','normal','FontName',FntName,'FontSize',FtSz,'Color',[0.5 0.5 0.5])
%         text(Heads_Sm{lfly}(frames(end)-deltaf,1)*params.px2mm,...
%             Heads_Sm{lfly}(frames(end)-deltaf,2)*params.px2mm,'End',...{'visit';'ends'}
%             'FontWeight','normal','FontName',FntName,'FontSize',FtSz,'Color',[0.5 0.5 0.5])
%         
        %% Colorcode trajectory based on ethogram
%         colormap_segments=Etho_Colors;%Etho_Tr_Colors;%
%         etho_segments=Etho_H_Speed(lfly,:);%Etho_Tr(lfly,:);%
%         plot_traj_etho(Heads_Sm,lfly,range,etho_segments,colormap_segments,2*LineW,params)
        %% Find micromovement bouts surrounding time segment
        %         microstarts=find(conv(double(Etho_Speed{lfly}==2),[1 -1])==1);
        %         microends=find(conv(double(Etho_Speed{lfly}==2),[1 -1])==-1)-1;
        %
        %         bout_micromovstart=find(microstarts<range(1),1,'last');
        %         bout_micromovend=find(microends>range(end),1,'first');
        %         Colormicromovement=jet(bout_micromovend-bout_micromovstart+1);
        %         micromovcounter=1;
        %         for lmicrobout=bout_micromovstart:bout_micromovend
        %             framesmicro=microstarts(lmicrobout):microends(lmicrobout);
        %
        %             framesmicro(framesmicro<frames(1))=[];
        %             framesmicro(framesmicro>frames(end))=[];
        %             if ~isempty(framesmicro)
        %                 plot(Heads_Sm{lfly}(framesmicro,1)*params.px2mm,...
        %                     Heads_Sm{lfly}(framesmicro,2)*params.px2mm,...
        %                     'LineWidth',1.5*LineW,'Color',Colormicromovement(micromovcounter,:))
        %
        %             end
        %             micromovcounter=micromovcounter+1;
        %         end
        %% Include turns inside activity in red, and outside activity in blue:
        % % %     turnsstarts=ALERTS{2}((ALERTS{2}(:,3)==Spots)&(ALERTS{2}(:,4)==lfly),1);
        % % %     turnsends=ALERTS{2}((ALERTS{2}(:,3)==Spots)&(ALERTS{2}(:,4)==lfly),2);
        % % %     if ~isempty(turnsstarts)
        % % %         for lturn=1:length(turnsstarts)
        % % %             if sum(ismember((turnsstarts(lturn):turnsends(lturn)),range))==...
        % % %                     length(turnsstarts(lturn):turnsends(lturn))
        % % %                 plot(Heads_Sm{lfly}(turnsstarts(lturn):turnsends(lturn),1)*params.px2mm,...
        % % %                     Heads_Sm{lfly}(turnsstarts(lturn):turnsends(lturn),2)*params.px2mm,...
        % % %                     'LineWidth',LineW,'Color','r')
        % % %             end
        % % %         end
        % % %     end
        % % %     turnsstarts=ALERTS{3}((ALERTS{3}(:,3)==Spots)&(ALERTS{3}(:,3)==lfly),1);
        % % %     turnsends=ALERTS{3}((ALERTS{3}(:,3)==Spots)&(ALERTS{3}(:,3)==lfly),2);
        % % %     if ~isempty(turnsstarts)
        % % %         for lturn=1:length(turnsstarts)
        % % %             if sum(ismember((turnsstarts(lturn):turnsends(lturn)),range))==...
        % % %                     length(turnsstarts(lturn):turnsends(lturn))
        % % %                 plot(Heads_Sm{lfly}(turnsstarts(lturn):turnsends(lturn),1)*params.px2mm,...
        % % %                     Heads_Sm{lfly}(turnsstarts(lturn):turnsends(lturn),2)*params.px2mm,...
        % % %                     'LineWidth',LineW,'Color',Color(3,:))
        % % %             end
        % % %         end
        % % %     end
        %%
        axis(axeslimstraj)%axis([-1 19 -15 6])%YBout39
        %     axis off
        
        %% Pixel size lines
        %         x=-33:params.px2mm:33;
        %         plot([x;x],[repmat(-33,1,length(x));repmat(33,1,length(x))],':k',...
        %             'Color',[.7 .7 .7])
        %         hold on
        %         plot([repmat(-33,1,length(x));repmat(33,1,length(x))],[x;x],':k',...
        %             'Color',[.7 .7 .7])
        
        %% Food Activity bouts
        %     subplot('Position',[0.5416    0.76    0.3628    0.05])
        %     %             display('--- frames ---')
        %     %             find(Ethogram_matr{Conditions==params.ConditionIndex(lfly)}...
        %     %             (params.IndexAnalyse(params.ConditionIndex==params.ConditionIndex(lfly))==lfly,frames)==1,1,'first')+frames(1)
        %     % %             flycondcounter=find(params.IndexAnalyse(params.ConditionIndex==params.ConditionIndex(lfly))==lfly);
        %     image(Ethogram_matrAB{Conditions==params.ConditionIndex(lfly)}...
        %         (params.IndexAnalyse(params.ConditionIndex==params.ConditionIndex(lfly))==lfly,frames))
        %     colormap(ActivityBouts_Colors);
        %     freezeColors
        %     y_limetho=get(gca,'Ylim');
        %     hold on
        %     font_style(['Annotated bout #',...
        %         num2str(rows2plot(ltracecounter))],...' - Dur = ' num2str(ceil((range(end)-range(1)-2*deltaf)/50)) ' s'],...
        %         [],{'Activity';'bouts'},'normal',FntName,FtSz)
        %     set(gca,'XTickLabel',[],'Box','off','XTick',[],'YTickLabel',[],'YTick',[])
        %     xlim([0 frames(end)-frames(1)])
        % %     display('Bout start frames:')
        % %     lboutstart=(find(BoutsInfo.DurIn{lfly}(:,2)>frames(1),1,'first'));
        % %     lboutend=(find(BoutsInfo.DurIn{lfly}(:,3)<frames(end),1,'last'));
        % %     startframes=BoutsInfo.DurIn{lfly}(lboutstart:lboutend,2)
        % %     display('Bout end frames:')
        % %     endframes=BoutsInfo.DurIn{lfly}(lboutstart:lboutend,3)
        %     %     %% Walking Vector
        %     %     subplot('Position',[0.5416    0.66    0.3628    0.1])
        %     %     X=Walking_vec{lfly};
        %     %     var_label={[]};
        %     %     figname=[];
        %     %     lowthr=nan;uppthr=4;
        %     %     plot_mann_ann
        %     %     ylim([0.5 3.5])
        %     %     set(gca,'XTickLabel',[],'XTick',[],'YTick',[1 2 3],'YTickLabel',...
        %     %         {'W';'~W';'R'})
        %     %     xlabel([])
        %% Manual Annotation Ethogram
        if annotation_row~=0
            %             subplot('Position',[0.5416    0.74   0.3628    0.05])% Ethogram on top
            subplot('Position',[0.5416    0.17    0.3628    0.05])%Ethogram at the bottom
            manual_annotation_etho=ones(1,size(Heads_Sm{lfly},1));
            %%% Feeding - 6 (Y) or 7 (S)
            for litem=1:size(Annotation_micromovements(annotation_row).Feeding,1)
                manual_annotation_etho(Annotation_micromovements(annotation_row).Feeding(litem,1):...
                    Annotation_micromovements(annotation_row).Feeding(litem,2))=lsubs+5;
            end
            %%% Grooming - 8
            for litem=1:size(Annotation_micromovements(annotation_row).Grooming,1)
                manual_annotation_etho(Annotation_micromovements(annotation_row).Grooming(litem,1):...
                    Annotation_micromovements(annotation_row).Grooming(litem,2))=8;
            end
            %%% Resting - 5
            for litem=1:size(Annotation_micromovements(annotation_row).Resting,1)
                manual_annotation_etho(Annotation_micromovements(annotation_row).Resting(litem,1):...
                    Annotation_micromovements(annotation_row).Resting(litem,2))=5;
            end
            %%% Turning - 9
            for litem=1:size(Annotation_micromovements(annotation_row).Turning,1)
                manual_annotation_etho(Annotation_micromovements(annotation_row).Turning(litem,1):...
                    Annotation_micromovements(annotation_row).Turning(litem,2))=9;
            end
            %%% Walking - 4
            for litem=1:size(Annotation_micromovements(annotation_row).Walking,1)
                manual_annotation_etho(Annotation_micromovements(annotation_row).Walking(litem,1):...
                    Annotation_micromovements(annotation_row).Walking(litem,2))=4;
            end
            %%% Slow walk - 3 (Unclassified fast-micromovement) or slow walk?
            for litem=1:size(Annotation_micromovements(annotation_row).Other,1)
                manual_annotation_etho(Annotation_micromovements(annotation_row).Other(litem,1):...
                    Annotation_micromovements(annotation_row).Other(litem,2))=3;
            end
            %%% Stopping - 11
            for litem=1:size(Annotation_micromovements(annotation_row).Stopping,1)
                manual_annotation_etho(Annotation_micromovements(annotation_row).Stopping(litem,1):...
                    Annotation_micromovements(annotation_row).Stopping(litem,2))=11;
            end
            
            image(manual_annotation_etho)
            colormap(Etho_Colors);
            freezeColors
            y_limetho=get(gca,'Ylim');
            hold on
            font_style([],...
                [],{'Annotated';num2str(annotation_row)},'normal',FntName,FtSz)
            set(gca,'XTickLabel',[],'Box','off','XTick',[],'YTickLabel',[],'YTick',[])
            xlim([frames(1) frames(end)])
        end
        %% Dist 2 Spot
        %         subplot('Position',[0.5416    0.59    0.3628    0.12])% If ethogram on top
        subplot('Position',[0.5416    0.67    0.3628    0.1])% To be on top
        
        hold on
        severalplots=0;
        clear X
        X=Dist2Spots*params.px2mm;
        
        var_label={'Dist from spot';'(mm)'};
        figname=[];
        lowthr=2.3;%2.2;%1.9;
        uppthr=nan;%3;
        %     plot([range(1) range(end)],[2.2 2.2],'--')
        plot_mann_ann
        ylim(y_lim)
        set(gca,'XTickLabel',[],'XTick',[])
        xlabel([])
%         text(timerange(1)+delta+0.01,y_lim(2)+0.15,{'visit';'starts'},...
%             'FontWeight','normal','FontName',FntName,'FontSize',FtSz-1,'Color',[0.5 0.5 0.5])
%         text(timerange(end)-delta+0.01,y_lim(2)+0.15,{'visit';'ends'},...
%             'FontWeight','normal','FontName',FntName,'FontSize',FtSz-1,'Color',[0.5 0.5 0.5])
        title(['Annotated bout #',...
            num2str(rows2plot(ltracecounter))])
        %% Steplength
        %         subplot('Position',[0.5416    0.46   0.3628    0.1])%if ethogram on top [0.5416    0.21    0.3628    0.18]
        subplot('Position',[0.5416    0.56   0.3628    0.1])%if only dist on top
        
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
%         boutstart=find(walkstarts<range(1),1,'last');
%         boutend=find(walkends>range(end),1,'first');
%         for lwalkingbout=boutstart:boutend
%             if insec==1
%                 fillhw=fill([walkstarts(lwalkingbout);walkstarts(lwalkingbout);...
%                     walkends(lwalkingbout); walkends(lwalkingbout)]/framerate/60,...
%                     [0;25;...
%                     25;0],...
%                     Colorpatch(3,:));
%             else
%                 fillhw=fill([walkstarts(lwalkingbout);walkstarts(lwalkingbout);...
%                     walkends(lwalkingbout); walkends(lwalkingbout)],...
%                     [0;25;...
%                     25;0],...
%                     Colorpatch(3,:));
%             end
%             set(fillhw,'EdgeColor',Colorpatch(3,:))%,'FaceAlpha',.5,...
%             %                 'EdgeAlpha',.5);
%         end
%         
        %%% Plot of shaded area where inactivity bout
%         inactstarts=find(conv(double(Walking_vec{lfly}==3),[1 -1])==1);
%         inactends=find(conv(double(Walking_vec{lfly}==3),[1 -1])==-1);
%         %%% Find inactivity bouts surrounding time segment
%         boutstart1=find(inactstarts<range(1),1,'last');
%         boutstart2=find(inactstarts<range(end),1,'last');
%         boutstart=min([boutstart1,boutstart2]);
%         boutend1=find(inactends>range(end),1,'first');
%         boutend2=find(inactends>range(1),1,'first');
%         boutend=max([boutend1,boutend2]);
%         %                 display('Inactivity moments inside this range')
%         for linactbout=boutstart:boutend
%             %                     display([num2str(inactstarts(linactbout)) ':' num2str(inactends(linactbout))])
%             if insec==1
%                 fillhin=fill([inactstarts(linactbout);inactstarts(linactbout);...
%                     inactends(linactbout); inactends(linactbout)]/framerate/60,...
%                     [0;25;...
%                     25;0],...
%                     [0.9 0.9 0.9]);
%             else
%                 fillhin=fill([inactstarts(linactbout);inactstarts(linactbout);...
%                     inactends(linactbout); inactends(linactbout)],...
%                     [0;25;...
%                     25;0],...
%                     [0.9 0.9 0.9]);
%             end
%             set(fillhin,'EdgeColor',[0.9 0.9 0.9],'FaceAlpha',.5,...
%                 'EdgeAlpha',.5);
%         end
        
        
        var_label={'Speed';'(mm/s)'};
        figname=[];
        lowthr=0.8;uppthr=2;%lowthr=0.05;uppthr=nan;%
        
        h1=plot_kinetic(X,frames,timerange2,lowthr,uppthr,.5*LineW,Color(3,:));
        plot_mann_ann
        h2=plot_kinetic(Steplength_Sm_c{lfly}*params.px2mm*params.framerate,...
            frames,timerange2,lowthr,uppthr,.5*LineW,'k');%Color(2,:)
        set(gca,'XTickLabel',[],'XTick',[])
        xlabel([])
%         legend([h1,h2],{'Head';'Centr'},'Position',[.92 0.56 .005 .02],'FontSize',FtSz-1)
        legend('boxoff')
        %             ylim([0 0.8])
        %             text(timerange(1)+delta,X(frames(1)+deltaf),...
        %              num2str(X(frames(1)+deltaf)),'FontSize',15,...
        %              'FontName','calibri')
        %% Heading
        %         subplot('Position',[0.5416    0.4    0.3628    0.1])
        %         hold on
        %         severalplots=0;
        %         clear X
        %         X=Heading{lfly};
        %
        %         var_label={'Heading';'(º)'};
        %         figname=[];
        %         lowthr=nan;uppthr=nan;
        %
        %         plot_mann_ann
        
        %% Head Micromovement bouts
%         subplot('Position',[0.5416    0.48    0.3628    0.03])
%         hold on
%         severalplots=0;
%         clear X
%         X=Binary_Head_mm(:,lfly);
%         var_label={'Head';'bouts'};
%         plot_kinetic(X,frames,timerange2,nan,nan,LineW,Color(3,:));
%         plot_kinetic(X,frames,timerange2,nan,nan,LineW-.5*LineW,'k');
%         font_style([],[],var_label,'normal',FntName,FtSz)
%         xlim(x_lim)
%         ylim([-.1 1.1])
%         set(gca,'XTickLabel',[],'XTick',[],'Box','off')
%         xlabel([])
        %% Activity Bouts
%         subplot('Position',[0.5416    0.43    0.3628    0.03])
%         hold on
%         severalplots=0;
%         clear X
%         X=Binary_AB(:,lfly);
%         var_label={'Act';'bouts'};
%         figname=[];
%         lowthr=nan;uppthr=nan;
%         plot_kinetic(X,frames,timerange2,lowthr,uppthr,LineW,Color(3,:));
%         plot_kinetic(X,frames,timerange2,lowthr,uppthr,LineW-.5*LineW,'k');
%         font_style([],[],var_label,'normal',FntName,FtSz)
%         xlim(x_lim)
%         ylim([-.1 1.1])
%         set(gca,'XTickLabel',[],'XTick',[],'Box','off')
%         xlabel([])
%         %         image(Binary_AB(frames,lfly)'+1)%1 is absence (white), 2 is presence (black)
%         % %         image(logical(Binary_OB(frames,lfly)')+1)
%         %         colormap([1 1 1;0 0 0])
%         %         font_style([],[],{'Activity';'Bouts'},'normal',FntName,FtSz)
%         %         set(gca,'XTickLabel',[],'Box','off','XTick',[],'YTickLabel',[],'YTick',[])
%         %         xlim([0 frames(end)-frames(1)])
%         %         freezeColors
        %% Ethogram
        subplot('Position',[0.5416    0.38   0.3628    0.05])
%         image(Etho_Speed{lfly}(frames)')
        image(Etho_H_Speed(lfly,frames))
        colormap(Etho_Colors);
        freezeColors
        y_limetho=get(gca,'Ylim');
        hold on
        font_style([],...
            [],'Ethogram','normal',FntName,FtSz)
        set(gca,'XTick',[],'Box','off','YTickLabel',[],'YTick',[])
        xlim([0 frames(end)-frames(1)])
        Etho_Colors_Labels={'Rest','Micromov','Walk',...
            'Sharp Turn','Jump','Head Y','Head S'};
        hcb=colorbar;set(hcb,'YTick',(1:size(Etho_Colors,1)),...
            'YTickLabel',Etho_Colors_Labels,'FontName',FntName,'FontSize',FtSz,'Position',[.915 .37 0.02 0.1])
        %% Visits Binary Raster plot
        subplot('Position',[0.5416    0.30   0.3628    0.05])
        BinaryYSVisits=CumTimeV{1}(frames,lfly);
        BinaryYSVisits(BinaryYSVisits==0)=3;
        BinaryYSVisits(CumTimeV{2}(frames,lfly)==1)=2;
        
        image(BinaryYSVisits')
        colormap([243 164 71;170 170 170;255 255 255]/255);
        freezeColors
        y_limetho=get(gca,'Ylim');
        hold on
        font_style([],...
            'Time (s)','Visits','normal',FntName,FtSz)
        set(gca,'XTick',[0:1:10]*50*60,'XTickLabel',cellfun(@(x)num2str(x),num2cell([0:1:10]*60),'uniformoutput',0),'Box','off','YTickLabel',[],'YTick',[])
        xlim([0 frames(end)-frames(1)])
        Visit_Labels={'Yeast','Sucrose','Not a visit'};
        hcb=colorbar;set(hcb,'YTick',(1:3),...
            'YTickLabel',Visit_Labels,'FontName',FntName,'FontSize',FtSz,'Position',[.915 .3 0.02 0.1])

        %% Angular speed
        subplot('Position',[0.5416    0.45    0.3628    0.1])%0.26 Y
        hold on
        severalplots=0;
        clear X
        if ~exist('HeadingDiff','var'),flies_idx=params.IndexAnalyse;
            [~,~,HeadingDiff] =Heading_WalkingDir(Heads_Sm,Tails_Sm,Centroids_Sm);
        end
        X=(HeadingDiff{lfly});%WalkingDirDiff{lfly};
        
        var_label={'Angular Speed';'(º/0.02 s)'};%{'Change in Walk Dir';'(º/0.02 s)'};
        figname=[];
        lowthr=-3;uppthr=3;
        
        y_lim=[min(X(range))-0.05*min(X(range)) max(X(range))+0.05*max(X(range))];%get(gca,'YLim');
        
        %         %%% Plotting shaded micromovements
        %         micromovcounter=1;
        %         for lmicrobout=bout_micromovstart:bout_micromovend
        %             framesmicro=microstarts(lmicrobout):microends(lmicrobout);
        %             if ~isempty(framesmicro)
        %                 fillhin=fill([framesmicro(1);framesmicro(1);...
        %                     framesmicro(end); framesmicro(end)],...
        %                     [y_lim(1);y_lim(2);...
        %                     y_lim(2);y_lim(1)],...
        %                     Colormicromovement(micromovcounter,:));
        %                 set(fillhin,'EdgeColor',Colormicromovement(micromovcounter,:),'FaceAlpha',.5,...
        %                 'EdgeAlpha',.5);
        %                 micromovcounter=micromovcounter+1;
        %             end
        %         end
        plot_mann_ann
        set(gca,'XTickLabel',[],'XTick',[])
        xlabel([])
        %% Diff in head and centroid speed
        %         subplot('Position',[0.5416    0.17    0.3628    0.05])
        %         hold on
        %         severalplots=0;
        %         clear X
        %         X=(Steplength_Sm_h{lfly}-Steplength_Sm_c{lfly})*params.px2mm*params.framerate;
        %
        %         var_label={'s_h - s_c';'(mm/s)'};
        %         figname=[];
        %         lowthr=1;uppthr=nan;
        %
        %         plot_mann_ann
        
        
        %% Micromovement
        %         subplot('Position',[0.5416    0.23    0.3628    0.1])%[0.5416    0.21    0.3628    0.18]
        %         hold on
        %         clear X
        %         severalplots=0;
        %         var_label='Area covered (px/s)';
        %         figname=[];
        %         plot([range(1) range(end)],[.3 .3],'--','Color',[.7 .7 .7])
        %         plot([range(1) range(end)],[1.1 1.1],'--','Color',[.7 .7 .7])
        %
        %         display('Bout start frames:')
        %         startframes=microstarts(bout_micromovstart:bout_micromovend)
        %         display('Bout end frames:')
        %         endframes=microends(bout_micromovstart:bout_micromovend)
        %
        %         pxstoplot=nan(bout_micromovend+1-bout_micromovstart,1);
        %         micromovcounter=1;
        %         for lmicrobout=bout_micromovstart:bout_micromovend
        %             framesmicro=microstarts(lmicrobout):microends(lmicrobout);
        %         framesmicro(framesmicro<frames(1))=[];
        %         framesmicro(framesmicro>frames(end))=[];
        %             if ~isempty(framesmicro)
        %% px covered per sec
        %                 counts=hist3(Heads_Sm{lfly}...
        %                     (framesmicro,:)*params.px2mm,...
        %                     'Edges',{x,x});
        %                 areacovered=(sum(sum(counts~=0)));
        %                 %             pxsperdist=areacovered/...
        %                 %                 sum(Steplength_Sm_h{lfly}(framesmicro)*params.px2mm);
        %                 pxspersec=areacovered/...
        %                     (length(framesmicro)/params.framerate);
        %                 pxstoplot(micromovcounter)=pxspersec;
        
        %                 area(framesmicro,pxspersec*ones(length(framesmicro),1),...
        %                     'LineWidth',.5,...
        %                     'FaceColor',Colormicromovement(micromovcounter,:),...
        %                     'EdgeColor',Colormicromovement(micromovcounter,:));
        %             if micromovcounter==3, return, end
        %                 micromovcounter=micromovcounter+1;
        %             end
        %         end
        %         y_lim=[0 max(pxstoplot(~isnan(pxstoplot)))+0.05*max(pxstoplot(~isnan(pxstoplot)))];%
        %         font_style([],x_label,var_label,'normal',FntName,FtSz)
        %         if (plotmanual_ann_edge==1) && length(y_lim)==2
        %             plot([timerange(1)+delta timerange(1)+delta],y_lim,'-.k',...
        %                 [timerange(end)-delta,timerange(end)-delta],y_lim,'-.k',...
        %                 'LineWidth',LineW,'Color',Color(2,:))%[192 0 0]/255)
        %
        %             xlim(x_lim)
        %             ylim(y_lim)
        %         end
        
        
        %% Save plot
        
%         figname=[ num2str(rows2plot(ltracecounter)) ' - ' Vartoplot 'Etho,Dist,Speed,Micromov2Thr2 - Fly ' num2str(lfly),...
%             ', ' num2str(range(1)-delay) ' to ' num2str(range(end)+delay)];
        figname=[ num2str(rows2plot(ltracecounter)) ' - ' Vartoplot 'Visits - Fly ' num2str(lfly),...
            ', ' num2str(range(1)-delay) ' to ' num2str(range(end)+delay)];
        if annotation_row~=0
            figname=[ num2str(annotation_row) ' - ' Vartoplot 'Etho,Dist,Speed,Micromov2Thr - Fly ' num2str(lfly),...
                ', ' num2str(range(1)-delay) ' to ' num2str(range(end)+delay)];
        end
        if save_plot==1
            print('-dpng','-r900',[DataSaving_dir_temp Exp_num '\Plots\Manual Ann\',figname '.png'])%,'.png' or '-dtiff','-r600' ..
        end
        
        if lrow~=rows2plot(end)
            pause
        end
        
    end
    % save([Variablesfolder 'Micromovement_pxcovered_' Exp_num Exp_letter ' ' date '.mat'],'Mm_Grooming','Mm_inside','Mm_outside')
    if size(Annotationrows,2)>1,pause, end
end