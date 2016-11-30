%% Plotting Ethogram with Time of the day on the side
h_dist=0.05;
v_dist=0.06;
height=(1-4*v_dist)/2;
width=(1-6*h_dist)*3/8;

PanelPosit=[h_dist 3*v_dist+height width height;...
    (1.1)*h_dist+width 3*v_dist+height width/3.5 height;...
    4*h_dist+(1+1/3)*width 3*v_dist+height width height;...
    4.1*h_dist+(2+1/3)*width 3*v_dist+height width/3.5 height;...
    h_dist v_dist width height;...
    (1.1)*h_dist+width v_dist width/3.5 height;...
    4*h_dist+(1+1/3)*width v_dist width height;...
    4.1*h_dist+(2+1/3)*width v_dist width/3.5 height];
% close all
% figure('Position',[100 50 1400 930],'Color','w')
% 
% for lplot=1:size(PanelPosit,1)
%     subplot('Position',PanelPosit(lplot,:))
% end
%% Removing 8s from EthoH and defining colormap
Etho_H_tmp=Etho_H;
Etho_H_tmp(Etho_H_tmp==9)=8;Etho_H_tmp(Etho_H_tmp==10)=9;
Etho_H_tmp_colors=[...
    [0.6 0.6 0.6]*255;...%1 - Gray (Resting)
    Color(1,:)*255;...%2 - Purple (slow micromovement)
    204 140 206;...%3 - Light Purple (fast-micromovement)
    124 143 222;...%4 -  Blueish violet (Slow walk)
    Color(3,:)*255;...%5 - Light Blue (Walking)
    Color(2,:)*255;...%6 - Green (Turn)
    255 0 0;...%7 - Red (Jump)
    238 96 8;...%9 - Orange(Yeast head slow micromovement)
    0 0 0]/255;%10 - Black (Sucrose)
%% Transforming

TimesNum=[FlyDB.TimeNumber]';
TimesNumNew=(TimesNum-min(TimesNum))*100;
[~,maxidx]=max(TimesNumNew);
[~,minidx]=min(TimesNumNew);
colortime=summer(ceil(max(TimesNumNew))+1);

saveplot=0;
FntName='arial';
FtSz=6;
close all
fhandle=figure('Position',[100 50 1400 930],'Color','w','Name','Ethogram all conds, Speedsort, Time of day barh');
plotcounter=0;
for lcond=Conditions
    %% Plot Ethogram
    plotcounter=plotcounter+1;
    subplot('Position',PanelPosit(plotcounter,:))
    
%     Idx_sort=Flies_cluster{lcond};
    CondIdx=find(params.ConditionIndex==lcond);
    [~,Idx_sort_temp]=sort(Speed_OutVisits_all(CondIdx'));
    Idx_sort=CondIdx(Idx_sort_temp);
    Idx_sort_label=cellfun(@(x)num2str(x),num2cell(Idx_sort),'UniformOutput',0);
    
    image(Etho_H_tmp(Idx_sort,:))
    set(gca,'XTick',[1:20*50*60:120*50*60],...
        'XTickLabel',{'0','20','40','60','80','100','120'},...
        'YTick',(1:length(Idx_sort)),'YTickLabel',Idx_sort_label)
    font_style(params.Labels{lcond},'Time of assay (min)',...
        'Single Flies','normal',FntName,FtSz)
    colormap(Etho_H_tmp_colors);
    freezeColors
    %% Plot Time of Day as image with colors
%     plotcounter=plotcounter+1;
%     subplot('Position',PanelPosit(plotcounter,:))
%     image(TimesNumNew(Idx_sort),'CDataMapping','scaled')
%     axis off
%     colortime=jet(length(unique(TimesNumNew)));
%     colormap(summer)%(colortime)
%     hold on
%     for lflycond=1:length(Idx_sort)
%         text(1,lflycond,datestr(TimesNumNew(Idx_sort(lflycond)),'HH:MM'),'HorizontalAlignment','center',...
%             'FontSize',FtSz,'FontName',FntName)
%     end
% %     colorbar
    %% Plot time of Day as bars
    plotcounter=plotcounter+1;
%     subplot('Position',PanelPosit(plotcounter,:))
    axhandle=axes('Position',PanelPosit(plotcounter,:));
%     h=barh(1:length(Idx_sort),TimesNumNew(Idx_sort));
%     set(h,'EdgeColor','k','FaceColor','y')
    
    hold on
    
    for lflycond=1:length(Idx_sort)
        barh(lflycond,TimesNumNew(Idx_sort(lflycond)),'parent', axhandle, 'facecolor', colortime(ceil(TimesNumNew(Idx_sort(lflycond)))+1,:))
        text(TimesNumNew(Idx_sort(lflycond)),lflycond,datestr(TimesNum(Idx_sort(lflycond)),'HH:MM'),...
            'HorizontalAlignment','left','FontSize',FtSz,'FontName',FntName)
    end
    
    set(gca,'YDir','reverse','box','off','YTick',[],'XTick',[],'XLim',[0 max(TimesNumNew)],...
        'YLim',[.5 length(Idx_sort)+.5])
    font_style([],{'Time of day'; '(HH:MM)'},...
        [],'normal',FntName,FtSz)
    
end
if (saveplot==1)
    savefig_withname(1,'600','png',DataSaving_dir_temp,Exp_num,Exp_letter,'Ethograms')
end
%% Time of Day correlation with Speed per condition
% close all
saveplot=0;
FntName='arial';
FtSz=8;

TimesNum_cell=num2cell(TimesNum);
TimesStr=cellfun(@(x)datestr(x,'HH:MM'),TimesNum_cell,'UniformOutput',0);
UniqueTimes=unique(TimesNumNew);
YAxisTimes=UniqueTimes(1:floor(length(UniqueTimes)/5):end);
YAxisTimesIdx=nan(length(YAxisTimes),1);
for lYAxisTimes=YAxisTimes'
    YAxisTimesIdx(lYAxisTimes==YAxisTimes)=find(TimesNumNew==lYAxisTimes,1,'first');
end

figure('Position',[2100 50 1200 930],'Color','w','Name','Speed outside visits correlation time of day')
Colors_cond=Colors(length(Conditions));
lcondcounter=0;
for lcond=Conditions
    lcondcounter=lcondcounter+1;
    display(['------ ' params.LabelsShort{lcond} ' -----'])
    subplot(2,ceil(length(Conditions)/2),lcondcounter)
    x=TimesNumNew(params.ConditionIndex==lcond);
    y=Speed_OutVisits_all(params.ConditionIndex==lcond);
    plot(x,y,'o',...
        'MarkerEdgeColor',[.7 .7 .7],'MarkerFaceColor',Colors_cond(lcondcounter,:));
    set(gca,'XTick',TimesNumNew(YAxisTimesIdx),'XTickLabel',TimesStr(YAxisTimesIdx),...
        'XLim',[-1 max(TimesNumNew)+1],'YLim',[0 13])
    font_style(params.Labels{lcond},'Time of the day (HH:MM)',...
        'Speed outside visits (mm/s)','normal',FntName,FtSz)
    
    %% Linear Regression %%
   
    p= polyfit(x,y,1);
    f= polyval(p,x);
    hold on
    plot([min(x) max(x)],[min(f) max(f)],'-r','Color',.4*[1 1 1])
    %%
    display('R2 using corrcoef')
    [R,p] = corrcoef(x,y,'rows','pairwise');
    R2 = R(1,2).^2;
    pvalue = p(1,2);
    text(0,11,{['R= ' num2str(R(1,2))];['R^2= ' num2str(R2)];['p value= ' num2str(pvalue)]},'FontName',FntName,'FontSize',FtSz)
end
if (saveplot==1)
    savefig_withname(1,'600','png',DataSaving_dir_temp,Exp_num,Exp_letter,'Activity')
end    
%%  Time of Day correlation with Speed all flies
close all
saveplot=0;
FntName='arial';
FtSz=9;
figure('Position',[2100 50 1200 930],'Color','w','Name','Speed outside visits correlation time of day, all cond')
x=TimesNumNew;
y=Speed_OutVisits_all;
plot(x,y,'o',...
    'MarkerEdgeColor',[.7 .7 .7],'MarkerFaceColor',Colors_cond(6,:));
set(gca,'XTick',TimesNumNew(YAxisTimesIdx),'XTickLabel',TimesStr(YAxisTimesIdx),...
    'XLim',[-1 max(TimesNumNew)+1],'YLim',[0 13])
font_style('All flies','Time of the day (HH:MM)',...
    'Speed outside visits (mm/s)','normal',FntName,FtSz)

%%% Linear Regression %%

p= polyfit(x,y,1);
f= polyval(p,x);
hold on
plot([min(x) max(x)],[min(f) max(f)],'-r','Color',.4*[1 1 1])
%%%
display('R2 using corrcoef')
[R,p] = corrcoef(x,y,'rows','pairwise');
R2 = R(1,2).^2;
pvalue = p(1,2);
text(0,11,{['R= ' num2str(R(1,2))];['R^2= ' num2str(R2)];['p value= ' num2str(pvalue)]},'FontName',FntName,'FontSize',FtSz)
if (saveplot==1)
    savefig_withname(1,'600','png',DataSaving_dir_temp,Exp_num,Exp_letter,'Activity')
end

%% Time of Day correlation with Total time on Yeast (Head mm)
close all
saveplot=0;
FntName='arial';
FtSz=8;

TotalTimesHmm=sum(CumTimeH{1})/params.framerate/60;%min


TimesNum_cell=num2cell(TimesNum);
TimesStr=cellfun(@(x)datestr(x,'HH:MM'),TimesNum_cell,'UniformOutput',0);
UniqueTimes=unique(TimesNumNew);
YAxisTimes=UniqueTimes(1:floor(length(UniqueTimes)/5):end);
YAxisTimesIdx=nan(length(YAxisTimes),1);
for lYAxisTimes=YAxisTimes'
    YAxisTimesIdx(lYAxisTimes==YAxisTimes)=find(TimesNumNew==lYAxisTimes,1,'first');
end

figure('Position',[2100 50 1200 930],'Color','w','Name','Total time on yeast correlation time of day')
Colors_cond=Colors(length(Conditions));
lcondcounter=0;
for lcond=Conditions
    lcondcounter=lcondcounter+1;
    display(['------ ' params.LabelsShort{lcond} ' -----'])
    subplot(2,ceil(length(Conditions)/2),lcondcounter)
    x=TimesNumNew(params.ConditionIndex==lcond);
    y=TotalTimesHmm(params.ConditionIndex==lcond)';
    plot(x,y,'o',...
        'MarkerEdgeColor',[.7 .7 .7],'MarkerFaceColor',Colors_cond(lcondcounter,:));
    set(gca,'XTick',TimesNumNew(YAxisTimesIdx),'XTickLabel',TimesStr(YAxisTimesIdx),...
        'XLim',[-1 max(TimesNumNew)+1])
    font_style(params.Labels{lcond},'Time of the day (HH:MM)',...
        'Total time on Yeast -Head microm- (min)','normal',FntName,FtSz)
    
    %% Linear Regression %%
   
    p= polyfit(x,y,1);
    f= polyval(p,x);
    hold on
    plot([min(x) max(x)],[min(f) max(f)],'-r','Color',.4*[1 1 1])
    %%
    display('R2 using corrcoef')
    [R,p] = corrcoef(x,y,'rows','pairwise');
    R2 = R(1,2).^2;
    pvalue = p(1,2);
    text(0,11,{['R= ' num2str(R(1,2))];['R^2= ' num2str(R2)];['p value= ' num2str(pvalue)]},'FontName',FntName,'FontSize',FtSz)
end
if (saveplot==1)
    savefig_withname(1,'600','png',DataSaving_dir_temp,Exp_num,Exp_letter,'Activity')
end    