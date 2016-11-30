function [TSRadiiBoxplot_Subgroup,Ylabelparams,xvalues_r,numcond,num_subgroups_r]=...
    timesegmentsboxplot_radii(TimeSegmentsParams,Conditions,ranges,params,Spot_thrs,last_param)
%%
display('CALCULATING BOXPLOT OF TIMESEGMENT PARAMS RADII')
numcond=nan(length(Conditions),1);
lcondcounter=0;
for lcond=Conditions
    lcondcounter=lcondcounter+1;
    numcond(lcondcounter)=sum(params.ConditionIndex==lcond);
end

num_subgroups_r=size(ranges,1);
xvalues_r=1:num_subgroups_r*(length(Spot_thrs)+1);
xvalues_r((1:num_subgroups_r)*(length(Spot_thrs)+1))=[];

% last_param=41;
params2plot=1:9;
TSRadiiBoxplot_Subgroup=cell(size(params2plot,2),1);
Ylabelparams=cell(size(params2plot,2),1);


for lgroupparam=params2plot
    Ylabelparams{lgroupparam}=TimeSegmentsParams{1}(last_param+(lgroupparam-1)*length(Spot_thrs)+1).YLabel{1};
    TSRadiiBoxplot_Subgroup{lgroupparam}=cell(length(Conditions),1);
    
    lcondcounter=0;
    for lcond=Conditions
        lcondcounter=lcondcounter+1;
        
        
        X=nan(max(numcond),length(xvalues_r));
        
        lcolcounter=0;
        for lrange=1:size(ranges,1)
            lthrcounter=0;
            for lHThr=Spot_thrs
                lthrcounter=lthrcounter+1;
                lcolcounter=lcolcounter+1;
                
                lparam=last_param+(lgroupparam-1)*length(Spot_thrs)+lthrcounter;
                variable_rad=TimeSegmentsParams{lcond}(lparam).Data(lrange,:)';
                X(1:size(variable_rad,1),lcolcounter)=variable_rad;
            end
        end
        
        TSRadiiBoxplot_Subgroup{lgroupparam}{lcondcounter}=X;
        
    end
end
