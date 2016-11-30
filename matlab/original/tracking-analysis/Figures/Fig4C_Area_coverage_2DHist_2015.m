% function [AreaCoverage_2DHist,Pos_Spot_2DHist] = Area_coverage_2DHist(FlyDB,DurInV,Binary_Head_mm,Heads_Sm,params)
%% Set parameters
dist_thr=2.7;%4;%mm


save_plot=0;
FtSz=10;%20;
LineW=0.8;
FntName='arial';
new_figure=1;
if new_figure==1
    plot_type='Area_2D';%'Area covered boxplots';%'Time_Spot_2D';%
    Conditions=[1 3];unique(params.ConditionIndex);%
else
    Conditions=[1 3];%
end
%%
xrange=-dist_thr/params.px2mm:dist_thr/params.px2mm;%every pixel

numcond=nan(length(Conditions),1);
lcondcounter=0;
for lcond=Conditions
    lcondcounter=lcondcounter+1;
    numcond(lcondcounter)=sum(params.ConditionIndex==lcond);
end

if length(Conditions)<length(unique(params.ConditionIndex))
    figname_cond=[];
    for lcond=Conditions
        figname_cond=[figname_cond ' - ' params.LabelsShort{lcond}];
    end
else
    figname_cond=' - All conditions';
end
[CondColors,Cmap_patch]=Colors(length(params.Labels));%Colors(length(Conditions));

Pos_Spot_2DHist=cell(length(params.Subs_Names),1);
AreaCoverage_2DHist=cell(length(params.Subs_Names),1);
AreaCovered_Hmm_permin=cell(length(params.Subs_Names),1);%For now is the mean area covered for each fly
AreaCovered_Hmm_pervis=cell(length(params.Subs_Names),1);%For now is the mean area covered for each fly
A_visit=cell(length(params.Subs_Names),1);
for lsubs=params.Subs_Numbers
    Pos_Spot_2DHist{lsubs==params.Subs_Numbers}=cell(length(Conditions),1);
    AreaCoverage_2DHist{lsubs==params.Subs_Numbers}=cell(length(Conditions),1);
    AreaCovered_Hmm_permin{lsubs==params.Subs_Numbers}=nan(size(Binary_Head_mm,2),1);
    AreaCovered_Hmm_pervis{lsubs==params.Subs_Numbers}=nan(size(Binary_Head_mm,2),1);
    A_visit{lsubs==params.Subs_Numbers}=nan(size(Binary_Head_mm,2),1);
    for lcondcounter=1:length(Conditions)
        Pos_Spot_2DHist{lsubs==params.Subs_Numbers}{lcondcounter}=zeros(length(xrange));
        AreaCoverage_2DHist{lsubs==params.Subs_Numbers}{lcondcounter}=zeros(length(xrange));
    end
end

%%
if new_figure==1
    close all
    subs=params.Subs_Numbers;
else
    subs=1;
end
for lsubs=subs
    if new_figure==1
        figname=['2D Hist on ' params.Subs_Names{lsubs==params.Subs_Numbers} ' spots_' plot_type ' Hmm' figname_cond ' ' date];
        
        switch plot_type
            case {'Area_2D';'Time_Spot_2D'}
                figure('Position',[100 50 params.scrsz(3)-450 params.scrsz(4)-150],...
                    'Color','w','Name',figname);
            case 'Area covered boxplots'
                figure('Position',[100 50 400 400],...
                    'Color','w','Name',figname);
        end
    end
    xvalues=1:length(Conditions);
    X=nan(max(numcond),length(xvalues));
    X2=nan(max(numcond),length(xvalues));
    lcondcounter=0;
    for lcond=Conditions
        lcondcounter=lcondcounter+1;
        
        for lfly=find(params.ConditionIndex==lcond)
            display(lfly)
            
            Geometry = FlyDB(lfly).Geometry;
            WellPos=FlyDB(lfly).WellPos;
            if ~isempty(DurInV{lfly})
                visit_rows=find(DurInV{lfly}(:,1)==lsubs)';
                Ar_Cov_temp=nan(length(visit_rows),1);
                Ar_Cov_temp2=nan(length(visit_rows),1);
                A_Visit=nan(length(visit_rows),1);
                visitcounter=0;
                for lvisit=visit_rows
                    visitcounter=visitcounter+1;
                    Heads_temp=repmat(WellPos(DurInV{lfly}(lvisit,4),:),DurInV{lfly}(lvisit,5),1) -...
                        Heads_Sm{lfly}(DurInV{lfly}(lvisit,2):DurInV{lfly}(lvisit,3),:);%

                    Dist2fSpot=sqrt(sum(((Heads_temp-repmat([0,0],DurInV{lfly}(lvisit,5),1)).^2),2)).*params.px2mm;

%                     logical_Hmm=logical(Binary_Head_mm(DurInV{lfly}(lvisit,2):DurInV{lfly}(lvisit,3),lfly));
                    %                 logical_4mm=Dist2fSpot<=Break_thr;
%                     count_fly= hist3([Heads_temp(logical_Hmm,2) Heads_temp(logical_Hmm,1)],{xrange xrange});
                    count_fly= hist3([Heads_temp(:,2) Heads_temp(:,1)],{xrange xrange});
                    Pos_Spot_2DHist{lsubs==params.Subs_Numbers}{lcondcounter}=Pos_Spot_2DHist{lsubs==params.Subs_Numbers}{lcondcounter}+count_fly;
                    AreaCoverage_2DHist{lsubs==params.Subs_Numbers}{lcondcounter}=AreaCoverage_2DHist{lsubs==params.Subs_Numbers}{lcondcounter}+logical(count_fly);
                    Ar_Cov_temp(visitcounter)=sum(sum(count_fly~=0))/(DurInV{lfly}(lvisit,5)/params.framerate/60);%px/min;
                    Ar_Cov_temp2(visitcounter)=sum(sum(count_fly~=0));%px
                    %%% Area covered during visit
                    Visitframes=DurInV{lfly}(lvisit,2):DurInV{lfly}(lvisit,3);
                    countfly_AVisit=hist3([Heads_Sm{lfly}(Visitframes,2) Heads_Sm{lfly}(Visitframes,1)],{xrange xrange});
                    A_Visit(visitcounter)=sum(sum(countfly_AVisit~=0))/(DurInV{lfly}(lvisit,5)/params.framerate/60);%px/min;
                end
                AreaCovered_Hmm_permin{lsubs==params.Subs_Numbers}(lfly)=mean(Ar_Cov_temp);
                AreaCovered_Hmm_pervis{lsubs==params.Subs_Numbers}(lfly)=mean(Ar_Cov_temp2);
                A_visit{lsubs==params.Subs_Numbers}(lfly)=mean(A_Visit);
            end
        end
        %% Plotting 2DHist
        switch plot_type
            case {'Area_2D';'Time_Spot_2D'}
                if new_figure==1
                    subplot(2,ceil(length(Conditions)/2),lcondcounter)
                elseif new_figure==0
                    plotcounter=plotcounter+1;
                    subplot('Position',Positions(plotcounter,:))
                end
                if strfind(plot_type,'Area_2D')
                    vartoplot=AreaCoverage_2DHist{lsubs==params.Subs_Numbers}{lcondcounter};
                    
                elseif strfind(plot_type,'Time_Spot_2D')
                    vartoplot=Pos_Spot_2DHist{lsubs==params.Subs_Numbers}{lcondcounter};
                else
                    error('plotting must be ''Area_2D'' or ''Time_Spot_2D''')
                end
                Freq=vartoplot/sum(sum(vartoplot));
                imagesc(xrange*params.px2mm,xrange*params.px2mm,Freq,[0 0.004])%);%,);%For VelGamma,clims);% or log(Condfr)) %
                if lcondcounter==length(Conditions)
                    hcb=colorbar;
                end
                if new_figure==1
                    th=suptitle(params.Subs_Names{lsubs==params.Subs_Numbers});
                    set(th,'FontName',FntName,'FontSize',FtSz+2)
                    font_style(params.Labels{lcond},'X positions (mm)','Y positions (mm)','normal',FntName,FtSz)
                else
                    colormap(jet(255))
                    freezeColors
                    if lcondcounter==length(Conditions)
%                         cbfreeze(cbhandle)
                        set(hcb,'FontName',FntName,'FontSize',FtSz,...
                            'Position',[Positions(plotcounter,1)+Positions(plotcounter,3)+0.005,...
                            Positions(plotcounter,2) 0.01 Positions(plotcounter,4)])
                        set(gca,'Position',Positions(plotcounter,:),'YTick',[],'YTickLabel',[])
                        font_style(params.Labels{lcond},'X positions (mm)',[],'normal',FntName,FtSz)
                    
                    else
                    font_style(params.Labels{lcond},'X positions (mm)','Y positions (mm)','normal',FntName,FtSz)    
                    end
                    
                end
                
                set(gca,'YDir','normal')
                axis equal
                axis([xrange(1)*params.px2mm xrange(end)*params.px2mm xrange(1)*params.px2mm xrange(end)*params.px2mm])
            case 'Area covered boxplots'
                
                X(1:numcond(lcondcounter),lcondcounter)=AreaCovered_Hmm_permin{lsubs==params.Subs_Numbers}(params.ConditionIndex==lcond);
                X2(1:numcond(lcondcounter),lcondcounter)=AreaCovered_Hmm_pervis{lsubs==params.Subs_Numbers}(params.ConditionIndex==lcond);
%                 X(1:numcond(lcondcounter),lcondcounter)=A_visit{lsubs==params.Subs_Numbers}(params.ConditionIndex==lcond);
        end
    end
    if strfind(plot_type,'Area covered boxplots')
        %% Area covered per min of visit
        if new_figure==0
            plotcounter=plotcounter+1;
            subplot('Position',Positions(plotcounter,:))
        else
            plotcounter=plotcounter+1;
            subplot(1,2,plotcounter)
        end
        numvariables=1;
        if new_figure==1
            labels=params.LabelsShort(Conditions);
        else
%             labels=cell(length(xvalues),1);
            labels={'AA+';'AA-'};
        end
        
        [~,lineh] = plot_boxplot_Fig2(X,labels,xvalues,...plot_boxplot_tiltedlabels
            repmat(Cmap_patch(Conditions,:),numvariables,1),repmat(CondColors(Conditions,:),numvariables,1),...
            'k',.4,FtSz,FntName,'.');
%         if new_figure==0
%             ax=get(gca,'YLim');
%             thandle=text((1:numvariables)*(length(Conditions)+1)-floor(length(Conditions)/2),...
%                     ax(1)*ones(1,numvariables),'Head mm');
%             set(thandle,'HorizontalAlignment','right','VerticalAlignment','top',...
%             'Rotation',20,'FontSize',FtSz,'FontName',FntName);
%         end
        
        
        xlim([0 (length(Conditions)+1)])
        font_style([],[],{'Mean area covered';'per min of visit (px/min)'},'normal',FntName,FtSz)
        
        stats_boxplot_tiltedlabels(X,cell(1,1),Conditions,xvalues,[plot_type ' per min'],lsubs,params,...
            DataSaving_dir_temp,Exp_num,Exp_letter,figname_cond,'Visits',FtSz,FntName)
        if lsubs==1
            YLim2=[0 400];
        else
            YLim2=get(gca,'YLim');
        end
        ylim(YLim2)
        set(gca,'YTick',[0:100:YLim2(2)],'YTickLabel',cellfun(@(x)num2str(x),num2cell([0:100:YLim2(2)]),'uniformoutput',0))
        %% Area covered per visit
%         if new_figure==0
%             plotcounter=plotcounter+1;
%             subplot('Position',Positions(plotcounter,:))
%         else
%             plotcounter=plotcounter+1;
%             subplot(1,2,plotcounter)
%         end
%             
%         [~,lineh] = plot_boxplot_Fig2(X2,labels,xvalues,...plot_boxplot_tiltedlabels
%             repmat(Cmap_patch(Conditions,:),numvariables,1),repmat(CondColors(Conditions,:),numvariables,1),...
%             'k',.4,FtSz,FntName,'.');
% 
%         xlim([0 (length(Conditions)+1)])
%         font_style([],[],{'Mean area covered';'per visit (px)'},'normal',FntName,FtSz)
%         
%         stats_boxplot_tiltedlabels(X2,cell(1,1),Conditions,xvalues,[plot_type ' per visit'],lsubs,params,...
%             DataSaving_dir_temp,Exp_num,Exp_letter,figname_cond,'Visits',FtSz,FntName)
%         if lsubs==1
%             YLim2=[0 150];
%         else
%             YLim2=get(gca,'YLim');
%         end
%         
%         set(gca,'YTick',[0:50:YLim2(2)],'YTickLabel',cellfun(@(x)num2str(x),num2cell([0:50:YLim2(2)]),'uniformoutput',0))
    end
end

if save_plot==1
    %%
    savefig_withname(1,'600','png',DataSaving_dir_temp,Exp_num,Exp_letter,...
        'Visits')
end