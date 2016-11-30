function [Counts_Cond,binfly]=hist_boutlength(Var2plot,plotting,Conditions,params)
%   BoutLengthHist_single generates histogram of bout durations for all the
%   substrates specified in params.Subs_Names
%   Inputs:
%   times           = [times, flies, subs] each entry are the times for
%                     that fly in that condition and that substrate.
%
%   Outputs:
%   Counts_Cond     = cell array, rows: substrate, cols: cond
%   bins            = in seconds

Freq_Cond=cell(size(Var2plot,1),1);
Counts_Cond=cell(size(Var2plot,1),1);%rows:Substrates
Colormap=Colors(length(Conditions));%lines

%% BINS
n_bins=40;%45;%50 and 1.19 Outer, or 60 and 1.15. %40 and 1.1
binfactor=1.1;% 1.19OuterArea, last bout~1000. %1.15;% InFood, last bout~
bins=zeros(n_bins,1);
bins(1)=0.02;
bins(2)=7*bins(1);%7*bins(1);%6*bins(1);%
bins(1:5)=0.02:(5-0.02)/4:5;
for lbin=3:n_bins-2
    if lbin<10
        binfactor=1;%1
        %     elseif lbin>=60 &&lbin<60
        %         binfactor=1;
    elseif lbin>=10
        binfactor=1.15;%1.2;
    end
    bins(lbin+2)=bins(lbin+1)+binfactor*(bins(lbin+1)-bins(lbin));
end
bins(n_bins+1)=Inf;%Col vector

%%% Linear bins
% lastbin=100;
% num_bins=50;
% bins=0.02:(lastbin-0.02)/(num_bins-1):lastbin; %Comment for logarithmic binning!!
% bins=[bins Inf]';%Comment for logarithmic binning!!

All_bins{1}=bins';
All_bins{2}=bins';
All_bins{3}=bins';
% bins=(0:0.5:60);
% display(bins')
display(bins(end-1))

%% Bouts Histogram

for lsubstrate=1:size(Var2plot,1)
    if plotting==1
        scrsz = get(0,'ScreenSize');
        figure('Position',[100 50 scrsz(3)-150 scrsz(4)-150],'Color','w')
        hold on
    end
    bins=All_bins{lsubstrate};
    %     figure('Position',[100 50 scrsz(3)-450 scrsz(4)-150]);
    %     hold on
    
    h=zeros(length(Conditions),1);
    lcondcounter=1;
    
    durCount=nan(length(bins),size(Var2plot{lsubstrate},1));
    for lfly=1:size(Var2plot{lsubstrate},1)
        if ~isempty(Var2plot{lsubstrate}{lfly})
            [durCount(:,lfly)]= histc(Var2plot{lsubstrate}{lfly},bins);% for individual flies
            %%%% durCount=rows:Intervals, cols:flies
            %         durFreq=durCount;%/sum(durCount);% Sum of all data points
        end
    end
    bincorrection=0; %Set 1 to correct, 0 to leave it linear.
    if bincorrection==1
        durFreq=zeros(length(bins)-1,size(Var2plot{lsubstrate},1));
        
        %%%% Correcting for bin size and calculating frequency
        for lbin=2:length(bins(1:end-1))
            %%% Empirical mass function=Countinterval/(intervallength*TotalCounts)
            durFreq(lbin-1,:)=durCount(lbin-1,:)./((bins(lbin)-bins(lbin-1)).*sum(durCount));
        end
        
        Freq_Cond{lsubstrate}=durFreq;%rows:bins, cols:flies
        
    elseif bincorrection==0
        Counts_Cond{lsubstrate}=durCount(1:end-1,:);
        Freq_Cond{lsubstrate}=durCount(1:end-1,:)./repmat(sum(durCount(1:end-1,:)),size(durCount(1:end-1,:),1),1);
        
    end
    
    for lcond=Conditions
        %%
        if plotting==1
            durFreq_mean=nanmean(Freq_Cond{lsubstrate}(:,params.ConditionIndex==lcond),2);
            durFreq_stderr=nanstd(Freq_Cond{lsubstrate}(:,params.ConditionIndex==lcond),0,2)/sqrt(sum(params.ConditionIndex==lcond));
            %%
            timebins_plot=bins(1:end-1);%/60;
            h(lcondcounter)=plot(timebins_plot,durFreq_mean,'-b','Color',Colormap(lcondcounter,:),...
                'LineWidth',3);% Histogram of yeast bouts durations, Deprived
            plot(timebins_plot,durFreq_mean,'-ob','Color',Colormap(lcondcounter,:),...
                'LineWidth',1,'MarkerEdgeColor','k',...
                'MarkerSize',4,'MarkerFaceColor',Colormap(lcondcounter,:));
            line(repmat(timebins_plot,2,1),[durFreq_mean-durFreq_stderr,durFreq_mean+durFreq_stderr]',...
                'Color',Colormap(lcondcounter,:),'LineWidth',1);
            
            
            %% Dividing for boxplots
            plot(timebins_plot([7 15]),durFreq_mean([7 15]),'ok',...
                'MarkerSize',3,...
                'MarkerFaceColor','k');% Dividing edges for boxplots
            
            xlabel([params.Subs_Names{lsubstrate} ' Bout Duration (s)'],'FontWeight','bold','FontSize',16)
            
            title([num2str(length(bins)) ' bins'],'FontWeight','bold','FontSize',16);
            set(gca,'FontSize',16);%,'YScale','log','XScale','log');%
            %         xlim([0 30]);%([0 bins(bin_UpLimIdx+1)]);
            
        end
        lcondcounter=lcondcounter+1;
    end
    if plotting==1
        if bincorrection==1
            ylabel('Empirical Probability Density','FontWeight','bold','FontSize',16);
        elseif bincorrection==0
            ylabel('Frequency','FontWeight','bold','FontSize',16);
        end
        legend1=legend(h,params.LabelsShort{Conditions});
        set(legend1, 'FontSize',14);
        set(gca,'FontSize',14);
        %         plot([min(timebins_plot) max(timebins_plot)],[0.05 0.05],'--b','LineWidth',2)
        %         text(1,0.04,' \uparrow p = 0.05','Color','b',...
        %                             'FontWeight','bold','FontSize',16);
        %         plot([min(timebins_plot) max(timebins_plot)],[0.01 0.01],'--k','LineWidth',2)
        %         text(1,0.005,' \uparrow p = 0.01','Color','b',...
        %                             'FontWeight','bold','FontSize',16);
        
        %     saveas(gcf, ['C:\Users\FaisalLab\Documents\Veronica\Data Analysis\'...
        %         'Analysis Data\Experiment 3\Plots\Plots London\Bouts\'...
        %         fig_name ' Bouts Duration LnY_Hist, ' num2str(length(bins)) ' bins'], 'tiff')
    end
end
[binfly] = LongBout_fly;

    function [binfly] = LongBout_fly
        %LongBout_fly generates a cell array with #entries=#substrates, each one
        %with a row vector carrying the first bout with p<0.05 (first <0.95 in the
        %cumulative probability) per fly.
        % [binfly] = LongBout_fly(Counts_Cond,bins,params.Subs_Names,params)
        
        % binfly=cell(length(params.Subs_Names),1);
        binfly=cell(size(Var2plot,1),1);
        for lsubs=1:size(Var2plot,1)%length(params.Subs_Names)
            binfly{lsubs}=nan(1,params.numflies);
            for llfly=1:params.numflies
                if ~isempty(Var2plot{lsubs}{llfly})
                    range=0:max(Var2plot{lsubs}{llfly})/999:max(Var2plot{lsubs}{llfly});
                    [counts,bins_x]=hist(Var2plot{lsubs}{llfly},range);
                    bout_idx=find(cumsum(counts/sum(counts))>0.95, 1, 'first');
                    if ~isempty(bout_idx)
                        binfly{lsubs}(llfly)=bins_x(bout_idx);
                    end
                end
            end
        end
    end
end



