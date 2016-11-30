function [h,CumTimes_mean] = plot_Cumulative(CumTime,...
    Conditions,lsubs,MaxFrames,params,varplotting,FontSize,Fontname,Color,Color_patch)
% h = plot_Cumulative(CumTime,Conditions,lsubs)
% CumTime is a cell array with substrates as entries
% if nargin==8, [Colormap,Cmap_patch]=Colors(length(Conditions));end
    
if length(Conditions)==1
    Colormap=Color;
    Cmap_patch=Color_patch;
else
    [Colormap,Cmap_patch]=Colors(length(Conditions));
end


h=zeros(length(Conditions),1);
x=(1:MaxFrames)'/params.framerate/60;
elem2plot_idx=1:5000:MaxFrames;%params.MinimalDuration;%
for lcond=Conditions
    display(lcond)
    CumTimes=cumsum(CumTime{lsubs}(1:MaxFrames,params.ConditionIndex==lcond));
    
    CumTimes_mean=nanmean(CumTimes,2)/params.framerate/60;
    stderr=nanstd(CumTimes,0,2)./...
        sqrt(sum(params.ConditionIndex==lcond))/params.framerate/60;
    h(Conditions==lcond)=plot_line_errpatch(x(elem2plot_idx),...
        CumTimes_mean(elem2plot_idx),stderr(elem2plot_idx),...
        Colormap((Conditions==lcond),:),Cmap_patch((Conditions==lcond),:));
    
end
font_style([],'Time (min)',...
    {varplotting; ' Cumulative Time'},'normal',Fontname,FontSize)

end

