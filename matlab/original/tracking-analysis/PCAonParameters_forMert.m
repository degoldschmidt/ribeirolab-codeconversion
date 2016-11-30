%% %% PCA on total parameters
%% Preparing PCA inputs
Conditions=[1 3];%1-Fully Fed; 2-Deprived
params2plot=[1:6 9:12 13 16 22 30 34:39 46:56 60 61 77 93 117 120];%Parameter index: 1-Av Speed; 2-Distance...

ParamsforPCA_pre=nan(params.numflies,size(TimeSegmentsParams{1},2));
LabelsforPCA_pre=cell(size(TimeSegmentsParams{1},2),1);

%%% Creating matrix with selected parameters in each column and flies in
%%% rows. I have all my parameters in TimeSegmentsParams variable
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

ParamsforPCA(isnan(ParamsforPCA))=0;%turning all nan into zeros... need to find a better solution...

%% PCA
w = 1./var(ParamsforPCA);
[wcoeff,score,latent,tsquared,explained] = pca(ParamsforPCA,...
'VariableWeights',w);

coefforth = diag(sqrt(w))*wcoeff;%Transform the coefficients so that they are orthonormal.
%%  Plotting each fly in PC space
% close all
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

scrsz = get(0,'ScreenSize');

figure('Position',[100 50 scrsz(3)-1000 scrsz(4)-450],'Name',['PCA PC3 vs PC2 ' date])
hold on
lcondcounter=0;
for lcond=Conditions
    lcondcounter=lcondcounter+1;
    %%% Plotting PC3 vs PC2 (third column vs second column of score matrix)
    plot(score(newcondIdx==lcond,2),score(newcondIdx==lcond,3),'o',...
    'MarkerFaceColor',newcondcolors(lcondcounter,:),'MarkerEdgeColor',newcondcolors(lcondcounter,:))
 
end
xlabel('PC2')
ylabel('PC3')
title('Mated AA+ & Mated AA-')

%% Weight of each parameter in each PC
figure('Position',[100 50 900 900],'Color','w','Name',['Weights of parameters in PC123 sorted - from Mated AA+ & AA- ' date])
%%% sort parameters according to PC1
[~,sort_idx]=sort(coefforth(:,1));
for l=1:3
    subplot(3,1,l)
    bar(1:length(LabelsforPCA),coefforth(sort_idx,l))
    set(gca,'Xticklabel',[],'Color','none')
    box off
    ylim3=get(gca,'YLim');
    %%% Write parameter labels in x axis
    if l==3 
        lparamcounter=0;
        for lparam=sort_idx'
            lparamcounter=lparamcounter+1;
            thandle=text(lparamcounter,ylim3(1),LabelsforPCA{lparam});
            set(thandle,'HorizontalAlignment','right','VerticalAlignment','bottom',...
            'Rotation',90,'FontSize',FtSz-2,'FontName',FntName);
        end
    end
    font_style([],[],['Weights PC' num2str(l)],'normal',FntName,FtSz)
end
%% Correlation matrix
for lcond=Conditions
    figure('Name',['Corr Matrix params sorted PC1 from MAA+- for ' params.LabelsShort{lcond} ' ' date])
    C=corr(ParamsforPCA(newcondIdx==lcond,sort_idx),ParamsforPCA(newcondIdx==lcond,sort_idx));
    imagesc(C), colormap(jet),colorbar
    set(gca,'Xticklabel',[],'Color','none','Yticklabel',[])
    %%% Write parameter labels in x and y axis
    lparamcounter=0;
    for lparam=sort_idx'
        lparamcounter=lparamcounter+1;
        thandle=text(lparamcounter,length(LabelsforPCA),LabelsforPCA{lparam});
        thandle2=text(0,lparamcounter,LabelsforPCA{lparam});
                
        set(thandle,'HorizontalAlignment','right','VerticalAlignment','bottom',...
            'Rotation',90,'FontSize',FtSz-2,'FontName',FntName);
        set(thandle2,'HorizontalAlignment','right','VerticalAlignment','middle',...
            'Rotation',0,'FontSize',FtSz-2,'FontName',FntName);
    end
    title(params.LabelsShort{lcond})
end
