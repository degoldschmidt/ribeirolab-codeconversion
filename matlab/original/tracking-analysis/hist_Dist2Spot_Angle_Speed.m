MaxRad=4;%4.8;%mm
histparams.paramname='Polar';
histparams.X_range=-180:2*180/49:180;%0:120/149:120;%0:120/149:120;%-pi:2*pi/149:pi;% %Theta range in degrees
histparams.Y_range=0:MaxRad/49:MaxRad;%params.OuterRingRadious:(66/2-params.OuterRingRadious)/99:66/2;% Radious range in mm
histparams.xlabel='\theta, Angle [º]';%


%% 2D - Histogram
VarHist=cell(length(params.Subs_Names),1);
Dist2SpotCell=cell(length(params.Subs_Names),1);
peak_FeedRad=[0 2.5;0 2.5;0 2.5;0 2.5];%[0 2.1;0 2.1250;0 1.8;0 2.1250];%[1.65 2.1;1.6750 2.1250;1.35 1.8;1.6750 2.1250];
SpeedCell=cell(length(params.Subs_Names),1);
for lsubs=1:length(params.Subs_Names)
    VarHist{lsubs}=zeros(length(histparams.Y_range),length(histparams.X_range),length(flies_idx));
    Dist2SpotCell{lsubs}=cell(size(Steplength_Sm_c));
    SpeedCell{lsubs}=cell(size(Steplength_Sm_c));
end
for lfly=flies_idx
    for lsubs=1:length(params.Subs_Names)
        Dist2SpotCell{lsubs}{lfly}=[];
        SpeedCell{lsubs}{lfly}=[];
        %         AllSpots=find(FlyDB(lfly).Geometry==lsubs);
        f_spot=FlyDB(lfly).WellPos(FlyDB(lfly).Geometry==lsubs,:);%FlyDB(lfly).WellPos(AllSpots(AllSpots<=6),:);%Yeast spots
        %     f_spot=f_spot([1 3 5 7 9 11 14 16 18],:);%Yeast([2 4 6 8 10 12 13 15 17],:);%Sucrose positions
        counts_temp=zeros(size(histparams.Y_range,2),size(histparams.X_range,2),2);

        for n=1:size(f_spot,1)
            Diff2fSpots=Heads_Sm{lfly}(1:params.MinimalDuration,:)-...
                repmat(f_spot(n,:),...
                params.MinimalDuration,1);

            %         Dist2fSpots=sqrt(sum(((Diff2fSpots).^2),2));
            [Th,Dist2fSpots]=cart2pol(Diff2fSpots(:,1),Diff2fSpots(:,2));
            log_temp=(Dist2fSpots<(MaxRad/params.px2mm));%&(Steplength_Sm_c{lfly}<=2/params.framerate/params.px2mm);%params.StopVel);
            log_speed=(Dist2fSpots<=(peak_FeedRad(params.ConditionIndex(lfly),2)/params.px2mm))&...
                (Dist2fSpots>=(peak_FeedRad(params.ConditionIndex(lfly),1)/params.px2mm));
            counts_temp(:,:,2)= hist3([Dist2fSpots(log_temp)*params.px2mm,...
                Th(log_temp)/pi*180],...
                {histparams.Y_range histparams.X_range});
            counts_temp(:,:,1)=nansum(counts_temp,3);

            Dist2SpotCell{lsubs}{lfly}=[Dist2SpotCell{lsubs}{lfly};...
                Dist2fSpots(log_temp)*params.px2mm];
            SpeedCell{lsubs}{lfly}=[SpeedCell{lsubs}{lfly};...
                Steplength_Sm_c{lfly}(log_speed)*params.px2mm*params.framerate];

        end


        counts=counts_temp(:,:,1);
        %     Freq=n./sum(sum(n)); %Counts, not frequecy
        VarHist{lsubs}(:,:,lfly)=counts;
    end
    display(lfly);
end

%% 2D Histograms
% close all
% plotting=2;
% for lsubs=1:length(params.Subs_Names)
% histparams.ylabel=['Dist from ' params.Subs_Names{lsubs}(1:end-4) ' Spots [mm]'];%
% Jointfr=sum(VarHist{lsubs},3);
% Jointfr=Jointfr./sum(sum(Jointfr));
%
%     figure('Position',[100 50 params.scrsz(3)-150 params.scrsz(4)-150])
%     lcondcounter=1;
%     for lcond=Conditions
%
%         Condtmp=sum(VarHist{lsubs}(:,:,params.ConditionIndex==lcond),3);
%         Cond_fr=Condtmp./sum(sum(Condtmp));
%
%         subplot(2,ceil(length(Conditions)/2),lcondcounter)
%
%         if plotting ==2
%             if lsubs==2, clims=[0 2.5e-3];else clims=[0 2e-3];end;
%             imagesc(histparams.X_range,histparams.Y_range,(Cond_fr),clims);%[0 2e-3]);%[0 2e-3]
%         elseif plotting ==3
%             imagesc(histparams.X_range,histparams.Y_range,log10(Cond_fr),[-6 -2.2]);%[-6 -2.7]
%         end
%
% %         set(gca,'FontSize',14)
%         if mod(lcondcounter,ceil(length(Conditions)/2))==0
%         colorbar
%         end
%         font_style(params.Labels(lcond),histparams.xlabel,histparams.ylabel,'normal','calibri',20)
%         set(gca,'YDir','normal')
%         lcondcounter=lcondcounter+1;
%     end
%
% end
%% Concatenated histogram
x_Label=['Speed on spots [mm/s]'];
%x_Label=['Distance from ' params.Subs_Names{lsubs} ' Spots [mm]'];
Rank_Freq_plot(SpeedCell,Conditions,params,1,70,[10 20],...
    x_Label,...
    'Event Nº',0,Dropbox_choicestrategies,Exp_num,Exp_letter,DataSaving_dir_temp)
%% Histogram of Distance to Spots
numbins=20;
SpotRad_range=0:MaxRad/(numbins-1):MaxRad;%
for lsubs=1%:length(params.Subs_Names)
    %% Dist to spot
    histparams.ylabel=['Distance from ' params.Subs_Names{lsubs} ' Spots [mm]'];%
%     set subplots to zero inside hist_cell to make the engagement plot
    hist_cell(SpotRad_range,Dist2SpotCell{lsubs},histparams.ylabel,'Frequency',Conditions,params)%[1 3],params)%Conditions,params)
    xlim([SpotRad_range(1) SpotRad_range(end)])
%         saveplots(Dropbox_choicestrategies,'Engage',['p(Dist2' params.Subs_Names{lsubs},...
%         ',' num2str(numbins) ' bins, All cond'],DataSaving_dir_temp,Exp_num,0,0)
    %% Speed at Peak Feeding Radius
    numbins=70;
    MaxSpeed=4;
    Speed_range=0:MaxSpeed/(numbins-1):MaxSpeed;%
     histparams.ylabel=['Speed on ' params.Subs_Names{lsubs} ' Spots [mm/s]'];%
    Condfr_mean=hist_cell(Speed_range,SpeedCell{lsubs},histparams.ylabel,'p(Speed|d \leq 2.5 mm)',Conditions,params);%Conditions,params)
    xlim([Speed_range(1) Speed_range(end)])
%     saveplots(Dropbox_choicestrategies,'Engage',['p(Vel, given dist2,5mm) ' params.Subs_Names{lsubs},...
%         ',' num2str(numbins) ' bins, All cond'],DataSaving_dir_temp,Exp_num,0,0)
end
% ylim([0 0.07])
% y_lim=get(gca,'YLim');
%% Plotting p(engagement) in second Y axis
% %%% Putting axis of histogram in the right with a the same color of the
% %%% plot
% % 
% % box off
% % xlabel([])
% % set(gca,'YAxisLocation','right','YColor',[0 150 0]/255,'XTick',[])
% LineColor=[149 55 53]/255;%[228 108 10]/255;
% haxes_real_pos=get(gca,'Position');
% haxes= axes('Position',haxes_real_pos,...
%                 'YAxisLocation','left',...
%                 'Color','none');
% %%% Engagement given distance to spot
% dist2spot=(0:MaxRad/299:MaxRad)';%X_range;% % Uncomment to plot
% hline=line(dist2spot,dist2spot_engagement(dist2spot),'Color',LineColor,...
% 'Parent',haxes,'LineWidth',4);%[84 130 53]/255
% font_style([],histparams.ylabel,...
%         'g(d)','normal','calibri',38)%'p(engagement|distance to spot)'
% set(haxes,'YColor',LineColor,'XColor',[0 150 0]/255,'XTick',[0 1 2 3 4])%[84 130 53]/255
% axis([SpotRad_range(1) SpotRad_range(end) 0 1.07])
% grid on
% % %%% Engagement given speed    
% % speed=0:Speed_range(end)/299:Speed_range(end);
% % p_engagement_given_speed=speed_engagement(speed,params);
% % hline=line(speed,p_engagement_given_speed,'Color',LineColor,...
% %     'Parent',haxes,'LineWidth',3);
% % font_style([],[],...
% %         'p(engagement|speed)','bold','calibri',20)
% % set(haxes,'XTick',[],'YColor',LineColor)%[84 130 53]/255
% % axis([Speed_range(1) Speed_range(end) 0 0.25/0.15])
% % line([1 1],[0 0.25/0.15],'LineStyle','--','Color','k','Parent',haxes)
% % saveplots(Dropbox_choicestrategies,'Presentations','0003A p(eng_given_dist)',...
% %     DataSaving_dir_temp,Exp_num,0,1)
%% Shading area of interest
% Colorpatch=Colors(4);
% jbfill([1.35 1.8],[y_lim(2) y_lim(2)],...[1.65 2.1]%FF-M
%         [0 0],...
%         Colorpatch(1,:),Colorpatch(1,:),0,0.5);
    
%% Average of Average Speeds along radii
% X_range=0:MaxRad/30:MaxRad;%
% Steplength_Dist=cell(size(params.Subs_Names));
% for lsubs=1:length(params.Subs_Names)
%     Steplength_Dist{lsubs}=nan(length(X_range),size(Steplength_Sm_c,1));
%     
%     for lfly=flies_idx
%         
%         f_spot=FlyDB(lfly).WellPos(FlyDB(lfly).Geometry==lsubs,:);
%         Dist2AllSpots=nan(params.MinimalDuration,1);
%         for n=1:size(f_spot,1)
%             Diff2fSpots=Heads_Sm{lfly}(1:params.MinimalDuration,:)-...
%                 repmat(f_spot(n,:),...
%                 params.MinimalDuration,1);
%             
%             Dist2fSpots=sqrt(sum(((Diff2fSpots).^2),2));
%             
%             log_temp=(Dist2fSpots<=(MaxRad/params.px2mm));%&(Steplength_Sm_c{lfly}<=2/params.framerate/params.px2mm);%params.StopVel);
%             Dist2AllSpots(log_temp)=Dist2fSpots(log_temp)*params.px2mm;
%         end
%         
%         %         % Sanity check for when Dist2AllSpots has as many columns as spots.
%         %         if sum(sum(Dist2AllSpots>0,2)>1)~=0,display('ERROR'),return,end
%         for lbin=1:length(X_range)-1
%             in_bin=(Dist2AllSpots>=X_range(lbin))&(Dist2AllSpots<X_range(lbin+1));
%             Steplength_Dist{lsubs}(lbin,lfly)=nanmean(Steplength_Sm_c{lfly}(in_bin))*params.framerate*params.px2mm;
%         end
%         
%         
%         display(lfly);
%     end
% end
% %%% Plotting Av of Av Speed vs Radius
% subplots=0;
% Symbol_plot={'-o';'-o';'-o';'-o'};%
% [Colormap,Cmap_patch]=Colors(length(Conditions),1);
% for lsubs=1:length(params.Subs_Names)
%     X_Label=['Dist from ' params.Subs_Names{lsubs}(1:end-4) ' Spots [mm]'];
%     Y_Label='Average of Average Speed (mm/s)';
%     figure('Position',[100 50 params.scrsz(3)-150 params.scrsz(4)-150]),
%     Vel_Dist_mean=nan(length(X_range)-1,length(unique(params.ConditionIndex)));
%     Vel_Dist_stderr=nan(length(X_range)-1,length(unique(params.ConditionIndex)));
%     h=zeros(length(Conditions),1);
%     lcondcounter=1;
%     for lcond=Conditions
%         Vel_Dist_mean(:,lcond)=nanmean(Steplength_Dist{lsubs}(1:end-1,params.ConditionIndex==lcond),2);
%         Vel_Dist_stderr(:,lcond)=nanstd(Steplength_Dist{lsubs}(1:end-1,params.ConditionIndex==lcond),0,2)./...
%             sqrt(sum(params.ConditionIndex==lcond));
%         if subplots==1
%             subplot(2,ceil(length(Conditions)/2),lcondcounter)
%             
%             Colorplot=Colormap(lcond,:);
%             Colorpatch=Cmap_patch(lcondcounter,:);
%             
%             h(lcondcounter)=plot(X_range(1:end-1),Vel_Dist_mean(:,lcond),Symbol_plot{1},'Color',Colorplot,...
%                 'LineWidth',2,'MarkerSize',3);
%             
%             hold on
%             font_style(params.Labels{lcond},X_Label,...
%                 Y_Label,'bold','calibri',20)
%         else
%             Colorpatch=Cmap_patch(lcondcounter,:);
%             h(lcondcounter)=plot(X_range(1:end-1),Vel_Dist_mean(:,lcond),Symbol_plot{lcondcounter},'Color',Colormap(lcond,:),...
%                 'LineWidth',3,'MarkerSize',4);
%             hold on
%         end
%         jbfill(X_range(1:end-1),[Vel_Dist_mean(:,lcond)+Vel_Dist_stderr(:,lcond)]',...
%             [Vel_Dist_mean(:,lcond)-Vel_Dist_stderr(:,lcond)]',...
%             Colorpatch,Colorpatch,0,0.5);
%         
%         
%         lcondcounter=lcondcounter+1;
%         
%     end
%     if subplots~=1
%         font_style(params.Subs_Names{lsubs},X_Label,Y_Label,'bold','calibri',20)%Uncomment for not subplots
%         legend(h,params.LabelsShort(Conditions))%Uncomment for not subplots
%         xlim([range(1) X_range(end-1)])
%         %     Y_axis_lim=get(gca,'YLim');
%         %     plot([2 2],Y_axis_lim,'--k','LineWidth',2)
%         % set(gca,'XLim',[4 15],'YScale','log','YLim',[1e-3 5e-3])%0.05])
%         % plot([2 2],[1e-3 0.05],'--k','LineWidth',1)
%         %     axis([2 30 0 0.04])%axis([0 5 0 0.015])
%     end
%     
% end
% % plot([0 X_range(end-1)],[2.7 2.7],'--k','LineWidth',2)
%% Average of all Speed points

% X_range=0:MaxRad/20:MaxRad;%
% Steplength_Dist=cell(size(params.Subs_Names));
% for lsubs=1:length(params.Subs_Names)
%     Steplength_Dist{lsubs}=cell(length(Conditions),1);
%     lcondcounter=1;
%     for lcond=Conditions
%         Steplength_Dist{lsubs}{lcondcounter}=cell(length(X_range),1);
%         for lfly=find(params.ConditionIndex==lcond)
%             
%             f_spot=FlyDB(lfly).WellPos(FlyDB(lfly).Geometry==lsubs,:);
%             Dist2AllSpots=nan(params.MinimalDuration,1);
%             for n=1:size(f_spot,1)
%                 Diff2fSpots=Heads_Sm{lfly}(1:params.MinimalDuration,:)-...
%                     repmat(f_spot(n,:),...
%                     params.MinimalDuration,1);
%                 
%                 Dist2fSpots=sqrt(sum(((Diff2fSpots).^2),2));
%                 
%                 log_temp=(Dist2fSpots<=(MaxRad/params.px2mm));%&(Steplength_Sm_c{lfly}<=2/params.framerate/params.px2mm);%params.StopVel);
%                 Dist2AllSpots(log_temp)=Dist2fSpots(log_temp)*params.px2mm;
%             end
%             
%             %         % Sanity check for when Dist2AllSpots has as many columns as spots.
%             %         if sum(sum(Dist2AllSpots>0,2)>1)~=0,display('ERROR'),return,end
%             Steplength_Dist{lsubs}{lcondcounter}{lbin}=[];
%             for lbin=1:length(X_range)-1
%                 in_bin=(Dist2AllSpots>=X_range(lbin))&(Dist2AllSpots<X_range(lbin+1));
%                 Steplength_Dist{lsubs}{lcondcounter}{lbin}=[Steplength_Dist{lsubs}{lcondcounter}{lbin};...
%                     Steplength_Sm_c{lfly}(in_bin)*params.framerate*params.px2mm];
%             end
%             
%             
%             display(lfly);
%         end
%         lcondcounter=lcondcounter+1;
%     end
% end
% %%% Plotting Av of Av Speed vs Radius
% subplots=0;
% Symbol_plot={'-o';'-o';'-o';'-o'};%
% [Colormap,Cmap_patch]=Colors(length(Conditions),1);
% for lsubs=1:length(params.Subs_Names)
%     X_Label=['Dist from ' params.Subs_Names{lsubs}(1:end-4) ' Spots [mm]'];
%     Y_Label='Average Speed (mm/s)';
%     figure('Position',[100 50 params.scrsz(3)-150 params.scrsz(4)-150]),
%     Vel_Dist_mean=nan(length(X_range)-1,length(unique(params.ConditionIndex)));
%     Vel_Dist_stderr=nan(length(X_range)-1,length(unique(params.ConditionIndex)));
%     h=zeros(length(Conditions),1);
%     lcondcounter=1;
%     for lcond=Conditions
%         for lbin=1:length(X_range)-1
%             Vel_Dist_mean(lbin,lcond)=nanmean(Steplength_Dist{lsubs}{lcondcounter}{lbin}(Steplength_Dist{lsubs}{lcondcounter}{lbin}>0));
%             Vel_Dist_stderr(lbin,lcond)=nanstd(Steplength_Dist{lsubs}{lcondcounter}{lbin}(Steplength_Dist{lsubs}{lcondcounter}{lbin}>0))./...
%                 sqrt(length(Steplength_Dist{lsubs}{lcondcounter}{lbin}));
%         end
%         if subplots==1
%             subplot(2,ceil(length(Conditions)/2),lcondcounter)
%             
%             Colorplot=Colormap(lcond,:);
%             Colorpatch=Cmap_patch(lcondcounter,:);
%             
%             h(lcondcounter)=plot(X_range(1:end-1),Vel_Dist_mean(:,lcond),Symbol_plot{1},'Color',Colorplot,...
%                 'LineWidth',2,'MarkerSize',3);
%             
%             hold on
%             font_style(params.Labels{lcond},X_Label,...
%                 Y_Label,'bold','calibri',20)
%         else
%             Colorpatch=Cmap_patch(lcondcounter,:);
%             h(lcondcounter)=plot(X_range(1:end-1),Vel_Dist_mean(:,lcond),Symbol_plot{lcondcounter},'Color',Colormap(lcond,:),...
%                 'LineWidth',3,'MarkerSize',4);
%             hold on
%         end
%         jbfill(X_range(1:end-1),[Vel_Dist_mean(:,lcond)+Vel_Dist_stderr(:,lcond)]',...
%             [Vel_Dist_mean(:,lcond)-Vel_Dist_stderr(:,lcond)]',...
%             Colorpatch,Colorpatch,0,0.5);
%         
%         
%         lcondcounter=lcondcounter+1;
%         
%     end
%     if subplots~=1
%         font_style(params.Subs_Names{lsubs},X_Label,Y_Label,'bold','calibri',20)%Uncomment for not subplots
%         legend(h,params.LabelsShort(Conditions))%Uncomment for not subplots
%         %     Y_axis_lim=get(gca,'YLim');
%         %     plot([2 2],Y_axis_lim,'--k','LineWidth',2)
%         % set(gca,'XLim',[4 15],'YScale','log','YLim',[1e-3 5e-3])%0.05])
%         % plot([2 2],[1e-3 0.05],'--k','LineWidth',1)
%         %     axis([2 30 0 0.04])%axis([0 5 0 0.015])
%     end
%     
% end