function binfly=hist_InactDur(Inact_Dur,params,Conditions,plotting)
%binfly=hist_InactDur(Inact_Dur,params,Conditions,plotting)

if nargin==3, plotting=0;end
nbins=200;%50
maxtime=30;%5;% For Raw InterActivityIntervals
% Var_Dur=RawRevisits_Dur;
% nbins=90;maxtime=1300;%
Hist_range=0:maxtime/(nbins-1):maxtime; % Time range in s %bins=80 for Vmax=4, non-zero

HistCount_Inact=nan(size(Hist_range,2),length(Inact_Dur));
binfly=nan(size(Inact_Dur,1),1);
for lfly=1:size(Inact_Dur,1)
    display(lfly)
    HistCount_Inact(:,lfly)=hist(Inact_Dur{lfly}/params.framerate,Hist_range);
    frqs=HistCount_Inact(:,lfly)/sum(HistCount_Inact(:,lfly));
    bout_idx=find(cumsum(frqs)>0.99, 1, 'first');
    if ~isempty(bout_idx)
        binfly(lfly)=Hist_range(bout_idx);
    end
    
end

%% Plot histogram
close all
if plotting==1
    
    Freq=HistCount_Inact./repmat(nansum(HistCount_Inact),length(Hist_range),1);
    
    Condfr_mean=nan(size(HistCount_Inact,1),length(unique(params.ConditionIndex)));
    Condfr_stderr=nan(size(HistCount_Inact,1),length(unique(params.ConditionIndex)));
    
    [Colormap,Cmap_patch]=Colors(length(Conditions),1);
    
    figure('Position',[100 50 params.scrsz(3)-150 params.scrsz(4)-150],'Color','w'),
    
    subplot(2,3,[1,2,4,5])
    %% Plotting Histogram
    h=zeros(length(Conditions),1);
    
    lcondcounter=1;
    
    for lcond=Conditions
        Condfr_mean(:,lcond)=nanmean(Freq(:,params.ConditionIndex==lcond),2);
        Condfr_stderr(:,lcond)=nanstd(Freq(:,params.ConditionIndex==lcond),0,2)./sqrt(sum(params.ConditionIndex==lcond));
        Colorplot=Colormap(lcond,:);
        
        Colorpatch=Cmap_patch(lcondcounter,:);
        h(lcondcounter)=plot(Hist_range,Condfr_mean(:,lcond),'-o','Color',Colormap(lcond,:),...
            'LineWidth',2,'MarkerSize',2);
        hold on
        
        jbfill(Hist_range,[Condfr_mean(:,lcond)+Condfr_stderr(:,lcond)]',...
            [Condfr_mean(:,lcond)-Condfr_stderr(:,lcond)]',...
            Colorpatch,Colorpatch,0,0.5);
        plot([nanmean(binfly(params.ConditionIndex==lcond)),...
            nanmean(binfly(params.ConditionIndex==lcond))],...
            [0 0.3],'--','Color',Colorplot,'LineWidth',1)
        axis([0 maxtime 0 max(Condfr_mean(:,lcond))])
        lcondcounter=lcondcounter+1;
    end
    
    
    font_style([num2str(nbins) ' bins'],'Duration (s)',...
        'p(Dur of inactivity bouts)','normal','calibri',10)
    legend(h,params.LabelsShort(Conditions))%Uncomment for not subplots
    
    subplot(2,3,3)
    %% Plotting means
    plot_bar(binfly,'Average long inactivity bout duration [s]',...
        Conditions,params,1,3,9,2,'calibri')
    %% Saving images
    %     dir2savefigs=[DataSaving_dir_temp Exp_num '\Plots\Activity\'];
    %     fignameSpeed1=[dir2savefigs 'Long Inactivity Bouts'];
    % %     saveas(gcf,[fignameSpeed1 '.fig'],'fig')
    %     saveas(gcf,[fignameSpeed1 '.png'],'png')
    
end
