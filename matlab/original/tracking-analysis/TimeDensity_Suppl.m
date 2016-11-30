% %% Plotting vertical line of defined radius
% hold on
% Y_axis_lim=get(gca,'YLim');
% plot([4 4],Y_axis_lim,'--k','LineWidth',2)
% % % hold on
% % % X_axis_lim=get(gca,'XLim');
% % % plot(X_axis_lim,[4 4],'--k','LineWidth',2)
%% Time density & Crossings inside fictitious spots
% T_dens_f_spot=nan(size(FeedingRadii,2),length(flies_idx));
% Crossings_f_spot=nan(size(FeedingRadii,2),length(flies_idx));
% Intimes_f=nan(size(FeedingRadii,2),length(flies_idx));
% % [f_spotx,f_spoty]=pol2cart([0;pi/4;pi/2;3*pi/4;pi;-pi/4;-pi/2;-3*pi/4],repmat(27/params.px2mm,8,1));%Edge Spots
% [f_spotx,f_spoty]=pol2cart([0;pi/6;pi/3;pi/2;2*pi/3;5*pi/6;pi;...
%                             -[pi/6;pi/3;pi/2;2*pi/3;5*pi/6]],repmat(25.5/params.px2mm,12,1));%Edge Spots
% f_spot=[f_spotx f_spoty];
% % f_spot=[87.3787  -51.4700;...
% %    43.6600  -77.1689;...
% %    -0.8850 -101.4071;...
% %   -45.0002  -76.3951;...
% %   -88.2636  -49.9372;...
% %   -88.6602    0.7737;...
% %    88.6602   -0.7737;...
% %    88.2636   49.9372;...
% %    45.0002   76.3951;...
% %     0.8850  101.4071;...
% %   -43.6600   77.1689;...
% %   -87.3787   51.4700];
% 
% lflycounter=1;
% for lfly=flies_idx
%     display(lfly)
%     
%     Dist2fSpots=nan(length(Heads{lfly}),size(f_spot,1));
%     for n=1:size(f_spot,1)
%         Dist2fSpots(:,n)=sqrt(sum(((Heads{lfly}-...
%             repmat(f_spot(n,:),...
%             length(Heads{lfly}),1)).^2),2));
%     end
%     for lFeedRad=FeedingRadii(1,:)
%         %     display(['-------FEEDING RADIUS: ' num2str(lFeedRad) ' mm-----'])
%         Areaf=size(f_spot,1)*pi()*((lFeedRad)^2);
%         Inlogf=(Dist2fSpots<=lFeedRad/params.px2mm);
%         
%         
%         InOutf=conv(sum(Inlogf,2),[1 -1]);
%         if   ~isempty(find(InOutf,1))
%             temp=diff(find(InOutf));
%             time_in=temp(1:2:end);
%             Intimes_f(FeedingRadii(1,:)==lFeedRad,lflycounter)=sum(time_in);
%             T_dens_f_spot(FeedingRadii(1,:)==lFeedRad,lflycounter)=...
%                 sum(time_in)/(Areaf*length(Heads{lfly}));
%             Crossings_f_spot(FeedingRadii(1,:)==lFeedRad,lflycounter)=...
%                 length(time_in)/(size(f_spot,1)*2*pi*lFeedRad);%(length(Heads{lfly}));
%         end
%         
%         
%     end
%     lflycounter=lflycounter+1;
% end
%% Normalizer for crossings
% Areas=nan(size(FeedingRadii,2),1);
% for lFeedRad=FeedingRadii(1,:)
%     Areas(FeedingRadii(1,:)==lFeedRad)=...
%         size(f_spot,1)*pi*((lFeedRad)^2);
% end
% % Exp_time=nan(1,length(flies_idx));
% time_moving=nan(1,length(flies_idx));
% Steplength = Steplength_fun(Heads);
% lflycounter=1;
% for lfly=flies_idx
%     time_moving(lflycounter)=sum(Steplength{lfly}*params.px2mm*params.framerate>params.StopVel);
% %     Exp_time(lflycounter)=length(Heads{lfly});
%     lflycounter=lflycounter+1;
% end


%% Plotting fictitious spots
% [Colormap,Cmap_patch]=Colors(length(Conditions),1);
% lcondcounter=1;
% for lcond=Conditions
%     %% Plotting time density
%     normalizer=1./repmat(time_moving(params.ConditionIndex(flies_idx)==lcond),size(FeedingRadii,2),1);%...
% %                 repmat(Exp_time(params.ConditionIndex(flies_idx)==lcond),size(FeedingRadii,2),1).*...
% %                 repmat(Areas,1,sum(params.ConditionIndex(flies_idx)==lcond))./...
% %                 Intimes_f(:,params.ConditionIndex(flies_idx)==lcond,lsubs);
%     subplot(1,2,1)
%     TtimeA_m=nanmean(T_dens_f_spot(:,params.ConditionIndex(flies_idx)==lcond),2);%
%     TtimeA_errup=nanstd(T_dens_f_spot(:,params.ConditionIndex(flies_idx)==lcond),0,2)/...
%         sqrt(sum(params.ConditionIndex==lcond))/2;
%     plot(FeedingRadii(1,:),TtimeA_m,'--g',...
%         'Color',Colormap(lcondcounter,:),...
%         'LineWidth',1);
%     hold on
%     jbfill(FeedingRadii(1,:),[TtimeA_m+TtimeA_errup]',...
%         [TtimeA_m-TtimeA_errup]',...
%         Cmap_patch(lcondcounter,:),Cmap_patch(lcondcounter,:),0,0.5);
%     %% Plotting number of crossings
%     subplot(1,2,2)
%     TtimeA_m=nanmean(Crossings_f_spot(:,params.ConditionIndex(flies_idx)==lcond).*normalizer,2);%
%     TtimeA_errup=nanstd(Crossings_f_spot(:,params.ConditionIndex(flies_idx)==lcond).*normalizer,0,2)/...
%         sqrt(sum(params.ConditionIndex==lcond))/2;
%     plot(FeedingRadii(1,:),TtimeA_m,'--g',...
%         'Color',Colormap(lcondcounter,:),...
%         'LineWidth',1);
%     hold on
%     jbfill(FeedingRadii(1,:),[TtimeA_m+TtimeA_errup]',...
%         [TtimeA_m-TtimeA_errup]',...
%         Cmap_patch(lcondcounter,:),Cmap_patch(lcondcounter,:),0,0.5);
%     lcondcounter=lcondcounter+1;
% end
%% Plot arena with spots
% figure
% [~,Colormap_patch]=Colors(2,1);
% c1=circle_([0,0],params.OuterRingRadious,100,'--');
% set(c1,'Color',[0.7 0.7 0.7],'LineWidth',2)
% hold on
% c1=circle_([0,0],30,100,'-');
% set(c1,'Color',[0.7 0.7 0.7],'LineWidth',2)
% msize=25;
% plot(FlyDB(lfly).WellPos(FlyDB(lfly).Geometry==1,1)*params.px2mm,...
%         FlyDB(lfly).WellPos(FlyDB(lfly).Geometry==1,2)*params.px2mm,'ob',...
%         'MarkerSize',msize,'MarkerFaceColor',[201 215 255]/255,'MarkerEdgeColor',[201 215 255]/255)%'MarkerSize',3
% 
% plot(FlyDB(lfly).WellPos(FlyDB(lfly).Geometry==2,1)*params.px2mm,...
%         FlyDB(lfly).WellPos(FlyDB(lfly).Geometry==2,2)*params.px2mm,...
%         'or','MarkerSize',msize,'MarkerFaceColor',[255 197 197]/255,'MarkerEdgeColor',[255 197 197]/255)    
%     
% plot(f_spot(:,1)*params.px2mm,...
%         f_spot(:,2)*params.px2mm,...
%         'or','MarkerSize',msize,'MarkerFaceColor',Colormap_patch(2,:),'MarkerEdgeColor',Colormap_patch(2,:))
% c=circle_([f_spot(1,1)*params.px2mm,...
%         f_spot(1,2)*params.px2mm],...
%         4,100,'--');
%     set(c,'Color',[0.7 0.7 0.7],'LineWidth',2)
%     c=circle_([FlyDB(lfly).WellPos(13,1)*params.px2mm,...
%         FlyDB(lfly).WellPos(13,2)*params.px2mm],...
%         2.2,100,'--');
%     set(c,'Color',[0.7 0.7 0.7],'LineWidth',2)
%     c=circle_([FlyDB(lfly).WellPos(1,1)*params.px2mm,...
%         FlyDB(lfly).WellPos(1,2)*params.px2mm],...
%         2.2,100,'--');
%     set(c,'Color',[0.7 0.7 0.7],'LineWidth',2)
% axis off
%% Plotting distance from one spot
% spotXY=[f_spotx f_spoty];
% 
% for lfly=55%1:137
%     %     spotXY=FlyDB(lfly).WellPos(1,:);
%     Dist2Spots=sqrt(sum((Heads{lfly}-repmat(spotXY,length(Heads{lfly}),1)).^2,2));
%     plot(Dist2Spots(:,1),'-r')
%     font_style(['Fly Nº ' num2str(lfly)],'frame Nº','Distance from spot (px)','normal','calibri',20)
%     % pause
% end
% 
% %% Normalizer for crossings
% bla=nan(size(FeedingRadii,2));
% for lFeedRad=FeedingRadii(1,:)
%     
%     bla(FeedingRadii(1,:)==lFeedRad)=...
%         9*pi*((lFeedRad)^2);
%     
% end
% %% Time density inside Outer Area
% T_dens_OuterA=nan(1,length(flies_idx));
% Area=pi()*(31^2-params.OuterRingRadious^2);
% lflycounter=1;
% for lfly=flies_idx
%     display(lfly)
%     [~,R]=cart2pol(Heads{lfly}(:,1),Heads{lfly}(:,2));
%     
%     InOut=conv(double(R>=params.OuterRingRadious/params.px2mm),[1 -1]);
%     if   ~isempty(find(InOut,1))
%         temp=diff(find(InOut));%Durations in bouts & inter bouts.
%         %%% Selecting only Inside bout durations:
%         time_in=temp(1:2:end);
%         %%% Calculating time inside per unit of area and unit of
%         %%% time of the experiment [1/mm^2]
%         T_dens_OuterA(lflycounter)=...
%             sum(time_in)/(Area*length(Heads{lfly}));
%     end
%     lflycounter=lflycounter+1;
% end
% % plot_bar( T_dens_OuterA/params.framerate/60,'Time in Edge (min)', Conditions, params)
% 
% lcondcounter=1;
% for lcond=Conditions
%     TtimeA_m=nanmean(T_dens_OuterA(params.ConditionIndex(flies_idx)==lcond));%
%     TtimeA_errup=nanstd(T_dens_OuterA(params.ConditionIndex(flies_idx)==lcond),0,2)/...
%         sqrt(sum(params.ConditionIndex==lcond))/2;
%     plot([FeedingRadii(1,1) FeedingRadii(1,end)],[TtimeA_m TtimeA_m],'--b',...
%         'Color',Colormap(lcondcounter,:),...
%         'LineWidth',1);
%     jbfill([FeedingRadii(1,1) FeedingRadii(1,end)],[TtimeA_m+TtimeA_errup TtimeA_m+TtimeA_errup],...
%         [TtimeA_m-TtimeA_errup TtimeA_m-TtimeA_errup],...
%         Cmap_patch(lcondcounter,:),Cmap_patch(lcondcounter,:),0,0.5);
%     lcondcounter=lcondcounter+1;
% end
%% Plotting
Conditions=[1 3];
%%% Normalizer for crossings
Substrates=params.Subs_Names;
Areas=nan(size(FeedingRadii,2),1);
for lFeedRad=FeedingRadii(1,:)
    Areas(FeedingRadii(1,:)==lFeedRad)=...
        9*pi*((lFeedRad)^2);
end

% Exp_time=nan(1,length(flies_idx));
time_moving=nan(1,length(flies_idx));

lflycounter=1;
for lfly=flies_idx
    time_moving(lflycounter)=sum(Steplength_Sm_h{lfly}*params.px2mm*params.framerate>params.Walk_Vel);
%     Exp_time(lflycounter)=length(Heads{lfly});
    lflycounter=lflycounter+1;
end

%%% Plotting
[Colormap2,Cmap_patch]=Colors(length(Conditions));
Colormap=[Colormap2(2,:);Colormap2(1,:)]
close all
for ltype=1%typesofarea
    lsubscounter=1;
    for lsubs=Substrates
        
        figure('Position',[100 50 params.scrsz(3)-950 params.scrsz(4)-150],'Color','w')
        hold on
        h=zeros(length(Conditions),1);
        lcondcounter=1;
        stats=2;
        for lcond=Conditions
            normalizer=1./repmat(time_moving(params.ConditionIndex(flies_idx)==lcond),size(FeedingRadii,2),1);%...
%                 repmat(Exp_time(params.ConditionIndex(flies_idx)==lcond),size(FeedingRadii,2),1).*...
%                 repmat(Areas,1,sum(params.ConditionIndex(flies_idx)==lcond))./...
%                 Intimes(:,params.ConditionIndex(flies_idx)==lcond,lsubs);
            if stats==1
                %% Median time density
                TtimeSqr_m=nanmedian(time_density{ltype}(:,params.ConditionIndex(flies_idx)==lcond,lsubscounter),2);%
                TtimeSqr_errup=prctile(time_density{ltype}(:,params.ConditionIndex(flies_idx)==lcond,lsubscounter),25,2);
                TtimeSqr_errdown=prctile(time_density{ltype}(:,params.ConditionIndex(flies_idx)==lcond,lsubscounter),75,2);
                %% Median Number of crossings
                num_cross_m=nanmedian(num_cross{ltype}(:,params.ConditionIndex(flies_idx)==lcond,lsubscounter),2);%
                num_cross_errup=prctile(num_cross{ltype}(:,params.ConditionIndex(flies_idx)==lcond,lsubscounter),25,2);
                num_cross_errdown=prctile(num_cross{ltype}(:,params.ConditionIndex(flies_idx)==lcond,lsubscounter),75,2);
            elseif stats==2
                %% Mean time density
%                 TtimeSqr_m=nanmean(time_density{ltype}(:,params.ConditionIndex(flies_idx)==lcond,lsubscounter),2);%
%                 TtimeSqr_errup=nanstd(time_density{ltype}(:,params.ConditionIndex(flies_idx)==lcond,lsubscounter),0,2)/...
%                     sqrt(sum(params.ConditionIndex==lcond))/2;
%                 TtimeSqr_errdown=TtimeSqr_errup;
                
                %% Mean number of crossings
                num_cross_m=nanmean(num_cross{ltype}(:,params.ConditionIndex(flies_idx)==lcond,lsubscounter).*...
                    normalizer,2);%
                num_cross_errup=nanstd(num_cross{ltype}(:,params.ConditionIndex(flies_idx)==lcond,lsubscounter).*...
                    normalizer,0,2)/...
                    sqrt(sum(params.ConditionIndex==lcond))/2;
                num_cross_errdown=num_cross_errup;
                
            end
            %% Plotting time density
%             subplot(1,2,1)
%             hline=line([FeedingRadii(1,:);FeedingRadii(1,:)],...
%                 [[TtimeSqr_m+TtimeSqr_errup]';...
%                 [TtimeSqr_m-TtimeSqr_errdown]']);
%             set(hline,'LineWidth',2,'Color',Colormap(lcondcounter,:))
%             hold on
%             plot(FeedingRadii(1,:),TtimeSqr_m,'ob',...%'-b',...
%                 'Color',Colormap(lcondcounter,:),...
%                 'LineWidth',3,'MarkerSize',5,'MarkerFaceColor',Colormap(lcondcounter,:));
% 
%             hold on
%             
% %             jbfill(FeedingRadii(1,:),[TtimeSqr_m+TtimeSqr_errup]',...
% %                 [TtimeSqr_m-TtimeSqr_errdown]',...
% %                 Cmap_patch(lcondcounter,:),Cmap_patch(lcondcounter,:),0,0.5);
%             if ltype==2
%                 font_style([params.Subs_Names{lsubscounter} ': (r_1-1) \leq r_f \leq r_1'],...
%                     'Nutrient Interaction Radius (mm)',...
%                     'Time inside ROI, normalized (1/mm^2)','bold','calibri',20)
%             elseif ltype==1
%                 font_style([params.Subs_Names{lsubscounter} ': r_f \leq r_1'],...
%                     'Nutrient Interaction Radius (mm)',...
%                     'Time inside ROI, normalized (1/mm^2)','bold','calibri',20)
%             end
%             xlim([FeedingRadii(1,1) FeedingRadii(1,end)])
            %% Plotting number of crossings
           
%             subplot(1,2,2)

             hline=line([FeedingRadii(1,:);FeedingRadii(1,:)],...
                [[num_cross_m+num_cross_errup]';...
                [num_cross_m-num_cross_errdown]']);
            set(hline,'LineWidth',2,'Color',Colormap(lcondcounter,:))
            hold on
            h(lcondcounter)=plot(FeedingRadii(1,:),num_cross_m,'-ob',...'-b',...
                'Color',Colormap(lcondcounter,:),...
                'LineWidth',3,'MarkerSize',5,'MarkerFaceColor',Colormap(lcondcounter,:));
            hold on
%             jbfill(FeedingRadii(1,:),[num_cross_m+num_cross_errup]',...
%                 [num_cross_m-num_cross_errdown]',...
%                 Cmap_patch(lcondcounter,:),Cmap_patch(lcondcounter,:),0,0.5);
            
            
            if ltype==2
                font_style([params.Subs_Names{lsubscounter} ': (r_1-1) \leq r_f \leq r_1'],...
                    'Nutrient Interaction Radius [mm]',...
                    ['Number of ' params.Subs_Names{lsubscounter}(1:end-4)  ' bouts, normalized'],'normal','calibri',24)
            elseif ltype==1
                font_style([params.Subs_Names{lsubscounter} ': r_f \leq r_1'],...
                    'Nutrient Interaction Radius [mm]',...
                    ['Number of ' params.Subs_Names{lsubscounter}(1:end-4)  ' bouts, normalized'],'normal','calibri',24)
            end
            xlim([FeedingRadii(1,1) FeedingRadii(1,end)])

            lcondcounter=lcondcounter+1;
        end
%         legend(h,params.Labels{Conditions});
        export_fig([saving_dir 'Number of ' params.Subs_Names{lsubscounter}(1:end-4) ' bouts across radii'], '-tif')
        lsubscounter=lsubscounter+1;
        
    end
end
