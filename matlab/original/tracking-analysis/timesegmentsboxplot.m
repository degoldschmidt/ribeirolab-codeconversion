function [TimeSegmentsBoxplot,xvalues,numcond,num_subgroups]=...
    timesegmentsboxplot(TimeSegmentsParams,Conditions,ranges,params,params2plot,fliesidx)
%%
AllConditions=unique(params.ConditionIndex);
display('CALCULATING BOXPLOT OF TIMESEGMENT PARAMS')
numcond=nan(length(Conditions),1);
lcondcounter=0;
for lcond=Conditions
    lcondcounter=lcondcounter+1;
    numcond(lcondcounter)=sum(params.ConditionIndex==lcond);
end

num_subgroups=size(ranges,1);
xvalues=1:num_subgroups*(length(Conditions)+1);
xvalues((1:num_subgroups)*(length(Conditions)+1))=[];
TimeSegmentsBoxplot=cell(length(TimeSegmentsParams{1}),1);
maxrange=nan(length(Conditions),1);
for lparam=params2plot%1:length(TimeSegmentsParams{1})
    for lcond=Conditions
        maxrange(lcond==Conditions)=size(TimeSegmentsParams{lcond==AllConditions}(lparam).Data,1);
    end
    
    X=nan(max(numcond),length(xvalues));
%     display(['parameter: ' num2str(lparam)])
    lcolcounter=0;
    for lrange=1:min(maxrange)%size(ranges,1)
        lcondcounter=0;
        for lcond=Conditions
%             display(params.LabelsShort{lcond})
            lcondcounter=lcondcounter+1;
            lcolcounter=lcolcounter+1;
            variable_cond=TimeSegmentsParams{lcond==AllConditions}(lparam).Data(lrange,fliesidx{Conditions==lcond})';
            X(1:size(variable_cond,1),lcolcounter)=variable_cond;
        end
    end
    TimeSegmentsBoxplot{lparam}=X;
end