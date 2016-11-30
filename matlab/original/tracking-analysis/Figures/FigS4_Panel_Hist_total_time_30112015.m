%% Histogram of Distance to Spots
% % load('E:\Analysis Data\Experiment 0003\Variables\TotalYHmm3A6AR1_4 30-Nov-2015.mat')
% 
Labelsmergedshort=params.LabelsShort(Conditions);%{'Virgin, AA+';'Virgin, AA-';'Mated, AA+';'Mated AA+ suboptimal';'Mated, AA-'};
% Labelsmergedshort={'Virgin, AA+ suboptimal';'Virgin, AA-';'Mated AA+ suboptimal';'Mated, AA-'};

save_plot=1;
FtSz=8;
FntName='arial';
lsubs=1;
plot_type='Bars';%'Line';%

ColorsFig2C=[84 130 53;... Green - Virgin Yaa
    0,64,255;... Blue - Virgin AA-
    179 83 181;... Orchid - Mated Yaa
    255 192 0;... Yellow - Mated Hunt
    204,0,0;... Red - Mated AA-
    ]/255;%[3,241,253;0,64,255;255 192 0;204,0,0;]/255;%EXP0004A

Max_range=50;%% min
step=5;%Max_range/8;%10;%Max_range/nbins
variable_label='Total time Hmm';
Across_flies=0;

Conditions=[2 1 3 4];%EXP8B [6 4 5 1 3];%[2 4 1 3];%EXP 4A 
orderinpaper=[2 1 3 4];%EXP 8B[6 4 5 1 3 2];%[2 4 1 3];%EXP 4A 
condtag='cond1-4';%'All cond';%'cond5 1 3';%'cond1 3';%

X_range=[0:step:Max_range inf];%

close all
x=0.1;
y=0.2;
dy=0.03;
heightsubplot=1-1.4*y;
widthsubplot=1-1.4*x;
figname=['FigS4 Hist ' variable_label ' ' params.Subs_Names{lsubs==params.Subs_Numbers} ' spots '];
figure('Position',[100 50 800 800],...
    'Color','w','Name',figname,'PaperUnits',...
            'centimeters','PaperPosition',[1 1 10 5]);
set(gca,'Position',[x y widthsubplot heightsubplot])

HistCount=zeros(size(X_range,2),length(Conditions));
newcondcolors=nan(length(Conditions),3);
lcondcounter=0;
for lcond=Conditions
    lcondcounter=lcondcounter+1;
    HistCount(:,lcondcounter)=histc(sum(CumTimeH{lsubs}(:,params.ConditionIndex==lcond))/50/60,X_range);
    newcondcolors(lcondcounter,:)=ColorsFig2C(orderinpaper==lcond,:);
end
Freq=HistCount(1:end-1,:)./repmat(nansum(HistCount(1:end-1,:)),length(X_range)-1,1);


%%% Histogram as bars
if strfind(plot_type,'Bars')
    barhandle=bar(X_range(1:end-1),Freq);
    hold on
    for lcondcounter=1:size(Freq,2)
        set(barhandle(lcondcounter),'FaceColor',newcondcolors(lcondcounter,:),...
            'LineWidth', 1,'EdgeColor',newcondcolors(lcondcounter,:));
    end
end

font_style([],['Total time ' params.Subs_Names{lsubs==params.Subs_Numbers} ' head micromovement (min)'],...params.Subs_Names{lsubs}
    'Ocurrences, normalised','normal',FntName,FtSz)%Uncomment for not subplots
legend(Labelsmergedshort)
legend('boxoff')
ylim([-.05 1])
xlim([X_range(1)-step/2 X_range(end-1)+step/2])
set(gca,'Xtick',X_range(1:end-1))%0:20:Max_range)
box off
if save_plot==1
        savefig_withname(1,'600','png',DataSaving_dir_temp,Exp_num,Exp_letter,...
            'Total times')
end


%% Histogram of Yeast Visit Durations
% save_plot=0;
% lsubs=1;
% plot_type='Bars';%'Line';%
% variable_label='Total time microm';
% Across_flies=0;
% 
% close all
% xpos=0.17;%0.45;%
% ypos=0.27;
% dy=0.03;
% heightsubplot=1-1.2*ypos;
% widthsubplot=1-1.2*xpos;
% max_vals=[120 20];
% num_bins=10;
% 
% for lcond=Conditions
%     for lsubs=1%:2
%         figure('Position',[50 50 800 800],'Color','w','PaperUnits','centimeters',...
%             'PaperPosition',[1 1 3 3.5],'Name',['Fig1F Boxplot ' params.Subs_Names{lsubs} ' Hmm Ttimes - ' params.LabelsShort{lcond}  date]);%
%         set(gca,'Position',[xpos ypos widthsubplot heightsubplot])
%         if num_bins==0,nbins=50; else nbins=num_bins; end
%         
%         if max_vals(lsubs==params.Subs_Numbers)==0,max_x=max(x_lims);else max_x=max_vals(lsubs==params.Subs_Numbers);end
%         step=max_x/(nbins-1);
%         X_range=[0:step:max_x, Inf];
%         
%         HistCount=zeros(size(X_range,2),sum(params.ConditionIndex==lcond));
%         lflycounter=0;
%         for lfly=find(params.ConditionIndex==lcond)
%             lflycounter=lflycounter+1;
%             display(lfly)
%             if ~isempty(DurInV{lfly})
%                 HistCount(:,lflycounter)=histc(DurInV{lfly}(DurInV{lfly}(:,1)==lsubs,5)/params.framerate,X_range);%Steplength_Sm{lfly}(log_vectIn)
%             end
%         end
%         
%         Freq=HistCount(1:end-1,:)./repmat(nansum(HistCount(1:end-1,:)),length(X_range)-1,1);
%         Condfr_mean=nanmean(Freq,2);
%         Condfr_stderr=nanstd(Freq,0,2)./sqrt(sum(params.ConditionIndex==lcond));
%         
%         %%% Histogram as bars
%         if strfind(plot_type,'Bars')
%             barhandle=bar(X_range(1:end-1),Condfr_mean);
%             hold on
%             set(barhandle,'FaceColor',ColorsFig2C(lcond==Conditions,:),...
%                 'LineWidth', LineW,'EdgeColor',ColorsFig2C(lcond==Conditions,:));%,'BarWidth',0.4);
%             
%             %% Adding the error bars
%             ybuff=0;
%             for i=1:length(barhandle)
%                 XDATA=get(get(barhandle(i),'Children'),'XData');
%                 YDATA=get(get(barhandle(i),'Children'),'YData');
%                 for j=1:size(XDATA,2)
%                     x=XDATA(1,j)+(XDATA(3,j)-XDATA(1,j))/2;
%                     y=YDATA(2,j)+ybuff;
%                     %             plot(x,y,'o','Color',[.5 .5 .5],'MarkerSize',3,'MarkerFaceColor',[.5 .5 .5])
%                     plot([x x],[y,...
%                         y+Condfr_stderr(j,Conditions(i)==Conditions)],'-','Color',[.5 .5 .5],'MarkerFaceColor',[.5 .5 .5],'LineWidth',.8)
%                 end
%             end
%             
%             xlim([-step/2-5 1.1*max_x])
%             ylim([-.03 1])
%         end
%         set(gca,'Xtick',0:20:120,'XTickLabel',{'0';[];'40';[];'80';[];'120'})
%         font_style([],['Visit duration (s)'],[],'normal',FntName,FtSz)%{'Occurrences';'normalised'}
%         set(gca,'tickdir','out')
%         box off
%         
%     end
% end
% if save_plot==1
%     savefig_withname(1,'600','png',DataSaving_dir_temp,Exp_num,Exp_letter,...
%         'Visits')
% end
