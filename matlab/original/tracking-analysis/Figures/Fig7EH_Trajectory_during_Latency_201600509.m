Spots=0;
FntName='arial';
FtSz=10;
range=1:params.MinimalDuration;
LineW=0.8;
colormap_segments=[204 121 167;0 0 255]/255;%[243 164 71;0 0 255]/255;
save_plot=1;
close all
Conditions=2;%2
for lcond=Conditions

    figure('Position',[2100 300 1400 400],'Color','w','PaperUnits',...
        'centimeters','PaperPosition',[1 1 19 10])
    numfliescond=sum(params.ConditionIndex==lcond);
    
    flies2plot=1%find(params.ConditionIndex==lcond);%1%
    plottime=5;%min
    flycounter=0;
    for lfly=flies2plot
        set(gcf,'Name',['Trajectory during latency + 40 min, cond ' num2str(lcond) ', fly ' num2str(lfly) ' ' date])
        clf
        latency_fly=ceil(latency_root(lfly));
        if ~isnan(latency_fly)
            range=1:latency_fly;
            nsubplots=latency_fly/(5*50*60);
            RANGES=cell(4,1);
            if nsubplots>2
                RANGES{1}=1:plottime*50*60;
                RANGES{2}=plottime*50*60+1:plottime*2*50*60;
                RANGES{3}=plottime*2*50*60+1:latency_fly;
            elseif nsubplots>1
                RANGES{1}=1:plottime*50*60;
                RANGES{2}=plottime*50*60+1:latency_fly;
                RANGES{3}=[1 1];
            else
                RANGES{1}=1:latency_fly;
                RANGES{2}=[1 1];
                RANGES{3}=[1 1];
            end
                
            if latency_fly+1+plottime*9*50*60>params.MinimalDuration
                RANGES{4}=latency_fly+1:params.MinimalDuration;
            else
                RANGES{4}=latency_fly+1:latency_fly+1+plottime*9*50*60;
            end
                %%
            for lrange=1:length(RANGES)
                subplot(1,4,lrange)
                range=RANGES{lrange};
                hc(2)=plot_tracks_single(FlyDB,Heads_Sm{lfly},lfly,Spots,params,1,...
                    'w',range,0,1,0);
                
                if lrange==length(RANGES)
                    background=[.5 .5 .5];%'k';%
                else
                    background=[.5 .5 .5];%'k';
                end
                
                etho_segments=CumTimeEnc{1}(:,lfly)';
                etho_segments(CumTimeV{1}(:,lfly)==1)=2;
                plot_traj_etho(Heads_Sm,lfly,range,etho_segments,colormap_segments,...
                    3*LineW,params)
                hc(2)=plot_tracks_single(FlyDB,Heads_Sm{lfly},lfly,Spots,params,1,...
                    background,range,0,0,LineW);
                
                
%                 font_style({['Fly Nº ' num2str(lfly) ', latency: ' num2str(ceil(latency_root(lfly)/50/60)) 'min'];...
%                     [num2str(floor(range(1)/50/60)) ' to ' num2str(ceil(range(end)/50/60)) ' min']},...
%                     [],[],'normal',FntName,FtSz)
                font_style([],...
                    [],[],'normal',FntName,FtSz)
                axis([-33 33 -33 33])
                axis off
            end
        else
            RANGES={1:plottime*50*60;plottime*50*60+1:plottime*2*50*60;...
                plottime*2*50*60+1:plottime*3*50*60;plottime*3*50*60+1:params.MinimalDuration};
            for lrange=1:length(RANGES)
                subplot(1,4,lrange)
                range=RANGES{lrange};
                hc(2)=plot_tracks_single(FlyDB,Heads_Sm{lfly},lfly,Spots,params,1,...
                    'w',range,0,1,LineW);
                etho_segments=CumTimeEnc{1}(:,lfly)';
                etho_segments(CumTimeV{1}(:,lfly)==1)=2;
                plot_traj_etho(Heads_Sm,lfly,range,etho_segments,colormap_segments,...
                    5*LineW,params)
                hc(2)=plot_tracks_single(FlyDB,Heads_Sm{lfly},lfly,Spots,params,1,...
                    'k',range,0,0,LineW/2);
%                 font_style({['Fly Nº ' num2str(lfly) ', latency: ' num2str(ceil(latency_root(lfly))) 'min'];...
%                     [num2str(floor(range(1)/50/60)) ' to ' num2str(floor(range(end)/50/60)) ' min']},...
%                     [],[],'normal',FntName,FtSz)
                font_style([],...
                    [],[],'normal',FntName,FtSz)
                axis([-33 33 -33 33])
                axis off
            end
            
        end
        
%        pause 
       if (save_plot==1)
            savefig_withname(1,'600','png',DataSaving_dir_temp,Exp_num,Exp_letter,'Latency')
            savefig_withname(0,'600','eps',DataSaving_dir_temp,Exp_num,Exp_letter,'Figures')
       end
    end
end
%% Box plot for duration of first long visit
% firstv_fr=nan(params.numflies,1);
% for lfly=1:params.numflies
% %     temp=DurInEncounter{lfly}(DurInEncounter{lfly}(:,1)==1,:);
%     temp=DurInV{lfly}(DurInV{lfly}(:,1)==1,:);
%     row=find(temp(:,5)/50>=30,1,'first');%30
%     if ~isempty(row)
%         firstv_fr(lfly)=temp(row,5)/50/60;%sec
%     end
% end
% NonEaterThr=60;%s
% save_plot=1;
% y_label={'Duration of first';'long yeast visit (min)'};%{'Lag duration';'(min)'};
% y_label_FIG='1st vlarger 30s';%'Lag duration';
% sub_folder='Parameters';
% close all
% if length(Conditions)<=3
%     x=0.47;%0.18 when ylabels are three lines, 0.13 for single line ylabels
%     paperpos=[1 1 3 4];
% else
%     x=.45;
%     paperpos=[1 1 4 4];%[1 1 5 4];
% end
% y=0.2;%0.11 when x labels are one line, 0.18 when they are tilted labels
% dy=0.03;
% heightsubplot=1-1.6*y;
% widthsubplot=1-1.1*x;
% lsubs=1;
% 
% numcond=nan(length(Conditions),1);
% lcondcounter=0;
% for lcond=Conditions
%     lcondcounter=lcondcounter+1;
%     numcond(lcondcounter)=sum(params.ConditionIndex==lcond);
% end
% figname=['Fig7IBoxplot5mm ' condtag ' ' y_label_FIG ' '];
% figure('Position',[50 50 800 800],'Color','w','PaperUnits','centimeters',...
%     'PaperPosition',paperpos,'Name',[figname date]);%
% set(gca,'Position',[x y widthsubplot heightsubplot])
% 
% hold on
% lcondcounter=0;
% X=nan(max(numcond),length(Conditions));
% for lcond=Conditions
%     lcondcounter=lcondcounter+1;
%     X(1:numcond(lcondcounter),lcondcounter)=firstv_fr(params.ConditionIndex==lcond);
% end
% 
% mediancolor=zeros(length(Conditions),3);
% IQRcolor=newcondcolors;
% [~,lineh] = plot_boxplot_tiltedlabels(X,cell(size(X,2),1),1:size(X,2),...
%     IQRcolor,mediancolor,[.4 .4 .4],.4,FtSz,FntName,'o',1);%'k'
% font_style([],[],y_label,'normal',FntName,FtSz)
% %     MergedConditions=1:length(Conditions);
% stats_boxplot_tiltedlabels(X,...
%     {y_label_FIG},Conditions,1:size(X,2),...
%     figname,0,params,...
%     DataSaving_dir_temp,Exp_num,Exp_letter,condtag,sub_folder,FtSz,FntName);
% 
% ylim([0 40])% 1.8*max(prctile(X,75))])
% xlim([0.5 (length(MergedConditions)+.5)])
% set(gca,'xcolor','w')
% 
% if save_plot==1
%     savefig_withname(1,'600','png',DataSaving_dir_temp,Exp_num,Exp_letter,...
%         sub_folder)
%     savefig_withname(0,'600','eps',DataSaving_dir_temp,Exp_num,Exp_letter,...
%         'Figures')
%     
% end

