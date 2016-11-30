%% Plotting Fly trajectory and kinematic parameters
%% Segment to plot
delay=0;%20;%30;%if larger than zero will show dynamic plot
deltaf=1;
save_plot=0;
merged=1;
FtSz=8;%20;
FntName='arial';
LineW=0.8;

x=0.18;y=0.11;dy=0.03;
heightsubplot=(1-2*y-4*dy)/4;
widthsubplot=1-1.5*x;

Subplot_positions=[x y+3*heightsubplot+4*dy widthsubplot (2/3)*heightsubplot;...
    x y+2*heightsubplot+3*dy widthsubplot (2/3)*heightsubplot;...
    x y+2*heightsubplot/2+2*dy widthsubplot heightsubplot;...
    x y+heightsubplot/2+dy widthsubplot heightsubplot/2;...
    x y widthsubplot heightsubplot/2];


% Annotationrows=[12 16 32 33 47 49 54 55 58 57 65 67 74 94 98 102 129];%1:139;
Annotationrows=0;%12:140;%find(cell2mat(cellfun(@(x)~isempty(x),{Annotation_micromovements(1:139).Resting}','uniformoutput',false)))';

%% Other parameters
%%% Colors, format parameters
insec=0;%0;

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



plotmanual_ann_edge=1;

%%% Video parameters
fps=20;
step=50;
Repeatloop=1;% Times to repeat display

close all
fig=figure('Position',[50 50 800 950],'Color','w','PaperUnits','centimeters',...
    'PaperPosition',[1 1 9 9]);%
for annotation_row=Annotationrows
    
    ManualAnnotation.YFeedingEvents=[56086 65469 1 8];%[58085 62577 1 8];%[150000 167300 12 119];%[58385 62277 1 1];%[332663 344999 7 1];%[65875 65944 1 32];%%[88753 89859 1 32];%[89653 89859 1 32];%[121826 134731 16 113];
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
        
        frames=range;
        timerange2=range;
        headingframes=frames(1:10:end);
        
        if insec==1,timerange2=frames/framerate/60;%
        end
        
        clf
        %% Dist 2 Spot
        lplot=1;
        subplot('Position',Subplot_positions(lplot,:))% To be on top
        
        hold on
        severalplots=0;
        clear X
        X=Dist2Spots*params.px2mm;
        
        var_label={'Distance';'from spot';'(mm)'};
        figname=[];
        lowthr=2.5;%2.3;%2.2;%1.9;
        uppthr=5;%3;
        %     plot([range(1) range(end)],[2.2 2.2],'--')
        plot_mann_ann
        ylim([0 6]);set(gca,'XTickLabel',[],'XTick',[],'YTick',0:6,'YTickLabel',...
            {'0',' ','2',' ','4',' ','6'})%Bottom part of axis
%         ylim([6 25]);set(gca,'XTickLabel',[],'XTick',[],'YTick',10:5:25,'YTickLabel',{'10',' ',' ','25'})%Top part of axis
        xlabel([])
       
        %% Steplength
        lplot=lplot+1;
        subplot('Position',Subplot_positions(lplot,:))%if only dist on top
        
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
        
        var_label={'Speed';'(mm/s)'};
        figname=[];
        lowthr=0.2;uppthr=2;%lowthr=0.05;uppthr=nan;%
        
        h1=plot_kinetic(X,frames,timerange2,lowthr,uppthr,LineW,[0 114 178]/255);
        plot_mann_ann
        h2=plot_kinetic(Steplength_Sm_c{lfly}*params.px2mm*params.framerate,...
            frames,timerange2,lowthr,uppthr,LineW,'k');%Color(2,:)
        
        xlabel([])
                legend([h1,h2],{'Head';'Centr'},'Position',[.92 0.56 .005 .02],'FontSize',FtSz-1)
        legend('boxoff')
%         ylim([0 20]);set(gca,'XTickLabel',[],'XTick',[])
        ylim([0 6]);set(gca,'XTickLabel',[],'XTick',[],'YTick',0:6,'YTickLabel',{'0',' ','2',' ','4',' ','6'})%Bottom part of axis
%         ylim([6 20]);set(gca,'XTickLabel',[],'XTick',[],'YTick',10:5:20,'Yticklabel',{'10',' ','20'})
        %             text(timerange(1)+delta,X(frames(1)+deltaf),...
        %              num2str(X(frames(1)+deltaf)),'FontSize',15,...
        %              'FontName','calibri')
        
        %% Angular speed
        lplot=lplot+1;
        subplot('Position',Subplot_positions(lplot,:))%0.26 Y
        hold on
        severalplots=0;
        clear X
        if ~exist('HeadingDiff','var'),flies_idx=params.IndexAnalyse;
            [~,~,HeadingDiff] =Heading_WalkingDir(Heads_Sm,Tails_Sm,Centroids_Sm);
        end
        X=(HeadingDiff{lfly})*params.framerate;%WalkingDirDiff{lfly};
        
        var_label={'Angular';'Speed';'(º/s)'};%{'Change in Walk Dir';'(º/0.02 s)'};
        figname=[];
        lowthr=-125;uppthr=125;
        
        y_lim=[min(X(range))-0.05*min(X(range)) max(X(range))+0.05*max(X(range))];%get(gca,'YLim');
        
        plot_mann_ann
        set(gca,'XTickLabel',[],'XTick',[])
        xlabel([])
        ylim([-400 y_lim(2)])
        %% Ethogram
        lplot=lplot+1;
        subplot('Position',Subplot_positions(lplot,:))
        %         image(Etho_Speed{lfly}(frames)')
        
        image(Etho_H_Speed(lfly,frames))
        colormap(EthoH_Colors);
        freezeColors
        y_limetho=get(gca,'Ylim');
        hold on
        font_style([],...
            [],{'Etho-';'gram'},'normal',FntName,FtSz)
        set(gca,'XTick',[],'Box','off','YTickLabel',[],'YTick',[])
        xlim([0 frames(end)-frames(1)])
%         Etho_Colors_Labels={'Rest','Micromov','Walk',...
%             'Sharp Turn','Jump','Head Y','Head S'};
%                 hcb=colorbar;set(hcb,'YTick',(1:size(EthoH_Colors,1)),...
%                     'YTickLabel',Etho_Colors_Labels,'FontName',FntName,'FontSize',FtSz,'Position',[.915 .37 0.02 0.1])
        %% Visits Binary Raster plot
        lplot=lplot+1;
        subplot('Position',Subplot_positions(lplot,:))
        BinaryYSVisits=CumTimeV{1}(frames,lfly);
        BinaryYSVisits(BinaryYSVisits==0)=3;
        BinaryYSVisits(CumTimeV{2}(frames,lfly)==1)=2;
        
        image(BinaryYSVisits')
        [~,~,~,VisitsColor]=ColorsPaper5cond_fun;
        colormap([VisitsColor;1 1 1]);%170 170 170
        

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
        
        
        %% save plot
        figname=[ num2str(rows2plot(ltracecounter)) ' - ' Vartoplot 'Visits - Fly ' num2str(lfly),...
            ', ' num2str(range(1)-delay) ' to ' num2str(range(end)+delay) ' ' date];
        
        set(gcf,'Name',figname)
        if save_plot==1
            subfolder='Figures';
            %%
            savefig_withname(1,'600','png',DataSaving_dir_temp,Exp_num,Exp_letter,...
                subfolder)
            %%
            savefig_withname(0,'600','eps',DataSaving_dir_temp,Exp_num,Exp_letter,...
                subfolder)
            
        end
        
        if lrow~=rows2plot(end)
            pause
        end
        
    end
    % save([Variablesfolder 'Micromovement_pxcovered_' Exp_num Exp_letter ' ' date '.mat'],'Mm_Grooming','Mm_inside','Mm_outside')
    if size(Annotationrows,2)>1,pause, end
end