%% Initial parameters
FtSz=10;%20;
FntName='arial';
LineW=0.8;
mediancolor=zeros(2,3);
[~,~,~,IQRcolor]=ColorsPaper5cond_fun;%[230 159 0;170 170 170]/255;%[243 164 71;170 170 170]/255;

%% Plotting Box plots of Total time of Yeast Head micromovement (YHmm)
Condition=6;%5;%
% save_plot=0;
% close all
% x=0.35;%0.18 when ylabels are three lines, 0.13 for single line ylabels
% y=0.2;%0.11 when x labels are one line, 0.18 when they are tilted labels
% dy=0.03;
% heightsubplot=1-1.6*y;
% widthsubplot=1-1.2*x;
% Labelsmergedshort={'Yeast';'Sucrose'};%%{'V AA+b';'V AA-';'M AA+b';'M AA+u';'M AA-'};
% figure('Position',[50 50 800 800],'Color','w','PaperUnits','centimeters',...
%     'PaperPosition',[1 1 4 3],'Name',['Fig1E Boxplot YSHmm Ttimes - ' params.LabelsShort{Condition} ' ' date]);%
% set(gca,'Position',[x y widthsubplot heightsubplot])
% clear X
% X=nan(sum(params.ConditionIndex==Condition),2);
% for lsubs=1:2
%     X(:,lsubs)=sum(CumTimeH{lsubs}(:,params.ConditionIndex==Condition))/50/60;
% end
% 
% [~,lineh] = plot_boxplot_tiltedlabels(X,Labelsmergedshort,1:2,...
%     IQRcolor,mediancolor,[.4 .4 .4],.4,FtSz,FntName,'o');%'k'
% font_style([],[],{'Total duration';'of food micro-';'movement (min)'},'normal',FntName,FtSz)
% MergedConditions=1:2;
% stats_boxplot_tiltedlabels_Fig1EG(X,...
%     {'Total YSHmm'},1:2,...
%     ['Fig1E Boxplot YSHmm Ttimes '],0,params,...
%     DataSaving_dir_temp,Exp_num,Exp_letter,params.LabelsShort{Condition},'Total times',FtSz,FntName,Labelsmergedshort);
% set(gca,'XTickLabel',[],'XTick',[],'xcolor','w')
% xlim([0.5 (length(MergedConditions)+.5)])
% if Condition==6, 
%     ylim([0 5])
%     set(gca,'YTick',0:5,'YTickLabel',{'0',' ','2',' ','4',' '})
% elseif Condition==5
%     ylim([0 25])
%     set(gca,'YTick',0:5:25,'YTickLabel',{'0',' ','10',' ','20',' '})
% end
% 
% 
% if save_plot==1
%     savefig_withname(1,'600','png',DataSaving_dir_temp,Exp_num,Exp_letter,...
%         'Total times')
%     savefig_withname(0,'600','eps',DataSaving_dir_temp,Exp_num,Exp_letter,...
%         'Figures')
% end
%% Plotting Histogram of durations of Yeast Head micromovement (YHmm)
save_plot=0;
lsubs=1;
plot_type='Bars';%'Line';%
variable_label='Total time microm';
Across_flies=0;

% close all
xpos=0.25;%0.18 when ylabels are three lines, 0.13 for single line ylabels
ypos=0.27;%0.11 when x labels are one line, 0.18 when they are tilted labels
dy=0.03;
heightsubplot=1-1.2*ypos;
widthsubplot=1-1.2*xpos;
max_vals=[20 20];
num_bins=10;

for lsubs=1:2
    figure('Position',[50 50 800 800],'Color','w','PaperUnits','centimeters',...
        'PaperPosition',[1 1 5.5 3],'Name',['Fig1F Hist ' params.Subs_Names{lsubs} ' Hmm Ttimes - ' params.LabelsShort{Condition} ' '  date]);%
    set(gca,'Position',[xpos ypos widthsubplot heightsubplot])
    if num_bins==0,nbins=50; else nbins=num_bins; end
    
    max_x=max_vals(lsubs==params.Subs_Numbers);
    step=max_x/(nbins-1);
    X_range=[0:step:max_x Inf];
    
    HistCount=zeros(size(X_range,2),sum(params.ConditionIndex==Condition));
    lflycounter=0;
    for lfly=find(params.ConditionIndex==Condition)
        lflycounter=lflycounter+1;
        display(lfly)
        if ~isempty(DurInH{lfly})
            HistCount(:,lflycounter)=histc(DurInH{lfly}(DurInH{lfly}(:,1)==lsubs,5)/params.framerate,X_range);%Steplength_Sm{lfly}(log_vectIn)
        end
    end
    
    Freq=HistCount(1:end-1,:)./repmat(nansum(HistCount(1:end-1,:)),length(X_range)-1,1);
    Condfr_mean=nanmean(Freq,2);
    Condfr_stderr=nanstd(Freq,0,2)./sqrt(sum(params.ConditionIndex==Condition));
    
    %%% Histogram as bars
    if strfind(plot_type,'Bars')
        barhandle=bar(X_range(1:end-1),Condfr_mean);
        hold on
        set(barhandle,'FaceColor',IQRcolor(lsubs,:),...
                'LineWidth', LineW,'EdgeColor',IQRcolor(lsubs,:));%,'BarWidth',0.4);
        
        %% Adding the error bars
        ybuff=0;
        for i=1:length(barhandle)
            XDATA=get(get(barhandle(i),'Children'),'XData');
            YDATA=get(get(barhandle(i),'Children'),'YData');
            for j=1:size(XDATA,2)
                x=XDATA(1,j)+(XDATA(3,j)-XDATA(1,j))/2;
                y=YDATA(2,j)+ybuff;
                %             plot(x,y,'o','Color',[.5 .5 .5],'MarkerSize',3,'MarkerFaceColor',[.5 .5 .5])
                plot([x x],[y,...
                    y+Condfr_stderr(j,Conditions(i)==Conditions)],'-','Color',[.5 .5 .5],'MarkerFaceColor',[.5 .5 .5],'LineWidth',.8)
            end
        end
        
        xlim([-step/2-.35 1.1*max_x])
    ylim([-.03 1])
    
    end
    font_style([],['Micromovement duration (s)'],{'Occurrences';'normalized'},'normal',FntName,FtSz)
    set(gca,'Ytick',0:0.25:1)
    box off
    
end
%%
if save_plot==1
    savefig_withname(1,'600','png',DataSaving_dir_temp,Exp_num,Exp_letter,...
        'Bouts')
    savefig_withname(0,'600','eps',DataSaving_dir_temp,Exp_num,Exp_letter,...
        'Figures')
end
