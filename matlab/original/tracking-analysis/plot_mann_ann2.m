if severalplots==0
%     plot_kinetic(X,frames,timerange2,lowthr,uppthr,LineW,Color(1,:));
    plot_kinetic(X,frames,timerange2,lowthr,uppthr,LineW,'k');
end
%% Axes Format
font_style(figname,x_label,var_label,'normal',FntName,FtSz)
xlim(x_lim)
y_lim=[min(X(range))-0.1*abs(min(X(range))) max(X(range))+0.1*abs(max(X(range)))];%get(gca,'YLim');
ylim(y_lim)

