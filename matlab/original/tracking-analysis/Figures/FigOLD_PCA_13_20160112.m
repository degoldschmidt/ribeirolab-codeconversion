%% PCA on total parameters at 60 min
ranges=[1 345000];% 120 min
saveplot=1;
SubFolder_name='Visits';
load('E:\Analysis Data\Experiment 0003\Variables\TimeSegmentsParams_H0_1r_until115_0003D 12-Jan-2016.mat')
%%
params2plot=[48 49 11 12 9 10 73 87 81 30 31 58 59 25 70:72 95 2 54 4 56];
Conditions=[1 3];

ParamsforPCA_pre=nan(params.numflies,size(TimeSegmentsParams{1},2));
LabelsforPCA_pre=cell(size(TimeSegmentsParams{1},2),1);
Labelsforpaper(48).Label='Total Y';Labelsforpaper(48).Class=2;%Exploitation
Labelsforpaper(49).Label='Total S';Labelsforpaper(49).Class=2;%Exploitation
Labelsforpaper(11).Label='Nº visits Y';Labelsforpaper(11).Class=2;%Exploitation
Labelsforpaper(12).Label='Nº visits S';Labelsforpaper(12).Class=2;%Exploitation
Labelsforpaper(9).Label='Visit duration Y';Labelsforpaper(9).Class=2;%Exploitation
Labelsforpaper(10).Label='Visit duration S';Labelsforpaper(10).Class=2;%Exploitation
Labelsforpaper(73).Label='Nº encounters Y';Labelsforpaper(73).Class=4;%Global exploration
Labelsforpaper(87).Label='Engagement Y';Labelsforpaper(87).Class=2;%Exploitation
Labelsforpaper(81).Label='YPI encounters';Labelsforpaper(81).Class=4;%Global exploration
Labelsforpaper(30).Label='Dist from center Y';Labelsforpaper(30).Class=3;%Patch exploration
Labelsforpaper(31).Label='Dist from center S';Labelsforpaper(31).Class=3;%Patch exploration
Labelsforpaper(58).Label='Speed (Y visits)';Labelsforpaper(58).Class=3;%Patch exploration
Labelsforpaper(59).Label='Angular speed (Y visits)';Labelsforpaper(59).Class=3;%Patch exploration
Labelsforpaper(25).Label='Y inter-visit distance';Labelsforpaper(25).Class=4;%Global exploration
Labelsforpaper(70).Label='Transition to same Y';Labelsforpaper(70).Class=4;%Global exploration
Labelsforpaper(71).Label='Transition to close Y';Labelsforpaper(71).Class=4;%Global exploration
Labelsforpaper(72).Label='Transition to far Y';Labelsforpaper(72).Class=4;%Global exploration
Labelsforpaper(95).Label='Lag phase';Labelsforpaper(95).Class=4;%Global exploration
Labelsforpaper(2).Label='Speed outside visits';Labelsforpaper(2).Class=1;%Locomotor activity
Labelsforpaper(54).Label='% Active outside visits';Labelsforpaper(54).Class=1;%Locomotor activity
Labelsforpaper(4).Label='% Time on edge';Labelsforpaper(4).Class=1;%Locomotor activity
Labelsforpaper(56).Label='Edge activity';Labelsforpaper(56).Class=1;%Locomotor activity

Classification_colors=[167 255 255;...1- Locomotor activity
    227 190 202;... 2- Exploitation
    250 234 176;... 3- Patch exploration
    240 240 240]/255; %4- Global exploration

AllConditions=unique(params.ConditionIndex);
lrange=1;
lcondcounter=0;
for lcond=AllConditions
    lcondcounter=lcondcounter+1;
    Idx_cond=find(params.ConditionIndex==lcond);
    for lparam=1:size(TimeSegmentsParams{1},2)
        ParamsforPCA_pre(Idx_cond,lparam)=TimeSegmentsParams{lcond==AllConditions}(lparam).Data(lrange,:)';
        if lcondcounter==1
%             LabelsforPCA_pre{lparam}=TimeSegmentsParams{lcond==AllConditions}(lparam).YLabel;
            LabelsforPCA_pre{lparam}=Labelsforpaper(lparam).Label;
        end
    end
    
end

ParamsforPCA=ParamsforPCA_pre((params.ConditionIndex==Conditions(1))|(params.ConditionIndex==Conditions(2)),params2plot);
% ParamsforPCA=ParamsforPCA_pre(:,params2plot);
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
%% %% Plotting Data in PC space
close all
FtSz=8;
FntName='arial';
singleflycolor=0;
Conditions=[1 3];%[6 4 5 1 3];%%
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

newcondIdx=params.ConditionIndex((params.ConditionIndex==Conditions(1))|(params.ConditionIndex==Conditions(2)));
newflyidx=params.IndexAnalyse((params.ConditionIndex==Conditions(1))|(params.ConditionIndex==Conditions(2)));
pairsofPCS=[1 2;1 3;2 3];%plots PC2 vs PC1 and PC3 vs PC1
for lgraph=1:size(pairsofPCS,1)
    PCx=pairsofPCS(lgraph,1);
    PCy=pairsofPCS(lgraph,2);
    figure('Position',[100 50 920 630],'Name',['PCA PC' num2str(PCy) ' vs PC' num2str(PCx) ' from cond1_3 ' date],...
        'PaperUnits','centimeters','PaperPosition',[0 0 4.5 4.5])
    hold on
    lcondcounter=0;
    for lcond=Conditions
        lcondcounter=lcondcounter+1;
        plot(score(newcondIdx==lcond,PCx),score(newcondIdx==lcond,PCy),SymbolCond_temp{orderinpaper==lcond},...
            'MarkerFaceColor',newcondcolors(lcondcounter,:),'MarkerEdgeColor','k')
    end
    font_style([],['PC' num2str(PCx)],['PC' num2str(PCy)],'normal',FntName,FtSz)
    if PCx==1 && PCy==2
        axis([-6.5 6 -5 6])
    end
end

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
horizontal=0;
colorparambar=jet(length(LabelsforPCA));
if horizontal==1
AxesPositions=[0.31 0.11 0.19 .8;...
    0.56 0.11 0.19 .8;...
    0.82 0.11 0.19 .8];
paperpos=[0 0 10 8];
PC2plot=1:3;
else
    AxesPositions=[0.15 0.54 .8 0.4];%;...
%     0.15 0.34 .8 0.4;...
%     0.15 0.14 .8 0.4];
    paperpos=[0 0 9.3 4.5];
    PC2plot=2;% Optimised for one at a time
end
figure('Position',[100 50 900 900],'Color','w','Name',...
    ['Weights of parameters in PC' num2str(PC2plot) ' - from cond1_3, sorted class - ' date],...
    'PaperUnits','centimeters','PaperPosition',paperpos)
for l=PC2plot
    if horizontal==1
        axhandle=axes('Position',AxesPositions(l,:));
    else
        axhandle=axes('Position',AxesPositions(1,:));
    end
    hold on
%     subplot(1,3,l)
    if l==2 % sort all others according to PCA
        [~,sort_idx]=sort(coefforth(:,l));
    end
%     sort_idx=(1:length(LabelsforPCA))';
    [~,sort_idx2]=sort(coefforth(:,l));
    if rainbowbar==0
        if horizontal==1
        barhandle=barh(1:length(LabelsforPCA),coefforth(sort_idx,l),'parent', axhandle);
        set(barhandle,'FaceColor',Color(3,:),...
                'LineWidth', .8,'EdgeColor','k');%,'BarWidth',0.4);
        lim3=get(gca,'XLim');
        else
            barhandle=bar(1:length(LabelsforPCA),coefforth(sort_idx,l),'parent', axhandle);
            set(barhandle,'FaceColor',Color(3,:),...
                    'LineWidth', .8,'EdgeColor','k');%,'BarWidth',0.4);
            lim3=get(gca,'YLim');
        end
        
    else
        lim3=-.5;%
        lparamcounter=0;
        for lparamidx=sort_idx'
            lparamcounter=lparamcounter+1;
            if horizontal==1
                barh(lparamcounter,coefforth(lparamidx,l),...
                'parent', axhandle, 'facecolor', colorparambar(sort_idx2==lparamidx,:))
            else
%                 colorofbar=colorparambar(sort_idx2==lparamidx,:);
                colorofbar=Classification_colors(Labelsforpaper(params2plot(lparamidx)).Class,:);
                bar(lparamcounter,coefforth(lparamidx,l),...
            'parent', axhandle, 'facecolor',colorofbar)
        
            end
            hold on
        end
        
    end
    if horizontal==1
    set(gca,'YTick',1:length(sort_idx),'Yticklabel',[],'Color','none','YDir','reverse')
    else
    set(gca,'XTick',1:length(sort_idx),'Xticklabel',[],'Color','none')
    end
    %% Parameter labels
    if l==2
        lparamcounter=0;
        for lparamidx=sort_idx'
            lparamcounter=lparamcounter+1;
            
            if iscell(LabelsforPCA{lparamidx})
                if horizontal==1
                    thandle=text(lim3(1)-.1,lparamcounter,[LabelsforPCA{lparamidx}{1} ' ' LabelsforPCA{lparamidx}{2}]);
                else
                    thandle=text(lparamcounter,lim3(1)-.1,[LabelsforPCA{lparamidx}{1} ' ' LabelsforPCA{lparamidx}{2}]);
                end
            else
                if horizontal==1
                    thandle=text(lim3(1)-.1,lparamcounter,LabelsforPCA{lparamidx});
                else
                    thandle=text(lparamcounter,lim3(1)-.1,LabelsforPCA{lparamidx});
                end
            end
            if horizontal==1
            set(thandle,'HorizontalAlignment','right',...
                'Rotation',0,'FontSize',FtSz,'FontName',FntName);
            else
                set(thandle,'HorizontalAlignment','right','VerticalAlignment','Middle',...
                'Rotation',45,'FontSize',FtSz,'FontName',FntName);
            end
        end
    end
    
    box off
    
    if horizontal==1
        font_style([],['PC' num2str(l)],[],'normal',FntName,FtSz)
        ylim([.5 lparamcounter+.5])
    else
        font_style([],[],['PC' num2str(l)],'normal',FntName,FtSz)
         xlim([.5 lparamcounter+.5])
    end
end
%% Correlation matrix
% close all
if PC2plot==1
    for lcond=Conditions
        figure('Name',['Corr Matrix params sorted PC1 from MAA+- for ' params.LabelsShort{lcond} ' ' date],...
            'Color','w','PaperUnits','centimeters','PaperPosition',[0 0 10 10])
        C=corr(ParamsforPCA(newcondIdx==lcond,sort_idx),ParamsforPCA(newcondIdx==lcond,sort_idx));
        imagesc(C,[-1 1]), colormap(jet),hcb=colorbar;
        set(hcb,'Position',[0.8875    0.2976    0.03    0.5524])
        set(gca,'Xticklabel',[],'Color','none','Yticklabel',[],'XTick',1:length(sort_idx),...
            'YTick',1:length(sort_idx),'Position',[.3 .3 .55 .55])
        lparamcounter=0;
        for lparam=sort_idx'
        lparamcounter=lparamcounter+1;
            %         thandle=text(1:length(LabelsforPCA),ylim3(1)*ones(1,length(LabelsforPCA)),LabelsforPCA(:));
                    if iscell(LabelsforPCA{lparam})
                        thandle=text(lparamcounter,length(LabelsforPCA)+.7,[LabelsforPCA{lparam}{1} LabelsforPCA{lparam}{2}]);
                        thandle2=text(0,lparamcounter,[LabelsforPCA{lparam}{1} LabelsforPCA{lparam}{2}]);
                    else
                        thandle=text(lparamcounter,length(LabelsforPCA)+.7,LabelsforPCA{lparam});
                        thandle2=text(0,lparamcounter,LabelsforPCA{lparam});
                    end
            set(thandle,'HorizontalAlignment','right','VerticalAlignment','middle',...
                'Rotation',90,'FontSize',FtSz,'FontName',FntName);
            set(thandle2,'HorizontalAlignment','right','VerticalAlignment','middle',...
                'Rotation',0,'FontSize',FtSz,'FontName',FntName);
        end
        title(params.LabelsShort{lcond})
    end
end
%% % variance explained per PC
figure('Position',[100 50 900 900],'Color','w','Name',...
    ['Variance explained - from cond1_3 - ' date],...
    'PaperUnits','centimeters','PaperPosition',[0 0 4 5])
barhandle=bar(1:10,explained(1:10));
set(barhandle,'FaceColor',[170 170 170]/255,...
                'LineWidth', .8,'EdgeColor','k');%,'BarWidth',0.4);
hold on
plot(1:10,cumsum(explained(1:10)),'-or','LineWidth',.8,'MarkerFaceColor','r','MarkerSize',3)    
font_style([],'Principal Component','Variance Explained (%)','normal',FntName,FtSz)
axis([.5 10.5 0 100])
%% MArker legend
figure('Position',[100 50 900 900],'Name',['Labels paper cond1_3 ' date],...
    'PaperUnits','centimeters','PaperPosition',[0 0 7 7])
hold on
lcondcounter=0;
for lcond=Conditions
    lcondcounter=lcondcounter+1;
    plot(lcondcounter,1,SymbolCond_temp{orderinpaper==lcond},...
        'MarkerFaceColor',newcondcolors(lcondcounter,:),...
        'MarkerEdgeColor',newcondcolors(lcondcounter,:),...
        'MarkerSize',8)
    labelspaper_new{lcondcounter}=labelspaper{orderinpaper==lcond};
end
legend(labelspaper_new,'FontName',FntName,'FontSize',FtSz)
legend('boxoff')
%%
if saveplot==1
        savefig_withname(1,'600','png',DataSaving_dir_temp,Exp_num,Exp_letter,...
            SubFolder_name)
end