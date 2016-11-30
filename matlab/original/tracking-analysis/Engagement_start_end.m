close all
for MergeThr=5%[3 4 5];%s
    
    load([Variablesfolder 'ManualAnnotation0003A 01-Dec-2014.mat'])
    
    plotmanual_ann_edge=1;
    Param_color_=Colors(4);
    
    Vartoplot='SFeedingEvents';%'Not_engage_Y';%'Revisits';%'Edge';%Yi_Yj;%Grooming;%Not_engage_Y;%
    
    Engagement_values=nan(size(ManualAnnotation.(Vartoplot),1),3);%[p(eng)_start p(eng)_end p(eng)_max]
    
    Thresh_Engagement=[0 1 5 10 25 50 75 95 99]/100;%[1 5 10]/100;%
    
    
    Correct_start=nan(length(Thresh_Engagement),size(ManualAnnotation.(Vartoplot),1));%rows:thresholds,cols: annotated bouts
    Correct_end=nan(length(Thresh_Engagement),size(ManualAnnotation.(Vartoplot),1));%rows:thresholds,cols: annotated bouts
    Duration_err=nan(length(Thresh_Engagement),length(Thresh_Engagement),size(ManualAnnotation.(Vartoplot),1));%Rows: Start thresholds, Cols: End thresholds
    %%
    Xtick_labels=cell(length(Thresh_Engagement),1);
    lthrcounter=1;
    for lthr_start=Thresh_Engagement%
        Xtick_labels{lthrcounter}=num2str(lthr_start*100);
        lthrcounter=lthrcounter+1;
    end
    FtSz=14;
    prevfly=0;
    %%fig=figure('Color','w','Position',[50 50 1000 754]);
    
    frames_range=1:params.MinimalDuration;
%     traces2plot=34%[16:18,40,42,48,39,41,43,45,1:15,44,46,47,33:35,36,19,20,22,23,21,24:26,29:31,32,27,28,37,38];%1:14;
    traces2plot=[5,12,2:4,1,9,10,13,8,7,11,14,6];
    for ltrace=ManualAnnotation.(Vartoplot)(traces2plot,1)'
        
        boutnumber=find(ManualAnnotation.(Vartoplot)(:,1)==ltrace);
        display(['------ Bout Nº' num2str(boutnumber) ' ------'])
        lfly=ManualAnnotation.(Vartoplot)(ManualAnnotation.(Vartoplot)(:,1)==ltrace,4);
        
        Geometry=FlyDB(lfly).Geometry;
        
        event_label=[Vartoplot ' - '];
        range=ltrace:ManualAnnotation.(Vartoplot)(ManualAnnotation.(Vartoplot)(:,1)==ltrace,2);
        
        insec=0;%0;
        
        timerange=(1:length(range));%s =range;%default in frames%
        x_label='Time (frames)';
        if insec==1,
            timerange=range/params.framerate;
            delta=delta/params.framerate;
            x_label='Time (s)';
        end
        frames=range;%To be the same that the dynamic plot
        timerange2=timerange;%To be the same that the dynamic plot
        x_lim=[timerange(1) timerange(end)];
        
        Spots=ManualAnnotation.(Vartoplot)(ManualAnnotation.(Vartoplot)(:,1)==ltrace,3);
        lsubs=Geometry(Spots);
        
        
        %% Calculating errors for start and end threshold
        if prevfly~=lfly
            BoutsInfo_lfly_cell=cell(length(Thresh_Engagement),length(Thresh_Engagement));
        end
        for lthr_start=Thresh_Engagement%
%             display(lthr_start)
            
            for lthr_end=Thresh_Engagement%
%                 display(lthr_end)
                %% Calculating bouts for that fly
                if prevfly~=lfly
                    
                    BoutsInfo_lfly=...
                        bouts(Engagement_p,InSpot,FlyDB,...
                        lfly,params,frames_range,lthr_start,lthr_end,MergeThr);
                    BoutsInfo_lfly_cell{lthr_start==Thresh_Engagement,...
                        lthr_end==Thresh_Engagement}=BoutsInfo_lfly;
                end
                %% Selecting the  most overlapping bout
                lboutstart1=...
                    (find(BoutsInfo_lfly_cell{lthr_start==Thresh_Engagement,...
                        lthr_end==Thresh_Engagement}.DurIn{lfly}(:,2)<=frames(1),1,'last'));
                framesbout1=BoutsInfo_lfly_cell{lthr_start==Thresh_Engagement,...
                        lthr_end==Thresh_Engagement}.DurIn{lfly}(lboutstart1,2):...
                        BoutsInfo_lfly_cell{lthr_start==Thresh_Engagement,...
                        lthr_end==Thresh_Engagement}.DurIn{lfly}(lboutstart1,3);
                overlap1=sum(ismember(frames,framesbout1));
                
                lboutstart2=(find(BoutsInfo_lfly_cell{lthr_start==Thresh_Engagement,...
                        lthr_end==Thresh_Engagement}.DurIn{lfly}(:,2)>frames(1),1,'first'));
                framesbout2=BoutsInfo_lfly_cell{lthr_start==Thresh_Engagement,...
                        lthr_end==Thresh_Engagement}.DurIn{lfly}(lboutstart2,2):...
                        BoutsInfo_lfly_cell{lthr_start==Thresh_Engagement,...
                        lthr_end==Thresh_Engagement}.DurIn{lfly}(lboutstart2,3);
                overlap2=sum(ismember(frames,framesbout2));
                
                if overlap1>overlap2
                    engagement_frames=framesbout1;
                elseif overlap1<overlap2
                    engagement_frames=framesbout2;
                elseif (overlap1==0)&&(overlap2==0)
                    engagement_frames=0;
                else
                    error('equal overlap for both bouts')
                end
                %% Calculating the error in the bout duration
                dur_err=100*((engagement_frames(end)-engagement_frames(1))-...
                    (frames(end)-frames(1)))/(frames(end)-frames(1));
                Duration_err(lthr_start==Thresh_Engagement,lthr_end==Thresh_Engagement,boutnumber)=...
                    dur_err;
                %% Plotting Area under curve
%                 fig=figure('Color','w','Position',[50 50 1000 754]);
%                 Plotting_pEngag_Duration_Thr
%                 figname=[event_label ' - Errors - ' num2str(boutnumber)];% - Mean'];
%                 %             saveplots(Dropbox_choicestrategies,'Manual Ann',figname,DataSaving_dir_temp,Exp_num,0,0)
%                 return
                
            end
            
            
            
        end
        prevfly=lfly;
    end
    
    %% Plotting Duration error for start and end thresholds
    fig=figure('Color','w','Position',[332 50 1070 780])%[2014 45 1770 930]);%[100 50 params.scrsz(3)-150 params.scrsz(4)-150]);
    
    for ltrace=traces2plot%1:length(ManualAnnotation.(Vartoplot)(:,1)')
        clf
        
            average_error=Duration_err(1:end,1:end,ltrace);
            imagesc(average_error,[-100 100]);
            colormap default
            firstword=['Bout ' num2str(ltrace)];
            figname=[event_label  'Duration errors speed 2mms- ' num2str(ltrace) ];
            textcolor=[0.4 0.4 0.4];
        
        set(gca,'YTick',1:length(Thresh_Engagement),'YTickLabel',Xtick_labels(1:end),...
            'XTick',1:length(Thresh_Engagement),'XTickLabel',Xtick_labels)%length(Thresh_Engagement)+3
        clrbar=colorbar; %get(cbar_handle,'YTick')
        
        font_style([firstword,...
            ': % Error=[(Engagement Duration)-(Actual Duration)]/(Actual Duration)'],...
            'End thresholds [%]',...
            'Start thresholds [%]','normal','calibri',FtSz)
        hold on
        for lrow=1:size(average_error,1)
            for lcol=1:size(average_error,2)
                text(lcol,lrow,num2str(floor(average_error(lrow,lcol))),...
                    'FontName','calibri','FontSize',FtSz-1,'Color',textcolor,'FontWeight','bold')
            end
        end
%         text(3,6,num2str(floor(average_error(6,3))),...
%             'FontName','calibri','FontSize',14,'Color','m','FontWeight','bold')
        
%         saveplots(Dropbox_choicestrategies,...
%             ['Manual Ann\Errors with different engagement thresholds\Merge Thr ' num2str(MergeThr) 's'],...
%             figname,DataSaving_dir_temp,Exp_num,0,0)
        print('-djpeg',[DataSaving_dir_temp Exp_num,...
            '\Plots\Manual Ann\Errors with different engagement thresholds\Merge Thr ',...
            num2str(MergeThr) 's\' figname '.jpeg'])
%             pause
    end
    %% Plotting MEAN Duration error for start and end thresholds
    if length(traces2plot)==length(ManualAnnotation.(Vartoplot)(:,1)')
        close all
        fig=figure('Color','w','Position',[332 50 1070 780])%[2014 45 1770 930]);%[100 50 params.scrsz(3)-150 params.scrsz(4)-150]);
        
        
        meanplot=1;
        
        average_error=mean(abs(Duration_err(1:end,1:end,:)),3);%
        imagesc(average_error,[0 100]);
        colormap(bone)
        firstword='Mean ';
        figname=[event_label  'Duration errors speed 2mms - Mean abs'];
        textcolor=[247 150 70]/255;
        
        set(gca,'YTick',1:length(Thresh_Engagement),'YTickLabel',Xtick_labels(1:end),...
            'XTick',1:length(Thresh_Engagement),'XTickLabel',Xtick_labels)%length(Thresh_Engagement)+3
        clrbar=colorbar; %get(cbar_handle,'YTick')
        
        font_style([firstword,...
            ': % Error=[(Engagement Duration)-(Actual Duration)]/(Actual Duration)'],...
            'End thresholds [%]',...
            'Start thresholds [%]','normal','calibri',FtSz)
        hold on
        for lrow=1:size(average_error,1)
            for lcol=1:size(average_error,2)
                text(lcol,lrow,num2str(floor(average_error(lrow,lcol))),...
                    'FontName','calibri','FontSize',FtSz-1,'Color',textcolor,'FontWeight','bold')
            end
        end
%         text(3,6,num2str(floor(average_error(6,3))),...
%             'FontName','calibri','FontSize',14,'Color','m','FontWeight','bold')
        
%         saveplots(Dropbox_choicestrategies,...
%             ['Manual Ann\Errors with different engagement thresholds\Merge Thr ' num2str(MergeThr) 's'],...
%             figname,DataSaving_dir_temp,Exp_num,0,0)
        print('-djpeg',[DataSaving_dir_temp Exp_num,...
            '\Plots\Manual Ann\Errors with different engagement thresholds\Merge Thr ',...
            num2str(MergeThr) 's\' figname '.jpeg'])
    end
    %% Plotting MEDIAN Duration error for start and end thresholds
    if length(traces2plot)==length(ManualAnnotation.(Vartoplot)(:,1)')
        close all
        fig=figure('Color','w','Position',[332 50 1070 780])%[2014 45 1770 930]);%[100 50 params.scrsz(3)-150 params.scrsz(4)-150]);
        
        
        meanplot=1;
        
        average_error=median(Duration_err(1:end,1:end,:),3);%
        imagesc(average_error,[-100 100]);
        colormap default
        firstword='Median ';
        figname=[event_label  'Duration errors speed 2mms - Median'];
        textcolor=[0.4 0.4 0.4];
        
        set(gca,'YTick',1:length(Thresh_Engagement),'YTickLabel',Xtick_labels(1:end),...
            'XTick',1:length(Thresh_Engagement),'XTickLabel',Xtick_labels)%length(Thresh_Engagement)+3
        clrbar=colorbar; %get(cbar_handle,'YTick')
        
        font_style([firstword,...
            ': % Error=[(Engagement Duration)-(Actual Duration)]/(Actual Duration)'],...
            'End thresholds [%]',...
            'Start thresholds [%]','normal','calibri',FtSz)
        hold on
        for lrow=1:size(average_error,1)
            for lcol=1:size(average_error,2)
                text(lcol,lrow,num2str(floor(average_error(lrow,lcol))),...
                    'FontName','calibri','FontSize',FtSz-1,'Color',textcolor,'FontWeight','bold')
            end
        end
%         text(3,6,num2str(floor(average_error(6,3))),...
%             'FontName','calibri','FontSize',14,'Color','m','FontWeight','bold')
        
%         saveplots(Dropbox_choicestrategies,...
%             ['Manual Ann\Errors with different engagement thresholds\Merge Thr ' num2str(MergeThr) 's'],...
%             figname,DataSaving_dir_temp,Exp_num,0,0)
        print('-djpeg',[DataSaving_dir_temp Exp_num,...
            '\Plots\Manual Ann\Errors with different engagement thresholds\Merge Thr ',...
            num2str(MergeThr) 's\' figname '.jpeg'])
    end
    %% Errors, histogram
    Error_bout=squeeze(Duration_err(6,3,:));
    fig=figure('Position',[100 43 400 930],'Color','w');
    subplot('Position',[0.2233    0.46    0.6817    0.3412])
    nbins=10;
    absolute_error=0;
    if absolute_error==1
        step=max(abs(Error_bout))/(nbins-1);
        [count,xbin]=hist(abs(Error_bout),...
            0:step:max(abs(Error_bout)));
    else
        step=(max(Error_bout)+abs(min(Error_bout)))/(nbins-1);
        [count,xbin]=hist(Error_bout,...
            min(Error_bout):step:max(Error_bout));
    end
    
    
    
    count(count==0)=nan;
    parentHandle= bar(xbin,count/nansum(count),...
        'EdgeColor','k','FaceColor','k',...
        'BarWidth',1,'LineWidth',1.5);
    childHandle = get(parentHandle,'Children');
    set(childHandle,'FaceAlpha',0.5); % 0 = transparent, 1 = opaque.
    if absolute_error==1
        xlim([0-2*step max(abs(Error_bout))+2*step])
    else
        xlim([min(Error_bout)-2*step max(Error_bout)+2*step])
    end
    font_style([],[],'Frequency',...
        'normal','calibri',16)
    set(gca,'Xtick',[],'Xticklabel',[],'box','off')
    
    
    %%% Distribution of errors without binning
    subplot('Position',[0.2233    0.1100    0.6817    0.3412])
    
    
    if absolute_error==1
        plot(sort(abs(Error_bout),'ascend'),1:size(Error_bout,1),'o',...
            'MarkerEdgeColor','k','MarkerFaceColor','k');
        xlim([0-2*step max(abs(Error_bout))+2*step])
    else
        plot(sort(Error_bout,'ascend'),1:size(Error_bout,1),'o',...
            'MarkerEdgeColor','k','MarkerFaceColor','k');
        xlim([min(Error_bout)-2*step max(Error_bout)+2*step])
    end
    ylim([0 size(Error_bout,1)])
    font_style([],'Error in duration [%]',...
        'Annotated bout',...
        'normal','calibri',16)
    set(gca,'box','off')
    figname=[event_label '- Errors_All_Start50_End5 speed 2mms'];
    saveplots(Dropbox_choicestrategies,...
            ['Manual Ann\Errors with different engagement thresholds\Merge Thr ' num2str(MergeThr) 's'],...
            figname,DataSaving_dir_temp,Exp_num,0,1)
    
end