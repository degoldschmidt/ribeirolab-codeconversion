%% Plotting trajectories
saveplot=1;
subfolder='Manual Ann';
exampleindex=[4 5 6];%4
FtSz=8;
FntName='arial';
LineW=1.5;

% if ~exist('Etho_Speed_new','var')
%     [Etho_Speed_new,Etho_colors_new,Etho_Colors_Labels] = Etho_Speed2New(params.MinimalDuration,Etho_Speed,1);
% end
% 
% Etho_H_Speed=Etho_Speed_new;
% Etho_H_Speed(Etho_H==9)=6;%YHmm
% Etho_H_Speed(Etho_H==10)=7;%SHmm
% EthoH_Colors=[Etho_colors_new;...
%     [250 244 0]/255;...%6 - Yellow (Yeast micromovement)
%     0 0 0];%7 - Sucrose
if ~exist('Etho_Tr2','var')
    [~,Etho_Tr2,Etho_Tr_Colors2]=TransitionProb2(DurInV,Heads_Sm,FlyDB,params);
    EthoH_Colors=Etho_Tr_Colors2;
end

close all
delta=27.9;
Examples=[89 30500 149000 -0.5 18 -20 2.5 0 0 0;...1%[fly range(1) range(end) [axeslimits]]
    84 75000 120000 -33 33 -33 33 0 0 0;...
    126 100*50*60 120*50*60 -33 33 -33 33 0 0 0;...
    72 31.1*50*60 102700 -5.51 -5.51+delta -20.8 -20.8+delta 1 7 14;...
    138 244400 82*50*60 -20.48 -20.48+delta -6.28 -6.28+delta 3 16 0;...
    89 31500 120000 -5.07 -5.07+delta -20.74 -20.74+delta 1 7 0];%-8 -1 -6 14

Colormap=Colors(3);%hsv(length(flies_idx));%
Spots=0;%[1,5,9,14];


plotarena=1;
lflycounter=0;
for lfly=Examples(exampleindex,1)'
    lflycounter=lflycounter+1;
    
    figure('Position',[50 50 900 900],'Color','w','PaperUnits','centimeters','PaperPosition',[1 1 3 3])%[1 1 9 9])
    hold on
    
    range=Examples(exampleindex(lflycounter),2):Examples(exampleindex(lflycounter),3);
    xlim_=Examples(exampleindex(lflycounter),4:5);%
    ylim_=Examples(exampleindex(lflycounter),6:7);%
    Spots=Examples(exampleindex(lflycounter),8:end);
    %     clf
    %% Grey line for centroid and arrows, and color-coded head line according to behaviour
    hc(2)=plot_tracks_single(FlyDB,Heads_Sm{lfly},lfly,Spots,params,1,...
        [.7 .7 .7],range,FtSz,1,0);
    colormap_segments=EthoH_Colors;%Etho_Tr_Colors;%
    etho_segments=Etho_Tr2(lfly,:);%Etho_H_Speed(lfly,:);%Etho_Tr(lfly,:);%
    plot_traj_etho(Heads_Sm,lfly,range,etho_segments,colormap_segments,...
        LineW,params,Centroids_Sm)
%     hc(2)=plot_tracks_single(FlyDB,Heads_Sm{lfly},lfly,Spots,params,1,...
%         [.5 .5 .5],range,FtSz,0,0.5);
            
   axis([xlim_ ylim_])
       
    
    %%% Figure Name
    figname=[params.LabelsShort{params.ConditionIndex(lfly)},...
        '; Fly Nº' num2str(lfly) ', ' num2str(range(1)) ' to ' num2str(range(end))];
    set(gcf,'Name',figname)
    %     pause
    %     clf
    axis off
    title([])
end
% plot_tracks(FlyDB,Centroids_Sm,flies_idx,params)% Plotting trajectories, subplots: conditions
% set(gca,'Box','on')



if saveplot==1
    savefig_withname(1,'600','png',DataSaving_dir_temp,Exp_num,Exp_letter,...
        subfolder)
    savefig_withname(0,'600','eps',DataSaving_dir_temp,Exp_num,Exp_letter,...
        'Figures')
end