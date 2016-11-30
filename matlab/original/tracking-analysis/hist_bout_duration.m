function Inline=hist_bout_duration(DurIn,Conditions,params,plotting,num_bins,max_vals,...
    x_label,CondColors,FtSz,FntName,subs,subplots)
% Rank_Freq_plot concatenates all flies of one specific condition, sorts
% individual elements and plot in log log scale as Pr(Variable>x) also
% called complementary cumulative distribution plot
% max_vals vector with maximum value in the x range. If zero, the maximum
% value in range will be the maximum value in the data vector
% num_bins is the number of bins, if zero, the default is 50 bins.
% DurIn must be in frames and fps should be in as params.framerate
% Inline is a cell containing concatenated durations with n-rows=Nºsubstrates
% and m-cols=NºConditions
% plotting =1 --> Unbinned and binned distributions for each condition
% plotting =2 --> Unbinned and binned distributions for all conditions
% plotting =3 --> Rank Frequency plots for all conditions
% plotting =4 --> All previous plots
% plotting =5 --> Average histogram with standard error


if sum(nargin==(3:9))==1
    FntName='arial';subs=params.Subs_Numbers;subplots=0;
    if sum(nargin==(3:8))==1
        FtSz=14;
        if sum(nargin==(3:7))==1
            CondColors=Colors(length(unique(params.ConditionIndex)));
            if sum(nargin==(3:6))==1
                x_label='Durations';
                if sum(nargin==(3:5))==1
                    max_vals=[500 500];
                    if sum(nargin==(3:4))==1
                        num_bins=100;
                        if sum(nargin==(3:3))==1
                            plotting=4;
                        end
                    end
                end
            end
        end
    end
end

scrsz = get(0,'ScreenSize');
symbols={'s','^','*','o','v','+','o','o'};
%% Concatenated bout times vectors of all flies of the same condition
%%% Create a vector of observations for each condition by concatenating
%%% individual fly bout times (and removing the nans)
AllConditions=unique(params.ConditionIndex);
Inline=cell(length(params.Subs_Names),length(Conditions));
subcounter=0;
for lsubs=params.Subs_Numbers
    subcounter=subcounter+1;
    lcondcounter=1;
    for lcond=Conditions
        for lfly=find(params.ConditionIndex==lcond)
            clear temp
            if ~isempty(DurIn{lfly})
                Inline{subcounter, lcondcounter}=[Inline{subcounter, lcondcounter}; (DurIn{lfly}(DurIn{lfly}(:,1)==lsubs,5))/params.framerate];%s
            end
        end
        lcondcounter=lcondcounter+1;
    end
end

%% Plotting binned and unbinned distributions for each condition

%%%% Binning is adjusted per condition
if plotting==1 || plotting==4
    if num_bins==0,nbins=50; else nbins=num_bins; end
    
    for lsubcounter=params.Subs_Numbers
        figure('Position',[100 50 scrsz(3)-150 scrsz(4)-150],'Color','w',...
                'Name',['Binned and Unbinned ' params.Subs_Names{lsubcounter},...
                x_label ', Conds ' num2str(Conditions) ' ' date])
        
        hold on
        
        for lcondcounter=1:length(Conditions)
            %% Start p(eng) values, histogram
            
            subplot(2,length(Conditions),lcondcounter)
            
            step=max(Inline{lsubcounter,lcondcounter})/(nbins-1);
            [count,xbin]=hist((Inline{lsubcounter,lcondcounter}),...
                0:step:max(Inline{lsubcounter,lcondcounter}));
            count(count==0)=nan;
            parentHandle= bar(xbin,count/nansum(count),...
                'EdgeColor',CondColors(Conditions(lcondcounter)==unique(params.ConditionIndex),:),'FaceColor',CondColors(Conditions(lcondcounter)==unique(params.ConditionIndex),:),...
                'BarWidth',1,'LineWidth',1.5);
            childHandle = get(parentHandle,'Children');
            set(childHandle,'FaceAlpha',0.5); % 0 = transparent, 1 = opaque.
            xlim([-step/2 max(Inline{lsubcounter,lcondcounter})])
            font_style(params.Subs_Names{lsubcounter},[x_label ' (s)'],'Occurrences, normalised',...
                'normal',FntName,FtSz)
            
            
            %% Distribution of bout durations without binning
            subplot(2,length(Conditions),lcondcounter+length(Conditions))
            
            plot(sort(Inline{lsubs,lcondcounter},'ascend'),1:size(Inline{lsubs,lcondcounter},1),'o',...
                'MarkerEdgeColor',CondColors(Conditions(lcondcounter)==unique(params.ConditionIndex),:),...
                'MarkerFaceColor',CondColors(Conditions(lcondcounter)==unique(params.ConditionIndex),:));
            
            ylim([0 size(Inline{lsubs,lcondcounter},1)])
            xlim([-step/2 max(Inline{lsubs,lcondcounter})])
            font_style(params.LabelsShort{Conditions(lcondcounter)},[x_label ' (s)'],...
                'Nº of Occurrences',...
                'normal',FntName,FtSz)
            
        end
        
        
    end
end
%% Plotting binned and unbinned distributions for all conditions
%%%% Same Binning for all conditions
if plotting==2 || plotting==4
    if num_bins==0,nbins=50; else nbins=num_bins; end
    binfly=cell(length(params.Subs_Names),1);
    
    for lsubs=params.Subs_Numbers
        binfly{lsubs==params.Subs_Numbers}=nan(length(Conditions),1);
        
        figure('Position',[100 50 scrsz(3)-150 scrsz(4)-150],'Color','w',...
            'Name',['Binned and Unbinned ' params.Subs_Names{lsubs==params.Subs_Numbers},...
            ' ' x_label '_All, Conds ' num2str(Conditions) ' ' date])
        
        x_lims=nan(length(Conditions),1);
        h=nan(length(Conditions),1);
        numbouts=nan(length(Conditions),1);
        
        for lcondcounter=1:length(Conditions)
            x_lims(lcondcounter)=max(Inline{lsubs==params.Subs_Numbers,lcondcounter});
            numbouts(lcondcounter)=size(Inline{lsubs==params.Subs_Numbers,lcondcounter},1);
        end
        
        if max_vals(lsubs==params.Subs_Numbers)==0,max_x=max(x_lims);else max_x=max_vals(lsubs==params.Subs_Numbers);end
        step=max_x/(nbins-1);
        for lcondcounter=1:length(Conditions)
            %% Start p(eng) values, histogram
%             subplot(2,1,1)
            hold on
            [count,xbin]=hist((Inline{lsubs==params.Subs_Numbers,lcondcounter}),...
                0:step:max_x);
            count(count==0)=nan;
            h(lcondcounter)=plot(xbin,count/nansum(count),[symbols{lcondcounter} 'b'],'Color',CondColors(Conditions(lcondcounter)==unique(params.ConditionIndex),:),...
                'MarkerFaceColor',CondColors(Conditions(lcondcounter)==unique(params.ConditionIndex),:),'LineWidth',2);
            plot(xbin,count/nansum(count),...
                '-b','Color',CondColors(Conditions(lcondcounter)==unique(params.ConditionIndex),:),'LineWidth',2);
            
            %% 95% Threshold
            bins=0:max(Inline{lsubs,lcondcounter})/(1000-1):max(Inline{lsubs,lcondcounter});
            [count_th]=hist(Inline{lsubs,lcondcounter},bins);

            bout_idx=find(cumsum(count_th/sum(count_th))>0.7, 1, 'first');

            if ~isempty(bout_idx)
                binfly{lsubs}(lcondcounter)=bins(bout_idx);
                plot([bins(bout_idx) bins(bout_idx)],[0 max(count/nansum(count))],...
                '--b','Color',CondColors(Conditions(lcondcounter)==unique(params.ConditionIndex),:))
            end
            
            %% Distribution of bout durations without binning
%             subplot(2,1,2)
%             hold on
%             plot(sort(Inline{lsubs==params.Subs_Numbers,lcondcounter},'ascend'),1:size(Inline{lsubs==params.Subs_Numbers,lcondcounter},1),'o',...
%                 'MarkerEdgeColor',CondColors(Conditions(lcondcounter)==unique(params.ConditionIndex),:),'MarkerFaceColor',CondColors(Conditions(lcondcounter)==unique(params.ConditionIndex),:));
            
            
        end
%         subplot(2,1,1)
        xlim([-step/2 max_x])
        font_style(params.Subs_Names{lsubs==params.Subs_Numbers},[x_label ' (s)'],'Ocurrences, normalised',...
            'normal',FntName,FtSz)
        legend(h,params.LabelsShort(Conditions))
%         subplot(2,1,2)
%         ylim([0 max(numbouts)])
%         xlim([-step/2 max_x])
%         font_style([],[x_label ' (s)'],...
%             'Nº of Ocurrences',...
%             'normal',FntName,FtSz)
        
    end
end
%% Complementary Cumulative Distribution (RankFrequency plot as Appendix 6 of Newman,2005)
if plotting==3 || plotting ==4
%     [CondColors]=Colors(length(unique(params.ConditionIndex)));%
    if ~subplots
        figure('Position',[100 50 scrsz(3)-450 scrsz(4)-150],'Color','w',...
        'Name',['Rank Frequency plot',...
        x_label '_All, Conds ' num2str(Conditions) ' ' date])
    end
    subscounter=0;
    for lsubs=subs
        subscounter=subscounter+1;
        if ~subplots
            subplot(1,length(params.Subs_Names),subscounter)
        end
        hold on
        [ h ] = plot_rank_freq(Inline,params,lsubs,x_label,CondColors(ismember(unique(params.ConditionIndex),Conditions),:),FtSz,2);
%         legend(h,params.LabelsShort(Conditions),'Location','SouthWest')
%         legend('boxoff')
    end
    
end

%% Average histogram with error bars
if plotting==5
    plot_type='Bars';%'Line';%
    if num_bins==0,nbins=50; else nbins=num_bins; end
    for lsubs=subs
        if max_vals(lsubs==params.Subs_Numbers)==0,max_x=max(x_lims);else max_x=max_vals(lsubs==params.Subs_Numbers);end
        step=max_x/(nbins-1);
        X_range=0:step:max_x;
        figname=['Average Hist ' params.Subs_Names{lsubs==params.Subs_Numbers} ' spots, ' plot_type ', Conds ' num2str(Conditions) ' ' date];
        if ~subplots
            figure('Position',[100 50 scrsz(3)-450 scrsz(4)-150],...
                'Color','w','Name',figname);
        end
        HistCount=zeros(size(X_range,2),params.numflies);
        for lfly=1:params.numflies
            display(lfly)
            if ~isempty(DurIn{lfly})
                HistCount(:,lfly)=hist(DurIn{lfly}(DurIn{lfly}(:,1)==lsubs,5)/params.framerate,X_range);%Steplength_Sm{lfly}(log_vectIn)
            end
        end
        
        Symbol_plot={'-o';'-^';'-s';'-d'};%{'-';'--';'-.'};
        
       
        Freq=HistCount./repmat(nansum(HistCount),length(X_range),1);
        Condfr_mean=nan(size(HistCount,1),length(Conditions));
        Condfr_stderr=nan(size(HistCount,1),length(Conditions));
        
%         [CondColors]=Colors(length(unique(params.ConditionIndex)));%Colors(length(Conditions));
        
        %%% Histogram as Line
        h=zeros(length(Conditions),1);
        lcondcounter=0;
        for lcond=Conditions
            lcondcounter=lcondcounter+1;
            Condfr_mean(:,lcondcounter)=nanmean(Freq(:,params.ConditionIndex==lcond),2);
            Condfr_stderr(:,lcondcounter)=nanstd(Freq(:,params.ConditionIndex==lcond),0,2)./sqrt(sum(params.ConditionIndex==lcond));
            
            if strfind(plot_type,'Line')
                %% Mean and stderr (average across flies)
                if lcondcounter>4
                    symbol2plot='-o';
                else
                    symbol2plot=Symbol_plot{lcondcounter};
                end
                h(lcondcounter)=plot(X_range,Condfr_mean(:,lcondcounter),symbol2plot,...
                    'Color',CondColors(lcond==unique(params.ConditionIndex),:),'LineWidth',2,'MarkerSize',2,'MarkerFaceColor',CondColors(lcond==unique(params.ConditionIndex),:));
                hold on
                
                line(repmat(X_range,2,1),[Condfr_mean(:,lcondcounter)'-Condfr_stderr(:,lcondcounter)';...
                    Condfr_mean(:,lcondcounter)'+Condfr_stderr(:,lcondcounter)'],'LineWidth',1,'Color',CondColors(lcond==unique(params.ConditionIndex),:))
                %     y_lim(lcondcounter,:)=get(gca,'YLim');
                
                
                
            end
            
        end
        %%% Histogram as bars
        if strfind(plot_type,'Bars')
            barhandle=bar(X_range,Condfr_mean);
            hold on
            for lcondcounter=1:length(Conditions)
                set(barhandle(lcondcounter),'FaceColor',CondColors(Conditions(lcondcounter)==unique(params.ConditionIndex),:),...
                    'LineWidth', 1,'EdgeColor',CondColors(Conditions(lcondcounter)==unique(params.ConditionIndex),:));%,'BarWidth',0.4);
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
                        y+Condfr_stderr(j,Conditions(i)==Conditions)],'-','Color',[.5 .5 .5],'MarkerFaceColor',[.5 .5 .5],'LineWidth',.8)
                end
            end
            %     ylim([0 100])
            
                legend(params.LabelsShort{Conditions})    
                legend('boxoff')
                xlim([-step/2 1.1*max_x])
        else
            
                legend(h, params.LabelsShort{Conditions})
                xlim([-step/2 1.1*max_x])  
                legend('boxoff')
            
        end
        
        font_style(params.Subs_Names{lsubs==params.Subs_Numbers},[x_label ' (s)'],'Occurrences, normalised',...
            'normal',FntName,FtSz)
        set(gca,'tickdir','out')
    end
end
