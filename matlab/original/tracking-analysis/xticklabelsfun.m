function Xticklabels=xticklabelsfun(ranges)

n_rounded=nan(1,size(ranges,1));
n2_rounded=nan(1,size(ranges,1));
Xticklabels=cell(1,size(ranges,1));
for lrange=1:size(ranges,1)
    
    n=((ranges(lrange,2)-ranges(lrange,1))/2+ranges(lrange,1))/50/60;
    n2=(ranges(lrange,2))/50/60;
    n_rounded(lrange) = round(n*(10^2))/(10^2);
    n2_rounded(lrange)= round(n2*(10^2))/(10^2);
    if lrange==1
        Xticklabels{lrange}=['0 - ' num2str(n2_rounded(lrange))];
    else
        Xticklabels{lrange}=[num2str(n2_rounded(lrange-1)) ' - ' num2str(n2_rounded(lrange))];
    end
end
% xticklabels=cellfun(@num2str,num2cell(n_rounded),'UniformOutput',0);