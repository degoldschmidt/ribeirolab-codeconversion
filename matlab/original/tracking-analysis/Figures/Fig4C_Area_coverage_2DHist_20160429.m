% function [AreaCoverage_2DHist,Pos_Spot_2DHist] = Area_coverage_2DHist(FlyDB,DurInV,Binary_Head_mm,Heads_Sm,params)
%% Set parameters
dist_thr=2.7;%4;%mm
save_plot=1;
FtSz=10;%20;
FntName='arial';
Conditions=[1 3];%doesn't work for more. Look at previous date script.
plot_type='Time_Spot_2D';%'Area_2D';%
%%
xrange=-dist_thr/params.px2mm:dist_thr/params.px2mm;%every pixel

condtag=['cond' num2str(Conditions)];%

Pos_Spot_2DHist=cell(length(params.Subs_Names),1);
AreaCoverage_2DHist=cell(length(params.Subs_Names),1);
for lsubs=params.Subs_Numbers
    Pos_Spot_2DHist{lsubs==params.Subs_Numbers}=cell(length(Conditions),1);
    AreaCoverage_2DHist{lsubs==params.Subs_Numbers}=cell(length(Conditions),1);
    for lcondcounter=1:length(Conditions)
        Pos_Spot_2DHist{lsubs==params.Subs_Numbers}{lcondcounter}=zeros(length(xrange));
        AreaCoverage_2DHist{lsubs==params.Subs_Numbers}{lcondcounter}=zeros(length(xrange));
    end
end

%% Calculating 2D hist of area covered. Only the different pixels covered per visit, per fly are considered.

subs=1;%params.Subs_Numbers;
for lsubs=subs
    lcondcounter=0;
    for lcond=Conditions
        lcondcounter=lcondcounter+1;
        
        for lfly=find(params.ConditionIndex==lcond)
            display(lfly)
            WellPos=FlyDB(lfly).WellPos;
            if ~isempty(DurInV{lfly})
                visit_rows=find(DurInV{lfly}(:,1)==lsubs)';
                
                visitcounter=0;
                for lvisit=visit_rows
                    visitcounter=visitcounter+1;
                    
                    Heads_temp=repmat(WellPos(DurInV{lfly}(lvisit,4),:),DurInV{lfly}(lvisit,5),1) -...
                        Heads_Sm{lfly}(DurInV{lfly}(lvisit,2):DurInV{lfly}(lvisit,3),:);%
                    
                    Dist2fSpot=sqrt(sum(((Heads_temp-repmat([0,0],DurInV{lfly}(lvisit,5),1)).^2),2)).*params.px2mm;
                    
                    logical_distThr=Dist2fSpot<=dist_thr;
                    count_fly= hist3([Heads_temp(logical_distThr,2) Heads_temp(logical_distThr,1)],{xrange xrange});
                    Pos_Spot_2DHist{lsubs==params.Subs_Numbers}{lcondcounter}=Pos_Spot_2DHist{lsubs==params.Subs_Numbers}{lcondcounter}+count_fly;
%                     AreaCoverage_2DHist{lsubs==params.Subs_Numbers}{lcondcounter}=AreaCoverage_2DHist{lsubs==params.Subs_Numbers}{lcondcounter}+logical(count_fly);
                    
                end
                
            end
        end
    end
end
%% Plotting 2DHist
close all
AxesPositions=[0.13 0.15 0.30 0.75;...
               0.52 0.15 0.30 0.75;...
               0.85 0.23 0.035 0.60];
for lsubs=subs
    figname=['2D Hist on ' params.Subs_Names{lsubs==params.Subs_Numbers} ' spots_' plot_type ' ' condtag ' ' date];
    figure('Position',[100 50 params.scrsz(3)-450 params.scrsz(4)-150],...
        'Color','w','Name',figname,'PaperUnits','centimeters','PaperPosition',[1 1 8 4]);
    
   lcondcounter=0;
    for lcond=Conditions
        lcondcounter=lcondcounter+1;        
        
        subplot('Position',AxesPositions(lcondcounter,:))
        
        vartoplot=Pos_Spot_2DHist{lsubs==params.Subs_Numbers}{lcondcounter};%AreaCoverage_2DHist
        
        Freq=vartoplot/sum(sum(vartoplot));
        imagesc(xrange*params.px2mm,xrange*params.px2mm,Freq,[0 0.004])%[0 0.0025]%For area
        colormap(jet)
        font_style(params.LabelsShort{lcond},'X positions (mm)','Y positions (mm)','normal',FntName,FtSz)
        
        if lcondcounter==length(Conditions)
            hcb=colorbar;
            set(hcb,'Position',AxesPositions(lcondcounter+1,:))
            ylabel([])
        end
        set(gca,'YDir','normal')
        axis equal
        axis([xrange(1)*params.px2mm xrange(end)*params.px2mm xrange(1)*params.px2mm xrange(end)*params.px2mm])
    end
end

if save_plot==1
    %%
    savefig_withname(1,'600','png',DataSaving_dir_temp,Exp_num,Exp_letter,...
        'Visits')
    savefig_withname(0,'600','eps',DataSaving_dir_temp,Exp_num,Exp_letter,...
        'Figures')
end