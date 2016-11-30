function varargout=BoxplotPASHAfun(Events,UserFunction,UserString,labels,Centers,Colors,BoxPlotYN,Substrate,varargin)
nCond=unique(cell2mat(cellfun(@unique,Events.Condition,'UniformOutput',false )));
nCond=nCond(~isnan(nCond));
%
varargout{1}=nan;
if numel(strmatch(func2str(UserFunction),'hist'))>0
    %% Find how many conditions were present
    for nRows=1:size(Events.(UserString),1)
        day=nRows;
        % get number of events per condition
        for C=1:numel(nCond)
            AAA=Events.(UserString)(day,Events.Substrate{day}==1&Events.Condition{day}==nCond(C));
            bins=AAA;
            for kuku=1:size(AAA,2)
                bins{kuku}=varargin{1};
            end
            C1N{nRows,C}=cellfun(UserFunction,Events.(UserString)(day,Events.Substrate{day}==1&Events.Condition{day}==nCond(C)),bins,'UniformOutput',false);
            C2N{nRows,C}=cellfun(UserFunction,Events.(UserString)(day,Events.Substrate{day}==2&Events.Condition{day}==nCond(C)),bins,'UniformOutput',false);
        end
    end
    
    %% Collapse different runs
    for n=1:size(C1N,2)
        CSubstr1N{n}=[C1N{:,n}];
    end
    
    for n=1:size(C2N,2)
        CSubstr2N{n}=[C2N{:,n}];
    end
    
    
    %%
    N2N=cellfun(@numel,CSubstr2N);
    N1N=cellfun(@numel,CSubstr1N);
    
    
    for n=1:size(CSubstr2N,2)
        for x=1:size(CSubstr2N{1,n},2)
            MatrSubstr2{1,n}(x,:)=CSubstr2N{1,n}{1,x};
        end
    end
    
    for n=1:size(CSubstr1N,2)
        for x=1:size(CSubstr1N{1,n},2)
            MatrSubstr1{1,n}(x,:)=CSubstr1N{1,n}{1,x};
        end
    end
    
    
    if Substrate==1
        
        task_14_define_parameters_for_plotting
        task_14_shaded_plot_jbfill_WithIRQ(MatrSubstr1,labels,Centers,Colors,1)
        xlabel('Time, (s)')
        
        title(Events.SubstrateLabel{1})
        legend(Events.ConditionLabel)
        axis tight
        
    elseif Substrate==2
        
        task_14_define_parameters_for_plotting
        task_14_shaded_plot_jbfill_WithIRQ(MatrSubstr2,labels,Centers,Colors,1)
        xlabel('Time, (s)')
        
        title(Events.SubstrateLabel{2})
        legend(Events.ConditionLabel)
        axis tight
        
    end
    elseif numel(strmatch(func2str(UserFunction),'xcorr'))>0
    
    %% Xcorrs
    %% Find how many conditions were present
    nCond=unique(cell2mat(cellfun(@unique,Events.Condition,'UniformOutput',false )));
    nCond=nCond(~isnan(nCond));
    BinaryArray=MakeBinaryCellArray(Events.(UserString),varargin);
    for nRows=1:size(Events.(UserString),1)
        day=nRows;
        % get number of events per condition
        for C=1:numel(nCond)
            AAA=Events.(UserString)(day,Events.Substrate{day}==1&Events.Condition{day}==nCond(C));
            bins=AAA;
            sizeShit=numel(BinaryArray(day,Events.Substrate{day}==1&Events.Condition{day}==nCond(C)));
            if sizeShit>0
                for kuku=1:sizeShit
                    bins{kuku}=varargin{2}(end);
                    OptionsNorm{kuku}='coeff';
                end
                C1N{nRows,C}=cellfun(UserFunction,BinaryArray(day,Events.Substrate{day}==1&Events.Condition{day}==nCond(C)),bins,OptionsNorm,'UniformOutput',false);
                C2N{nRows,C}=cellfun(UserFunction,BinaryArray(day,Events.Substrate{day}==2&Events.Condition{day}==nCond(C)),bins,OptionsNorm,'UniformOutput',false);
                %if there are no elements in the   some cells of the
                %BinaryArray the result is strange
                clear bins OptionsNorm
            else
                bins={};
                OptionsNorm={};
                C1N{nRows,C}=[];
                C2N{nRows,C}=[];
            end
            
        end
    end
    %% clean up, remove the
    Lags=varargin{2};
    
    for x=1:size(C1N,1)
        for y=1:size(C1N,2)
            XXX=C1N{x,y};
            for n=1:max(size(XXX))
                if isnan(sum(XXX{n}))
                    C1N{x,y}{1,n}=nan(size(Lags));
                end
            end
        end
    end   
    
    for x=1:size(C2N,1)
        for y=1:size(C2N,2)
            XXX=C2N{x,y};
            for n=1:max(size(XXX))
                if isnan(sum(XXX{n}))
                    C2N{x,y}{1,n}=nan(size(Lags));
                end
            end
        end
    end   
    
    %%
    % Collapse different runs
    for n=1:size(C1N,2)
        CSubstr1N{n}=[C1N{:,n}];
    end
    
    for n=1:size(C2N,2)
        CSubstr2N{n}=[C2N{:,n}];
    end  
    %
    N2N=cellfun(@numel,CSubstr2N);
    N1N=cellfun(@numel,CSubstr1N);
    
    for n=1:size(CSubstr2N,2)
        for x=1:size(CSubstr2N{1,n},2)
            MatrSubstr2{1,n}(x,:)=CSubstr2N{1,n}{1,x};
        end
    end
    
    for n=1:size(CSubstr1N,2)
        for x=1:size(CSubstr1N{1,n},2)
            MatrSubstr1{1,n}(x,:)=CSubstr1N{1,n}{1,x};
        end
    end
    
    task_14_shaded_plot_jbfill_WithIRQ(MatrSubstr2,labels,Centers,Colors,1)
    xlabel('Time, (s)')
    legend(labels)
    axis tight    
    
    %% end of Xcorrs
    elseif numel(strmatch(func2str(UserFunction),'FeedingDensity'))>0

        for nRows=1:size(Events.(UserString),1)
            day=nRows;
            % get number of events per condition
            for C=1:numel(nCond)
                C2N{nRows,C}=cellfun(UserFunction,Events.RMSEventsDurs(day,Events.Substrate{day}==Substrate&Events.Condition{day}==nCond(C)),Events.(UserString)(day,Events.Substrate{day}==Substrate&Events.Condition{day}==nCond(C)),'UniformOutput',false);
            end
        end

    for n=1:size(C2N,2)
        CSubstr2N{n}=[C2N{:,n}];
    end
    
    N2N=cellfun(@numel,CSubstr2N);
    MM2N=nan(size(CSubstr2N,2),max(cellfun(@numel,CSubstr2N)));
     
    for n =1:size(CSubstr2N,2)
        MM2N(n,1:N2N(n))=cellfun(@median,CSubstr2N{1,n});
    end
    
%% box plot 
    
   [p2,table,stats] =kruskalwallis(MM2N',Events.ConditionLabel,'off');
    varargout{1}=pairwise_comparisons(MM2N,0);

if BoxPlotYN==0
    Median_CI_PLot(MM2N',labels)%,'outliersize',0.5,'Color',[0 0 0])
else
     boxplot(MM2N',labels,'outliersize',0.5,'Color',[0 0 0])
end
     set(gca,'ActivePositionProperty', 'Position')

else
 
    for nRows=1:size(Events.(UserString),1)
        % get number of events per condition
        for C=nCond
            C2N{nRows,C}=cellfun(UserFunction,Events.(UserString)(nRows,Events.Substrate{nRows}==Substrate&Events.Condition{nRows}==nCond(C)));
        end
    end
    
    for n=1:size(C2N,2)
        CSubstr2N{n}=[C2N{:,n}];
    end
    
    N2N=cellfun(@numel,CSubstr2N);
    MM2N=nan(size(CSubstr2N,2),max(cellfun(@numel,CSubstr2N)));
    
    for n =1:size(CSubstr2N,2)
        MM2N(n,1:N2N(n))=[CSubstr2N{1,n}];
    end
 try
    varargout{1}=pairwise_comparisons(MM2N,0);
 catch
     varargout{1}=nan;
 end
    varargout{2}=MM2N';
      
if BoxPlotYN==0
Median_CI_PLot(MM2N',labels)%,'outliersize',0.5,'Color',[0 0 0])
elseif BoxPlotYN==1
     boxplot(MM2N',labels,'outliersize',0.5,'Color',[0 0 0])%,'colors',[0.9 0.9 09])%,'widths',0.3)
     
     hold on
     plotSpread(MM2N','distributionColors','k')%,'colors',[0.9 0.9 09])%,'widths',0.3)
elseif BoxPlotYN==2
    Col_vector_temp=MM2N';
    plot_boxplot_Fig2(Col_vector_temp,labels,[1:size(Col_vector_temp,2)],...
        Colors,zeros(size(Col_vector_temp,2),3),...
        'k',.4,8,'Arial','.');%[.5 .5 .5]
%     TiltedBoxPlot(Col_vector_temp,labels)  
    
%     jitter=0.25;
%     Col_vector_temp=MM2N';
%     for lcol=1:size(Col_vector_temp,2)
%         Col_vector=Col_vector_temp(:,lcol);
%         fillhandle=fill([repmat(lcol-jitter/2,2,1);...
%                         repmat(lcol+jitter/2,2,1)],...
%             [prctile(Col_vector,25);...
%             repmat(prctile(Col_vector,75),2,1);...
%             prctile(Col_vector,25)],...
%             [.6 .6 .6]);%plot the data
%         set(fillhandle,'EdgeColor','k','FaceAlpha',.2,...
%             'LineWidth',1,'EdgeAlpha',.2);%set edge color
%         hold on
%         plot([lcol-jitter-.01*jitter;lcol+jitter+.01*jitter],...
%             repmat(nanmedian(Col_vector),2,1),...
%             'Color','k','LineWidth',2)
%     end
%     plotSpread(MM2N','distributionColors','k')
%     
%     set(gca,'XTick',[],'XTickLabel',[])
%     ax=get(gca,'Ylim');
%     %%% Rotate x axis labels
%     t=text(1:length(labels),ax(1)*ones(1,length(labels)),labels);
%     set(t,'HorizontalAlignment','right','VerticalAlignment','top',...
%         'Rotation',20);%,'FontSize',FontSz-1,'FontName',fontName);
%     xlim([0.5 size(Col_vector_temp,2)+0.5])
end
     set(gca,'ActivePositionProperty', 'Position')
end
 

