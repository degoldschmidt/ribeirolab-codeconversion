%% Plotting trajectories
exampleindex=23;%1:17;
if exampleindex==9
    plot_type='headetho';%'normalarrows';%'speedsingle';%
    Spots=1;
else
    plot_type='etho';%'normalarrows';%
    Spots=0;%[1,5,9,14];
end
if exampleindex==8,Spots=7;end
saveplot=0;
FtSz=8;
FntName='arial';
LineW=.5;%0.5

if ~exist('Etho_Speed_new','var')
    [Etho_Speed_new,Etho_colors_new,Etho_Colors_Labels] = Etho_Speed2New(params.MinimalDuration,Etho_Speed,1);
end

Etho_H_Speed=Etho_Speed_new;
Etho_H_Speed(Etho_H==9)=6;%YHmm
Etho_H_Speed(Etho_H==10)=7;%SHmm
EthoH_Colors=[Etho_colors_new;...
    [240 228 66]/255;%[250 244 0]/255;...%6 - Yellow (Yeast micromovement)
    0 0 0];%7 - Sucrose



if exampleindex==9
    paperpos=[1 1 4 4];
else
    paperpos=[1 1 20 20];%[1 1 9 9];
end
close all

Examples=[97 29350 31952 -27 -2 -21 7 0;...1%[fly range(1) range(end) [axeslimits]]
    3 180000 210000 -33 33 -33 33 0;...2
    119 150000 167300 -25 20 -16 15 0;...3
    97 29350 32000 -33 33 -33 33 0;...4
    32 26380 32000 11 25 -20 -10 0;...5
    8 58085 62577 -33 33 -33 33 0;...6
    114 140163 142022 -33 33 -33 33 0;...7
    8 56085 65470 -11 21 -21 12 7;...8 Fig1C Full example trajectory. plot_type='headetho';%
    8 58367 62300 6.5 13 -8 -1 1;...9 Fig1C Inset: Yeast visit. plot_type='etho';%
    89 30500 149000 -0.5 18 -20 2.5 0;...%10-8 -1 -6 14
    1 112600 115200 -15 10 -25 5 9;...%11
    97 29350 35000 -33 33 -33 33 0;...%12
    32 6000 99999 0 25 -23 5 0;...%13
    8 59367 62300 6.5 13 -8 -1 0;...%14
    11 207810 208000 -3 36 -33 1 0;...%15
    97 35899 36001 -10 -5 11 24 0;...%16
    138 244500 246000 -9 12 0 22 0;...%17
    138 244650 246000 0 22 0 22 0;...%18
    97 29650 30385 -22 0 -18 4 0;...%19
    97 30400 31952 -22 0 -22 0 0;...%20 31952
    114 140705 140760 -24 14 -15 -4 0;...%21
    3 207790 209100 -33 33 -33 33 0;...%22
    3 206900 207100 -33 33 -33 33 0];%23

Colormap=Colors(3);%hsv(length(flies_idx));%



plotarena=1;
lflycounter=0;
for lfly=Examples(exampleindex,1)'
    figure('Position',[50 50 900 900],'Color','w','PaperUnits','centimeters','PaperPosition',paperpos)%[1 1 9 9])
    hold on
    lflycounter=lflycounter+1;
    range=Examples(exampleindex(lflycounter),2):Examples(exampleindex(lflycounter),3);
    xlim_=Examples(exampleindex(lflycounter),4:5);%
    ylim_=Examples(exampleindex(lflycounter),6:7);%
    Spots=Examples(exampleindex(lflycounter),8);
    %     clf
    switch plot_type
        case 'normalarrows'
            %% Purple line for head trajetory, green line for centroid
            %%% trajectory and orientation arrows
            plot_tracks_single(FlyDB,Centroids_Sm{lfly},lfly,Spots,params,1,...
                Colormap(1,:),range,FtSz,plotarena,LineW)%[0.7 0.7 0.7]%Plotting selected flies
            range_h=range(1:3:end);
            plot_heading(Centroids_Sm{lfly},Heads_Sm{lfly},Tails_Sm{lfly},1,...
                Colormap(1,:),params,range_h,2,0.5,LineW)%2,0.09)%Colormap(3,:);%Colormap(lflycounter,:) %[0.7 0.7 0.7]
            plot_tracks_single(FlyDB,Heads_Sm{lfly},lfly,Spots,params,1,...
                Colormap(2,:),range,FtSz,0,LineW)%Plotting selected flies
            plot_tracks_single(FlyDB,Heads_Sm{lfly},lfly,Spots,params,1,...
                'k',range,FtSz,0,LineW/2)
            
            
        case 'etho'
            %% Grey line for centroid and arrows, and color-coded head line according to behaviour
%             hc(2)=plot_tracks_single(FlyDB,Centroids_Sm{lfly},lfly,Spots,params,1,...
%                 [.7 .7 .7],range,FtSz,1,2*LineW);
            colormap_segments=EthoH_Colors;%Etho_Tr_Colors;%
            etho_segments=Etho_H_Speed(lfly,:);%Etho_Tr(lfly,:);%
            plot_traj_etho(Heads_Sm,lfly,range,etho_segments,colormap_segments,...
                2*LineW,params,Centroids_Sm,Tails_Sm)
            hc(2)=plot_tracks_single(FlyDB,Heads_Sm{lfly},lfly,Spots,params,1,...
                'k',range,FtSz,0,2*LineW);%[.5 .5 .5]
            
        case 'headetho'
            hc(2)=plot_tracks_single(FlyDB,Heads_Sm{lfly},lfly,Spots,params,1,...
                'w',range,0,1,2*LineW);
            colormap_segments=EthoH_Colors;%Etho_Tr_Colors;%
            etho_segments=Etho_H_Speed(lfly,:);%Etho_Tr(lfly,:);%
            plot_traj_etho(Heads_Sm,lfly,range,etho_segments,colormap_segments,...
                2*LineW,params)
            hc(2)=plot_tracks_single(FlyDB,Heads_Sm{lfly},lfly,Spots,params,1,...
                [.5 .5 .5],range,0,0,LineW);
            
            
            
    end
    
    axis([xlim_ ylim_])
    if exampleindex==9
    startcolor=[243 164 71]/255;endcolor=[156 133 192]/255;
    %%% Markers for start and end of the visit
%     plot(Heads_Sm{lfly}(range(1),1)*params.px2mm,...%fixed from beginning(rangetart:lframe,1),...%with delay
%         Heads_Sm{lfly}(range(1),2)*params.px2mm,'og','Color',startcolor,...Color(2,:)
%         'MarkerEdgeColor',startcolor,'MarkerFaceColor',startcolor,'MarkerSize',4)%Color(2,:)
%     plot(Heads_Sm{lfly}(range(end),1)*params.px2mm,...%fixed from beginning(rangetart:lframe,1),...%with delay
%         Heads_Sm{lfly}(range(end),2)*params.px2mm,'or','Color',endcolor,...Color(2,:)
%         'MarkerEdgeColor',endcolor,'MarkerFaceColor',endcolor,'MarkerSize',4)%Color(2,:)
    else
%     text(Heads_Sm{lfly}(range(1),1)*params.px2mm,...
%         Heads_Sm{lfly}(range(1),2)*params.px2mm,'Start',...+.3{'visit';'starts'}
%         'FontWeight','normal','FontName',FntName,'FontSize',FtSz,'Color',[0.5 0.5 0.5],...
%         'HorizontalAlignment','left','VerticalAlignment','Top')
%     text(Heads_Sm{lfly}(range(end),1)*params.px2mm,...
%         Heads_Sm{lfly}(range(end),2)*params.px2mm,'End',...{'visit';'ends'}
%         'FontWeight','normal','FontName',FntName,'FontSize',FtSz,'Color',[0.5 0.5 0.5],...
%         'HorizontalAlignment','left','VerticalAlignment','Top')
    end
    if exampleindex==8, plot([10 13],[10 10],'-k','LineWidth',1); end
    if exampleindex==9, plot([7 10],[-1.5 -1.5],'-k','LineWidth',1); end
    %%% Figure Name
    figname=[params.LabelsShort{params.ConditionIndex(lfly)},...
        '; Fly Nº' num2str(lfly) ', ' num2str(range(1)) ' to ' num2str(range(end)) ' ' date];
    set(gcf,'Name',figname)
    %     pause
%         clf
    
end
% plot_tracks(FlyDB,Centroids_Sm,flies_idx,params)% Plotting trajectories, subplots: conditions

% set(gca,'Box','on')
% if exampleindex==9
    axis off
% end

if saveplot==1
    %%
    savefig_withname(0,'600','png',DataSaving_dir_temp,Exp_num,Exp_letter,...
        'Figures')
%     savefig_withname(1,'600','eps',DataSaving_dir_temp,Exp_num,Exp_letter,...
%         'Figures')
    savefig_withname(0,'600','eps',DataSaving_dir_temp,Exp_num,Exp_letter,...
        'Figures')
end