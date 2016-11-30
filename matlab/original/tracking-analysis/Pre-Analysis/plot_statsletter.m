
%% Mann Whitney
Conditions=[1:4];
Varname='NumBouts';
    for llcond=1:length(Conditions)-1
        for lcompar=llcond+1:length(Conditions)
            lcond1=Conditions(llcond);
            lcond2=Conditions(lcompar);
            
%             p=ranksum(BoutNum(lsubstrate,params.ConditionIndex==lcond1)',...
%                 BoutNum(lsubstrate,params.ConditionIndex==lcond2)');%*length(Conditions)
%             display(['p-value ' params.LabelsShort{lcond1} ' vs ' params.LabelsShort{lcond2} ' = ' num2str(p)])
            display([num2str(lcond1) ' vs ' num2str(lcond2)])
        end
    end