if severalplots==0
%     plot_kinetic(X,frames,timerange2,lowthr,uppthr,LineW,Color(1,:));
    plot_kinetic(X,frames,timerange2,lowthr,uppthr,LineW,'k');
end
%% Axes Format
font_style(figname,x_label,var_label,'normal',FntName,FtSz)
xlim(x_lim)
y_lim=[min(X(range))-0.1*abs(min(X(range))) max(X(range))+0.1*abs(max(X(range)))];%get(gca,'YLim');
ylim(y_lim)
if plotmanual_ann_edge==1;
%     plot([timerange(1)+delta timerange(1)+delta],y_lim,'-.k',...
%         [timerange(end)-delta,timerange(end)-delta],y_lim,'-.k',...
%         'LineWidth',0.5*LineW,'Color',Color(2,:))%[192 0 0]/255)
elseif plotmanual_ann_edge==2
%     plot(timerange2(deltaf),...
%             X(frames(1)+deltaf),'oy','Color',Color(2,:),...
%             'MarkerEdgeColor',Color(2,:),'MarkerFaceColor',Color(2,:),'MarkerSize',4)
%     plot(timerange2(end-deltaf),...%fixed from beginning(framestart:lframe,1),...%with delay
%         X(frames(end)-deltaf),'oy','Color',Color(2,:),...
%         'MarkerEdgeColor','r','MarkerFaceColor','r','MarkerSize',4)
% %     quiver(timerange2(deltaf)+dx,...%start
% %         X(frames(1)+deltaf)-dy,...
% %         -dx,-dy,0,'Color',Color(2,:),'LineWidth',LineW,'MaxHeadSize',MaxHdSize)%0.3
% %     quiver(timerange2(end-deltaf)+dx,...%start
% %         X(frames(end)-deltaf)-dy,...
% %         -dx,-dy,0,'Color','r','LineWidth',LineW,'MaxHeadSize',MaxHdSize)%0.3
end
