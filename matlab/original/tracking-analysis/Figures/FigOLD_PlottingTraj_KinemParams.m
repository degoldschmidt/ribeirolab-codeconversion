%% Plotting Fly trajectory and kinematic parameters
% clear all
% clc
% Run the AnalysisPipeline (with 0003 A) and then this code.
load('E:\Analysis Data\Experiment 0003\Variables\Fig1 13-Apr-2015.mat')
%% Record Video or Dynamic plot?
deltaf_temp=[300 200];%200;
%% Segment to plot
% load([Variablesfolder 'ManualAnnotation0003A 01-Dec-2014.mat'])
ManualAnnotation.YFeedingEvents=[58385 62277 1 1];%8];
ManualAnnotation.SFeedingEvents=[140563 140722 11 2];%114];
Vartoplot_temp={'YFeedingEvents';'SFeedingEvents'};%'Revisits';%'Not_engage_Y';%%'Edge';%Yi_Yj;%Grooming;
rows2plot_temp=[1 1];%1:size(ManualAnnotation.(Vartoplot)(:,1),1);%[1 6 8 22 37 39 40 43];%
axeslimstraj_temp=[5 12.5 -8 -0.5;...
    -21.5 -14 -8.5 -1];
lsubs_x=[0.2 0.47];
width=0.2;height1=0.05;
Positions_temp{1}=[lsubs_x(1) 0.7 width 0.16;...
    lsubs_x(1) 0.63 width height1;...distance
    lsubs_x(1) 0.56 width height1;...%speed lsubs_x(1) 0.43 width 0.06;...%angular speed
    lsubs_x(1) 0.44 width/3 height1;...% Cumulative
    lsubs_x(1)+width/3+0.06 0.44 width/3 height1;...%Total times
    lsubs_x(1) 0.32 width/3 height1;...% Number of bouts
    lsubs_x(1)+width/3+0.06 0.32 width/3 height1]; % Mean duration

Positions_temp{2}=[lsubs_x(2) 0.7 width 0.16;...
    lsubs_x(2) 0.63 width height1;...distance
    lsubs_x(2) 0.56 width height1;...%speed%     lsubs_x(2) 0.43 width 0.06];%angular speed
    lsubs_x(2) 0.44 width/3 height1;...% Cumulative
    lsubs_x(2)+width/3+0.06 0.44 width/3 height1;...%Total times
    lsubs_x(2) 0.32 width/3 height1;...% Number of bouts
    lsubs_x(2)+width/3+0.06 0.32 width/3 height1]; % Mean duration

%% Other parameters
%%% Colors, format parameters
insec=1;%0;
States_Colors=[238 96 8;0 0 0;0 166 0; 255 255 255]/255;%[Orange, Black, Green, White]
[Color, Color_patch]=Colors(3);
WalkingEtho_Colors=[Color(3,:);[1 1 1];[0.5 0.5 0.5]];%[blue, white, gray]
Param_color=[235 135 15]/255;
FtSz=6;%20;
LineW=1;%0.8;
FntName='arial';
plotmanual_ann_edge=2;%1
saveplot=0;
Conditions=1:4;
MaxSample=360000;
MaxFrames=floor(MaxSample/2);%
[DursFlyPAD_Cond,CumTime_FlyPAD_Cond,OnsFlyPAD_Cond]=plot_FlyPAD_Tracking(Events,...
    'Activity Bouts','Head micromovement bouts',...
    CumTimeHR0506,DurInHR0506,Conditions,paramsR05R06,'none',MaxSample,...
    DataSaving_dir_temp,Exp_num,Exp_letter);
NumBoutsH_temp=nan(2,size(CumTimeHR0506{1},2));
%% Saving parameters that I need to plot this
RealFly=[8,114];
Head_SmFig1=cell(2,1);
Head_SmFig1{1}=Heads_Sm{RealFly(1)};
Head_SmFig1{2}=Heads_Sm{RealFly(2)};
FlyDB_Fig1=FlyDB([RealFly(1) RealFly(2)]);
params_Fig1=params;
Etho_Speed_Fig1=cell(2,1);
Etho_Speed_Fig1{1}=Etho_Speed{RealFly(1)};
Etho_Speed_Fig1{2}=Etho_Speed{RealFly(2)};
Steplength_Sm_c_Fig1=cell(2,1);
Steplength_Sm_c_Fig1{1}=Steplength_Sm_c{RealFly(1)};
Steplength_Sm_c_Fig1{2}=Steplength_Sm_c{RealFly(2)};
Steplength_Sm_h_Fig1{1}=Steplength_Sm_h{RealFly(1)};
Steplength_Sm_h_Fig1{2}=Steplength_Sm_h{RealFly(2)};

save([DataSaving_dir_temp Exp_num '\Variables\Fig1 ' date '.mat'],...
    'Head_SmFig1','FlyDB_Fig1','params_Fig1','Etho_Speed_Fig1',...
    'Steplength_Sm_c_Fig1','CumTimeHR0506','DurInHR0506','paramsR05R06','params','Events',...
    'DataSaving_dir_temp','Exp_num','Exp_letter')
%% Plotting
close all
fig=figure('Position',[2000 67 1100 930],'Color','w','PaperUnits',...
    'centimeters','PaperPosition',[3 5 18.5 20],'Name',['Fig1-Setup ' date]);%


for lsubs=1:2
    deltaf=deltaf_temp(lsubs);
    Vartoplot=Vartoplot_temp{lsubs};
    rows2plot=rows2plot_temp(lsubs);
    ltracecounter=1;
    for ltrace=ManualAnnotation.(Vartoplot)(rows2plot,1)'
        lfly=ManualAnnotation.(Vartoplot)(ManualAnnotation.(Vartoplot)(:,1)==ltrace,4);
        Geometry=FlyDB_Fig1(lfly).Geometry;
        
        range=ltrace-deltaf:ManualAnnotation.(Vartoplot)(ManualAnnotation.(Vartoplot)(:,1)==ltrace,2)+deltaf;
        
        x_label='Time (frames)';
        if insec==1,
            framerate=params_Fig1.framerate;
            timerange=range/params_Fig1.framerate/60;%
            delta=deltaf/params_Fig1.framerate/60;%
            x_label='Time (min)';
        elseif insec==2
            framerate=params_Fig1.framerate;
            timerange=range/params_Fig1.framerate;%
            delta=deltaf/params_Fig1.framerate;%
            x_label='Time (s)';
        else
            timerange=range;
            framerate=0;
            delta=deltaf;
        end
        frames=range;
        timerange2=timerange;%To be the same that the dynamic plot
        x_lim=[timerange(1) timerange(end)];
        
        Spots=ManualAnnotation.(Vartoplot)(ManualAnnotation.(Vartoplot)(:,1)==ltrace,3);
        lsubs=Geometry(Spots);
        
        %% Figure
        if size(rows2plot,2)>1
            clf
        end
        
        axeslimstraj=[min(Head_SmFig1{lfly}(range,1)) max(Head_SmFig1{lfly}(range,1)),...
            min(Head_SmFig1{lfly}(range,2)) max(Head_SmFig1{lfly}(range,2))]*params_Fig1.px2mm;
        
        %%% --- If dynamic plot -start ----
        
        
        
        
        frames=range;
        timerange2=range;
        headingframes=frames(1:10:end);
        
        
        if insec==1,timerange2=frames/framerate/60;%
        elseif insec==2,timerange2=frames/framerate;%
        end
        %% Head Trajectory and dynamic body orientation with delay
        subplot('Position',Positions_temp{lsubs}(1,:))%[0.07 0.11 0.36 0.81]);%[0.13 0.11 0.36 0.81]
        hold on
        
        
        
        %%% Thick and thin line for Heads
        hc(2)=plot_tracks_single(FlyDB_Fig1,Head_SmFig1{lfly},lfly,Spots,params_Fig1,1,...
            'k',frames,FtSz,1,0.4*LineW);%Color(1,:)
        
        %%% Change color of trajectory to highlight the Head micromovements
        colormap_segments=[1 1 1;Color(1,:)];%EthoH_colors_new;%Etho_Tr_Colors;%Etho_Colors;
        Head1_2=Binary_Head_mm(:,RealFly(lfly))';
        Head1_2(Head1_2==1)=2;
        Head1_2(Head1_2==0)=1;
        etho_segments=Head1_2;%Etho_H_new(lfly,:);%Etho_Tr(lfly,:);%Etho_Speed_new(lfly,:);%
        plot_traj_etho(Head_SmFig1,lfly,range,etho_segments,colormap_segments,LineW,params)
        
        plot_tracks_single(FlyDB_Fig1,Head_SmFig1{lfly},lfly,Spots,params_Fig1,1,...
            'k',frames,FtSz,0,0.4*LineW);
        
        
        
        
        %%% Marker on start and end of annotated bout
        dx=0.3;%Length of arrow
        MaxHdSize=1;
%         %         quiver(Head_SmFig1{lfly}(frames(1)+deltaf,1)*params_Fig1.px2mm+dx,...%start
%         %             Head_SmFig1{lfly}(frames(1)+deltaf,2)*params_Fig1.px2mm+dx,...
%         %             -dx,-dx,0,'Color',Color(2,:),'LineWidth',2*LineW,'MaxHeadSize',MaxHdSize)%0.3
%         %         quiver(Head_SmFig1{lfly}(frames(end)-deltaf,1)*params_Fig1.px2mm+dx,...%start
%         %             Head_SmFig1{lfly}(frames(end)-deltaf,2)*params_Fig1.px2mm+dx,...
%         %             -dx,-dx,0,'Color','r','LineWidth',2*LineW,'MaxHeadSize',MaxHdSize)%0.3
%         
%         plot(Head_SmFig1{lfly}(frames(1)+deltaf,1)*params_Fig1.px2mm,...%fixed from beginning(framestart:lframe,1),...%with delay
%             Head_SmFig1{lfly}(frames(1)+deltaf,2)*params_Fig1.px2mm,'oy','Color',Color(2,:),...
%             'MarkerEdgeColor',Color(2,:),'MarkerFaceColor',Color(2,:),'MarkerSize',4)
%         plot(Head_SmFig1{lfly}(frames(end)-deltaf,1)*params_Fig1.px2mm,...%fixed from beginning(framestart:lframe,1),...%with delay
%             Head_SmFig1{lfly}(frames(end)-deltaf,2)*params_Fig1.px2mm,'oy','Color',Color(2,:),...
%             'MarkerEdgeColor','r','MarkerFaceColor','r','MarkerSize',4)
        axis(axeslimstraj_temp(lsubs,:))%(axeslimstraj)%axis([-1 19 -15 6])%YBout39
        axis off
        
        
        %% Dist 2 Spot
        subplot('Position',Positions_temp{lsubs}(2,:))%[0.5416    0.5556    0.16    0.06])%[0.5416    0.5556    0.3628    0.18]
        Dist2Spots=sqrt(sum(((Head_SmFig1{lfly}-...
            repmat(FlyDB_Fig1(lfly).WellPos(Spots,:),...
            length(Head_SmFig1{lfly}),1)).^2),2));
        
        hold on
        severalplots=0;
        clear X
        X=Dist2Spots*params_Fig1.px2mm;
        maxY=5;%
        colornum=1;
        %%% Plot of shaded area where head mm bout
        headtarts=find(conv(double(Head1_2==2),[1 -1])==1);
        headends=find(conv(double(Head1_2==2),[1 -1])==-1);
        % Find walking bouts surrounding time segment
        boutstart=find(headtarts<range(1),1,'last');
        boutend=find(headends>range(end),1,'first');
        for lheadbout=boutstart:boutend
            if insec==1
                fillh=fill([headtarts(lheadbout);headtarts(lheadbout);...
                    headends(lheadbout); headends(lheadbout)]/framerate/60,...
                    [0;maxY;...
                    maxY;0],...
                    Color(colornum,:));
            elseif insec==2
                fillh=fill([headtarts(lheadbout);headtarts(lheadbout);...
                    headends(lheadbout); headends(lheadbout)]/framerate,...
                    [0;maxY;...
                    maxY;0],...
                    Color(colornum,:));
            else
                fillh=fill([headtarts(lheadbout);headtarts(lheadbout);...
                    headends(lheadbout); headends(lheadbout)],...
                    [0;maxY;...
                    maxY;0],...
                    Color(colornum,:));
            end
            set(fillh,'EdgeColor',Color(colornum,:),'FaceAlpha',.3,...
                'EdgeAlpha',.3);
        end
        
        var_label={'Distance';'from spot';'(mm)'};
        figname=[];
        lowthr=2.5;%1.9;
        uppthr=nan;
        dx=2;dy=2;
        
        plot_mann_ann
        y_lim=[0 10.6646];
        ylim(y_lim)
        set(gca,'XTickLabel',[],'XTick',[])
        xlabel([])
        if lsubs==2
            ylabel([])
        end
        %% Steplength
        subplot('Position',Positions_temp{lsubs}(3,:))%[0.5416    0.48    0.16    0.06])%[0.5416    0.21    0.3628    0.18]
        hold on
        severalplots=0;
        clear X
        X=Steplength_Sm_h_Fig1{lfly}*params_Fig1.px2mm*params_Fig1.framerate;
        maxY=4;%23.5;%max(X(range))+0.05*max(X(range))
        
        %%% Plot of shaded area where walking bout
%         walkstarts=find(conv(double((Etho_Speed_Fig1{lfly}==5)|(Etho_Speed_Fig1{lfly}==4)),[1 -1])==1);
%         walkends=find(conv(double((Etho_Speed_Fig1{lfly}==5)|(Etho_Speed_Fig1{lfly}==4)),[1 -1])==-1);
%                 
%         % Find walking bouts surrounding time segment
%         boutstart=find(walkstarts<range(1),1,'last');
%         boutend=find(walkends>range(end),1,'first');
%         for lwalkingbout=boutstart:boutend
%             if insec==1
%                 fillh=fill([walkstarts(lwalkingbout);walkstarts(lwalkingbout);...
%                     walkends(lwalkingbout); walkends(lwalkingbout)]/framerate/60,...
%                     [0;maxY;...
%                     maxY;0],...
%                     Color(3,:));
%             elseif insec==2
%                 fillh=fill([walkstarts(lwalkingbout);walkstarts(lwalkingbout);...
%                     walkends(lwalkingbout); walkends(lwalkingbout)]/framerate,...
%                     [0;maxY;...
%                     maxY;0],...
%                     Color(3,:));
%             else
%                 fillh=fill([walkstarts(lwalkingbout);walkstarts(lwalkingbout);...
%                     walkends(lwalkingbout); walkends(lwalkingbout)],...
%                     [0;maxY;...
%                     maxY;0],...
%                     Color(3,:));
%             end
%             set(fillh,'EdgeColor',Color(3,:),'FaceAlpha',.3,...
%                 'EdgeAlpha',.3);
%         end
        
        
%         %%% Plot of shaded area where turning bout
%         turnstarts=find(conv(double((Etho_Speed_Fig1{lfly}==6)),[1 -1])==1);
%         turnends=find(conv(double((Etho_Speed_Fig1{lfly}==6)),[1 -1])==-1);
%         % Find walking bouts surrounding time segment
%         boutstart=find(turnstarts<range(1),1,'last');
%         boutend=find(turnends>range(end),1,'first');
%         for lturningbout=boutstart:boutend
%             if insec==1
%                 fillh=fill([turnstarts(lturningbout);turnstarts(lturningbout);...
%                     turnends(lturningbout); turnends(lturningbout)]/framerate/60,...
%                     [0;maxY;...
%                     maxY;0],...
%                     Color(2,:));
%             elseif insec==2
%                 fillh=fill([turnstarts(lturningbout);turnstarts(lturningbout);...
%                     turnends(lturningbout); turnends(lturningbout)]/framerate,...
%                     [0;maxY;...
%                     maxY;0],...
%                     Color(2,:));
%             else
%                 fillh=fill([turnstarts(lturningbout);turnstarts(lturningbout);...
%                     turnends(lturningbout); turnends(lturningbout)],...
%                     [0;maxY;...
%                     maxY;0],...
%                     Color(2,:));
%             end
%             set(fillh,'EdgeColor',Color(2,:),'FaceAlpha',.3,...
%                 'EdgeAlpha',.3);
%         end
        
        %%% Plot of shaded area where head mm bout
        headtarts=find(conv(double(Head1_2==2),[1 -1])==1);
        headends=find(conv(double(Head1_2==2),[1 -1])==-1);
        % Find walking bouts surrounding time segment
        boutstart=find(headtarts<range(1),1,'last');
        boutend=find(headends>range(end),1,'first');
        for lheadbout=boutstart:boutend
            if insec==1
                fillh=fill([headtarts(lheadbout);headtarts(lheadbout);...
                    headends(lheadbout); headends(lheadbout)]/framerate/60,...
                    [0;maxY;...
                    maxY;0],...
                    Color(colornum,:));
            elseif insec==2
                fillh=fill([headtarts(lheadbout);headtarts(lheadbout);...
                    headends(lheadbout); headends(lheadbout)]/framerate,...
                    [0;maxY;...
                    maxY;0],...
                    Color(colornum,:));
            else
                fillh=fill([headtarts(lheadbout);headtarts(lheadbout);...
                    headends(lheadbout); headends(lheadbout)],...
                    [0;maxY;...
                    maxY;0],...
                    Color(colornum,:));
            end
            set(fillh,'EdgeColor',Color(colornum,:),'FaceAlpha',.3,...
                'EdgeAlpha',.3);
        end
        
        
        var_label={'Head';'Speed';'(mm/s)'};
        figname=[];
        lowthr=2;uppthr=nan;%lowthr=1;uppthr=4;
        dx=1;dy=1;
        plot_mann_ann
        %             ylim([0 6.9280])
        ylim([0 maxY+3])
        %         set(gca,'XTickLabel',[],'XTick',[])
        %         xlabel([])
        if lsubs==2
            ylabel([])
        end
        %% Angular speed
        %         subplot('Position',Positions_temp{lsubs}(4,:))
        %         hold on
        %         severalplots=0;
        %         clear X
        %         if ~exist('HeadingDiff','var'),flies_idx=params_Fig1.IndexAnalyse;
        %             [~,~,HeadingDiff] =Heading_WalkingDir(Head_SmFig1,Tails_Sm,Centroids_Sm);
        %         end
        %         X=(HeadingDiff{lfly});%WalkingDirDiff{lfly};
        %
        %         var_label={'Angular Speed';'(º/0.02 s)'};%{'Change in Walk Dir';'(º/0.02 s)'};
        %         figname=[];
        %         lowthr=-3;uppthr=3;
        %
        %         y_lim=[min(X(range))-0.05*min(X(range)) max(X(range))+0.05*max(X(range))];%get(gca,'YLim');
        %
        %         plot_mann_ann
        %         ylim([-2 6])
        %         if lsubs==2
        %             ylabel([])
        %         end
    end
    %% Plotting cumulative
    %%% Tracking
    h=nan(2,1);
    lcond=1;
    Conditions=lcond;
    subplot('Position',Positions_temp{lsubs}(4,:))%[0.1 0.67 0.2 0.15]);%Tracking on top
    [h(1),CumTimes_mean]=plot_Cumulative(CumTimeHR0506,lcond,lsubs,MaxFrames,paramsR05R06,[],FtSz,FntName,Color(3,:),Color_patch(3,:));
    %             ylims=get(gca,'YLim');
    if lsubs==1,ylims=[0 15];
    elseif lsubs==2, ylims=[0 1];
    end
    axis([0 ceil(MaxFrames/params_Fig1.framerate/60) 0 ylims(2)])
    
    %%% FlyPAD
    x=(1:MaxSample)'/100/60;
    elem2plot_idx=1:2*5000:MaxSample;
    CumTimes=nanmean(CumTime_FlyPAD_Cond{lsubs}{lcond},2)/100/60;
    stderr=nanstd(CumTime_FlyPAD_Cond{lsubs}{lcond},0,2)./...
        sqrt(size(CumTime_FlyPAD_Cond{lsubs}{lcond},2))/100/60;
    h(2)=plot_line_errpatch(x(elem2plot_idx),...
        CumTimes(elem2plot_idx),stderr(elem2plot_idx),...
        'k',[.5 .5 .5]);
    
    %             legend(h,{'Tracking','FlyPAD'},'FontSize',FtSz-1,...
    %                 'Location','Best');
    %             legend('boxoff')
    if lsubs==1,y_label={'Cumulative';'Time (min)'};
    else y_label=[];
    end
    font_style([],'Time (min)',...
        y_label,'normal',FntName,FtSz)
    axis([0 ceil(MaxFrames/params_Fig1.framerate/60) 0 ylims(2)])
    set(gca,'box', 'off')
    
    %% Plotting box plots comparing certain aspects of the FlyPAD var with the Tracking AB
    %%% Max flies per condition in tracking
    numcond=nan(length(Conditions),1);
    for lcond=Conditions
        numcond(lcond)=sum(paramsR05R06.ConditionIndex==lcond);
    end
    boxes_colormap_FlyPAD=[0.7 0.7 0.7];%Colormap;
    boxes_colormap_Tracking=Color_patch(3,:);%Colormap;
    
    for lsubplot=5:7
        %% Plotting box plot of specific aspect of FlyPAD var
        switch lsubplot
            case 5 %% Total duration of FlyPAD_var
                subplot('Position',Positions_temp{lsubs}(lsubplot,:))
                X_FPAD=nan(size(DursFlyPAD_Cond{lsubs},1),length(Conditions));
                for lcond=Conditions
                    for lfly=1:size(DursFlyPAD_Cond{lsubs},1)
                        X_FPAD(lfly,lcond)=sum(DursFlyPAD_Cond{lsubs}{lfly,lcond})/100/60;
                    end
                end
            case 6 %% Mean duration of FlyPAD_var
                subplot('Position',Positions_temp{lsubs}(lsubplot,:))
                X_FPAD=nan(size(DursFlyPAD_Cond{lsubs},1),length(Conditions));
                for lcond=Conditions
                    for lfly=1:size(DursFlyPAD_Cond{lsubs},1)
                        X_FPAD(lfly,lcond)=mean(DursFlyPAD_Cond{lsubs}{lfly,lcond})/100;
                    end
                end
            case 7 %% Number of FlyPAD_var
                subplot('Position',Positions_temp{lsubs}(lsubplot,:))
                X_FPAD=nan(size(OnsFlyPAD_Cond{lsubs},1),length(Conditions));
                for lcond=Conditions
                    for lfly=1:size(OnsFlyPAD_Cond{lsubs},1)
                        X_FPAD(lfly,lcond)=numel(OnsFlyPAD_Cond{lsubs}{lfly,lcond});
                    end
                end
        end
        FlyPADfillhandle=plot_boxplot_Fig2(X_FPAD,{'FlyPAD'},...
            1,boxes_colormap_FlyPAD,'k','k',.7,FtSz,FntName,'.');%plot_boxplot_tiltedlabels
        %% Plotting box plot of specific aspect of Tracking Activity Bouts
        switch lsubplot
            case 5 %% Total duration of AB Tracking
                var_label='Total duration';
                if lsubs==1,y_label={'Total';'duration (min)'};
                else y_label=[];
                end
                X_Tr=nan(max(numcond),length(Conditions));
                for lcond=Conditions
                    X_Tr(1:numcond(lcond),lcond)=sum(CumTimeHR0506{lsubs}(1:MaxFrames,paramsR05R06.ConditionIndex==lcond))'/params_Fig1.framerate/60;
                end
            case 6 %% Mean duration of AB Tracking
                var_label='Mean duration';
                if lsubs==1,y_label={'Mean';'duration (s)'};
                else y_label=[];
                end
                X_Tr=nan(max(numcond),length(Conditions));
                for lcond=Conditions
                    counter=0;
                    for lfly=find(paramsR05R06.ConditionIndex==lcond)
                        counter=counter+1;
                        tempDur=DurInHR0506{lfly}(DurInHR0506{lfly}(:,1)==lsubs,5);
                        starts=DurInHR0506{lfly}(DurInHR0506{lfly}(:,1)==lsubs,2);
                        ends=DurInHR0506{lfly}(DurInHR0506{lfly}(:,1)==lsubs,3);
                        laststart=find(starts<MaxFrames,1,'Last');
                        tempDur=tempDur(1:laststart);
                        if ends(laststart)>MaxFrames
                            display(['Before: ' num2str(tempDur(end)),...
                                ', now: ' num2str(MaxFrames-starts(laststart))])
                            tempDur(end)=MaxFrames-starts(laststart);
                        end
                        NumBoutsH_temp(lsubs,lfly)=numel(tempDur);
                        X_Tr(counter,lcond)=nanmean(tempDur)/params_Fig1.framerate;
                    end
                end
            case 7 %% Number of AB Tracking
                var_label='Number of bouts';
                if lsubs==1,y_label={'Number of';'bouts'};
                else
                    y_label={[]};
                    
                end
                X_Tr=nan(max(numcond),length(Conditions));
                for lcond=Conditions
                    X_Tr(1:numcond(lcond),lcond)=NumBoutsH_temp(lsubs,paramsR05R06.ConditionIndex==lcond)';
                end
        end
        plot_boxplot_Fig2(X_Tr,{'Tracking'},...plot_boxplot_tiltedlabels
            3,boxes_colormap_Tracking,'k',...Color(3,:)
            'k',0.7,FtSz,FntName,'.');
        xlim([0 4])%    xlim([0.5 size(X,2)+0.5])
        font_style([],[],y_label,'normal',FntName,FtSz)
        %% Saving stats text file
        title_pvalue=['Uncorrected Mann Whitney p-values for ' var_label ' ' Events.SubstrateLabel{lsubs}];
        display(title_pvalue)
        fid=fopen([DataSaving_dir_temp Exp_num '\Plots\Presentations\',...
            Exp_num Exp_letter ' - ' var_label ' ' Events.SubstrateLabel{lsubs} ' ' date '.txt'],'w');
        
        fprintf(fid,'%s\r\n\r\n',title_pvalue);
        for lgroup=1:length(Conditions)
            fprintf(fid,'%s\r\n',['---- ' params_Fig1.LabelsShort{Conditions(lgroup)} ' ----']);
            p=ranksum(X_FPAD(:,lgroup),X_Tr(:,lgroup));
            pvaluetext=['FlyPAD Activity Bouts vs Tracking Head bouts = ' num2str(p)];
            display(pvaluetext)
            fprintf(fid,'%s\r\n',pvaluetext);
            
        end
        fclose(fid);
        %% Plot line with stats
        y_lims=get(gca,'YLim');
        plot([1 3],[.9*y_lims(2) .9*y_lims(2)],'-k','LineWidth',0.7*LineW)
        vertical='middle';
        margin=2;
        if (p<0.05)&&(p>=0.01)
            textstring='*';
        elseif (p<0.01)&&(p>=0.001)
            textstring='**';
        elseif (p<0.001)
            textstring='***';
        else
            textstring='ns';
            vertical='bottom';
            margin=1;
        end
        text(2,.9*y_lims(2),textstring,'HorizontalAlignment','center',...
            'VerticalAlignment',vertical,'Margin',margin,'FontSize',FtSz,'FontName',FntName)
    end
    
end

if saveplot==1,
%     figname=[Exp_num Exp_letter 'Example Fig1 dist, speed, TrackingR5-6 vs FlyPAD res1200 ' date];
%     print('-dpng','-r1200',[DataSaving_dir_temp Exp_num '\Plots\Presentations\' figname '.png'])
    savefig_withname(1,'600','eps','E:\Analysis Data\Experiment ','0003','A',...
    'Figures')
end