%% PCA on total parameters at 60 min
ranges=[1 345000];% 120 min
saveplot=0;
SubFolder_name='Visits';
% load('E:\Analysis Data\Experiment 0003\Variables\TimeSegmentsParams_H0_1r_until115_0003D 12-Jan-2016.mat')
%%
params2plot=[48 49 11 12 9 10 73 87 81 30 31 58 59 2 95 25 26 34 35 36 37 38 39 54 4 56];%


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

% ParamsforPCA=ParamsforPCA_pre((params.ConditionIndex==Conditions(1))|(params.ConditionIndex==Conditions(2)),params2plot);
ParamsforPCA=ParamsforPCA_pre(:,params2plot);
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
close all
FtSz=8;
FntName='arial';
singleflycolor=0;
Conditions=[6 4 5 1 3];%%[1 3];%
SymbolCond_temp={'o','^','s','v','d','*'};
Color=Colors(3);%
[ColorsFig2C,orderinpaper,labelspaper]=ColorsPaper5cond_fun;
[CondColors,Cmap_patch]=Colors(length(unique(params.ConditionIndex)));%
newcondcolors=nan(length(Conditions),3);
for lcond=Conditions
    if length(Conditions)<=size(ColorsFig2C,1)
        newcondcolors(lcond==Conditions,:)=ColorsFig2C(orderinpaper==lcond,:);%
    else
        newcondcolors(lcond==Conditions,:)=CondColors(ismember(unique(params.ConditionIndex),lcond),:);
    end
end

newcondIdx=params.ConditionIndex;%params.ConditionIndex((params.ConditionIndex==Conditions(1))|(params.ConditionIndex==Conditions(2)));
newflyidx=params.IndexAnalyse;%params.IndexAnalyse((params.ConditionIndex==Conditions(1))|(params.ConditionIndex==Conditions(2)));
scrsz = get(0,'ScreenSize');
figure('Position',[100 50 scrsz(3)-1000 scrsz(4)-450],'Name',['PCA PC2 vs PC1 from all cond ' date],...
    'PaperUnits','centimeters','PaperPosition',[0 0 7 7])
hold on
lcondcounter=0;
for lcond=Conditions
    lcondcounter=lcondcounter+1;
    plot(score(newcondIdx==lcond,1),score(newcondIdx==lcond,2),SymbolCond_temp{orderinpaper==lcond},...
        'MarkerFaceColor',newcondcolors(lcondcounter,:),'MarkerEdgeColor',newcondcolors(lcondcounter,:))
end
font_style([],'PC1','PC2','normal',FntName,FtSz)
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
close all
rainbowbar=1;
colorparambar=jet(length(LabelsforPCA));
AxesPositions=[0.3 0.11 0.19 .8;...
    0.55 0.11 0.19 .8;...
    0.81 0.11 0.19 .8];
figure('Position',[100 50 900 900],'Color','w','Name',...
    ['Weights of parameters in PC123 - from all conds - ' date],...
    'PaperUnits','centimeters','PaperPosition',[0 0 10 8])
for l=1:3
    axhandle=axes('Position',AxesPositions(l,:));
    hold on
%     subplot(1,3,l)
    if l==1 % sort all others according to PCA
        [~,sort_idx]=sort(coefforth(:,l));
    end
%     sort_idx=(1:length(LabelsforPCA))';
    [~,sort_idx2]=sort(coefforth(:,l));
    if rainbowbar==0
        barhandle=barh(1:length(LabelsforPCA),coefforth(sort_idx,l),'parent', axhandle);
        set(barhandle,'FaceColor',Color(3,:),...
                'LineWidth', .8,'EdgeColor','k');%,'BarWidth',0.4);
        xlim3=get(gca,'XLim');
        
    else
        xlim3=-.5;%
        lparamcounter=0;
        for lparamidx=sort_idx'
            
            lparamcounter=lparamcounter+1;
            
            barh(lparamcounter,coefforth(lparamidx,l),...
            'parent', axhandle, 'facecolor', colorparambar(sort_idx2==lparamidx,:))
            hold on
        end
        
    end
    set(gca,'Yticklabel',[],'Color','none','YDir','reverse')    
    %% Parameter labels
    if l==1
        lparamcounter=0;
        for lparamidx=sort_idx'
            lparamcounter=lparamcounter+1;
            
            if iscell(LabelsforPCA{lparamidx})
                thandle=text(xlim3(1)-.2,lparamcounter,[LabelsforPCA{lparamidx}{1} ' ' LabelsforPCA{lparamidx}{2}]);
            else
                thandle=text(xlim3(1)-.2,lparamcounter,LabelsforPCA{lparamidx});
            end
            set(thandle,'HorizontalAlignment','right',...
                'Rotation',0,'FontSize',FtSz,'FontName',FntName);
        end
    end
    
    box off
    font_style([],['PC' num2str(l)],[],'normal',FntName,FtSz)
    ylim([.5 lparamcounter+.5])
end
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
%% % variance explained per PC
figure('Position',[100 50 900 900],'Color','w','Name',...
    ['Variance explained - from all conds - ' date],...
    'PaperUnits','centimeters','PaperPosition',[0 0 4 5])
barhandle=bar(1:10,explained(1:10));
set(barhandle,'FaceColor',[170 170 170]/255,...
                'LineWidth', .8,'EdgeColor','k');%,'BarWidth',0.4);
hold on
plot(1:10,cumsum(explained(1:10)),'-or','LineWidth',.8,'MarkerFaceColor','r','MarkerSize',3)    
font_style([],'Principal Component','Variance Explained (%)','normal',FntName,FtSz)
axis([.5 10.5 0 100])
%% MArker legend

figure('Position',[100 50 scrsz(3)-1000 scrsz(4)-450],'Name',['Labels paper ' date],...
    'PaperUnits','centimeters','PaperPosition',[0 0 7 7])
hold on
lcondcounter=0;
for lcond=Conditions
    lcondcounter=lcondcounter+1;
    plot(lcondcounter,1,SymbolCond_temp{orderinpaper==lcond},...
        'MarkerFaceColor',newcondcolors(lcondcounter,:),...
        'MarkerEdgeColor',newcondcolors(lcondcounter,:),...
        'MarkerSize',8)
end
legend(labelspaper,'FontName',FntName,'FontSize',FtSz)
legend('boxoff')
%%
if saveplot==1
        savefig_withname(1,'600','png',DataSaving_dir_temp,Exp_num,Exp_letter,...
            SubFolder_name)
end