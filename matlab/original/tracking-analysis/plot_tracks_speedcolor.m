%% Plotting single trajectory with speed in color
save_plot=1;

Colormap_Speed=jet(255);
close all


% Rev_Presentation=Rev_Presentation+repmat([0 -250 +250],size(Rev_Presentation,1),1);
flies_idx=115;%32;
Colormap=Colors(3);%hsv(length(flies_idx));%
Spots=0;%[1,5,9,14];
FtSz=10;
FntName='arial';
xlim_=[10.7771 19.8770];%[11 16.2];%[-33 33];%
ylim_=[-17.6347 -8.5348];%[-17.2 -11.5];%[-33 33];%


figure('Position',[100 50 params.scrsz(3)-750 params.scrsz(4)-150],'Color','w','PaperUnits','centimeters',...
    'PaperPosition',[1 1 8 8],'Name',['Fig4F_Back fly ' num2str(flies_idx) ' ' date])
hold on

plotarena=1;
lflycounter=1;
for lfly=flies_idx%
%     clf
    if lfly==32, 
        range=[26455:30541];%[25455:30541];% Includes revisit
        xlim_=[10.7771 19.8770];%[11 16.2];%[-33 33];%
        ylim_=[-17.6347 -8.5348];%[-17.2 -11.5];%[-33 33];%
    elseif lfly==115, 
        range=187000:190000;
        xlim_=[-2.5 6.5999];%[11 16.2];%[-33 33];%
        ylim_=[7 16.0999];%
    end
    maxVel=2;
    Steplength_Sm_h_mm=Steplength_Sm_h{lfly}*params.framerate*params.px2mm;
    m_speed=254/(maxVel);%(max(Steplength_Sm_h_mm(range))-min(Steplength_Sm_h_mm(range)));
    b_speed=255-m_speed*maxVel;%max(Steplength_Sm_h_mm(range));
    
    range_h=range(1:end);
    plot_tracks_single(FlyDB,Heads_Sm{lfly},lfly,Spots,params,1,...
            'k',range,FtSz,0,3);
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