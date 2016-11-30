Spots=0;
FntName='arial';
FtSz=10;
range=1:params.MinimalDuration;
LineW=0.8;
colormap_segments=[204 121 167;0 0 255]/255;%[243 164 71;0 0 255]/255;
save_plot=1;
close all
Conditions=1;%2
for lcond=Conditions

    figure('Position',[2100 300 1400 400],'Color','w','PaperUnits',...
        'centimeters','PaperPosition',[1 1 19 10])
    numfliescond=sum(params.ConditionIndex==lcond);
    
    flies2plot=14;%find(params.ConditionIndex==lcond);%1%
    plottime=5;%min
    flycounter=0;
    for lfly=flies2plot
        set(gcf,'Name',['Trajectory during latency + 40 min, cond ' num2str(lcond) ', fly ' num2str(lfly) ' ' date])
        clf
        latency_fly=ceil(latency_root(lfly));
        if ~isnan(latency_fly)
            if lfly~=14
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
            else
                RANGES{1}=1:latency_fly;
                RANGES{2}=latency_fly+1:10*50*60;
                RANGES{3}=10*50*60:23*50*60;
                RANGES{4}=23*50*60:23*50*60+plottime*9*50*60;
            end
            %%
                %%
            for lrange=1:length(RANGES)
                subplot(1,4,lrange)
                range=RANGES{lrange};
                hc(2)=plot_tracks_single(FlyDB,Heads_Sm{lfly},lfly,Spots,params,1,...
                    'w',range,0,1,0);
                
                if lrange>1%==length(RANGES)
                    background=[.5 .5 .5];%'k';%[.5 .5 .5];
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
%                     [num2str((range(1)/50/60),'%.3g') ' to ' num2str((range(end)/50/60),'%.3g') ' min']},...
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

