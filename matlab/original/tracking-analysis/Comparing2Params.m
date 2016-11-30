%% Plotting Fly trajectory and kinematic parameters
% close all
%% Other parameters
%%% Colors, format parameters
insec=0;%0;
States_Colors=[238 96 8;0 0 0;0 166 0; 255 255 255]/255;%[Orange, Black, Green, White]
Color=Colors(3);
WalkingEtho_Colors=[Color(3,:);[1 1 1];[0.5 0.5 0.5]];%[blue, white, gray]
Param_color=[235 135 15]/255;
FtSz=9;%20;
LineW=1;
FntName='arial';
plotmanual_ann_edge=1;

%% Delta!
deltaf=50;%200;


%% Segment to plot
load([Variablesfolder 'ManualAnnotation0003A 07-Jan-2015.mat'])

% ManualAnnotation.YFeedingEvents=[fr_start fr_end Spots(1) lfly];
% ManualAnnotation.YFeedingEvents=[25455 30541 7 32];%[332663 344999 7 1];%[65875 65944 1 32];%%[88753 89859 1 32];%[89653 89859 1 32];%[121826 134731 16 113];

% load([Variablesfolder 'Annotation_micromovements_0003A 19-Feb-2015.mat'])
lastannotationrow=140;
newrows=size(cell2mat({Annotation_micromovements(1:lastannotationrow).Resting}'),1);
ManualAnnotation.RestNew=nan(newrows,4);
NewRest_temp={Annotation_micromovements(1:lastannotationrow).Resting}';
ManualAnnotation.RestNew(:,1:2)=cell2mat(NewRest_temp);
temp_idx=find(cell2mat(cellfun(@(x)~isempty(x),NewRest_temp,'uniformoutput',false)))';
Indexcounter=0;
for lannnew=temp_idx
    for num_rest=1:size(Annotation_micromovements(lannnew).Resting,1)
       Indexcounter=Indexcounter+1;
       ManualAnnotation.RestNew(Indexcounter,3:4)=Annotation_micromovements(lannnew).Info(3:4);
        
    end
end
%%
newrows=size(cell2mat({Annotation_micromovements(1:lastannotationrow).Grooming}'),1);
ManualAnnotation.GroomingNew=nan(newrows,4);
ManualAnnotation.GroomingNew(:,1:2)=cell2mat({Annotation_micromovements(1:lastannotationrow).Grooming}');
temp_idx=find(cell2mat(cellfun(@(x)~isempty(x),{Annotation_micromovements(1:139).Grooming}','uniformoutput',false)))';
Indexcounter=0;
for lannnew=temp_idx
    for num_rest=1:size(Annotation_micromovements(lannnew).Grooming,1)
        Indexcounter=Indexcounter+1;
        ManualAnnotation.GroomingNew(Indexcounter,3:4)=Annotation_micromovements(lannnew).Info(3:4);
    end
end

%%
Vars2compare={'Rest';'RestNew'};%{'Grooming';'Grooming'};%{'YFeedingEvents';'YFeedingEvents'};%
if length(Vars2compare)>1
    maxflies_temp=nan(length(Vars2compare),1);
    for lvar=1:length(Vars2compare)
        maxflies_temp(lvar)=size(ManualAnnotation.(Vars2compare{lvar}),1);
    end
    MaxFlies_var=max(maxflies_temp);
else
    MaxFlies_var=size(ManualAnnotation.(Vars2compare{1}),1);
end

fig=figure('Position',[100 10 1200 950],'Color','w');%
% Walking_vec=walking_fun(Steplength_Sm_c,Steplength_Sm180_h,flies_idx,params);
for lvar=1:length(Vars2compare)
    
    Vartoplot=Vars2compare{lvar};
    rowsVartoplot=size(ManualAnnotation.(Vartoplot),1);
    if (length(Vars2compare{1})==length(Vars2compare{2}))&&(isempty(find((Vars2compare{1}==Vars2compare{2})==0,1)))
        if lvar==1
            rows2plot=65:80;%1:7;%
        else
            rows2plot=81:96;%8:14;%
        end
    else
        rows2plot=1:min(rowsVartoplot,MaxFlies_var);
    end
        
    
    ltracecounter=1;
    for lrow=rows2plot
        ltrace=ManualAnnotation.(Vartoplot)(lrow,1);
        subplot_num=2*ltracecounter-1+(lvar-1);
        subplot(MaxFlies_var,length(Vars2compare),subplot_num)
        lfly=ManualAnnotation.(Vartoplot)(lrow,4);
        Geometry=FlyDB(lfly).Geometry;
        
        range=ltrace-deltaf:ManualAnnotation.(Vartoplot)(lrow,2)+deltaf;
        
        if insec==1,
            framerate=params.framerate;
            timerange=range/params.framerate/60;%
            delta=deltaf/params.framerate/60;%
            x_label='Time (min)';
        else
            timerange=range;
            framerate=0;
            delta=deltaf;
            x_label='Time (frames)';
        end
        frames=range;
        x_lim=[timerange(1) timerange(end)];
        
        Spots=ManualAnnotation.(Vartoplot)(lrow,3);
        lsubs=Geometry(Spots);
        
        timerange2=range;
        headingframes=frames(1:10:end);
        if insec==1,timerange2=frames/framerate/60;%
        end
        
        
        %% Steplength
        hold on
        severalplots=0;
        clear X
        X=Steplength_Sm_h{lfly}*params.px2mm*params.framerate;
        
        %%% Plot of shaded area where walking bout
        walkstarts=find(conv(double(Walking_vec{lfly}==1),[1 -1])==1);
        walkends=find(conv(double(Walking_vec{lfly}==1),[1 -1])==-1);
        %%% Find walking bouts surrounding time segment
        boutstart=find(walkstarts<range(1),1,'last');
        boutend=find(walkends>range(end),1,'first');
        for lwalkingbout=boutstart:boutend
            if insec==1
                fillh=fill([walkstarts(lwalkingbout);walkstarts(lwalkingbout);...
                    walkends(lwalkingbout); walkends(lwalkingbout)]/framerate/60,...
                    [0;25;...
                    25;0],...
                    Color(3,:));
            else
                fillh=fill([walkstarts(lwalkingbout);walkstarts(lwalkingbout);...
                    walkends(lwalkingbout); walkends(lwalkingbout)],...
                    [0;25;...
                    25;0],...
                    Color(3,:));
            end
            set(fillh,'EdgeColor',Color(3,:),'FaceAlpha',.3,...
                'EdgeAlpha',.3);
        end
        
        %%% Plot of shaded area where inactivity bout
%         inactstarts=find(conv(double(Walking_vec{lfly}==3),[1 -1])==1);
%         inactends=find(conv(double(Walking_vec{lfly}==3),[1 -1])==-1);
        
        inactstarts=find(conv(double(Walking_vec{lfly}==3),[1 -1])==1);
        inactends=find(conv(double(Walking_vec{lfly}==3),[1 -1])==-1);
        
        %%% Find inactivity bouts surrounding time segment
        boutstart=find(inactstarts<range(1),1,'last');
        boutend=find(inactends>range(end),1,'first');
        for linactbout=boutstart:boutend
            if insec==1
                fillh=fill([inactstarts(linactbout);inactstarts(linactbout);...
                    inactends(linactbout); inactends(linactbout)]/framerate/60,...
                    [0;25;...
                    25;0],...
                    [0.5 0.5 0.5]);
            else
                fillh=fill([inactstarts(linactbout);inactstarts(linactbout);...
                    inactends(linactbout); inactends(linactbout)],...
                    [0;25;...
                    25;0],...
                    [0.5 0.5 0.5]);
            end
            set(fillh,'EdgeColor',[0.5 0.5 0.5],'FaceAlpha',.3,...
                'EdgeAlpha',.3);
        end
        
        if ltracecounter==1
            var_label={'Speed';'(mm/s)'};
            figname=Vartoplot;
        else
            var_label=[];
            set(gca,'YTickLabel',[],'YTick',[])
            figname=[];
        end
        
        lowthr=0.05;uppthr=0.2;%lowthr=0.04;uppthr=0.15;%lowthr=2;uppthr=4;
        
        plot_mann_ann
        plot_kinetic(Steplength_Sm180_h{lfly}*params.px2mm*params.framerate,...
            frames,timerange2,lowthr,uppthr,1,Color(2,:));
        
        set(gca,'XTickLabel',[],'XTick',[])
        xlabel([])
        if ltracecounter~=1
            ylabel(num2str(lrow))
        end
        ylim([0 1])%ylim([0 .8])
        %         ylim([0 0.3])
        %% Area covered
%         hold on
%         clear X
%         severalplots=0;
%         X=AreaCovered{lfly};
%         if ltracecounter==1
%             var_label={'Area covered';'[px/s]'};
%             figname=Vartoplot;
%         else
%             var_label=[];
%             set(gca,'YTickLabel',[],'YTick',[])
%             figname=[];
%         end
%         
%         lowthr=nan;uppthr=0;
%         Color(3,:)=[120 52 76]/255;
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
%             
%         
%        set(gca,'XTickLabel',[],'XTick',[])
%         xlabel([])
%         if ltracecounter~=1
%             ylabel(num2str(lrow))
%         end
%         ylim([0 5])
        
        ltracecounter=ltracecounter+1;
    end
end

% figname=['Comparing Area covered for ' Vars2compare{1} ' and ' Vars2compare{2},...
%     'Win1sec.tif'];
figname=['Comparing Speed for ' Vars2compare{1} ' and ' Vars2compare{2},...
    '_Smooth180_0,5sec_Low0,05_NoHigh.tif'];
% print('-dtiff','-r600',[DataSaving_dir_temp Exp_num '\Plots\Manual Ann\' figname])