function [Freq_RV,RV_bins] = hist_RV(FlyDB,RepeatedVisits,Conditions,params)
%RVHist plots histogram without bin correction or density function with
%bin correction: Define inside the function
%   [Counts_RV] = RVHist(FlyDB,RepeatedVisits,Conditions,params)
% Inputs
% RepeatedVisits        Durations of Repeated Visits

%% Flies to Analyse
flies=1:params.numflies;
flies_idx=[];
for lcond=Conditions
    flies_idx=[flies_idx, flies(params.ConditionIndex==lcond)];
end

%% Creating matrix of repeated visits for histogram
RepVis_Dur=nan(2100,params.numflies,2);
for lfly=1:params.numflies
    filenumber=params.IndexAnalyse(lfly);
    for lsubs=[1 2]%Yeast Sucrose
        Geom=find(FlyDB(filenumber).Geometry'==lsubs)';%rows with subs
        geomcounter=1;
        for n=Geom
            clear temp
            temp=squeeze(RepeatedVisits(n,lfly,:));
            temp_log=~isnan(temp);
            RepVis_Dur(geomcounter:(geomcounter+length(temp(temp_log))-1),lfly,lsubs)=temp(temp_log);
            geomcounter=geomcounter+length(temp(temp_log));
        end
    end
end
%% Sanity Check1: Comparing Concatenated RepVis_Dur vector with Original vector
% for lcond=unique(params.ConditionIndex)
%     display(params.LabelsShort(lcond))
%     for lsubs=1:2
%         
%             if sum(sum(~isnan(RepVis_Dur(:,params.ConditionIndex==lcond,lsubs))))~=...
%                     Counts_RVEvents(lsubs,lcond)
%                 display(['WARNING: RepVis_Dur #' num2str(sum(sum(~isnan(RepVis_Dur(:,params.ConditionIndex==lcond,lsubs))))),...
%                     ' RVE events #' num2str(Counts_RVEvents(lsubs,lcond))])
%             end
%         
%      end
% end
% display('done')
%% Binning
Subs_Names={'Yeast','Sucrose'};%,'Outer Area'};
% Conditions=[1 2 5 6];%unique(params.ConditionIndex);%[1:2];%

n_bins=45;%50 and 1.19 Outer, or 60 and 1.15.
binfactor=1.1;% 1.19OuterArea, last bout~1000. %1.15;% InFood, last bout~
RV_bins=zeros(n_bins,1);
RV_bins(1)=0.02;
RV_bins(2)=7*RV_bins(1);%6*bins(1);%

for lbin=1:n_bins-2
    if lbin<10
        binfactor=1;
%     elseif lbin>=60 &&lbin<60
%         binfactor=1;
    elseif lbin>=10
        binfactor=1.2;
    end
    RV_bins(lbin+2)=RV_bins(lbin+1)+binfactor*(RV_bins(lbin+1)-RV_bins(lbin));
end
RV_bins(n_bins+1)=Inf;%Col vector
%%
%%% Linear bins
% bins=0.02:(355-0.02)/99:355; %Comment for logarithmic binning!!
% bins=[bins Inf]';%Comment for logarithmic binning!!

All_bins{1}=RV_bins';
All_bins{2}=RV_bins';
All_bins{3}=RV_bins';
% bins=(0:0.5:60);
% display(bins')
display(RV_bins(end-1))


%% Histogram of  with mean and s.e.m.
Freq_RV=cell(length(Subs_Names),1);%rows:Substrates, cols:Cond
Colormap=hsv(length(Conditions));%lines
if length(Conditions)==4
    Colormap=[255,191.25,0;0,63.75,255;255,0,0;0,255,255]/255;%[darkOrange,b,r,c];
end
scrsz = get(0,'ScreenSize');
    figure('Position',[100 50 scrsz(3)-150 scrsz(4)-150])
    
for lsubstrate=1:2%:length(Subs_Names)
    subplot(1,2,lsubstrate)
    hold on
    RV_bins=All_bins{lsubstrate};
       
    h=zeros(length(Conditions),1);
    lcondcounter=1;
    for lcond=Conditions
        clear durCount
        [durCount]= histc(RepVis_Dur(:,:,lsubstrate),RV_bins);% for individual flies
        %%%% durCount=rows:Intervals, cols:flies
        %         durFreq=durCount;%/sum(durCount);% Sum of all data points
        
        bincorrection=0; %Set 1 to correct, 0 to leave it linear.
        if bincorrection==1
            durFreq=zeros(length(RV_bins)-1,length(params.IndexAnalyse));

            %%%% Correcting for bin size and calculating frequency
            for lbin=2:length(RV_bins(1:end-1))
                %%% Empirical mass function=Countinterval/(intervallength*TotalCounts)
                durFreq(lbin-1,:)=durCount(lbin-1,:)./((RV_bins(lbin)-RV_bins(lbin-1)).*sum(durCount));
            end

            Freq_RV{lsubstrate}=durFreq;%rows:bins, cols:flies
            ylabel('Empirical Probability Density','FontWeight','bold','FontSize',16);
        elseif bincorrection==0
            Freq_RV{lsubstrate}=durCount(1:end-1,:)./repmat(sum(durCount(1:end-1,:)),size(durCount(1:end-1,:),1),1);
            ylabel('Frequency','FontWeight','bold','FontSize',16);
        end
                       
        %%
        durFreq_mean=nanmean(Freq_RV{lsubstrate}(:,params.ConditionIndex==lcond),2);
        durFreq_stderr=std(Freq_RV{lsubstrate}(:,params.ConditionIndex==lcond),0,2)/sqrt(sum(params.ConditionIndex==lcond));
        
        %%
        timebins_plot=RV_bins(1:end-1);
        h(lcondcounter)=plot(timebins_plot,durFreq_mean,'-b','Color',Colormap(lcondcounter,:),...
                    'LineWidth',3);% Histogram of yeast bouts durations, Deprived
        plot(timebins_plot,durFreq_mean,'-ob','Color',Colormap(lcondcounter,:),...
                    'LineWidth',1,'MarkerEdgeColor','k',...
            'MarkerSize',4,'MarkerFaceColor',Colormap(lcondcounter,:));
        line(repmat(timebins_plot,2,1),[durFreq_mean-durFreq_stderr,durFreq_mean+durFreq_stderr]',...
            'Color',Colormap(lcondcounter,:),'LineWidth',1);
        
        font_style([Subs_Names{lsubstrate} ', ' num2str(length(RV_bins)) ' bins'],...
            ['Repeated Visit Duration (s)'],'Frequency','bold','calibri',16)
        
%         xlim([0 30]);%([0 bins(bin_UpLimIdx+1)]);
        lcondcounter=lcondcounter+1;
    end
        legend1=legend(h,params.LabelsShort{Conditions});
        set(legend1, 'FontSize',14);
        set(gca,'FontSize',14);
    %     saveas(gcf, ['C:\Users\FaisalLab\Documents\Veronica\Data Analysis\'...
    %         'Analysis Data\Experiment 3\Plots\Plots London\Bouts\'...
    %         fig_name ' Bouts Duration LnY_Hist, ' num2str(length(bins)) ' bins'], 'tiff')
    
end

%% Finding jitter threshold
figure('Position',[100 50 scrsz(3)-150 scrsz(4)-150])
jit_thr=nan(params.numflies,1);
for lfly=flies_idx
    bin_idx=(find(cumsum(Freq_RV{lsubs}(:,lfly))>0.95,1,'first'));
    if ~isempty(bin_idx)
        jit_thr(lfly)=RV_bins(bin_idx);
    end
end
for lsubs=[1 2]
    subplot(1,2,lsubs)
    hold on
    lcondcounter=1;
    for lcond=Conditions
        lcond_log=params.ConditionIndex==lcond;
        PlottingSpreadPoints(jit_thr(lcond_log)',ones(1,sum(lcond_log))*lcondcounter)
        BoxPlot=boxplot(jit_thr(lcond_log),'colors',Colormap(lcondcounter,:),'widths',.3,...
            'outliersize',1,'positions',lcondcounter);%
        set(BoxPlot(:,:),'LineWidth',2);
        
        font_style([Subs_Names{lsubs} ' Repeated Visits'],[],'RepVisit Duration with p < 0.05, (sec)',...
            'bold','calibri',24)
        lcondcounter=lcondcounter+1;
    end
    set(gca,'XtickLabel',[])
    axis([0 lcondcounter 0 max(jit_thr)])%
    ax=axis;
    %%% Rotate x axis labels
    t=text(1:length(Conditions),ax(3)*ones(1,length(Conditions)),params.LabelsShort(Conditions));
    set(t,'HorizontalAlignment','right','VerticalAlignment','top',...
        'Rotation',45,'FontSize',20,'FontName','calibri');
    
    %%% Mann Whitney test for all possible pairs of conditions
    display(['---- Comparing jitter thresholds for' Subs_Names(lsubs)])
    for llcond_BN=1:length(Conditions)-1
        for lcomparBN=llcond_BN+1:length(Conditions)
            lcond1=Conditions(llcond_BN);
            lcond2=Conditions(lcomparBN);
            p=ranksum(jit_thr(params.ConditionIndex==lcond1),jit_thr(params.ConditionIndex==lcond2));%*length(Conditions)
            display(['p-value ' params.LabelsShort{lcond1} ' vs ' params.LabelsShort{lcond2} ' = ' num2str(p)])
        end
    end
    
    
end

