%% Plotting single trajectory with speed in color
save_plot=1;

Colormap_Speed=jet(255);
close all


% Rev_Presentation=Rev_Presentation+repmat([0 -250 +250],size(Rev_Presentation,1),1);
flies_idx=113;%114;%32;%125;%115;%
Colormap=Colors(3);%hsv(length(flies_idx));%
Spots=0;%[1,5,9,14];
FtSz=10;
FntName='arial';



plotarena=1;
lflycounter=1;
for lfly=flies_idx%
%     clf
    if lfly==32, 
        range=[26500:30500];%80sec [26255:30755];%90sec [26455:30541];%[25455:30541];% Includes revisit
        xlim_=[10.7771 19.8770];
        ylim_=[-17.6347 -8.5348];
    elseif lfly==115, 
        range=187000:190000;
        xlim_=[-2.5 6.5999];
        ylim_=[7 16.0999];
    elseif lfly==125, 
        range=118500:122000;
        xlim_=[10 19.0999];
        ylim_=[-17 -7.9001];
    elseif lfly==114, 
    range=105000:109000;
    ylim_=[-18 -8.9001];%
    xlim_=[-17 -7.9001];%
    elseif lfly==113, 
    range=111300:115300;%105000:109000;
    ylim_=[15 24.0999];%[-18 -8.9001];%
    xlim_=[2 11.0999];%[-17 -7.9001];%
    end
    rangelabel=[num2str(range(1)) '-' num2str(range(end))];
    figure('Position',[100 50 params.scrsz(3)-750 params.scrsz(4)-150],'Color','w','PaperUnits','centimeters',...
    'PaperPosition',[1 1 6 6],'Name',['Fig4F_Black fly ' num2str(flies_idx) ' ' rangelabel ' ' date])
hold on
    maxVel=2;
    Steplength_Sm_h_mm=Steplength_Sm_h{lfly}*params.framerate*params.px2mm;
    m_speed=254/(maxVel);%(max(Steplength_Sm_h_mm(range))-min(Steplength_Sm_h_mm(range)));
    b_speed=255-m_speed*maxVel;%max(Steplength_Sm_h_mm(range));
    
    range_h=range(1:end);
    plot_tracks_single(FlyDB,Heads_Sm{lfly},lfly,Spots,params,1,...
            'k',range,FtSz,0,3.5);%3.5 for black
%     for lframe=range_h
%         speed_color=floor(m_speed*Steplength_Sm_h_mm(lframe)+b_speed);
%         if speed_color>255,speed_color=255;end
%         plot(Heads_Sm{lfly}(lframe,1)*params.px2mm,Heads_Sm{lfly}(lframe,2)*params.px2mm,'ok',...
%                 'MarkerFaceColor',Colormap_Speed(speed_color,:),...
%                 'MarkerEdgeColor',Colormap_Speed(speed_color,:),'MarkerSize',2)
%         if mod(lframe,500)==0
%             display(lframe)
%         end
%     end
    title([])
    axis([xlim_ ylim_])
%     pause
%     clf
    lflycounter=lflycounter+1;
end
% plot_tracks(FlyDB,Centroids_Sm,flies_idx,params)% Plotting trajectories, subplots: conditions
% set(gca,'Box','on')
axis off
hcb=colorbar('location','southoutside');
    set(hcb,'XTick',0:0.5:1,'XTickLabel',{'0';'1';'2'},...'XTick',[0 0.2 0.4 0.6 0.8 1],'XTickLabel',{'0';'1';'2';'3';'4';'5'},...
        'FontSize',FtSz,'FontName',FntName,'Position',[0.3 0.1 0.3 0.03])
        
figname=[params.LabelsShort{params.ConditionIndex(lfly)},...
        '; Fly Nº' num2str(lfly) ', ' num2str(range(1)) ' to ' num2str(range(end))];

if save_plot==1
    savefig_withname(1,'600','png',DataSaving_dir_temp,Exp_num,Exp_letter,...
                'Manual Ann')
    savefig_withname(0,'600','eps',DataSaving_dir_temp,Exp_num,Exp_letter,...
        'Figures')
end