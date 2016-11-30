function wer=MeanwithPatchflyPAD(data,labels,Centers,Colors,Mean_or_Median,varargin)
hold all

if length(varargin)==1
    SFactor=varargin{1};
    
else
        SFactor=1;
    
end

    transparency=1;%.5;
 
    %% Mean
for o=1:length(data)
    
    index_of_inf_and_nans=[];
    for i=1:size(data{o},1)
        
       % find(isinf(data{o}(i,:)))
        if length(    find(isinf(data{o}(i,:))))>0 ||  length(    find(isnan(data{o}(i,:))))>0
            index_of_inf_and_nans=[index_of_inf_and_nans,i];
        end
    end
    
    if length(index_of_inf_and_nans)>0
        for qwe=1:10
            disp(['ATTENTION!!! DELETING ',num2str(length(index_of_inf_and_nans)),' data entries with NaNs or Infs'])
        end

        data{o}(index_of_inf_and_nans,:)=[];
    end
%     if Mean_or_Median==1
%         plot(Centers(1:SFactor:end),nanmean(data{o}(:,1:SFactor:end),1),'Color',Colors{o,1})
%         set(gca,'ActivePositionProperty', 'Position')
%     else
%         plot(Centers(1:SFactor:end),nanmedian(data{o}(:,1:SFactor:end),1),'Color',Colors{o,1})
%         set(gca,'ActivePositionProperty', 'Position')
%     end
end
% if length(labels{1})==0
% else
%     set(gca,'ActivePositionProperty', 'Position')
% %     wer=legend(labels);
% %     set(wer,'FontSize',7,'Location','SouthEast')
% %     legend boxoff
% end

%% Standard error
for o=1:length(data)
      
    
    edge=[1 1 1];
    add=1;
    
    % if there are nans, get the number of observations
    if length(find(isnan(data{o})==1))>0
        ObservationN=[];
        for columnN=1:size(data{o},2)
            ObservationN(columnN)=length(find(isnan(data{o}(:,columnN))==0));
            
        end
        
        if Mean_or_Median==1        
            
            upper=nanmean(data{o}(:,1:SFactor:end),1)+nanstd(data{o}(:,1:SFactor:end),0,1)./sqrt(ObservationN);
            lower=nanmean(data{o}(:,1:SFactor:end),1)-nanstd(data{o}(:,1:SFactor:end),0,1)./sqrt(ObservationN);
        else
            upper= prctile(data{o}(:,1:SFactor:end),75);% nanmedian(data{o},1)+nanstd(data{o},0,1)./sqrt(ObservationN);
            lower=prctile(data{o}(:,1:SFactor:end),25);%nanmedian(data{o},1)-nanstd(data{o},0,1)./sqrt(ObservationN);
        end
    else
        
                if Mean_or_Median==1        

        upper=nanmean(data{o}(:,1:SFactor:end),1)+nanstd(data{o}(:,1:SFactor:end),0,1)/sqrt(size(data{o},1));
        lower=nanmean(data{o}(:,1:SFactor:end),1)-nanstd(data{o}(:,1:SFactor:end),0,1)/sqrt(size(data{o},1));
                else
            upper= prctile(data{o}(:,1:SFactor:end),75);% nanmedian(data{o},1)+nanstd(data{o},0,1)./sqrt(ObservationN);
            lower=prctile(data{o}(:,1:SFactor:end),25);%nanmedian(data{o},1)-nanstd(data{o},0,1)./sqrt(ObservationN);
           
                end
    end
    Centers2=Centers(:)';
    upper=upper(:)';
    lower=lower(:)';
    jbfill_k_fig2(Centers2(1:SFactor:end),upper,lower,Colors{o,2},edge,add,transparency);
    set(gca,'ActivePositionProperty', 'Position')
end
   

for o=1:length(data)
    if Mean_or_Median==1
        plot(Centers(1:SFactor:end),nanmean(data{o}(:,1:SFactor:end),1),'Color',Colors{o,1},...
            'LineWidth',.8)
        set(gca,'ActivePositionProperty', 'Position')
    else
        plot(Centers(1:SFactor:end),nanmedian(data{o}(:,1:SFactor:end),1),'Color',Colors{o,1},...
            'LineWidth',.8)
        set(gca,'ActivePositionProperty', 'Position')
    end
end
% task_14_apply_axes_parameters

% figure;hold all
% plot(Centers,upper)
% plot(Centers,lower)

% for o=1:length(data)
%     plot(Centers,mean(data{o,1},1),'Color',Colors{o})
% end

%function[fillhandle,msg]=jbfill_k(xpoints,upper,lower,color,edge,add,transparency)
%USAGE: [fillhandle,msg]=jbfill(xpoints,upper,lower,color,edge,add,transparency)
%This function will fill a region with a color between the two vectors provided
%using the Matlab fill command.
%
%fillhandle is the returned handle to the filled region in the plot.
%xpoints= The horizontal data points (ie frequencies). Note length(Upper)
%         must equal Length(lower)and must equal length(xpoints)!
%upper = the upper curve values (data can be less than lower)
%lower = the lower curve values (data can be more than upper)
%color = the color of the filled area
%edge  = the color around the edge of the filled area
%add   = a flag to add to the current plot or make a new one.
%transparency is a value ranging from 1 for opaque to 0 for invisible for
%the filled color only.
