%% Plotting Fly trajectory and kinematic parameters
% clear all
% clc
% load('E:\Analysis Data\Experiment 0003\Variables\Fig1 06-Apr-2015.mat')
%% Record Video or Dynamic plot?
deltaf_temp=[1 1];%200;
%% Segment to plot
% load([Variablesfolder 'ManualAnnotation0003A 01-Dec-2014.mat'])
Visits_Traj_frames=2000:50000;%5250:50000;%5290:40000;
ManualAnnotation.YFeedingEvents=[25779 30000 7 1];%[25780 31400 7 1];%32
Vartoplot_temp={'YFeedingEvents';'SFeedingEvents'};%'Revisits';%'Not_engage_Y';%%'Edge';%Yi_Yj;%Grooming;
rows2plot_temp=[1 1];%1:size(ManualAnnotation.(Vartoplot)(:,1),1);%[1 6 8 22 37 39 40 43];%
axeslimstraj_temp=[11 19.3 -17.5 -9];
width=0.22;height1=0.025;
h_dist=0.05;
v_dist=0.025;
loc_x=0.05;
side_big_traj=0.225;
loc_y=1-side_big_traj-v_dist-0.05;
etho_bar_h=height1;%0.13;
%% Other parameters
%%% Colors, format parameters
insec=1;%0;
merged=1;
States_Colors=[238 96 8;0 0 0;0 166 0; 255 255 255]/255;%[Orange, Black, Green, White]
[Color, Color_patch]=Colors(3);
WalkingEtho_Colors=[Color(3,:);[1 1 1];[0.5 0.5 0.5]];%[blue, white, gray]
Param_color=[235 135 15]/255;
FtSz=6;%20;
LineW=0.8;
FntName='arial';
plotmanual_ann_edge=2;%1
saveplot=0;

Conditions=1:4;
maxFrame=params.MinimalDuration;
%%
close all
% fig=figure('Position',[2000 67 1200 930],'Color','w','Name',['Fig3A- Composition of visits Trajectory res1200 merged ' date]);%
Positions=[loc_x loc_y side_big_traj side_big_traj;...Whole visit trajectory
    loc_x+side_big_traj+0.02 loc_y+0.05*side_big_traj width width;...Trajectory speed etho color code%loc_x+2.3*width+h_dist+0.027 loc_y width 0.8*width;...Centroid Trajectory speed color code
    loc_x+side_big_traj+width-0.03 loc_y+0.05*side_big_traj width width;...Trajectory head bout & breaks color code
    loc_x+2*width+side_big_traj-0.03 loc_y+0.05*side_big_traj width width;...Head Trajectory speed color code 
    loc_x+0.05 loc_y-v_dist-height1 2.9*width+h_dist height1;...Visits Etho
    loc_x+0.05 loc_y-3*v_dist-2*height1 2.3*width+h_dist height1;...Etho_Speed
    loc_x+0.05 loc_y-4*v_dist-3*height1 2.3*width+h_dist height1;...Etho_H
    loc_x+0.05 loc_y-7*v_dist-3*height1-.6*width-.2 .6*width .6*width;...p(position) for AA+(Hunt)
    loc_x+0.05+.6*width+.5*h_dist loc_y-7*v_dist-3*height1-.6*width-.2 .6*width .6*width;...p(position) for AA-
    loc_x+0.05+2*.6*width+2.5*h_dist loc_y-7*v_dist-3*height1-.6*width-.2 0.3*width .6*width;...boxplot of area covered per min
    loc_x+0.05+2.5*.6*width+3.5*h_dist loc_y-7*v_dist-3*height1-.6*width-.2 0.3*width .6*width;...Histogram of distance from center
    loc_x+0.05+3*.6*width+4.5*h_dist loc_y-7*v_dist-3*height1-.6*width-.2 0.3*width .6*width;...boxplot of mean distance from center
    ];
% Positions=[loc_x loc_y-.75*width 1.5*width 1.5*width;...Whole visit trajectory
%     loc_x+1.5*width loc_y width 0.8*width;...Head Trajectory speed color code %loc_x+2.3*width+h_dist+0.027 loc_y width 0.8*width;...Centroid Trajectory speed color code
%     loc_x+1.5*width loc_y-.8*width width 0.8*width;...Trajectory speed etho color code
%     loc_x+2.3*width+h_dist loc_y-.8*width width .8*width;...Trajectory head bout & breaks color code
%     loc_x+0.03 loc_y-.8*width-v_dist-height1 2.9*width+h_dist height1;...Visits Etho
%     loc_x+0.1 loc_y-.8*width-3*v_dist-2*height1 2.3*width+h_dist height1;...Etho_Speed
%     loc_x+0.1 loc_y-.8*width-4*v_dist-3*height1 2.3*width+h_dist height1;...Etho_H
%     ];
bar_x=Positions(4,1)+Positions(4,3);

% for lplot=1:size(Positions,1)
%     subplot('Position',Positions(lplot,:))
% end



%%
[Etho_Speed_new,Etho_colors_new,Etho_Colors_Labels] = Etho_Speed2New(maxFrame,Etho_Speed,merged);
Etho_Colors=Etho_colors_new;
Colormap_Speed=jet(255);

%% Saving parameters that I need to plot this
lfly=32;
Head_SmFig2=Heads_Sm{lfly};
Cent_SmFig2=Centroids_Sm{lfly};
FlyDB_Fig2=FlyDB(lfly);
params_Fig2=params;
Etho_Speed_Fig2=Etho_Speed_new(lfly,:);
Etho_H_Fig2=Etho_H(lfly,:);
Stepl_h_Fig2=Steplength_Sm_h{lfly};
Stepl_c_Fig2=Steplength_Sm_c{lfly};
Binary_Break_Fig2=Binary_Break(:,lfly)';
Binary_V_Fig2=Binary_V(:,lfly)';
% Breaks
% save([DataSaving_dir_temp Exp_num '\Variables\Fig1 ' date '.mat'],...
%     'Head_SmFig2','FlyDB_Fig2','params_Fig2','Etho_Speed_Fig2','Steplength_Sm_c_Fig2')

% save([DataSaving_dir_temp Exp_num '\Variables\Fig1 ' date '.mat'],...
%     'Head_SmFig2','FlyDB_Fig2','params_Fig2','Etho_Speed_Fig2',...
%     'Steplength_Sm_c_Fig2','CumTimeH','DurInH','params','Events',...
%     'DataSaving_dir_temp','Exp_num','Exp_letter')
%% Plotting
close all
fig=figure('Position',[2000 67 1100 930],'Color','w',...
    'Name',['Fig3A- Composition of visits Trajectory ' date])%,'PaperUnits','centimeters','PaperPosition',[2 5 17 20]);%);%
plotcounter=0;

for lsubs=1%:2
    deltaf=deltaf_temp(lsubs);
    Vartoplot=Vartoplot_temp{lsubs};
    rows2plot=rows2plot_temp(lsubs);
    ltracecounter=1;
    for ltrace=ManualAnnotation.(Vartoplot)(rows2plot,1)'
        lfly=ManualAnnotation.(Vartoplot)(ManualAnnotation.(Vartoplot)(:,1)==ltrace,4);
        Geometry=FlyDB_Fig2(lfly).Geometry;
        
        range=ltrace-deltaf:ManualAnnotation.(Vartoplot)(ManualAnnotation.(Vartoplot)(:,1)==ltrace,2)+deltaf;
        
        x_label='Time (frames)';
        if insec==1,
            framerate=params_Fig2.framerate;
            timerange=range/params_Fig2.framerate/60;%
            delta=deltaf/params_Fig2.framerate/60;%
            x_label='Time (min)';
        elseif insec==2
            framerate=params_Fig2.framerate;
            timerange=range/params_Fig2.framerate;%
            delta=deltaf/params_Fig2.framerate;%
            x_label='Time (s)';
        else
            timerange=range;
            framerate=0;
            delta=deltaf;
        end
        
        x_lim=[timerange(1) timerange(end)];
        
        Spots=ManualAnnotation.(Vartoplot)(ManualAnnotation.(Vartoplot)(:,1)==ltrace,3);
        
        axeslimstraj=[min(Head_SmFig2(range,1)) max(Head_SmFig2(range,1)),...
            min(Head_SmFig2(range,2)) max(Head_SmFig2(range,2))]*params_Fig2.px2mm;
        
        frames=range;
        timerange2=range;
        headingframes=frames(1:10:end);
        
        if insec==1,timerange2=frames/framerate/60;%
        elseif insec==2,timerange2=frames/framerate;%
        end
        
        
        %% Head trajectory of a visit
        plotcounter=plotcounter+1;
        subplot('Position',Positions(plotcounter,:))
        plot_tracks_single(FlyDB_Fig2,Head_SmFig2,lfly,Spots,params_Fig2,1,...
                    [0 0 0],Visits_Traj_frames,FtSz,1,1.1*LineW);
        hold on
        plot_tracks_single(FlyDB_Fig2,Head_SmFig2,lfly,Spots,params_Fig2,1,...
                    'm',frames,FtSz,0,0.8*LineW);
%         axis([6.74 24.33 -21 -3.3])
        
        axis off
        %% Head Trajectory with speed in color
        for l=1%:2 %1 is head and 2 is centroid
            plotcounter=plotcounter+1;
            subplot('Position',Positions(plotcounter,:))
            maxVel=5;
            if l==1 %head
                Stepl=Stepl_h_Fig2*params.framerate*params.px2mm;
                Traj=Head_SmFig2;
            elseif l==2 %centroid
                Stepl=Stepl_c_Fig2*params.framerate*params.px2mm;
                Traj=Cent_SmFig2;
            end
            m_speed=254/(maxVel);%(max(Steplength_Sm_h_mm(range))-min(Steplength_Sm_h_mm(range)));
            b_speed=255-m_speed*maxVel;%max(Steplength_Sm_h_mm(range));

            range_h=range(1:end);
            plot_tracks_single(FlyDB_Fig2,Traj,lfly,Spots,params_Fig2,1,...
                [.95 .95 .95],range,FtSz,1,LineW);
            if saveplot==1
                for lframe=range_h
                    speed_color=floor(m_speed*Stepl(lframe)+b_speed);
                    if speed_color>255,speed_color=255;end
                    plot(Traj(lframe,1)*params_Fig2.px2mm,...
                        Traj(lframe,2)*params_Fig2.px2mm,'ok',...
                        'MarkerFaceColor',Colormap_Speed(speed_color,:),...
                        'MarkerEdgeColor',Colormap_Speed(speed_color,:),'MarkerSize',.5)
                    if mod(lframe,500)==0
                        display(lframe)
                    end
                end
            end
            axis(axeslimstraj_temp)
            colormap(jet)
            freezeColors
            
            set(gca,'box','off','Position',Positions(plotcounter,:))
            axis off
             title([])
        end
        colorbar;
            cbfreeze(cbhandle)
            set(cbhandle,'YTick',[0 0.2 0.4 0.6 0.8 1],'YTickLabel',{'0';'1';'2 mm/s';'3';'4';'5'},...
                'FontName',FntName,'FontSize',FtSz,...
                'Position',[bar_x Positions(4,2)+0.02 0.01 3*etho_bar_h])
        %% Head Trajectory with speed ethogram colorcode
        plotcounter=plotcounter+1;
        subplot('Position',Positions(plotcounter,:))
        hold on
        %%% Thick and thin line for Heads
                plot_tracks_single(FlyDB_Fig2,Head_SmFig2,lfly,Spots,params_Fig2,1,...
                    [1 1 1],frames(1:2),FtSz,1,LineW);
        
        %%% Find behaviour bouts surrounding time segment
        for letho=1:length(Etho_Colors)
            
            starts=find(conv(double(Etho_Speed_Fig2==letho),[1 -1])==1);
            ends=find(conv(double(Etho_Speed_Fig2==letho),[1 -1])==-1)-1;
            
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
                    if lmicrobout==bout_start
                        plot_tracks_single(FlyDB_Fig2,Head_SmFig2,lfly,Spots,params_Fig2,1,...
                            Colormicromovement,frames_etho,FtSz,0,0.9*LineW);
                    else
                        plot(Head_SmFig2(frames_etho,1)*params.px2mm,...
                            Head_SmFig2(frames_etho,2)*params.px2mm,...
                            'LineWidth',0.9*LineW,'Color',Colormicromovement)
                    end
                end
            end
        end
       
        axis(axeslimstraj_temp)%(axeslimstraj)%axis([-1 19 -15 6])%YBout39
        axis off
        title([])
        %% Head trajectory with Etho Head color code
        Head_Etho_Color=[255 255 255;238 96 8;5 16 241]/255;%1-Everything else,2-Yeast,3-Breaks
        Only_Etho_H=Etho_H_Fig2;
        Only_Etho_H(~(Only_Etho_H==9))=1;%Only_Etho_H(~((Only_Etho_H==9)|(Only_Etho_H==10)))=1;
        Only_Etho_H(Only_Etho_H==9)=2;
        %         Only_Etho_H(Only_Etho_H==10)=3;
        Only_Etho_H(Binary_Break_Fig2==1)=3;%Breaks
        
        plotcounter=plotcounter+1;
        subplot('Position',Positions(plotcounter,:))
        hold on
        %%% Thick and thin line for Heads
                plot_tracks_single(FlyDB_Fig2,Head_SmFig2,lfly,Spots,params_Fig2,1,...
                    [1 1 1],frames(1:2),FtSz,1,LineW);
        
        %%% Plotting head bouts
        for letho=2:3
            starts=find(conv(double(Only_Etho_H==letho),[1 -1])==1);
            ends=find(conv(double(Only_Etho_H==letho),[1 -1])==-1)-1;
            
            bout_start1=find(starts<range(1),1,'last');
            bout_start2=find(starts<range(end),1,'last');
            bout_start=min([bout_start1,bout_start2]);
            bout_end1=find(ends>range(end),1,'first');
            bout_end2=find(ends>range(1),1,'first');
            bout_end=max([bout_end1,bout_end2]);
            Colormicromovement=Head_Etho_Color(letho,:);
            for lmicrobout=bout_start:bout_end
                frames_etho=starts(lmicrobout):ends(lmicrobout);
                
                frames_etho(frames_etho<frames(1))=[];
                frames_etho(frames_etho>frames(end))=[];
                if ~isempty(frames_etho)
                    if lmicrobout==bout_start
                        plot_tracks_single(FlyDB_Fig2,Head_SmFig2,lfly,Spots,params_Fig2,1,...
                            Colormicromovement,frames_etho,FtSz,0,0.9*LineW);
                    else
                        
                        plot(Head_SmFig2(frames_etho,1)*params.px2mm,...
                            Head_SmFig2(frames_etho,2)*params.px2mm,...
                            'LineWidth',0.9*LineW,'Color',Colormicromovement)
                    end
                end
                if letho==3
                    
                    plot(Head_SmFig2(frames_etho,1)*params.px2mm,...
                            Head_SmFig2(frames_etho,2)*params.px2mm,...
                            'LineWidth',0.9*LineW,'Color',Colormicromovement)
                end
            end
            
        end
        axis(axeslimstraj_temp)%(axeslimstraj)%axis([-1 19 -15 6])%YBout39
        axis off
        title([])
        %% Ethogram: Visits
        Visit_etho_color=[255 255 255;183 147 21]/255;
        Binary_V_Fig2(Binary_V_Fig2==1)=2;
        Binary_V_Fig2(Binary_V_Fig2==0)=1;
        plotcounter=plotcounter+1;
        subplot('Position',Positions(plotcounter,:))
        image(Binary_V_Fig2(Visits_Traj_frames))
        colormap(Visit_etho_color);
        freezeColors
        
        hold on
        plot([frames(1)-Visits_Traj_frames(1) frames(1)-Visits_Traj_frames(1)],...
            [0.5 1.5],'-m','LineWidth',1)
        plot([frames(end)-Visits_Traj_frames(1) frames(end)-Visits_Traj_frames(1)],...
            [0.5 1.5],'-m','LineWidth',1)
        font_style([],[],'Visits','normal',FntName,FtSz)
        
        colorbar;
        cbfreeze(cbhandle)
        set(cbhandle,'YTick',(1:2),...
            'YTickLabel',{'Everything else','Visit'},'FontName',FntName,'FontSize',FtSz,...
            'Position',[bar_x Positions(5,2)-0.005 0.01 1.2*etho_bar_h])
        set(gca,'XTickLabel',[],'Box','off','XTick',[],'YTickLabel',[],'YTick',[],...
            'Position',Positions(plotcounter,:))
        ylim([0.5 1.5])
        %% Ethogram: Speed segmentation
        plotcounter=plotcounter+1;
        subplot('Position',Positions(plotcounter,:))
        image(Etho_Speed_Fig2(frames))
        colormap(Etho_Colors);
        y_limetho=get(gca,'Ylim');
        hold on
        font_style([],...
            [],{'Speed';'discrete'},'normal',FntName,FtSz)
        %         set(gca,'XTickLabel',[],'Box','off','XTick',[],'YTickLabel',[],'YTick',[])
        xlim([0 frames(end)-frames(1)])
        
        colorbar;
        cbfreeze(cbhandle)
        set(cbhandle,'YTick',(1:length(Etho_Colors_Labels)),...
            'YTickLabel',Etho_Colors_Labels,'FontName',FntName,'FontSize',FtSz,...
            'Position',[bar_x Positions(6,2)-0.005 0.01 2.4*etho_bar_h])
        freezeColors
        set(gca,'XTickLabel',[],'Box','off','XTick',[],'YTickLabel',[],'YTick',[],...
            'Position',Positions(plotcounter,:))
        
        %% Ethogram: Head micromovements and Breaks
        plotcounter=plotcounter+1;
        subplot('Position',Positions(plotcounter,:))
        image(Only_Etho_H(1,frames))
        colormap(Head_Etho_Color);
        freezeColors
        y_limetho=get(gca,'Ylim');
        hold on
        font_style([],...
            'Time (min)',{'Head';'bouts'},'normal',FntName,FtSz)%'Ethogram'
        
        xlim([0 frames(end)-frames(1)])
        x_ticks=frames(mod(frames,50*60/3)==0)-frames(1);
        num_dig=2;
        n=timerange(mod(frames,50*60/3)==0);
        n_rounded = round(n*(10^num_dig))/(10^num_dig);
        xticklabels=strread(num2str(n_rounded),'%s')';
        set(gca,'Box','off','YTick',[],'YTickLabel',[],'XTick',x_ticks,'XTickLabel',xticklabels)
        
        colorbar
        cbfreeze(cbhandle)
        set(cbhandle,'YTick',(1:3),...
            'YTickLabel',{'Everything else';'Yeast head bout';'Breaks'},'FontName',FntName,'FontSize',FtSz,...
            'Position',[bar_x Positions(7,2)-0.005 0.01 1.2*etho_bar_h])
        set(gca,'Position',Positions(plotcounter,:))
        
    end
    
    
end
%% Area Coverage
plotcounter=7;
plot_type='Time_Spot_2D';
Fig3C_Area_coverage_2DHist
plot_type='Area covered boxplots';
Fig3C_Area_coverage_2DHist
Hist_dist2spot_visits %%% Distribution on spot

if saveplot==1,
%     figname=[Exp_num Exp_letter 'Example Fig2 Composition of visits res1200 merged ' date];
%     print('-dpng','-r1200',[DataSaving_dir_temp Exp_num '\Plots\Presentations\' figname '.png'])
    savefig_withname(1,'600','png','E:\Analysis Data\Experiment ','0003','A',...
    'Figures')
end