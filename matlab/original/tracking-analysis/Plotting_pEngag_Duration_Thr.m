clf
deltaplot=1000;%frames
%%% Plotting in yellow selected engagement bout
area(engagement_frames,Engagement_p(engagement_frames,lfly),...
    'LineWidth',2,'FaceColor',[250 234 176]/255,'EdgeColor',[250 234 176]/255)
hold on
%%% Plotting engagement
if engagement_frames(1)<frames(1)
    frame1plot=engagement_frames(1);
else
    frame1plot=frames(1);
end
if engagement_frames(end)>frames(end)
    frame2plot=engagement_frames(end);
else
    frame2plot=frames(end);
end
plot(frame1plot-deltaplot:frame2plot+deltaplot,Engagement_p(frame1plot-deltaplot:frame2plot+deltaplot,lfly),'-r',...
    'LineWidth',2)

hold on
%%% Plotting start and end of annotated bout
plot([frames(1) frames(1)],[0 1],':k',...
    [frames(end) frames(end)],[0 1],':k','LineWidth',3)
%%% Plotting start and end of engagement bout
plot([engagement_frames(1) engagement_frames(1)],[0 1],'--b',...
    [engagement_frames(end) engagement_frames(end)],[0 1],'--b','LineWidth',3)

% % % % Note:To plot on top of engagement in Plottingfly32
% % % % plot([engagement_frames(1) engagement_frames(1)]/params.framerate/60,[0 0.9],'--k',...
% % % %     [engagement_frames(end) engagement_frames(end)]/params.framerate/60,[0 0.9],'--k','LineWidth',4)

xlim([frame1plot-deltaplot frame2plot+deltaplot])
font_style(['Bout ' num2str(boutnumber) ': ',...
    'Start Thr= ' num2str(lthr_start*100) ', End= ' num2str(lthr_end*100),...
    ' , Error: ' num2str(dur_err),...
    ' %'],...AUC
    'Time (frames)','p(engagement)','normal','calibri',FtSz)