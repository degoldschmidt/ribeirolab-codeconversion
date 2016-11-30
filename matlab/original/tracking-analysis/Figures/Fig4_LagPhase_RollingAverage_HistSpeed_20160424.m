%% INDEX:
%%% Box plot for lag phase
%%% Rolling average total duration of yeast hmm
%%% Example trajectories on the spot with head speed as color code
%%% Histogram of head speed on the spot
%%% Box plots of composition of visits

%% General initial parameters
FtSz=9;%20;
FntName='arial';
LineW=0.8;

Conditions=[2 3 1 5 6 4];% EXP 12A[1 2];%EXP 8A[5 1 3];%[2 1 3];%EXP 8B[6 4 5 1 3];%EXP 3D[1 3];%  [2 4 1 3];%EXP 4A
condtag=['cond' num2str(Conditions)];%'All cond';%'cond2134';%'cond1-4';%'cond5 1 3';%
LabelsShortPaper=params.LabelsShort(Conditions);%{'Virgin, AA+';'Virgin, AA-';'Mated, AA+';'Mated, AA+ suboptimal';'Mated, AA-'};

[ColorsinPaper,orderinpaper,labelspaper]=ColorsPaper5cond_fun(Exp_num, Exp_letter,params);
[CondColors]=Colors(length(unique(params.ConditionIndex)));%
lcondcounter=0;
MergedConditions=nan(length(Conditions),1);

newcondcolors=nan(length(Conditions),3);
for lcond=Conditions
    lcondcounter=lcondcounter+1;
    if length(Conditions)<=size(ColorsinPaper,1)
        newcondcolors(lcond==Conditions,:)=ColorsinPaper(orderinpaper==lcond,:);%
    else
        newcondcolors(lcond==Conditions,:)=CondColors(ismember(unique(params.ConditionIndex),lcond),:);
    end
    MergedConditions(lcondcounter)=find(orderinpaper==lcond);
end

%% Box plot for lag phase
NonEaterThr=60;%s
save_plot=1;
y_label={'Latency to long';'yeast visit (min)'};%{'Lag duration';'(min)'};
y_label_FIG='Latency Yvisit 30s';%'Lag duration';
sub_folder='Ethograms';
close all
if length(Conditions)<=3
    x=0.47;%0.18 when ylabels are three lines, 0.13 for single line ylabels
    paperpos=[1 1 3 4];
else
    x=0.2;%poxn0.35;% Ponx .45;
    paperpos=[1 1 4.5 3.5];%[1 1 4 4];%[1 1 5 4];
end
y=0.2;%0.11 when x labels are one line, 0.18 when they are tilted labels
dy=0.03;
heightsubplot=1-1.6*y;
widthsubplot=1-1.1*x;
lsubs=1;


% % % latency_root=nan(params.numflies,1);
% % % for lfly=1:params.numflies
% % % %     temp=DurInEncounter{lfly}(DurInEncounter{lfly}(:,1)==1,:);
% % %     temp=DurInV{lfly}(DurInV{lfly}(:,1)==1,:);%Frames
% % %     row=find(temp(:,5)>=30*50,1,'first');%30 seconds
% % %     if ~isempty(row)
% % %         latency_root(lfly)=temp(row,2);%frames
% % %     end
% % % end

numcond=nan(length(Conditions),1);
lcondcounter=0;
for lcond=Conditions
    lcondcounter=lcondcounter+1;
    numcond(lcondcounter)=sum(params.ConditionIndex==lcond);
end
figname=['Fig4BBoxplot5mm ' condtag ' ' y_label_FIG ' '];
figure('Position',[50 50 800 800],'Color','w','PaperUnits','centimeters',...
    'PaperPosition',paperpos,'Name',[figname date]);%
set(gca,'Position',[x y widthsubplot heightsubplot])

hold on
lcondcounter=0;
CumV=nan(max(numcond),length(Conditions));
for lcond=Conditions
    lcondcounter=lcondcounter+1;
%     CumV(1:numcond(lcondcounter),lcondcounter)=lags(find(params.ConditionIndex==lcond),1)/params.framerate/60;
    CumV(1:numcond(lcondcounter),lcondcounter)=latency_root(params.ConditionIndex==lcond)/params.framerate/60;
end

mediancolor=zeros(length(Conditions),3);
IQRcolor=newcondcolors;%[204 0 0;228 122 189]/255;%
[~,lineh] = plot_boxplot_tiltedlabels(CumV,cell(size(CumV,2),1),1:size(CumV,2),...
    IQRcolor,mediancolor,[.4 .4 .4],.4,FtSz,FntName,'o',1);%'k'
font_style([],[],y_label,'normal',FntName,FtSz)
%     MergedConditions=1:length(Conditions);
stats_boxplot_tiltedlabels(CumV,...
    {y_label_FIG},Conditions,1:size(CumV,2),...
    figname,0,params,...
    DataSaving_dir_temp,Exp_num,Exp_letter,condtag,sub_folder,FtSz,FntName);

% ylim([0 1.8*max(prctile(CumV,75))])%ylim([0 90])% ylim([0 35])%
xlim([0.5 (length(MergedConditions)+.5)])
set(gca,'xcolor','w')%,'ytick',0:30:90)%,'ytick',0:5:35)

if save_plot==1
    savefig_withname(1,'600','png',DataSaving_dir_temp,Exp_num,Exp_letter,...
        sub_folder)
    savefig_withname(0,'600','eps',DataSaving_dir_temp,Exp_num,Exp_letter,...
       'Thesis')%'Figures'
end


%% Rolling average total duration of yeast hmm
save_plot=1;sub_folder='Thesis';%'Time Segments';
close all

% lparam=46;%Total time YHMM  9;% Y Av Dur 

params2plot=48;%[9 48];%[48 95 87 9 64 73];%[46 48 11 9 73 87 81 64];%64;%
% load('E:\Analysis Data\Experiment 0003\Variables\TimeSegmentsParams_5mmH0_113r_until117_0003D 01-Apr-2016.mat')
% load('E:\Analysis Data\Experiment 0003\Variables\TimeSegmentsParams_5mmH0_113r_until117_0003D 10-Feb-2016.mat')
% % load('E:\Analysis Data\Experiment 0003\Variables\TimeSegmentsParams_H0_113r_until117_0003D 29-Jan-2016.mat')
% % load('E:\Analysis Data\Experiment 0003\Variables\TimeSegmentsParams_113r_until117_0003D 02-Dec-2015.mat','TimeSegmentsParams','ranges')
% % % % windowsize=5;%min
% % % % windowstep=1;%min
% % % % ranges=[(1:windowstep*50*60:lastframe-windowsize*60*50);...
% % % %         (1:windowstep*50*60:lastframe-windowsize*60*50)+windowsize*60*50]';


x=0.2;%0.18 when ylabels are three lines, 0.13 for single line ylabels
y=0.22;%0.11 when x labels are one line, 0.18 when they are tilted labels
dy=0.03;
heightsubplot=1-1.6*y;
widthsubplot=1-1.2*x;
step=4;%20;%1;%

for lparam=params2plot
figname=['paramNº' num2str(lparam) ' Rolling Median5mm Win5st' num2str(step) 'min ' condtag  ' ' date];
figure('Position',[50 50 1000 500],'Color','w','PaperUnits','centimeters',...
    'PaperPosition',[1 1 4.5 3],'Name',figname);%[1 1 8 4]%%fig4 [1 1 7 4.5]%Fig7
set(gca,'Position',[x y widthsubplot heightsubplot])

patch1_3=[245 228 169;208 146 167]/255;%repmat([.5 .5 .5],length(Conditions),1);%

hold on
AllConditions=unique(params.ConditionIndex);
h=nan(length(Conditions),1);
lcondcounter=0;
for lcond=Conditions
    lcondcounter=lcondcounter+1;
    X=TimeSegmentsParams{lcond==AllConditions}(lparam).Data;

%     plot(ranges(1:step:size(X,1),1)/50/60,X(1:step:end,:),'-',...['-' Symbol_cond{lcondcounter}],...
%         'LineWidth',LineW,'Color',patch1_3(lcondcounter,:))%
% 
% %     plot(ranges(1:step:size(X,1),1),1)/50/60,nanmedian(X(1:step:end,:),2),'-',...['-' Symbol_cond{lcondcounter}],...
% %         'LineWidth',2*LineW,'Color',newcolors(lcondcounter,:))%,'MarkerFaceColor',CondColors(ismember(unique(params.ConditionIndex),lcond),:),...
% % %         'MarkerSize',MkSz)

%     h=plot_line_errpatch(ranges(1:step:size(X,1),1)/50/60+2.5,nanmean(X(1:step:end,:),2),...
%         nanstd(X(1:step:end,:),0,2)/sqrt(sum(params.ConditionIndex==lcond)),newcolors(lcondcounter,:),patch1_3(lcondcounter,:));
    h(lcondcounter)=plot(ranges(1:step:size(X,1),1)/50/60,nanmedian(X(1:step:end,:),2),'-o',...
        'Color',newcondcolors(lcondcounter,:),'LineWidth',1.5,'MarkerSize',1,...
        'MarkerFaceColor',newcondcolors(lcondcounter,:));


%     plot([nanmedian(CumV(:,lcondcounter)) nanmedian(CumV(:,lcondcounter))],...
%         [0 6],'--','Color',newcondcolors(lcondcounter,:),'LineWidth',0.8)
end

y_label=TimeSegmentsParams{1}(lparam).YLabel;
y_label2=['param ' num2str(lparam)];
% xticklabels=cellfun(@num2str,num2cell(round((ranges(1:3:end,1)/50/60))),'UniformOutput',0);
if lparam==48,y_label={'Total duration';'of yeast visits';'(min)'};ylim([0 6]);end
ylim3=get(gca,'YLim');
% set(gca,'XTick',[0 Interval_Separator],'Xticklabel',[],'tickdir','out')
font_style([],'Time (min)',y_label2,'normal',FntName,FtSz)%'Time of assay (min)'%'Time from 1st long visit (min)'
if lparam==46,ylim([-0.2 4]);end
if lparam==9,ylim([0 3]);end
maxx=60;%120;
xlim([0 maxx])
set(gca,'xtick',0:20:maxx)
% legend(h,labelspaper(Conditions))
% legend('boxoff')
range=get(gca,'Ylim');
ylim([range(1)-0.1*(range(2)-range(1)) range(2)])
end

if save_plot==1
    savefig_withname(1,'600','png',DataSaving_dir_temp,Exp_num,Exp_letter,...
        sub_folder)
    savefig_withname(0,'600','eps',DataSaving_dir_temp,Exp_num,Exp_letter,...
        sub_folder)%'Figures'
end
%% Figure with Labels of parameters
% figname=['Fig4A labels Rolling Median5mm Win5st' num2str(step) 'min ' condtag ' ' date];
% figure('Position',[2100 50 500 500],'Color','w','Name',figname,'PaperUnits',...
%     'centimeters','PaperPosition',[0 0 10 10])
% hold on
% lparamcounter=0;
% for lparam=params2plot
%     lparamcounter=lparamcounter+1;
%     if iscell(TimeSegmentsParams{1}(lparam).YLabel)
%         y_label=TimeSegmentsParams{1}(lparam).YLabel;
%     else
%         y_label=TimeSegmentsParams{1}(lparam).YLabel;
%     end
%     plot([1 2],[lparamcounter lparamcounter],'-','LineWidth',2,'Color','k')
%     text(3,lparamcounter,[['Param ' num2str(lparam) ': ']; y_label],'FontName',FntName,'FontSize',FtSz)
%     
% end 
% axis([0 10 0 lparamcounter+1])
%     font_style({'Condition labels time segment parameters';['Exp ' num2str(Exp_num) num2str(Exp_letter) ', ' date]},[],[],'normal',FntName,FtSz)
%     axis off
% 
% 
% if save_plot==1
% savefig_withname(1,'600','png',DataSaving_dir_temp,Exp_num,Exp_letter,sub_folder)
% savefig_withname(0,'600','eps',DataSaving_dir_temp,Exp_num,Exp_letter,'Figures')
% end


%% Histogram of head speed on the spot
save_plot=1;
subfolder='Activity';
lsubs=1;
plot_type='Bars';
y_label_FIG='Hist speed ';

close all
xpos=0.25;%0.18 when ylabels are three lines, 0.13 for single line ylabels
ypos=0.27;%0.11 when x labels are one line, 0.18 when they are tilted labels
dy=0.03;
heightsubplot=1-1.2*ypos;
widthsubplot=1-1.2*xpos;
max_vals=[2 2];
num_bins=10;

figure('Position',[50 50 800 800],'Color','w','PaperUnits','centimeters',...
    'PaperPosition',[1 1 8 4],'Name',['Fig5 ' y_label_FIG params.Subs_Names{lsubs} ' ' condtag ' ' date]);%
set(gca,'Position',[xpos ypos widthsubplot heightsubplot])
if num_bins==0,nbins=50; else nbins=num_bins; end

if max_vals(lsubs==params.Subs_Numbers)==0,max_x=max(x_lims);else max_x=max_vals(lsubs==params.Subs_Numbers);end
step=max_x/(nbins-1);
X_range=[0:step:max_x Inf];


HistCount=zeros(size(X_range,2),params.numflies);
for lfly=1:params.numflies
    display(lfly)
    range=1:params.MinimalDuration;
    Speedh_temp=Steplength_Sm_h{lfly}(range);
    logicalinsideSubs1=CumTimeV{lsubs}(range,lfly)==1;
    if sum(logicalinsideSubs1)~=0
        %% Speed head during substrate 1 visits
        speedsfly=(Speedh_temp(logicalinsideSubs1)*params.px2mm*params.framerate);%mm/s
    else
        speedsfly=nan;
    end
    HistCount(:,lfly)=histc(speedsfly,X_range);%Steplength_Sm{lfly}(log_vectIn)

end

Freq=HistCount(1:end-1,:)./repmat(nansum(HistCount(1:end-1,:)),length(X_range)-1,1);
Condfr_mean=nan(size(Freq,1),length(Conditions));
Condfr_stderr=nan(size(Freq,1),length(Conditions));
lcondcounter=0;
for lcond=Conditions
    lcondcounter=lcondcounter+1;
    Condfr_mean(:,lcondcounter)=nanmean(Freq(:,params.ConditionIndex==lcond),2);
    Condfr_stderr(:,lcondcounter)=nanstd(Freq(:,params.ConditionIndex==lcond),0,2)./sqrt(sum(params.ConditionIndex==lcond));
end
%%% Histogram as bars
if strfind(plot_type,'Bars')
    barhandle=bar(X_range(1:end-1),Condfr_mean);
    hold on
    for lbarcond=1:size(Condfr_mean,2)
        set(barhandle(lbarcond),'FaceColor',ColorsinPaper(orderinpaper==Conditions(lbarcond),:),...
        'LineWidth', LineW,'EdgeColor',ColorsinPaper(orderinpaper==Conditions(lbarcond),:));%,'BarWidth',0.4);
    end
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
                y+Condfr_stderr(j,i)],'-','Color',[.5 .5 .5],'MarkerFaceColor',[.5 .5 .5],'LineWidth',.8)
        end
    end

    xlim([-step/2 1.1*max_x])
    ylim([-.02 .6])
end
font_style([],['Head speed during yeast visits (mm/s)'],{'Occurrences,';'normalized'},'normal',FntName,FtSz)
box off

if save_plot==1
    savefig_withname(1,'600','png',DataSaving_dir_temp,Exp_num,Exp_letter,...
        subfolder)
    savefig_withname(0,'600','eps',DataSaving_dir_temp,Exp_num,Exp_letter,...
        'Figures')
end
%% Box plots of composition of visits
% save_plot=1;
% subfolder='Visits';
% lsubs=1;
% y_label_FIG='Composition of visits ';
% 
% close all
% xpos=0.16;%0.18 when ylabels are three lines, 0.13 for single line ylabels
% ypos=0.25;%0.11 when x labels are one line, 0.18 when they are tilted labels
% dy=0.03;
% heightsubplot=1-1.2*ypos;
% widthsubplot=1-1.2*xpos;
% max_vals=[2 2];
% num_bins=10;
% 
% figure('Position',[50 50 800 800],'Color','w','PaperUnits','centimeters',...
%     'PaperPosition',[1 1 5.7 4],'Name',['Fig5 ' y_label_FIG params.Subs_Names{lsubs} ' ' condtag ' ' date]);%
% set(gca,'Position',[xpos ypos widthsubplot heightsubplot])
% 
% 
% if ~exist('Etho_Speed_new','var')
%     [Etho_Speed_new,Etho_colors_new,Etho_Colors_Labels] = Etho_Speed2New(params.MinimalDuration,Etho_Speed,1);
% end
% 
% Etho_H_Speed=Etho_Speed_new;
% Etho_H_Speed(Etho_H==9)=6;%YHmm
% Etho_H_Speed(Etho_H==10)=7;%SHmm
% EthoH_Colors=[Etho_colors_new;...
%     [250 244 0]/255;...%6 - Yellow (Yeast micromovement)
%     0 0 0];%7 - Sucrose
% 
% norm_label=' -Norm';
% plot_type='Dur of elements';
% variable_labels={'Rest','Micromovement','Walk','Turn'};
% var_ethoSpeed_new_number=[1 2 3 4];
% y_label={'Fraction of behavior';'in visit'};
% 
% numvariables=length(variable_labels);
% xvalues=1:numvariables*(length(Conditions)+1);
% xvalues((1:numvariables)*(length(Conditions)+1))=[];
% 
% X=nan(max(numcond),length(xvalues));
% clear variable_cond
% lcolcounter=0;
% for lvariable=1:numvariables
%     variable_label=variable_labels{lvariable};
%     display(['----- ' variable_label ' -----'])
%     lcondcounter=0;
%     for lcond=Conditions
%         lcondcounter=lcondcounter+1;
%         lcolcounter=lcolcounter+1;
%         
%         logical_subs=logical(CumTimeV{lsubs==params.Subs_Numbers}(:,params.ConditionIndex==lcond))';
%         DenominatorT=sum(CumTimeV{lsubs==params.Subs_Numbers}(:,params.ConditionIndex==lcond))';%conversion to %
%         
%         switch variable_label
%             case variable_labels
%                 ethonumber=var_ethoSpeed_new_number(lvariable);
%                 if (~isempty(strfind(variable_label,'Micromovement')))
%                     logical_etho=(Etho_Speed_new(params.ConditionIndex==lcond,:)==ethonumber)&...
%                         ~(Etho_H(params.ConditionIndex==lcond,:)==9+find(lsubs==params.Subs_Numbers)-1);
%                 else
%                     logical_etho=Etho_Speed_new(params.ConditionIndex==lcond,:)==ethonumber;
%                 end
%                 variable_cond=sum((logical_subs&logical_etho),2)./DenominatorT;
%                 
%         end
%         X(1:numcond(lcondcounter),lcolcounter)=variable_cond;
%     end
% end
% newcolors=nan(length(Conditions),3);
% MergedConditions=nan(length(Conditions),1);
% lcondcounter=0;
% for lcond=Conditions
%     lcondcounter=lcondcounter+1;
%     newcolors(lcondcounter,:)=ColorsinPaper(orderinpaper==lcond,:);
%     MergedConditions(lcondcounter)=find(orderinpaper==lcond);
% end
% if length(Conditions)==2, MergedConditions=1:length(Conditions);end
% mediancolor=zeros(length(Conditions),3);
% IQRcolor=newcolors;
% [~,lineh] = plot_boxplot_tiltedlabels(X,cell(length(xvalues),1),xvalues,...
%     repmat(IQRcolor,numvariables,1),repmat(mediancolor,numvariables,1),[.4 .4 .4],.4,FtSz,FntName,'o',1);
% 
% ax1=-0.01;
% x_ticks=(1:numvariables)*(length(Conditions)+1)-floor(length(Conditions)/2);
% thandle=text(x_ticks,...
%     ax1*ones(1,numvariables),variable_labels);
% set(thandle,'HorizontalAlignment','right','VerticalAlignment','top',...
%             'Rotation',20,'FontSize',FtSz,'FontName',FntName);
% xlim([0 numvariables*(length(Conditions)+1)])
% font_style([],[],y_label,'normal',FntName,FtSz)
% ylim([ax1 .4])
% stats_boxplot_tiltedlabels_Fig2B(X,...
%         variable_labels,MergedConditions,xvalues,...
%         y_label_FIG,lsubs,params,...
%         DataSaving_dir_temp,Exp_num,Exp_letter,condtag,subfolder,FtSz,FntName,LabelsShortPaper);
% % stats_boxplot_tiltedlabels(X,variable_labels,Conditions,xvalues,plot_type,lsubs,params,...
% %                 DataSaving_dir_temp,Exp_num,Exp_letter,condtag,'Visits',FtSz,FntName)
% if save_plot==1
%     savefig_withname(1,'600','png',DataSaving_dir_temp,Exp_num,Exp_letter,...
%         subfolder)
% end
%% INSET Box plots of composition of visits
% save_plot=1;
% subfolder='Visits';
% lsubs=1;
% y_label_FIG='Composition of visits inset ';
% 
% close all
% xpos=0.25;%0.18 when ylabels are three lines, 0.13 for single line ylabels
% ypos=0.2;%0.11 when x labels are one line, 0.18 when they are tilted labels
% dy=0.03;
% heightsubplot=1-1.4*ypos;
% widthsubplot=1-1.2*xpos;
% max_vals=[2 2];
% num_bins=10;
% 
% figure('Position',[50 50 800 800],'Color','w','PaperUnits','centimeters',...
%     'PaperPosition',[1 1 3 1.5],'Name',['Fig5 ' y_label_FIG params.Subs_Names{lsubs} ' ' condtag ' ' date]);%
% set(gca,'Position',[xpos ypos widthsubplot heightsubplot])
% 
% 
% if ~exist('Etho_Speed_new','var')
%     [Etho_Speed_new,Etho_colors_new,Etho_Colors_Labels] = Etho_Speed2New(params.MinimalDuration,Etho_Speed,1);
% end
% 
% Etho_H_Speed=Etho_Speed_new;
% Etho_H_Speed(Etho_H==9)=6;%YHmm
% Etho_H_Speed(Etho_H==10)=7;%SHmm
% EthoH_Colors=[Etho_colors_new;...
%     [250 244 0]/255;...%6 - Yellow (Yeast micromovement)
%     0 0 0];%7 - Sucrose
% 
% norm_label=' -Norm';
% plot_type='Dur of elements';
% variable_labels={'Walk','Turn'};
% var_ethoSpeed_new_number=[3 4];
% y_label={'Fraction of behavior';'in visit'};
% 
% numvariables=length(variable_labels);
% xvalues=1:numvariables*(length(Conditions)+1);
% xvalues((1:numvariables)*(length(Conditions)+1))=[];
% 
% X=nan(max(numcond),length(xvalues));
% clear variable_cond
% lcolcounter=0;
% for lvariable=1:numvariables
%     variable_label=variable_labels{lvariable};
%     display(['----- ' variable_label ' -----'])
%     lcondcounter=0;
%     for lcond=Conditions
%         lcondcounter=lcondcounter+1;
%         lcolcounter=lcolcounter+1;
%         
%         logical_subs=logical(CumTimeV{lsubs==params.Subs_Numbers}(:,params.ConditionIndex==lcond))';
%         DenominatorT=sum(CumTimeV{lsubs==params.Subs_Numbers}(:,params.ConditionIndex==lcond))';%conversion to %
%         
%         switch variable_label
%             case variable_labels
%                 ethonumber=var_ethoSpeed_new_number(lvariable);
%                 if (~isempty(strfind(variable_label,'Micromovement')))
%                     logical_etho=(Etho_Speed_new(params.ConditionIndex==lcond,:)==ethonumber)&...
%                         ~(Etho_H(params.ConditionIndex==lcond,:)==9+find(lsubs==params.Subs_Numbers)-1);
%                 else
%                     logical_etho=Etho_Speed_new(params.ConditionIndex==lcond,:)==ethonumber;
%                 end
%                 variable_cond=sum((logical_subs&logical_etho),2)./DenominatorT;
%                 
%         end
%         X(1:numcond(lcondcounter),lcolcounter)=variable_cond;
%     end
% end
% newcolors=nan(length(Conditions),3);
% MergedConditions=nan(length(Conditions),1);
% lcondcounter=0;
% for lcond=Conditions
%     lcondcounter=lcondcounter+1;
%     newcolors(lcondcounter,:)=ColorsinPaper(orderinpaper==lcond,:);
%     MergedConditions(lcondcounter)=find(orderinpaper==lcond);
% end
% if length(Conditions)==2, MergedConditions=1:length(Conditions);end
% mediancolor=zeros(length(Conditions),3);
% IQRcolor=newcolors;
% [~,lineh] = plot_boxplot_tiltedlabels(X,cell(length(xvalues),1),xvalues,...
%     repmat(IQRcolor,numvariables,1),repmat(mediancolor,numvariables,1),[.4 .4 .4],.4,FtSz,FntName,'o',1);
% 
% ax1=-.001;
% x_ticks=(1:numvariables)*(length(Conditions)+1)-floor(length(Conditions)/2);
% thandle=text(x_ticks,...
%     ax1*ones(1,numvariables),variable_labels);
% set(thandle,'HorizontalAlignment','right','VerticalAlignment','top',...
%             'Rotation',0,'FontSize',FtSz,'FontName',FntName);
%         set(gca,'Ytick',[0 0.01 0.02],'yticklabel',{'0','0.01','0.02'})
% xlim([0 numvariables*(length(Conditions)+1)])
% font_style([],[],[],'normal',FntName,FtSz)
% ylim([ax1 0.02])
% if save_plot==1
%     savefig_withname(1,'600','png',DataSaving_dir_temp,Exp_num,Exp_letter,...
%         subfolder)
% end