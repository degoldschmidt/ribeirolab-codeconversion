%% PCA on total parameters at 60 min
ranges=[1 180000];% 60 min
% load([Variablesfolder 'TimeSegmentsParams_' num2str(size(ranges,1)) 'r_until' num2str(floor((ranges(end)/50/60))) '_' Exp_num Exp_letter ' 04-Nov-2015.mat'])
%%
Conditions=[1 3];%unique(params.ConditionIndex);%[2 4 6 8];%
params2plot=[1:6 9:12 13 16 22 30 34:39 46:56 60 61 77 93 117 120];%1:size(TimeSegmentsParams{1},2);%


ParamsforPCA_pre=nan(params.numflies,size(TimeSegmentsParams{1},2));
LabelsforPCA_pre=cell(size(TimeSegmentsParams{1},2),1);

AllConditions=unique(params.ConditionIndex);
lrange=1;
lcondcounter=0;
for lcond=AllConditions
    lcondcounter=lcondcounter+1;
    Idx_cond=find(params.ConditionIndex==lcond);
    for lparam=1:size(TimeSegmentsParams{1},2)
        ParamsforPCA_pre(Idx_cond,lparam)=TimeSegmentsParams{lcond==AllConditions}(lparam).Data(lrange,:)';
        if lcondcounter==1
            LabelsforPCA_pre{lparam}=TimeSegmentsParams{lcond==AllConditions}(lparam).YLabel;
        end
    end
    
end

ParamsforPCA=ParamsforPCA_pre((params.ConditionIndex==Conditions(1))|(params.ConditionIndex==Conditions(2)),params2plot);
LabelsforPCA=LabelsforPCA_pre(params2plot);

ParamsforPCA(isnan(ParamsforPCA))=0;

w = 1./var(ParamsforPCA);
[wcoeff,score,latent,tsquared,explained] = pca(ParamsforPCA,...
'VariableWeights',w);

coefforth = diag(sqrt(w))*wcoeff;%Transform the coefficients so that they are orthonormal.
%% To plot future data in same PC space
W=diag(std(ParamsforPCA))\wcoeff;
[~, mu,we]=zscore(ParamsforPCA);
we(we==0)=1;
%% %% Plotting Data with Loadings from each Parameter
% close all
FtSz=9;
FntName='arial';
singleflycolor=1;
Conditions=[1 3];
SymbolCond_temp={'o','^','s','v','d'};
filled_temp=cell2mat(cellfun(@(x)~isempty(strfind(x,'AA+')),params.Labels,'uniformoutput',0));
FilledCond=filled_temp(Conditions);
SymbolCond=cell(length(Conditions),1);
for l=1:length(params.colLabels)
    filled_temp=cell2mat(cellfun(@(x)~isempty(strfind(x,params.colLabels{l})),params.Labels,'uniformoutput',0));
    SymbolCond(filled_temp(Conditions)==1)=SymbolCond_temp(l);
end

[CondColors,Cmap_patch]=Colors(length(unique(params.ConditionIndex)));%
newcondcolors=nan(length(Conditions),3);
for lcond=Conditions
    newcondcolors(lcond==Conditions,:)=CondColors(ismember(unique(params.ConditionIndex),lcond),:);
end

newcondIdx=params.ConditionIndex((params.ConditionIndex==Conditions(1))|(params.ConditionIndex==Conditions(2)));
newflyidx=params.IndexAnalyse((params.ConditionIndex==Conditions(1))|(params.ConditionIndex==Conditions(2)));
scrsz = get(0,'ScreenSize');
% figure('Position',[100 50 scrsz(3)-1000 scrsz(4)-450],'Name',['PCA PC2 vs PC1 ' params.LabelsShort{lcond}])
figure('Position',[100 50 scrsz(3)-1000 scrsz(4)-450],'Name',['PCA PC3 vs PC2 from Mated AA+ & Mated AA- single color and Nº ' date])
hold on
lcondcounter=0;
for lcond=Conditions
    lcondcounter=lcondcounter+1;
%     ParamsforPCA=ParamsforPCA_pre(params.ConditionIndex==lcond,params2plot);
%     plot3(score(params.ConditionIndex==lcond,1),score(params.ConditionIndex==lcond,2),...
%         score(params.ConditionIndex==lcond,3),'o',...
%         'MarkerFaceColor',newcondcolors(lcondcounter,:),'MarkerEdgeColor',newcondcolors(lcondcounter,:))
    if singleflycolor==1
            Totaltimes_cond=sum(CumTimeV{1}(:,params.ConditionIndex==lcond));%sum(CumTimeH{1}(:,params.ConditionIndex==lcond));
            Idx_cond=find(newcondIdx==lcond);%find(params.ConditionIndex==lcond);
            [Totalt_sorted,Idx_sort]=sort(Totaltimes_cond,...
                'ascend');
            color_fly=jet(length(Idx_cond));
%             lflycounter=0;
            for newlfly=Idx_cond
%                 lflycounter=lflycounter+1;
                
%                 tempscore=ParamsforPCA(lflycounter,:);
%                 tempscore=bsxfun(@minus,tempscore,mu);
%                 tempscore=bsxfun(@rdivide,tempscore,we);
%                 
%                 newscore=tempscore*W;

                if FilledCond(lcondcounter)==0
                    plot(score(newlfly,2),score(newlfly,3),SymbolCond{lcondcounter},...
                        'Color',color_fly(Idx_cond(Idx_sort)==newlfly,:),'MarkerSize',7,...
                        'LineWidth',2)
%                     plot(newscore(1),newscore(2),SymbolCond{lcondcounter},...
%                         'Color',color_fly(Idx_cond(Idx_sort)==lfly,:),'MarkerSize',7,...
%                         'LineWidth',2)
                else
                    plot(score(newlfly,2),score(newlfly,3),SymbolCond{lcondcounter},...
                        'Color',color_fly(Idx_cond(Idx_sort)==newlfly,:),'MarkerSize',7,...
                        'MarkerFaceColor',color_fly(Idx_cond(Idx_sort)==newlfly,:),'LineWidth',2)

%                     plot(newscore(1),newscore(2),SymbolCond{lcondcounter},...
%                         'Color',color_fly(Idx_cond(Idx_sort)==lfly,:),...
%                         'MarkerFaceColor',color_fly(Idx_cond(Idx_sort)==lfly,:),'MarkerSize',7,...
%                         'LineWidth',2)
                end
%                 plot(newscore(1),newscore(2),SymbolCond{lcondcounter},...
%                         'Color',newcondcolors(lcondcounter,:),...
%                         'MarkerFaceColor',newcondcolors(lcondcounter,:),'MarkerSize',7,...
%                         'LineWidth',2)
%                 text(newscore(1)+0.1,newscore(2),num2str(lfly),...
%                     'HorizontalAlignment','left')
                text(score(newlfly,2)+0.1,score(newlfly,3),num2str(newflyidx(newlfly)),...
                    'HorizontalAlignment','left')
            end
    else    
%         plot3(score(newcondIdx==lcond,1),score(newcondIdx==lcond,2),...
%             score(newcondIdx==lcond,3),'o',...
%             'MarkerFaceColor',newcondcolors(lcondcounter,:),'MarkerEdgeColor',newcondcolors(lcondcounter,:))
        plot(score(newcondIdx==lcond,2),score(newcondIdx==lcond,3),'o',...
            'MarkerFaceColor',newcondcolors(lcondcounter,:),'MarkerEdgeColor',newcondcolors(lcondcounter,:))
    end
    font_style(params.LabelsShort{lcond},'PC2','PC3','normal',FntName,FtSz)
%     zlabel('PC3','FontWeight','normal')
    
end
title('Mated AA+ & Mated AA-')
% xlim([-8 12])
% view(3), axis vis3d, box on, rotate3d on
% grid on
%%% Now the labels of the loadings from each parameter

% for lparam=1:length(coefforth)
%     plot3([0 coefforth(lparam,1)],[0 coefforth(lparam,2)],...
%         [0 coefforth(lparam,3)],'-m','LineWidth',2)
%      plot3([0 coefforth(lparam,1)],[0 coefforth(lparam,2)],...
%          [0 coefforth(lparam,3)],'*m','LineWidth',2)
% %      plot([0 0],[-1 1],'-k')
% %      plot([-1,1],[0 0],'k')
%      text(coefforth(lparam,1),coefforth(lparam,2),coefforth(lparam,3),LabelsforPCA{lparam},...
%          'FontName',FntName,'FontSize',FtSz)
% end
%% Let's say I plot fly 8
% % % X = ParamsforPCA;
% % % W=diag(std(ParamsforPCA))\wcoeff;
% % % [~, mu,we]=zscore(ParamsforPCA);
% % % we(we==0)=1;
% % % tempscore=ParamsforPCA(2,:);
% % % tempscore=bsxfun(@minus,tempscore,mu);
% % % tempscore=bsxfun(@rdivide,tempscore,we);
% % % 
% % % newscore=tempscore*W;
% % % y0=score(2,:);
% % % sum(abs(y0-y))
%% Observe weight of each parameter
% % close all
% lcond=3;
% % figure('Position',[100 50 900 900],'Color','w','Name',['Weights of parameters in PC123 - ' params.LabelsShort{lcond} ' ' date])
% figure('Position',[100 50 900 900],'Color','w','Name',['Weights of parameters in PC123 sorted - from Mated AA+ & AA- ' date])
% for l=1:3
% subplot(3,1,l)
% if l==1 % sort all others according to PCA
%     [~,sort_idx]=sort(coefforth(:,l));
% end
% bar(1:length(LabelsforPCA),coefforth(sort_idx,l))
% set(gca,'Xticklabel',[],'Color','none')
% box off
% ylim3=get(gca,'YLim');
%     if l==1 || l==3
%         lparamcounter=0;
%         for lparam=sort_idx'
%             lparamcounter=lparamcounter+1;
%     %         thandle=text(1:length(LabelsforPCA),ylim3(1)*ones(1,length(LabelsforPCA)),LabelsforPCA(:));
%             if iscell(LabelsforPCA{lparam})
% %                 thandle=text(lparamcounter,ylim3(1),[LabelsforPCA{lparam}{1} LabelsforPCA{lparam}{2}]);
%                 thandle=text(lparamcounter,ylim3(1),[LabelsforPCA{lparam}{1} LabelsforPCA{lparam}{2}]);
%             else
% %                 thandle=text(lparamcounter,ylim3(1),LabelsforPCA{lparam});
%                 thandle=text(lparamcounter,ylim3(1),LabelsforPCA{lparam});
%             end
%             set(thandle,'HorizontalAlignment','right','VerticalAlignment','bottom',...
%         'Rotation',90,'FontSize',FtSz-2,'FontName',FntName);
%         end
%     end
% font_style([],[],['Weights PC' num2str(l)],'normal',FntName,FtSz)
% end
%% Correlation matrix
% % % % close all
% for lcond=Conditions
%     figure('Name',['Corr Matrix params sorted PC1 from MAA+- for ' params.LabelsShort{lcond} ' ' date])
%     C=corr(ParamsforPCA(newcondIdx==lcond,sort_idx),ParamsforPCA(newcondIdx==lcond,sort_idx));
%     imagesc(C), colormap(jet),colorbar
%     set(gca,'Xticklabel',[],'Color','none','Yticklabel',[])
%     lparamcounter=0;
%     for lparam=sort_idx'
%     lparamcounter=lparamcounter+1;
%         %         thandle=text(1:length(LabelsforPCA),ylim3(1)*ones(1,length(LabelsforPCA)),LabelsforPCA(:));
%                 if iscell(LabelsforPCA{lparam})
%                     thandle=text(lparamcounter,length(LabelsforPCA),[LabelsforPCA{lparam}{1} LabelsforPCA{lparam}{2}]);
%                     thandle2=text(0,lparamcounter,[LabelsforPCA{lparam}{1} LabelsforPCA{lparam}{2}]);
%                 else
%                     thandle=text(lparamcounter,length(LabelsforPCA),LabelsforPCA{lparam});
%                     thandle2=text(0,lparamcounter,LabelsforPCA{lparam});
%                 end
%         set(thandle,'HorizontalAlignment','right','VerticalAlignment','bottom',...
%             'Rotation',90,'FontSize',FtSz-2,'FontName',FntName);
%         set(thandle2,'HorizontalAlignment','right','VerticalAlignment','middle',...
%             'Rotation',0,'FontSize',FtSz-2,'FontName',FntName);
%     end
%     title(params.LabelsShort{lcond})
% end
%% Exploring formation of clusters by intuitive parameters
Var_Labels={...'Nº Y Visits';...
%     '% Duration of longest visit';...
%     '% Visits to far Y';...
%     'Av Dur Y visit 50%TtY';...
    'Av Dur Y visit (min)';...
% 'Total time Y visit';...
'Total time Y Hmm (min)';...
    };
Vars_Values=zeros(params.numflies,length(Var_Labels));

for lfly=params.IndexAnalyse
    lfly
    if ~isempty(DurInV{lfly})
        %% Variable 1: Nº Y Visits / 10 min
%         NYVisits=sum(DurInV{lfly}(:,1)==params.Subs_Numbers(1));
%         Vars_Values(lfly,1)=...
%             NYVisits;%/params.MinimalDuration*30000;% Nº Y Visits (every10 min)
        
        %% Variable 2: (Duration of the longest visit / Total duration of all Yeast visits )*100
        DurVector=DurInV{lfly}(DurInV{lfly}(:,1)==params.Subs_Numbers(1),5);
%         Vars_Values(lfly,1)=...
%             max(DurVector)/sum(DurVector)*100;% Nº Y Visits (every10 min)
        %% Average duration of visit when 50% of total time of Yeast
%         Vars_Values(lfly,1)=...
%             mean(DurVector)/50;% s
        
        %% Average duration
%         Vars_Values(lfly,2)=...
%             mean(DurVector)/50/60;%s
        
        %% Total time YHMM
        Vars_Values(lfly,2)=...
            sum(CumTimeH{1}(:,lfly))/50/60;%min
        %% Total time Y Visits
        Vars_Values(lfly,1)=...
            sum(CumTimeV{1}(:,lfly))/60/50;%min
        %% Variable 3: Nº Y Visits to Far yeast / Total Nº of Y Visits
%         if size(params.Subs_Numbers,2)==2
%             FarTr=5;
%             farvisits=sum(conv(double(Etho_Tr2_2(lfly,:)==FarTr),[1 -1])==1);
%             if farvisits-1==NYVisits,
%                 farvisits=NYVisits;
%             elseif farvisits-1>NYVisits
%                 error('% far visits > 100')
%             end
%             Vars_Values(lfly,2)=...
%                 farvisits/NYVisits*100;
%         end
    end
end

%% K - means clustering
%# (K: number of clusters, G: assigned groups, C: cluster centers)
K = 3;
Conditions=[6 4 5 1 3];%[1:4];
singleflycolor=0;
[ColorsFig2C,orderinpaper]=ColorsPaper5cond_fun;
    [CondColors,Cmap_patch]=Colors(length(unique(params.ConditionIndex)));%
    newcondcolors=nan(length(Conditions),3);
    for lcond=Conditions
        if length(Conditions)<=size(ColorsFig2C,1)
            newcondcolors(lcond==Conditions,:)=ColorsFig2C(orderinpaper==lcond,:);%
        else
            newcondcolors(lcond==Conditions,:)=CondColors(ismember(unique(params.ConditionIndex),lcond),:);
        end
    end
%# show points and clusters (color-coded)
color_dots = cool(K);

close all
figname=['Clusters TotalYV, TotalYHmm_Cond' num2str(Conditions) ' ' date];%num2str(lfig)
figure('Position',[2100 50 1400 930],'Color','w','Name',figname,'PaperUnits',...
        'centimeters','PaperPosition',[0 0 20 5])
lcondcounter=0;
for lcond=Conditions
    lcondcounter=lcondcounter+1;
%     subplot(2,ceil(length(Conditions)/2),lcondcounter)
   subplot(1,length(Conditions),lcondcounter)
%     [G,C] = kmeans(Vars_Values(params.ConditionIndex==lcond,:), K, 'distance','sqEuclidean', 'start','sample');
    hold on
    if singleflycolor==1
        Totaltimes_cond=sum(CumTimeV{1}(:,params.ConditionIndex==lcond));%sum(CumTimeH{1}(:,params.ConditionIndex==lcond));
        [Totalt_sorted,Idx_sort]=sort(Totaltimes_cond,...
                'ascend');
        Idx_cond=find(params.ConditionIndex==lcond);
        color_fly=jet(length(Idx_cond));
        lflycounter=0;
        for lfly=Idx_cond
            lflycounter=lflycounter+1;
            if length(Var_Labels)==2
                plot(Vars_Values(lfly,1),Vars_Values(lfly,2),'o',...
                    'Color',color_fly(Idx_cond(Idx_sort)==lfly,:),...
                    'MarkerFaceColor',color_fly(Idx_cond(Idx_sort)==lfly,:),'MarkerSize',6)
            else
                plot3(Vars_Values(lfly,1),Vars_Values(lfly,2),Vars_Values(lfly,3),'o',...
                    'Color',color_fly(Idx_cond(Idx_sort)==lfly,:),...
                    'MarkerFaceColor',color_fly(Idx_cond(Idx_sort)==lfly,:),'MarkerSize',6)
            end
        end
    else
        if length(Var_Labels)==2
%             scatter(Vars_Values(params.ConditionIndex==lcond,1),...
%                 Vars_Values(params.ConditionIndex==lcond,2),36,newcondcolors(lcondcounter,:),'Marker','o')%color_dots(G,:)
            plot(Vars_Values(params.ConditionIndex==lcond,1),Vars_Values(params.ConditionIndex==lcond,2),'ok',...
                    'MarkerFaceColor',newcondcolors(lcondcounter,:),'MarkerSize',6)
        else
            scatter3(Vars_Values(params.ConditionIndex==lcond,1),...
            Vars_Values(params.ConditionIndex==lcond,2),...
            Vars_Values(params.ConditionIndex==lcond,3),...
            36,newcondcolors(lcondcounter,:),'Marker','o')%color_dots(G,:)
        end
    end
    
    
    font_style(params.LabelsShort{lcond},Var_Labels{1},Var_Labels{2},'normal',FntName,FtSz)
%     if length(Var_Labels)==2
%         line([0 41;80 41],[40 0;40 120],'LineStyle','--','Color',[.7 .7 .7],'LineWidth',1)
%         
%     else
%         zlabel(Var_Labels{3},'FontWeight','normal','FontName',FntName,'FontSize',FtSz)
%         
%         view(3), axis vis3d, box on, rotate3d on
%     end
      
    
    
end
axesHandles = findall(0,'type','axes');
if length(Var_Labels)==3
    axis(axesHandles,'equal')
    set(axesHandles,'XLim',[0 150],'Ylim',[0 100],'ZLim',[0 200])
   
end
savefig_withname(1,'600','png',DataSaving_dir_temp,Exp_num,Exp_letter,'Visits')