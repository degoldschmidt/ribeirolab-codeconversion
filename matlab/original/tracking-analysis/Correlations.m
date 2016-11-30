%% Correlation between variables

% ranges=[1 180000];% 60 min
% % load([Variablesfolder 'TimeSegmentsParams_' num2str(size(ranges,1)) 'r_until' num2str(floor((ranges(end)/50/60))) '_' Exp_num Exp_letter ' 04-Nov-2015.mat'])
% 
% Conditions=3;%unique(params.ConditionIndex);%[2 4 6 8];%
% params2plot=[1:6 9:12 13 16 22 30 34:39 46:56 60 61 77 93 117 120];%1:size(TimeSegmentsParams{1},2);%
% 
% 
% ParamsforPCA_pre=nan(params.numflies,size(TimeSegmentsParams{1},2));
% LabelsforPCA_pre=cell(size(TimeSegmentsParams{1},2),1);
% 
% AllConditions=unique(params.ConditionIndex);
% lrange=1;
% lcondcounter=0;
% for lcond=AllConditions
%     lcondcounter=lcondcounter+1;
%     Idx_cond=find(params.ConditionIndex==lcond);
%     for lparam=1:size(TimeSegmentsParams{1},2)
%         ParamsforPCA_pre(Idx_cond,lparam)=TimeSegmentsParams{lcond==AllConditions}(lparam).Data(lrange,:)';
%         if lcondcounter==1
%             LabelsforPCA_pre{lparam}=TimeSegmentsParams{lcond==AllConditions}(lparam).YLabel;
%         end
%     end
%     
% end
% 
% lcond=3;
% ParamsforPCA=ParamsforPCA_pre(params.ConditionIndex==lcond,params2plot);
% LabelsforPCA=LabelsforPCA_pre(params2plot);

%% All
% % close all
% figure
% C=corr(ParamsforPCA(:,sort_idx),ParamsforPCA(:,sort_idx));
% imagesc(C), colormap(jet),colorbar
% set(gca,'Xticklabel',[],'Color','none','Yticklabel',[])
% for lparam=params2plot(sort_idx)
%     %         thandle=text(1:length(LabelsforPCA),ylim3(1)*ones(1,length(LabelsforPCA)),LabelsforPCA(:));
%             if iscell(LabelsforPCA{lparam})
%                 thandle=text(lparam,length(LabelsforPCA),[LabelsforPCA{lparam}{1} LabelsforPCA{lparam}{2}]);
%                 thandle2=text(0,lparam,[LabelsforPCA{lparam}{1} LabelsforPCA{lparam}{2}]);
%             else
%                 thandle=text(lparam,length(LabelsforPCA),LabelsforPCA{lparam});
%                 thandle2=text(0,lparam,LabelsforPCA{lparam});
%             end
%     set(thandle,'HorizontalAlignment','right','VerticalAlignment','bottom',...
%         'Rotation',90,'FontSize',FtSz-2,'FontName',FntName);
%     set(thandle2,'HorizontalAlignment','right','VerticalAlignment','middle',...
%         'Rotation',0,'FontSize',FtSz-2,'FontName',FntName);
% end

%% Linear regression with r and r2
FtSz=9;
FntName='arial';
singleflycolor=1;

[CondColors,Cmap_patch]=Colors(length(unique(params.ConditionIndex)));%
newcondcolors=nan(length(Conditions),3);
for lcond=Conditions
    newcondcolors(lcond==Conditions,:)=CondColors(ismember(unique(params.ConditionIndex),lcond),:);
end
paramstocompare=[5 9];
lcondcounter=0;
for lcond=Conditions
    lcondcounter=lcondcounter+1;
    subplot(2,ceil(length(Conditions)/2),lcondcounter)
    x=ParamsforPCA_pre(params.ConditionIndex==lcond,paramstocompare(1));
    y=ParamsforPCA_pre(params.ConditionIndex==lcond,paramstocompare(2));
    plot(x,y,'o',...
            'MarkerEdgeColor',[.7 .7 .7],'MarkerFaceColor',newcondcolors(lcondcounter,:));
    %     axis([0 14 0 60])
    font_style(params.Labels{lcond},LabelsforPCA_pre{paramstocompare(1)},...
        LabelsforPCA_pre{paramstocompare(2)},'normal',FntName,FtSz)
    hold on
    
    %% Linear Regression TYPE 1%%
    statopts=statset('Display','final');% If you specify 'iter', output is
    %%% displayed at each iteration. If you specify 'final', output is
    %%% displayed after the final iteration.
    fitparams = nlinfit(x,y,...
        @StraightLine,[1 0],statopts);
    Slope=fitparams(1);
    
    %%% Computing R2
    yresid = y - (fitparams(1).*x+fitparams(2));
    SSresid = sum(yresid.^2);
    SStotal = (length(y)-1) * var(y);%sum((y-mean(y)).^2)
    
    
    Rsq(lcondcounter) = 1 - SSresid/SStotal; % Compute R2
    display(['R2 using formula: ' num2str(Rsq(lcondcounter))])
    hold on
    plot([min(x) max(x)],[fitparams(1)*min(x)+fitparams(2) fitparams(1)*max(x)+fitparams(2)],'-r','Color',.4*[1 1 1])
    
end
%%

