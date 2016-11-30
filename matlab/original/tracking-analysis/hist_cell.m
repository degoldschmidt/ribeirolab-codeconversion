function Condfr_mean=hist_cell(X_range,Cell_Var,X_Label,Y_Label,Conditions,params)
HistCount=nan(size(X_range,2),length(Cell_Var));
% VelHistCount_Out=nan(size(Vel_range,2),length(Steplength_Sm));
for lfly=1:size(Cell_Var,1)
    display(lfly)
    
    HistCount(:,lfly)=hist(Cell_Var{lfly},X_range);%Steplength_Sm{lfly}(log_vectIn)
    
end
%% Plot histogram
% close all
inact_thr=0.1;
Symbol_plot={'-o';'-o';'-o';'-o'};%{'-';'--';'-.'};
numofplots=1;

for currplot=1:numofplots%:3;%1:In,2

subplots=0;%1; %%When plotting each condition in a subplot
switch currplot
    case 1
        VelHistCount=HistCount;
        params_plot=params;
    case 2
        
    case 3
        
end

Freq=VelHistCount./repmat(nansum(VelHistCount),length(X_range),1);
Condfr_mean=nan(size(VelHistCount,1),length(unique(params_plot.ConditionIndex)));
Condfr_stderr=nan(size(VelHistCount,1),length(unique(params_plot.ConditionIndex)));

[Colormap,Cmap_patch]=Colors(length(Conditions));
if currplot==1,
    figure('Position',[100 50 params.scrsz(3)-150 params.scrsz(4)-150],'Color','w'),
    if subplots==1
        h=zeros(length(Conditions),numofplots);% 3 for inside Y, outside Y, inside A
        y_lim=nan(length(Conditions),2);
    else
        h=zeros(length(Conditions),1);
    end
end

lcondcounter=1;

for lcond=Conditions
    Condfr_mean(:,lcond)=nanmean(Freq(:,params_plot.ConditionIndex==lcond),2);
    Condfr_stderr(:,lcond)=nanstd(Freq(:,params_plot.ConditionIndex==lcond),0,2)./sqrt(sum(params_plot.ConditionIndex==lcond));
    if subplots==1
        subplot(2,ceil(length(Conditions)/2),lcondcounter)
        if currplot==3
            Colorplot=[0 0 0];
            Colorpatch=[233 233 233]/255;
        else
            Colorplot=Colormap(lcondcounter,:);
            Colorpatch=Cmap_patch(lcondcounter,:);
        end
        h(lcondcounter,currplot)=plot(X_range,Condfr_mean(:,lcond),Symbol_plot{currplot},'Color',Colorplot,...
            'LineWidth',2,'MarkerSize',3);
        
        hold on
        font_style(params.Labels{lcond},X_Label,...
        Y_Label,'bold','calibri',20)%Uncomment for subplots
    else
        Colorpatch=Cmap_patch(lcondcounter,:);
        h(lcondcounter)=plot(X_range,Condfr_mean(:,lcond),Symbol_plot{lcondcounter},...
            'Color',Colormap(lcondcounter,:),...
        'LineWidth',2,'MarkerSize',3);
        hold on
    end
    jbfill(X_range,[Condfr_mean(:,lcond)+Condfr_stderr(:,lcond)]',...
        [Condfr_mean(:,lcond)-Condfr_stderr(:,lcond)]',...
        Colorpatch,Colorpatch,0,0.5);
    
    y_lim(lcondcounter,:)=get(gca,'YLim');
    
    lcondcounter=lcondcounter+1;
end
    

if subplots==1 && currplot==numofplots
    lcondcounter=1;
    for lcond=Conditions
        subplot(2,ceil(length(Conditions)/2),lcondcounter)
        ylim([0 max(y_lim(:,2))])
%         legend(h(lcondcounter,:),{'Inside Food Spots';'Outside Food spots';'Inside Agarose Spots'})
%         axis([0 2 0 0.15])%for 40 bins axis([0 2 0 0.15])
%         plot([inact_thr inact_thr],[0 0.15],'--','Color',[0.7 0.7 0.1],'LineWidth',1)
        lcondcounter=lcondcounter+1;
    end
elseif subplots~=1
    font_style([],X_Label,Y_Label,'normal','calibri',20)%Uncomment for not subplots
    legend(h,params.LabelsShort(Conditions),'Location','Best')%Uncomment for not subplots
%     ylim([0 0.25])
%Y_axis_lim=get(gca,'YLim');
%     plot([2 2],Y_axis_lim,'--k','LineWidth',2)
    % set(gca,'XLim',[4 15],'YScale','log','YLim',[1e-3 5e-3])%0.05])
    % plot([2 2],[1e-3 0.05],'--k','LineWidth',1)
%     axis([2 30 0 0.04])%axis([0 5 0 0.015])
end
end