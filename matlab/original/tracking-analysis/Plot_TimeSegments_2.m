%% Plot Time Segments
%%% Assumptions: There are two substrates. 1- Yeast and 2-Sucrose
saveplot=0;SubFolder_name='Time Segments';
fliestoplot=[1 11 32 136];%params.IndexAnalyse;%32;%Flies_cluster{3}';%flies_idx;
% ranges=[1 30000;30001 120000;120001 240000;240001 345000];%
% ranges=[1 30000;30001 90000;90001 150000;150001 210000;210001 270000;270001 345000];%
ranges=[1 15000;15001 45000;45001 105000;105001 165000;165001 225000;225001 285000;285001 345000];%
merged=1;
clear ylabel
FntName='arial';
if saveplot==1
    FtSz=8;
    LineW=0.8;
    MkSz=3;
else
    FtSz=11;
    LineW=1.2;
    MkSz=4;
end

%% Subplots positions
h_dist=0.05;
v_dist=0.03;
width=(1-(size(ranges,1)+1)*h_dist)/(size(ranges,1));
heights1=[0.2;0.1];%[0.2;0.04;0.04;0.02;0.02];
heights2=repmat(0.07,4,1);%[Traj,Etho_H,Etho_Tr]

numplots_per_col=size(heights1,1);
numcols=size(ranges,1);
y1=1-heights1(1)-v_dist;
clear Positions
Positions{1}=zeros(numcols*(numplots_per_col),4);
rangecounter=1;
for lrange=1:numcols
    Positions{1}((lrange-1)*(numplots_per_col)+1:lrange*(numplots_per_col),:)=...
        [repmat(h_dist+(lrange-1)*width+(lrange-1)*h_dist,numplots_per_col,1),...
        ones(numplots_per_col,1)-cumsum(heights1(1:end))-(1:numplots_per_col)'.*v_dist-0.05*ones(numplots_per_col,1),...
        repmat(width,numplots_per_col,1) heights1(1:end)];
%     Positions{1}(lrange*numplots_per_col-1,:)=...
%         [(h_dist+(lrange-1)*width+(lrange-1)*h_dist),...
%         1-sum(heights1(1:end-1))-(numplots_per_col-1)'.*v_dist-.05,...
%         width/2.5 heights1(end-1)];
%     Positions{1}(lrange*(numplots_per_col),:)=...
%         [Positions{1}(lrange*numplots_per_col-1,1)+(1-1/2.5)*width,...
%         1-sum(heights1(1:end-1))-(numplots_per_col-1)'.*v_dist-.05,...
%         width/2.5 heights1(end-1)];
    
end
halfrow=ceil(size(heights2,1)/2);
Positions{2}=[[repmat(h_dist*1.5,size(heights2,1),1),...
    1-sum(heights1(1:end))-(numplots_per_col)'.*v_dist-cumsum(heights2)-2*v_dist-(1:size(heights2,1))'.*v_dist-0.05*ones(size(heights2,1),1),...
    repmat((1-5*h_dist*1.5)/2,size(heights2,1),1), heights2];...
    [repmat(h_dist*1.5+(1-5*h_dist*1.5)/2+3*h_dist*1.5,size(heights2,1),1),...
    1-sum(heights1(1:end))-(numplots_per_col)'.*v_dist-cumsum(heights2)-2*v_dist-(1:size(heights2,1))'.*v_dist-0.05*ones(size(heights2,1),1),...
    repmat((1-5*h_dist*1.5)/2,size(heights2,1),1), heights2]];

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
Visit_N_Segm_colors=[Etho_colors_new;...
    [241 195 27;5 16 241]/255];...%[heads;breaks]
    
xlim_=[-33 33];%[11 16.2];%
ylim_=[-33 33];%[-17.2 -11.5];%

xrange=-33/params.px2mm:33/params.px2mm;

n_rounded=nan(1,size(ranges,1));
nf=nan(1,size(ranges,1));
for lrange=1:size(ranges,1)
    nf(lrange)=ceil((ranges(lrange,2)-ranges(lrange,1))/2)+ranges(lrange,1);%frames
    n=nf(lrange)/50/60;%min
    %     n2=(ranges(lrange,2))/50/60;
    n_rounded(lrange) = round(n*(10^2))/(10^2);
end

if ~exist('Etho_Tr','var')
    [TrEvents,TrArea,Etho_Tr,Etho_Tr_Colors]=TransitionProb(DurInV,Heads_Sm,FlyDB,params);
end
%%
close all
figure('Position',[2100 50 1400 930],'Color','w')
hold on
flycounter=0;
for lfly=fliestoplot
    clf
    variables=struct('YLabel1',{{'Y Av Dur';'(min)'};...1A
        'A_T/A_A_r_e_n_a';...2A
        {'Total Nº';'Visits'};...3A
        't_F_o_o_d/t_T';...4A%'A_F_o_o_d/A_T';...4A
        {'YPI';'(Nºvisits)'};...5A
        {'Y-Y Dist';'(cm)'};...6A
        {'S-Y Dist';'(cm)'};''},...7A
        'YLabel2',{{'S Av Dur';'(s)'};...1B
        {'Dist covered';'(cm)'};...2B
        {'Total time';'visits (min)'};...3B
        'A_e_d_g_e/A_T';...4B
        {'YPI';'(Time visits)'};...5B
        {'S-S Dist';'(cm)'};...6B
        {'Y-S Dist';'(cm)'};''},...7B
        'Data1',cell(8,1),'Data2',cell(8,1),...
        'Color1',num2cell(repmat(ColorAx1,8,1),2),'Color2',num2cell(repmat(ColorAx2,8,1),2),...
        'XAxes',num2cell(repmat([ranges(1)/params.framerate/60 ranges(end)/params.framerate/60],8,1),2),...
        'YAxes1',num2cell([0 0;0 0.3;0 40;0 1;-1 1;0 0;0 0;0 0],2),...
        'YAxes2',num2cell([0 0;0 0;0 0;0 1;-1 1;0 0;0 0;0 0],2));
    %plot1: Av. Dur Y (min) and S (s)
    %plot2: % of Arena Area Covered and Distance Covered
    %plot3: Total number of Visits and Total Visit Time (min)
    %plot4: timeVisit/timeSegment and AreaEdge/AreaT %%(AreaY+S)/AreaT
    %plot5: YPI Nº visits and YPI Time visits
    %plot6: Distance covered Y-Y (cm,independent of S intermediates) and S-S
    %plot7: Distance covered from S to Y and Y to S
    
    AvDurVisit=nan(size(ranges,1),length(params.Subs_Numbers));
    NVisits=nan(size(ranges,1),length(params.Subs_Numbers));
    TotalDurVisit=nan(size(ranges,1),length(params.Subs_Numbers));
    AreaVisit=nan(size(ranges,1),length(params.Subs_Numbers));
    timeVisit=nan(size(ranges,1),length(params.Subs_Numbers));
    
    AreaCovered=nan(size(ranges,1),1);
    EdgeA=nan(size(ranges,1),1);
    Edge_t_perc=nan(size(ranges,1),1);
    Dist=nan(size(ranges,1),1);
    
    for lrange=1:size(ranges,1)
        hold on
        range=ranges(lrange,1):ranges(lrange,2);
        display(['time range: ' num2str(range(1)) ' - ' num2str(range(end)) ' (fr)'])
        %% TOP1: Trajectories
        subplot('Position',Positions{1}((lrange-1)*numplots_per_col+1,:))
        plot_tracks_single(FlyDB,Heads_Sm{lfly},lfly,Spots,params,1,...
            [.7 .7 .7],range,FtSz,1,0.5*LineW);%Plotting selected flies
        
        %%% Plot trajectories with ethogram colors
        colormap_segments=Etho_colors_new;%Etho_Tr_Colors;%
        etho_segments=Etho_Speed_new(lfly,:);%Etho_Tr(lfly,:);%
        plot_traj_etho(Heads_Sm,lfly,range,etho_segments,colormap_segments,0.8*LineW,params)
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
        image([0 range(end)-range(1)],[0 20],Etho_Speed_new(lfly,range))
        colormap(Etho_colors_new);
        freezeColors
        hold on
        
         
        plot(0:range(end)-range(1),Steplength_Sm_h{lfly}(range)*params.px2mm*params.framerate,'-k','LineWidth',0.5*LineW)
        font_style([],'Time (min)','Speed_h (mm/s)','normal',FntName,FtSz)
        if lrange==1
            set(gca,'Box','off','YDir','normal','Ylim',[0 20],'XLim',[0 20*50*60],'XTick',[10 20]*50*60,'XTickLabel',{'10','20'})
%         xlim([0 range(end)-range(1)])
        else
            set(gca,'XTickLabel',[],'Box','off','XTick',[],'YTickLabel',[],'YTick',[],'YDir','normal','Ylim',[0 20],'XLim',[0 20*50*60])
            xlabel([])
%         xlim([0 range(end)-range(1)])
            ylabel([])
            
        end
        
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
            AvDurVisit(lrange,:)=[0 0];
            NVisits(lrange,:)=[0 0];
            
        else
            if (isempty(boutend))||(boutend<boutstart)
                error('boutend is empty or smaller than boutstart')
                % boutend=boutstart;
            end
            DurInV_Segm=DurInV{lfly}(boutstart:boutend,:);
            
            %% Y & S Visit variables
            for lsubs=params.Subs_Numbers
                %%% Number of visits
                NVisits(lrange,lsubs==params.Subs_Numbers)=sum(DurInV_Segm(:,1)==lsubs);
                %%% Average duration of visits
                AvDurVisit(lrange,lsubs==params.Subs_Numbers)=mean(DurInV_Segm(DurInV_Segm(:,1)==lsubs,5))/params.framerate;%s
                TotalDurVisit(lrange,lsubs==params.Subs_Numbers)=sum(DurInV_Segm(DurInV_Segm(:,1)==lsubs,5));%frames
                if lsubs==1
                    AvDurVisit(lrange,lsubs==params.Subs_Numbers)=AvDurVisit(lrange,lsubs==params.Subs_Numbers)/60;%min
                end
                
                %% Area covered during visit (inside range)
                visit_rows=find(DurInV_Segm(:,1)==lsubs)';
                Ar_Cov_temp=nan(length(visit_rows),1);
                time_visit_temp=nan(length(visit_rows),1);
                visitcounter=0;
                for lvisit=visit_rows
                    visitcounter=visitcounter+1;
                    Visitframes=DurInV_Segm(lvisit,2):DurInV_Segm(lvisit,3);
                    visitrange=range(ismember(range,Visitframes));
                    if ~isempty(visitrange)
                        Heads_temp=Heads_Sm{lfly}(visitrange,:);%
                        %%% Area covered during the visit
                        count_fly1= hist3([Heads_temp(:,2) Heads_temp(:,1)],{xrange xrange});
                        Ar_Cov_temp(visitcounter)=sum(sum(count_fly1~=0));
                        time_visit_temp(visitcounter)=length(visitrange);
                    else
                        Ar_Cov_temp(visitcounter)=0;
                    end
                    
                end
                AreaVisit(lrange,lsubs==params.Subs_Numbers)=sum(Ar_Cov_temp);
                timeVisit(lrange,lsubs==params.Subs_Numbers)=sum(time_visit_temp)/(range(end)-range(1));% In perc of time range
            end
        end
        
        %% Total Area of arena covered
        Heads_temp=Heads_Sm{lfly}(range,:);%
        count_fly2= hist3([Heads_temp(:,2) Heads_temp(:,1)],{xrange xrange});
        AreaCovered(lrange)=sum(sum(count_fly2~=0));
        
        %% Fraction of area covered on the edge
        [ Binary_Edge ] = Edge_Explor(Heads_Sm,lfly,params);
        count_fly3= hist3([Heads_temp(Binary_Edge(range),2) Heads_temp(Binary_Edge(range),1)],{xrange xrange});
        EdgeA(lrange)=(sum(sum(count_fly3~=0)));
        Edge_t_perc(lrange)=sum(Binary_Edge(range))/(range(end)-range(1));
        %% Distance covered
        Dist(lrange)=nansum(Steplength_Sm_c{lfly}(range))*params.px2mm/10;%cm
    end
    
    %% Saving variables in Struct
    variables(1).Data1=AvDurVisit(:,1);
    variables(1).Data2=AvDurVisit(:,2);
    variables(2).Data1=(AreaCovered*(params.px2mm^2))/(pi*(30^2));
    variables(2).Data2=Dist;
    variables(3).Data1=sum(NVisits,2);
    variables(3).Data2=sum(TotalDurVisit,2)/params.framerate/60;%min
    variables(4).Data1=sum(timeVisit,2);%sum(AreaVisit,2)./AreaCovered;
    variables(4).Data2=EdgeA./AreaCovered;%
    variables(5).Data1=(NVisits(:,1)-NVisits(:,2))./sum(NVisits,2);
    variables(5).Data2=(TotalDurVisit(:,1)-TotalDurVisit(:,2))./sum(TotalDurVisit,2);
    
    %% 1 - Number of Head mm per visit for Y & S
    
    for lplot=1:5%8
        subplot('Position',Positions{2}(lplot,:))
        [ax,p1,p2]=plotyy(n_rounded,variables(lplot).Data1,...
            n_rounded,variables(lplot).Data2);
        if sum(abs(variables(lplot).YAxes2))==0
            y_lim2=get(ax(2),'YLim');
        else
            y_lim2=variables(lplot).YAxes2;
        end
        if sum(abs(variables(lplot).YAxes1))==0
            y_lim1=get(ax(1),'YLim');
        else
            y_lim1=variables(lplot).YAxes1;
        end
        
        if (lplot==4)||(lplot==7)
            xticklabel=cellfun(@num2str,num2cell(n_rounded),'UniformOutput',0);
            x_label='Time of assay (min)';
        else
            xticklabel=[];
            x_label=[];
        end
        
        set(ax(1),'YColor',variables(lplot).Color1,'XTick',(n_rounded),'XtickLabel',[],...
            'FontSize',FtSz,'FontName',FntName,'xLim',variables(lplot).XAxes,'box','off','YLim',y_lim1)
        ylabel(ax(1),variables(lplot).YLabel1)
        set(ax(2),'YColor',variables(lplot).Color2,'XTick',(n_rounded),'XtickLabel',xticklabel,...
            'FontSize',FtSz,'FontName',FntName,'xLim',variables(lplot).XAxes,'box','off','YLim',y_lim2)
        ylabel(ax(2),variables(lplot).YLabel2)
        xlabel(ax(2),x_label)
        
        set(p1,'Color',variables(lplot).Color1,'LineStyle','--','Marker','o','MarkerFaceColor',variables(lplot).Color1,'MarkerSize',MkSz,'LineWidth',LineW)
        set(p2,'Color',variables(lplot).Color2,'LineStyle','--','Marker','^','MarkerFaceColor',variables(lplot).Color2,'MarkerSize',MkSz,'LineWidth',LineW)
        
        axes(ax(2))
        hold on
        for lrange=1:size(ranges,1)
            plot([ranges(lrange,2) ranges(lrange,2)]/params.framerate/60,y_lim2,'--','Color',Color(2,:))
        end
        
        
    end
    
    %% Save
    if saveplot==1
        set(gcf,'Name',[params.LabelsShort{params.ConditionIndex(lfly)},...
            '; Fly Nº' num2str(lfly) ', ' num2str(range(1)) ' to ' num2str(range(end)) ', ' num2str(size(ranges,1)) 'periods, tFood'])
        savefig_withname(0,'600','png',DataSaving_dir_temp,Exp_num,Exp_letter,...
            SubFolder_name)
    end
    if lfly~=fliestoplot(end)
        %         pause
    end
    
end

