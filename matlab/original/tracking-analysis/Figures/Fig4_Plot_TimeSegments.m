%% Plot Time Segments
saveplot=1;SubFolder_name='Time Segments';
fliestoplot=params.IndexAnalyse;%7;%32;%32;%Flies_cluster{3}';%flies_idx;
% ranges=[1 30000;30001 120000;120001 240000;240001 345000];%
ranges=[1 30000;30001 90000;90001 150000;150001 210000;210001 270000;270001 345000];%
% ranges=[1 15000;15001 45000;45001 105000;105001 165000;165001 225000;225001 285000;285001 345000];%
merged=1;
clear ylabel
FntName='arial';
if saveplot==1
    FtSz=8;
    LineW=0.8;
else
    FtSz=11;
    LineW=1.5;
end

%% Subplots positions
h_dist=0.03;
v_dist=0.03;
width=(1-(size(ranges,1)+1)*h_dist)/(size(ranges,1));
heights1=[0.2;0.04;0.04;0.02;0.02];
heights2=repmat(0.07,4,1);%[Traj,Etho_H,Etho_Tr]

numplots_per_col=size(heights1,1);
numcols=size(ranges,1);
y1=1-heights1(1)-v_dist;
clear Positions
Positions{1}=zeros(numcols*(numplots_per_col),4);
rangecounter=1;
for lrange=1:numcols
    Positions{1}((lrange-1)*(numplots_per_col)+1:lrange*(numplots_per_col)-1,:)=...
        [repmat(h_dist+(lrange-1)*width+(lrange-1)*h_dist,numplots_per_col-1,1),...
        ones(numplots_per_col-1,1)-cumsum(heights1(1:end-1))-(1:numplots_per_col-1)'.*v_dist-0.05*ones(numplots_per_col-1,1),...
        repmat(width,numplots_per_col-1,1) heights1(1:end-1)];
    Positions{1}(lrange*numplots_per_col-1,:)=...
        [(h_dist+(lrange-1)*width+(lrange-1)*h_dist),...
        1-sum(heights1(1:end-1))-(numplots_per_col-1)'.*v_dist-.05,...
        width/2.5 heights1(end-1)];
    Positions{1}(lrange*(numplots_per_col),:)=...
        [Positions{1}(lrange*numplots_per_col-1,1)+(1-1/2.5)*width,...
        1-sum(heights1(1:end-1))-(numplots_per_col-1)'.*v_dist-.05,...
        width/2.5 heights1(end-1)];
    
end
halfrow=ceil(size(heights2,1)/2);
Positions{2}=[[repmat(h_dist*2.5,size(heights2,1),1),...
    1-sum(heights1(1:end-1))-(numplots_per_col)'.*v_dist-cumsum(heights2)-(1:size(heights2,1))'.*v_dist-0.05*ones(size(heights2,1),1),...
    repmat((1-5*h_dist*2.5)/2,size(heights2,1),1), heights2];...
    [repmat(h_dist*2.5+(1-5*h_dist*2.5)/2+3*h_dist*2.5,size(heights2,1),1),...
    1-sum(heights1(1:end-1))-(numplots_per_col)'.*v_dist-cumsum(heights2)-(1:size(heights2,1))'.*v_dist-0.05*ones(size(heights2,1),1),...
    repmat((1-5*h_dist*2.5)/2,size(heights2,1),1), heights2]];

if (sum(sum(Positions{1}<0))~=0)||(sum(sum(Positions{2}<0))~=0)
    error('With these parameters, the subplots don''t fit in the figure')
end
% close all
% figure('Position',[100 50 1400 930],'Color','w')
% for lplot=1:size(Positions{1},1)
%     subplot('Position',Positions{1}(lplot,:))
% end
% for lplot=1:size(Positions{2},1)
%     subplot('Position',Positions{2}(lplot,:))
% end

%%
plotarena=1;
Spots=1;%current_spot;%[1,5,9,14];
Color=Colors(3);%hsv(length(flies_idx));%
ColorAx1=[238 96 8]/255;%Color(1,:);
ColorAx2=[.4 .4 .4];%Color(2,:);

if ~exist('Etho_Speed_new','var')
[Etho_Speed_new,Etho_colors_new,Etho_Colors_Labels] = Etho_Speed2New(params.MinimalDuration,Etho_Speed,merged);
end
if ~exist('Etho_H_new','var')
    [Etho_H_new, EthoH_colors_new,EthoH_Colors_Labels] = HeadEtho2New(Etho_H,Binary_Break,merged);
end
Visit_N_Segm_colors=[Etho_colors_new;...
    [241 195 27;5 16 241]/255];...%[heads;breaks]
    
xlim_=[-33 33];%[11 16.2];%
ylim_=[-33 33];%[-17.2 -11.5];%

xrange=-33/params.px2mm:33/params.px2mm;

n_rounded=nan(1,size(ranges,1));
for lrange=1:size(ranges,1)
    n=((ranges(lrange,2)-ranges(lrange,1))/2+ranges(lrange,1))/50/60;
    n2=(ranges(lrange,2))/50/60;
    n_rounded(lrange) = round(n*(10^2))/(10^2);
end

if ~exist('Etho_Tr','var')
    [TrEvents,TrArea,Etho_Tr,Etho_Tr_Colors]=TransitionProb(DurInV,Heads_Sm,FlyDB,params);
end
%%
close all
figure('Position',[2100 50 1400 930],'Color','w')
hold on

for lfly=fliestoplot
    clf
        variables=struct('NHeadmm',nan(size(ranges,1),2),'NBreaks',nan(size(ranges,1),2),...
        'AvDurVisit',nan(size(ranges,1),2),...
        'NVisits',nan(size(ranges,1),2),'SpotDist',nan(size(ranges,1),2),...'TrPr',nan(size(ranges,1),4),...
        'WalkDistSpeed',nan(size(ranges,1),2),'EdgeExpl',nan(size(ranges,1),2),...
        'AreaCovered',nan(size(ranges,1),2));
    Nvisits_TrPr=nan(size(ranges,1),2);
    
    for lrange=1:size(ranges,1)
        hold on
        range=ranges(lrange,1):ranges(lrange,2);
        display(['time range: ' num2str(range(1)) ' - ' num2str(range(end)) ' (fr)'])
        %% TOP1: Trajectories
        subplot('Position',Positions{1}((lrange-1)*numplots_per_col+1,:))
        plot_tracks_single(FlyDB,Heads_Sm{lfly},lfly,Spots,params,1,...
            [.7 .7 .7],range,FtSz,1,0.5*LineW);%Plotting selected flies
        
        %%% Plot trajectories with ethogram colors
        colormap_segments=EthoH_colors_new;%Etho_Tr_Colors;%Etho_Colors;
        etho_segments=Etho_H_new(lfly,:);%Etho_Tr(lfly,:);%Etho_Speed_new(lfly,:);%
        plot_traj_etho(Heads_Sm,lfly,range,etho_segments,colormap_segments,LineW,params)
        title([num2str(floor(range(1)/params.framerate/60)) ' - ' num2str(floor(range(end)/params.framerate/60)) ' min'],'FontSize',FtSz,'FontName',FntName)
        axis([xlim_ ylim_])
        axis off
        if lrange==1
            font_style({[params.LabelsShort{params.ConditionIndex(lfly)},...
                '; Fly Nº' num2str(lfly)]; ['0 - ' num2str(floor(range(end)/params.framerate/60)) ' min']},...
                [],[],'normal',FntName,FtSz)
        end
        %% TOP2: Head-Speed Ethogram
        subplot('Position',Positions{1}((lrange-1)*numplots_per_col+2,:))
        image(Etho_H_new(lfly,range))%image(Etho_Speed_new(lfly,range))
        colormap(EthoH_colors_new);%(Etho_colors_new);
        freezeColors
        
        set(gca,'XTickLabel',[],'Box','off','XTick',[],'YTickLabel',[],'YTick',[])
        xlim([0 range(end)-range(1)])
        font_style([],[],{'Speed';'Etho'},'normal',FntName,FtSz)
        if lrange~=1
            ylabel([])
        end
        if lrange==1
        cbh=colorbar;
        temppos=Positions{1}((lrange-1)*numplots_per_col+3,:);
        set(cbh,'Position',[temppos(1) temppos(2)-0.07 0.25*temppos(3) temppos(4)+0.09],...
            'YTick',1:length(EthoH_Colors_Labels),...
            'YTickLabel',EthoH_Colors_Labels,'Fontsize',8)
        end
        %% TOP3: Transition Ethogram
%         subplot('Position',Positions{1}((lrange-1)*numplots_per_col+3,:))
%         image(Etho_Tr(lfly,range))
%         colormap(Etho_Tr_Colors);
%         freezeColors
%         set(gca,'XTickLabel',[],'Box','off','XTick',[],'YTickLabel',[],'YTick',[])
%         xlim([0 range(end)-range(1)])
%         font_style([],[],{'Trans';'Etho'},'normal',FntName,FtSz)
%         if lrange~=1
%             ylabel([])
%         end
%         %         set(ch,'YTick',(1:length(Etho_Tr_Colors)),...
%         %     'YTickLabel',{'Y visit';'S visit';'To adj Y';'To adj S';'To far Y';'To far S';'Undef'},'FontName',FntName,'FontSize'
        %% Calculation of variables below - Visits that started in the previous period will be included
        %%% In the case the visit starts in the previous time segment and
        %%% finishes in the current time segment
        clear DurInV_Segm boutstart boutstart1 boutend1 boutend Head_Segm
        boutstart1=find(DurInV{lfly}(:,2)<=range(1),1,'last');
        if isempty(boutstart1)||(DurInV{lfly}(boutstart1,3)<=range(1))
            boutstart1=find(DurInV{lfly}(:,2)>=range(1),1,'first');
        end
        
        if DurInV{lfly}(boutstart1,2)<=range(end)
            boutstart=boutstart1;
            boutend1=find(DurInV{lfly}(:,3)<=range(end),1,'last');
            
            if isempty(boutend1)
                boutend=boutstart;
            elseif (boutend1~=size(DurInV{lfly},1))&&(DurInV{lfly}(boutend1+1,2)<=range(end))
                boutend=boutend1+1;
            else
                boutend=boutend1;
            end
            
        else
            boutstart=[];
        end
        
        if isempty(boutstart)
            DurInV_Segm=[];
            variables.NHeadmm(lrange,:)=[0 0];
            variables.NBreaks(lrange,:)=[0 0];
            variables.AvDurVisit(lrange,:)=[0 0];
            variables.NVisits(lrange,:)=[0 0];
            variables.SpotDist(lrange,:)=[0 0];
            %             variables.TrPr(lrange,:)=[0 0 0 0];
        else
            if (isempty(boutend))||(boutend<boutstart)
                error('boutend is empty or smaller than boutstart')
                %                 boutend=boutstart;
            end
            DurInV_Segm=DurInV{lfly}(boutstart:boutend,:);
            Visit_frames=DurInV{lfly}(boutstart,2):DurInV{lfly}(boutend,3);
            
            headstart=find(DurInH{lfly}(:,2)>=Visit_frames(1),1,'first');
            if isempty(headstart)||DurInH{lfly}(headstart,2)>=Visit_frames(end)
                Head_Segm=[];
            else
                headend=find(DurInH{lfly}(:,3)<=Visit_frames(end),1,'last');
                if headend<headstart,error('Head end end smaller than Head start'),end
                Head_Segm=DurInH{lfly}(headstart:headend,:);
            end
            
            %% 1 - 4: Y & S Visit variables
            for lsubs=params.Subs_Numbers
                clear breakstart breaksend
                Breaktemp=Breaks{lsubs==params.Subs_Numbers}(Breaks{lsubs==params.Subs_Numbers}(:,4)==lfly,1:2);
                breakstart=find(Breaktemp(:,1)>=Visit_frames(1),1,'first');
                if isempty(breakstart)||Breaktemp(breakstart,1)>=Visit_frames(end)
                    variables.NBreaks(lrange,lsubs==params.Subs_Numbers)=0;
                else
                    breaksend=find(Breaktemp(:,2)<=Visit_frames(end),1,'last');
                    if breaksend<breakstart,error('Break end smaller than Break start'),end
                    %%% Number of breaks per visit
                    variables.NBreaks(lrange,lsubs==params.Subs_Numbers)=(breaksend-breakstart+1)/sum(DurInV_Segm(:,1)==lsubs);
                end
                %%% Number of Head micromovements per visit
                
                variables.NHeadmm(lrange,lsubs==params.Subs_Numbers)=sum(Head_Segm(:,1)==lsubs)/sum(DurInV_Segm(:,1)==lsubs);
                
                %%% Number of visits
                variables.NVisits(lrange,lsubs==params.Subs_Numbers)=sum(DurInV_Segm(:,1)==lsubs);
                %%% Average duration of visits
                variables.AvDurVisit(lrange,lsubs==params.Subs_Numbers)=mean(DurInV_Segm(DurInV_Segm(:,1)==lsubs,5))/params.framerate;%s
                if lsubs==1
                    variables.AvDurVisit(lrange,lsubs==params.Subs_Numbers)=variables.AvDurVisit(lrange,lsubs==params.Subs_Numbers)/60;%min
                end
                %%% Average distance between next yeast or sucrose
                SpotNumbers=find(FlyDB(lfly).Geometry==lsubs);
                Wellpos=FlyDB(lfly).WellPos;
                V_Num_log=ismember(DurInV_Segm(:,4)', SpotNumbers);
                V_Num=DurInV_Segm(V_Num_log,4);%Numbers of spots visited
                if size(V_Num,1)>1
                    distspots_temp=nan(size(V_Num,1)-1,1);
                    for lspot=1:size(V_Num,1)-1
                        distspots_temp(lspot)=sqrt(sum((Wellpos(V_Num(lspot+1),:)-...
                            Wellpos(V_Num(lspot),:)).^2));
                        
                    end
                    variables.SpotDist(lrange,lsubs==params.Subs_Numbers)=mean(distspots_temp)*params.px2mm;
                else
                    % Only 1 visiy
                    variables.SpotDist(lrange,lsubs==params.Subs_Numbers)=nan;
                end
                %%% Average distance covered between next yeast or sucrose
%                 SpotNumbers=find(FlyDB(lfly).Geometry==lsubs);
%                 Wellpos=FlyDB(lfly).WellPos;
%                 V_Num_log=ismember(DurInV_Segm(:,4)', SpotNumbers);
%                 V_row=find(V_Num_log)';
%                 if size(V_row,1)>1
%                     distcovered_temp=nan(size(V_row,1)-1,1);
%                     for lspot=1:size(V_row,1)-1
%                         distcovered_temp(lspot)=...
%                             nansum(Steplength_Sm_c{lfly}(DurInV_Segm(V_row(lspot),3):DurInV_Segm(V_row(lspot+1),2)))*params.px2mm;%mm
%                     end
%                     variables.SpotDist(lrange,lsubs==params.Subs_Numbers)=nanmean(distcovered_temp)*params.px2mm;
%                 else
%                     % Only 1 visiy
%                     variables.SpotDist(lrange,lsubs==params.Subs_Numbers)=nan;
%                 end
            end
            %% TOP4: Visit composition - Number
            %             subplot('Position',Positions{1}((lrange-1)*numplots_per_col+4,:))
            
            %         for lto=1:size(Visit_N_Segm,2)
            %             set(barhandle(lto),'FaceColor',Visit_N_Segm_colors(lto,:),'LineWidth', 1,'EdgeColor',Visit_N_Segm_colors(lto,:));%,'BarWidth',0.4);
            %         end
            %% TOP5: Visit composition - Fraction
            %             subplot('Position',Positions{1}((lrvaange-1)*numplots_per_col+5,:))
            %% Area covered during visit (col1)
            lsubs=1;%Claculate area covered of yeast spots
            visit_rows=find(DurInV{lfly}(boutstart:boutend,1)==lsubs)'+boutstart-1;
            Ar_Cov_temp=nan(length(visit_rows),1);
            visitcounter=0;
            for lvisit=visit_rows
                visitcounter=visitcounter+1;
                Heads_temp=Heads_Sm{lfly}(DurInV{lfly}(lvisit,2):DurInV{lfly}(lvisit,3),:)-...
                    repmat(FlyDB(lfly).WellPos(DurInV{lfly}(lvisit,4),:),DurInV{lfly}(lvisit,5),1);%
%                 %%% Area of spot covered
%                 logical_Hmm=logical(Binary_Head_mm(DurInV{lfly}(lvisit,2):DurInV{lfly}(lvisit,3),lfly));
%                 count_fly= hist3([Heads_temp(logical_Hmm,2) Heads_temp(logical_Hmm,1)],{xrange xrange});
                %%% Area covered during the visit
                count_fly= hist3([Heads_temp(:,2) Heads_temp(:,1)],{xrange xrange});
                Ar_Cov_temp(visitcounter)=sum(sum(count_fly~=0));
            end
            variables.AreaCovered(lrange,1)=mean(Ar_Cov_temp)/1000;
        end
        %% 5: Transition probabilities
%         ltrcounter=0;
%         for ltr=size(params.Subs_Names,1)+1:3*size(params.Subs_Names,1)
%             ltrcounter=ltrcounter+1;
%             variables.TrPr(lrange,ltrcounter)=sum(conv(double(Etho_Tr(lfly,...
%                 range(1):range(end))==ltr),[1 -1])==1);
%             %                 Nvisits_TrPr(lrange,1)=sum(conv(double(Etho_Tr(lfly,...
%             %                     range(1):range(end))==1),[1 -1])==1);
%             %                 Nvisits_TrPr(lrange,2)=sum(conv(double(Etho_Tr(lfly,...
%             %                     range(1):range(end))==2),[1 -1])==1);
%             % %                 variables.TrPr(lrange,ltrcounter)=sum(conv(double(Etho_Tr(lfly,...
%             % %                     Visit_frames(1)-1:Visit_frames(end))==ltr),[1 -1])==1);
%         end
%         
%         %%% Sanity check transitions: There is almost always one more
%         %%% transition than the number of visits correspondent to the
%         %%% last IBI when the fly leaves the last food.
%         if abs(sum(variables.TrPr(lrange,:))-sum(variables.NVisits(lrange,:)))>1
%             error('Total number of transitions doesn''t match number of visits')
%         end
%         if sum(variables.TrPr(lrange,:))==0
%             variables.TrPr(lrange,:)=zeros(1,4);
%         else
%             variables.TrPr(lrange,:)=variables.TrPr(lrange,:)./sum(variables.TrPr(lrange,:))*100;
%         end
%         
        %% 6: Walking outside the visits (Distance and average speed)
        logicalwalkoutside=(Etho_Speed_new(lfly,range)==3)&~(Binary_V(range,lfly)');
        Speed_temp=Steplength_Sm_c{lfly}(range);
        
        if ~isempty(logicalwalkoutside)
            %%% Col1: Total distance walked (cm)
            variables.WalkDistSpeed(lrange,1)=nansum(Speed_temp(logicalwalkoutside))*params.px2mm/10;%cm
            %%% Col2: Average walking speed (mm/s)
            variables.WalkDistSpeed(lrange,2)=nanmean(Speed_temp(logicalwalkoutside))*params.px2mm*params.framerate;
        end
        if isnan(variables.WalkDistSpeed(lrange,2))
            variables.WalkDistSpeed(lrange,2)=0;
        end
        if isnan(variables.WalkDistSpeed(lrange,1))
            variables.WalkDistSpeed(lrange,1)=0;
        end
        
        %% 7: Thigmotaxis (Time and Activity on the edge)
        [ Binary_Edge ] = Edge_Explor(Heads_Sm,lfly,params);
        variables.EdgeExpl(lrange,1)=sum(Binary_Edge(range))/params.framerate/60;%min
        variables.EdgeExpl(lrange,2)=sum(conv(double(Binary_Edge(range)),[1 -1])==1);%Nº edge visits
        
        %% Area of arena covered outside visits (col2)
         Heads_temp=Heads_Sm{lfly}(range,:);%
         count_fly2= hist3([Heads_temp(~(Binary_V(range,lfly)'),2) Heads_temp(~(Binary_V(range,lfly)'),1)],{xrange xrange});
         variables.AreaCovered(lrange,2)=sum(sum(count_fly2~=0))/1000;
    end
    %% 1 - Number of Head mm per visit for Y & S
    plotcounter=1;
    subplot('Position',Positions{2}(plotcounter,:))
    [ax,p1,p2]=plotyy(n_rounded,variables.NHeadmm(:,1),...
        n_rounded,variables.NHeadmm(:,2));
    
    set(ax(1),'YColor',ColorAx1,'XTick',(n_rounded),'XtickLabel',[],'FontSize',FtSz,'FontName',FntName,'xLim',[ranges(1)/params.framerate/60 ranges(end)/params.framerate/60],'box','off')
    ylabel(ax(1),{'Nº Y mm';'per visit'})
    set(ax(2),'YColor',ColorAx2,'XTick',(n_rounded),'XtickLabel',[],'FontSize',FtSz,'FontName',FntName,'xLim',[ranges(1)/params.framerate/60 ranges(end)/params.framerate/60],'box','off')
    ylabel(ax(2),{'Nº S mm';'per visit'})
    set(p1,'Color',ColorAx1,'LineStyle','--','Marker','o','MarkerFaceColor',ColorAx1)
    set(p2,'Color',ColorAx2,'LineStyle','--','Marker','^','MarkerFaceColor',ColorAx2)
    y_limax2=get(ax(2),'YLim');
    axes(ax(2))
    hold on
    for lrange=1:size(ranges,1)
        plot([ranges(lrange,2) ranges(lrange,2)]/params.framerate/60,y_limax2,'--','Color',Color(2,:))
    end
    %% 2 - Nº of breaks per visit
    plotcounter=plotcounter+1;
    subplot('Position',Positions{2}(plotcounter,:))
    [ax,p1,p2]=plotyy(n_rounded,variables.NBreaks(:,1),...
        n_rounded,variables.NBreaks(:,2));
    
    set(ax(1),'YColor',ColorAx1,'XTick',(n_rounded),'XtickLabel',[],'FontSize',FtSz,'FontName',FntName,'xLim',[ranges(1)/params.framerate/60 ranges(end)/params.framerate/60],'box','off')
    ylabel(ax(1),{'Nº Breaks';'per Y visit'})
    set(ax(2),'YColor',ColorAx2,'XTick',(n_rounded),'XtickLabel',[],'FontSize',FtSz,'FontName',FntName,'xLim',[ranges(1)/params.framerate/60 ranges(end)/params.framerate/60],'box','off')
    ylabel(ax(2),{'Nº Breaks';'per S visit'})
    set(p1,'Color',ColorAx1,'LineStyle','--','Marker','o','MarkerFaceColor',ColorAx1)
    set(p2,'Color',ColorAx2,'LineStyle','--','Marker','^','MarkerFaceColor',ColorAx2)
    box('off')
    y_limax2=get(ax(2),'YLim');
    axes(ax(2))
    hold on
    for lrange=1:size(ranges,1)
        plot([ranges(lrange,2) ranges(lrange,2)]/params.framerate/60,y_limax2,'--','Color',Color(2,:))
    end
    %% 3 - Mean duration of Y & S visit
    plotcounter=plotcounter+1;
    subplot('Position',Positions{2}(plotcounter,:))
    [ax,p1,p2]=plotyy(n_rounded,variables.AvDurVisit(:,1),...
        n_rounded,variables.AvDurVisit(:,2));
    
    set(ax(1),'YColor',ColorAx1,'XTick',(n_rounded),'XtickLabel',[],'FontSize',FtSz,'FontName',FntName,'xLim',[ranges(1)/params.framerate/60 ranges(end)/params.framerate/60],'box','off')
    ylabel(ax(1),{'Y Av Dur','(min)'})
    set(ax(2),'YColor',ColorAx2,'XTick',(n_rounded),'XtickLabel',[],'FontSize',FtSz,'FontName',FntName,'xLim',[ranges(1)/params.framerate/60 ranges(end)/params.framerate/60],'box','off')
    ylabel(ax(2),{'S Av Dur','(s)'})
    set(p1,'Color',ColorAx1,'LineStyle','--','Marker','o','MarkerFaceColor',ColorAx1)
    set(p2,'Color',ColorAx2,'LineStyle','--','Marker','^','MarkerFaceColor',ColorAx2)
    box('off')
    axes(ax(2))
    y_limax2=get(ax(2),'YLim');
    hold on
    for lrange=1:size(ranges,1)
        plot([ranges(lrange,2) ranges(lrange,2)]/params.framerate/60,y_limax2,'--','Color',Color(2,:))
    end
    %% 4 - Nº of Y & S visits
    plotcounter=plotcounter+1;
    subplot('Position',Positions{2}(plotcounter,:))
    [ax,p1,p2]=plotyy(n_rounded,variables.NVisits(:,1),...
        n_rounded,variables.NVisits(:,2));
    
    
    set(ax(1),'YColor',ColorAx1,'XTick',(n_rounded),'FontSize',FtSz,'FontName',FntName,'xLim',[ranges(1)/params.framerate/60 ranges(end)/params.framerate/60],'box','off')
    ylabel(ax(1),{'Nº Y','Visits'})
    set(ax(2),'YColor',ColorAx2,'XTick',(n_rounded),'FontSize',FtSz,'FontName',FntName,'xLim',[ranges(1)/params.framerate/60 ranges(end)/params.framerate/60],'box','off')
    ylabel(ax(2),{'Nº S','Visits'})
    xlabel(ax(2),'Time of assay (min)')
    set(p1,'Color',ColorAx1,'LineStyle','--','Marker','o','MarkerFaceColor',ColorAx1)
    set(p2,'Color',ColorAx2,'LineStyle','--','Marker','^','MarkerFaceColor',ColorAx2)
    box('off')
    axes(ax(2))
    y_limax2=get(ax(2),'YLim');
    hold on
    for lrange=1:size(ranges,1)
        plot([ranges(lrange,2) ranges(lrange,2)]/params.framerate/60,y_limax2,'--','Color',Color(2,:))
    end
    %% 5 - Distances between Spots
    plotcounter=plotcounter+1;
    subplot('Position',Positions{2}(plotcounter,:))
    [ax,p1,p2]=plotyy(n_rounded,variables.SpotDist(:,1),...
        n_rounded,variables.SpotDist(:,2));
    maxY=max(max(variables.SpotDist));
    if isnan(maxY)||(maxY==0)
        maxY=1;
    end
    set(ax(1),'YColor',ColorAx1,'XTick',(n_rounded),'XtickLabel',[],...
        'FontSize',FtSz,'FontName',FntName,...
        'xLim',[ranges(1)/params.framerate/60 ranges(end)/params.framerate/60],'box','off',...
        'yLim',[0 maxY])
    ylabel(ax(1),{'Y Spot dist','(mm)'})%{'Inter Y dist','(mm)'})%
    set(ax(2),'YColor',ColorAx2,'XTick',(n_rounded),'XtickLabel',[],'FontSize',FtSz,'FontName',FntName,'xLim',[ranges(1)/params.framerate/60 ranges(end)/params.framerate/60],'box','off','yLim',[0 maxY])
    ylabel(ax(2),{'S spot dist','(mm)'})%{'Inter S dist','(mm)'})%
    set(p1,'Color',ColorAx1,'LineStyle','--','Marker','o','MarkerFaceColor',ColorAx1)
    set(p2,'Color',ColorAx2,'LineStyle','--','Marker','^','MarkerFaceColor',ColorAx2)
    box('off')
    axes(ax(2))
    y_limax2=get(ax(2),'YLim');
    hold on
    for lrange=1:size(ranges,1)
        plot([ranges(lrange,2) ranges(lrange,2)]/params.framerate/60,y_limax2,'--','Color',Color(2,:))
    end
%     plot([ranges(1)/params.framerate/60 ranges(end)/params.framerate/60],[10 10],'--','Color',[.5 .5 .5])
    
    
    %% 5 - Pr(Close) same & Pr (Far)
%     plotcounter=plotcounter+1;
%     subplot('Position',Positions{2}(plotcounter,:))
%     hold on
%     ltrcounter=0;
%     for ltr=size(params.Subs_Names,1)+1:3*size(params.Subs_Names,1)
%         ltrcounter=ltrcounter+1;
%         h=plot(n_rounded,variables.TrPr(:,ltrcounter),'--','Color',Etho_Tr_Colors(ltr,:),...
%             'Marker','o','MarkerFaceColor',Etho_Tr_Colors(ltr,:));
%         
%     end
%     legend({'To adjacent Y';'To adjacent S';'To far Y';'To far S'},'FontSize',FtSz-1,'Location','eastoutside')
%     legend('boxoff')
%     ylabel({'Transition';'Prob (%)'},'FontSize',FtSz,'FontName',FntName)
%     set(gca,'xLim',[ranges(1)/params.framerate/60 ranges(end)/params.framerate/60],'XTick',(n_rounded),'XtickLabel',[],'FontSize',FtSz,'FontName',FntName)
%     
%     box('off')
%     y_limax2=get(gca,'YLim');
%     for lrange=1:size(ranges,1)-1
%         plot([ranges(lrange,2) ranges(lrange,2)]/params.framerate/60,y_limax2,'--','Color',Color(2,:))
%     end
    %% 6 - Distance covered & Time walking
    plotcounter=plotcounter+1;
    subplot('Position',Positions{2}(plotcounter,:))
    [ax,p1,p2]=plotyy(n_rounded,variables.WalkDistSpeed(:,1),...
        n_rounded,variables.WalkDistSpeed(:,2));
    
    set(ax(1),'YColor',ColorAx1,'XTick',(n_rounded),'XtickLabel',[],'FontSize',FtSz,'FontName',FntName,'xLim',[ranges(1)/params.framerate/60 ranges(end)/params.framerate/60],'box','off')
    ylabel(ax(1),{'Walking','Dist (cm)'})
    set(ax(2),'YColor',ColorAx2,'XTick',(n_rounded),'XtickLabel',[],'FontSize',FtSz,'FontName',FntName,'xLim',[ranges(1)/params.framerate/60 ranges(end)/params.framerate/60],'box','off')
    ylabel(ax(2),{'Av.Walking','Speed(mm/s)'})
    set(p1,'Color',ColorAx1,'LineStyle','--','Marker','o','MarkerFaceColor',ColorAx1)
    set(p2,'Color',ColorAx2,'LineStyle','--','Marker','^','MarkerFaceColor',ColorAx2)
    box('off')
    axes(ax(2))
    y_limax2=get(ax(2),'YLim');
    hold on
    for lrange=1:size(ranges,1)
        plot([ranges(lrange,2) ranges(lrange,2)]/params.framerate/60,y_limax2,'--','Color',Color(2,:))
    end
    %% 7 - Time on edge & Nº of edge visits
    plotcounter=plotcounter+1;
    subplot('Position',Positions{2}(plotcounter,:))
    [ax,p1,p2]=plotyy(n_rounded,variables.EdgeExpl(:,1),...
        n_rounded,variables.EdgeExpl(:,2));
    
    %     xticklabels=strread(num2str(n_rounded),'%s')';
    set(ax(1),'YColor',ColorAx1,'XTick',(n_rounded),'XtickLabel',[],'FontSize',FtSz,'FontName',FntName,'xLim',[ranges(1)/params.framerate/60 ranges(end)/params.framerate/60],'box','off')
    ylabel(ax(1),{'Time on','Edge (min)'})
    set(ax(2),'YColor',ColorAx2,'XTick',(n_rounded),'XtickLabel',[],'FontSize',FtSz,'FontName',FntName,'xLim',[ranges(1)/params.framerate/60 ranges(end)/params.framerate/60],'box','off')
    ylabel(ax(2),{'Nº Edge','Visits'})
%     xlabel(ax(2),'Time of assay (min)')
    set(p1,'Color',ColorAx1,'LineStyle','--','Marker','o','MarkerFaceColor',ColorAx1)
    set(p2,'Color',ColorAx2,'LineStyle','--','Marker','^','MarkerFaceColor',ColorAx2)
    box('off')
    axes(ax(2))
    y_limax2=get(ax(2),'YLim');
    hold on
    for lrange=1:size(ranges,1)
        plot([ranges(lrange,2) ranges(lrange,2)]/params.framerate/60,y_limax2,'--','Color',Color(2,:))
    end
    %% 8 - Area covered during visit & Area covered outside the visit
    plotcounter=plotcounter+1;
    subplot('Position',Positions{2}(plotcounter,:))
    [ax,p1,p2]=plotyy(n_rounded,variables.AreaCovered(:,1),...
        n_rounded,variables.AreaCovered(:,2));
    set(ax(1),'YColor',ColorAx1,'XTick',(n_rounded),'FontSize',FtSz,'FontName',FntName,'xLim',[ranges(1)/params.framerate/60 ranges(end)/params.framerate/60],'box','off')
    ylabel(ax(1),{'Av. Area per','visit (px*10^-^3)'})
    set(ax(2),'YColor',ColorAx2,'XTick',(n_rounded),'FontSize',FtSz,'FontName',FntName,'xLim',[ranges(1)/params.framerate/60 ranges(end)/params.framerate/60],'box','off')
    ylabel(ax(2),{'Area','~visit (px*10^-^3)'})
    xlabel(ax(2),'Time of assay (min)')
    set(p1,'Color',ColorAx1,'LineStyle','--','Marker','o','MarkerFaceColor',ColorAx1)
    set(p2,'Color',ColorAx2,'LineStyle','--','Marker','^','MarkerFaceColor',ColorAx2)
    box('off')
    axes(ax(2))
    y_limax2=get(ax(2),'YLim');
    hold on
    for lrange=1:size(ranges,1)
        plot([ranges(lrange,2) ranges(lrange,2)]/params.framerate/60,y_limax2,'--','Color',Color(2,:))
    end
    %% Save
    SubFolder_name=['Time Segments\EthoSpeedCond' num2str(params.ConditionIndex(lfly))];
    if saveplot==1
        set(gcf,'Name',[params.LabelsShort{params.ConditionIndex(lfly)},...
            '; Fly Nº' num2str(lfly) ', ' num2str(range(1)) ' to ' num2str(range(end)) ', ' num2str(size(ranges,1)) 'periods-YSpotD'])
        savefig_withname(0,'600','png',DataSaving_dir_temp,Exp_num,Exp_letter,...
            SubFolder_name)
    end
    if lfly~=fliestoplot(end)
%         pause
    end
    
end

% set(gcf,'units','normalized','outerposition',[0 0 1 1])