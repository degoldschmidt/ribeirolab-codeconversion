Spots=0;
FntName='arial';
FtSz=10;
range=1:params.MinimalDuration;
LineW=0.8;

Conditions=2;
for lcond=Conditions
    numfliescond=sum(params.ConditionIndex==lcond);
    nrows=3;ncols=4;
    nfigures=ceil(numfliescond/(nrows*ncols));
    flies2plot=find(params.ConditionIndex==lcond);
    figcounter=0;
    for lfig=1:nfigures
        figcounter=figcounter+nrows*ncols;
        if figcounter>size(flies2plot,2)
            flies2plot_subset=flies2plot(figcounter-nrows*ncols+1:size(params2plot,2));
        else
            flies2plot_subset=flies2plot(figcounter-nrows*ncols+1:figcounter);
        end
        figname=['Trajectory during latency + 5 min, cond ' num2str(Conditions),...
            '-Fig' sprintf('%.2d',lfig) ' ' date];
        figure('Position',[2100 50 1400 930],'Color','w','Name',figname,'PaperUnits',...
                    'centimeters','PaperPosition',[0 0 30 20])            
        extratime=10;%min
        flycounter=0;
        for lfly=flies2plot_subset
            flycounter=flycounter+1;
            subplot(nrows,ncols,flycounter)
            latency_fly=ceil(latency_root(lfly)*50*60);
            if ~isnan(latency_fly)
                range=1:latency_fly;
                hc(2)=plot_tracks_single(FlyDB,Heads_Sm{lfly},lfly,Spots,params,1,...
                                'w',range,0,1,2*LineW);
                colormap_segments=[0 0 0 ;243 164 71]/255;
                etho_segments=CumTimeV{1}(:,lfly)'+1;%Etho_Tr(lfly,:);%
                plot_traj_etho(Heads_Sm,lfly,range,etho_segments,colormap_segments,...
                    2*LineW,params)
                hc(2)=plot_tracks_single(FlyDB,Heads_Sm{lfly},lfly,Spots,params,1,...
                    'k',range,0,0,LineW);
                if latency_fly+1+extratime*50*60>params.MinimalDuration
                    range=latency_fly+1:params.MinimalDuration;
                    extratime=(params.MinimalDuration-latency_fly+1)/50/60;%min
                else
                    range=latency_fly+1:latency_fly+1+extratime*50*60;
                end
                colormap_segments=[170 170 170;0 0 255]/255;
                etho_segments=CumTimeV{1}(:,lfly)'+1;%Etho_Tr(lfly,:);%
                plot_traj_etho(Heads_Sm,lfly,range,etho_segments,colormap_segments,...
                    2*LineW,params)
                hc(2)=plot_tracks_single(FlyDB,Heads_Sm{lfly},lfly,Spots,params,1,...
                    [170 170 170]/255,range,0,0,LineW);
                
            else
                range=1:extratime*50*60;%10 min
                                
                hc(2)=plot_tracks_single(FlyDB,Heads_Sm{lfly},lfly,Spots,params,1,...
                                'w',range,0,1,2*LineW);
                colormap_segments=[0 0 0;0 0 255]/255;
                etho_segments=CumTimeV{1}(:,lfly)'+1;%Etho_Tr(lfly,:);%
                plot_traj_etho(Heads_Sm,lfly,range,etho_segments,colormap_segments,...
                    2*LineW,params)
                hc(2)=plot_tracks_single(FlyDB,Heads_Sm{lfly},lfly,Spots,params,1,...
                    'k',range,0,0,LineW);
                
            end
            font_style({['Fly Nº ' num2str(lfly) ', latency: ' num2str(ceil(latency_root(lfly))) 'min'];...
            ['+ ' ceil(extratime) ' min']},[],[],'normal',FntName,FtSz)
            axis([-33 33 -33 33])
        end
        

    end
end