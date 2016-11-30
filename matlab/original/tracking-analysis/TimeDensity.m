function [time_density, num_cross,Intimes]=...
    TimeDensity(FlyDB,Heads,Steplength_Sm_h,FeedingRadii,flies_idx,Conditions,...
    params,SubFolder_name,DataSaving_dir_temp,Exp_num,Exp_letter,share,Dropbox_choicestrategies)
%% Time inside nutrient radius per unit of area and unit of recording time
% This because some flies were recorded for longer periods than others
% Use: TimeDensity(FlyDB,Heads,FeedingRadii,fly_idx,params)
% Inputs:
% Heads           Cell array with 2-col vectors with [X Y] positions to be
%                 considered. Each entry corresponds to the data of one fly.
% FeedingRadii    2-Rows vector with the radii to test in mm in the first
%                 row and second radii in second row: Evaluate time spent
%                 in the ring between these two radii

Substrates=params.Subs_Names;%[1 2];%[4];%
time_density=cell(size(FeedingRadii,1),1);
num_cross=cell(size(FeedingRadii,1),1);
Intimes=nan(size(FeedingRadii,2),length(flies_idx),length(Substrates));

if size(FeedingRadii,1)==1, typesofarea=1;
elseif size(FeedingRadii,1)==2,
    typesofarea=[1 2];
else error('size(FeedingRadii,1) must be 1 or 2')
end
typesofarea=1;
for ltype=typesofarea
    time_density{ltype}=nan(size(FeedingRadii,2),length(flies_idx),length(Substrates));
    num_cross{ltype}=nan(size(FeedingRadii,2),length(flies_idx),length(Substrates));
end

lflycounter=1;
for lfly=flies_idx
    %% Food types distribution in wells %%
    %     display(FlyDB(lfly).Filename)
    display(lfly)
    
    %% Calculating distances from food spots %
    Dist2Spots=nan(params.MinimalDuration,length(FlyDB(lfly).WellPos));%length(Heads{lfly})
    for n=1:length(FlyDB(lfly).WellPos)
        Dist2Spots(:,n)=sqrt(sum(((Heads{lfly}(1:params.MinimalDuration,:)-...
            repmat(FlyDB(lfly).WellPos(n,:),...
            params.MinimalDuration,1)).^2),2));%length(Heads{lfly})
    end
    
    %% Bout durations
    
    for lFeedRad=FeedingRadii(1,:)
%         display(['-------FEEDING RADIUS: ' num2str(lFeedRad) ' mm-----'])
        for ltype=typesofarea
            
            InOut=nan(params.MinimalDuration+1,length(Substrates));%length(Heads{lfly})
            if ltype==2
                Inlog1=(Dist2Spots<=lFeedRad/params.px2mm)&...
                    (Dist2Spots>=FeedingRadii(2,FeedingRadii(1,:)==lFeedRad)/params.px2mm);
            else
                Inlog1=(Dist2Spots<=lFeedRad/params.px2mm);
                
            end
            
            lsubscounter=1;
            for lsubs=1:length(Substrates)
                InOut(:,lsubscounter)=conv(sum(Inlog1(:,FlyDB(lfly).Geometry'==lsubs),2),[1 -1]);
                
                if ltype==2
                    Area1=sum(FlyDB(lfly).Geometry'==lsubs)*pi*((lFeedRad)^2);
                    Area2=sum(FlyDB(lfly).Geometry'==lsubs)*pi*((FeedingRadii(2,FeedingRadii(1,:)==lFeedRad))^2);
                    Area=Area1-Area2;
                    
                else
                    Area=sum(FlyDB(lfly).Geometry'==lsubs)*pi*((lFeedRad)^2);
                   
                end
                if   ~isempty(find(InOut(:,lsubscounter),1))
                    temp=diff(find(InOut(:,lsubscounter)));%Durations in bouts & inter bouts.
                    %%% Selecting only Inside bout durations:
                    time_in=temp(1:2:end)/params.framerate;%s --> Remove denominator if going to divide by length(Heads)
                    %%% Calculating time inside per unit of area 
                    %%% Alternative: and unit of time of the experiment [1/mm^2]
                    Intimes(FeedingRadii(1,:)==lFeedRad,lflycounter,lsubscounter)=sum(time_in);
                    time_density{ltype}(FeedingRadii(1,:)==lFeedRad,lflycounter,lsubscounter)=...
                        sum(time_in)/(Area);%/(Area*length(Heads{lfly}))%--> Careful!! with the time units!
                    %%% Note: Because number of crossings is twice the
                    %%% number of bouts, I multiply by 2.
                    num_cross{ltype}(FeedingRadii(1,:)==lFeedRad,lflycounter,lsubscounter)=...
                        2*length(time_in)/(sum(FlyDB(lfly).Geometry'==lsubs)*(2*pi*lFeedRad));%(*length(Heads{lfly}));%Number of bouts
                    
                end
                lsubscounter=lsubscounter+1;
            end
            
            
            
        end
        
    end
    lflycounter=lflycounter+1;
end


%% Plotting
FntSiz=14;
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
[Colormap,Cmap_patch]=Colors(length(Conditions));
close all
for ltype=1%typesofarea
    lsubscounter=1;
    for lsubs=1:length(Substrates)
        
        figure('Position',[100 50 params.scrsz(3)-550 params.scrsz(4)-150],'Color','w')
        hold on
        h=zeros(length(Conditions),1);
        lcondcounter=1;
        stats=2;
        for lcond=Conditions
            correction_factor=1./repmat(time_moving(params.ConditionIndex(flies_idx)==lcond),size(FeedingRadii,2),1);%...
%                 repmat(Exp_time(params.ConditionIndex(flies_idx)==lcond),size(FeedingRadii,2),1).*...
%                 repmat(Areas,1,sum(params.ConditionIndex(flies_idx)==lcond))./...
%                 Intimes(:,params.ConditionIndex(flies_idx)==lcond,lsubs);
            num_cross_temp=(num_cross{ltype}(:,...
                params.ConditionIndex(flies_idx)==lcond,lsubscounter).*correction_factor);
            num_cross_temp=num_cross_temp./(repmat(sum(num_cross_temp),length(FeedingRadii(1,:)),1));
            if stats==1
                %% Median time density
                TtimeSqr_m=nanmedian(time_density{ltype}(:,params.ConditionIndex(flies_idx)==lcond,lsubscounter),2);%
                TtimeSqr_errup=prctile(time_density{ltype}(:,params.ConditionIndex(flies_idx)==lcond,lsubscounter),25,2);
                TtimeSqr_errdown=prctile(time_density{ltype}(:,params.ConditionIndex(flies_idx)==lcond,lsubscounter),75,2);
                %% Median Number of crossings
                
                num_cross_m=nanmedian(num_cross_temp,2);%
                num_cross_errup=prctile(num_cross_temp,25,2);
                num_cross_errdown=prctile(num_cross_temp,75,2);
            elseif stats==2
                %% Mean time density
                TtimeSqr_m=nanmean(time_density{ltype}(:,params.ConditionIndex(flies_idx)==lcond,lsubscounter),2);%
                TtimeSqr_errup=nanstd(time_density{ltype}(:,params.ConditionIndex(flies_idx)==lcond,lsubscounter),0,2)/...
                    sqrt(sum(params.ConditionIndex==lcond))/2;
                TtimeSqr_errdown=TtimeSqr_errup;
                
                %% Mean number of crossings
                num_cross_m=nanmean(num_cross_temp,2);%
                num_cross_errup=nanstd(num_cross_temp,0,2)/...
                    sqrt(sum(params.ConditionIndex==lcond))/2;
                num_cross_errdown=num_cross_errup;
                
            end
            %% Plotting time density
            subplot(1,2,1)
            hline=line([FeedingRadii(1,:);FeedingRadii(1,:)],...
                [[TtimeSqr_m+TtimeSqr_errup]';...
                [TtimeSqr_m-TtimeSqr_errdown]']);
            set(hline,'LineWidth',2,'Color',Colormap(lcondcounter,:))
            hold on
            h(lcondcounter)=plot(FeedingRadii(1,:),TtimeSqr_m,'ob',...%'-b',...
                'Color',Colormap(lcondcounter,:),...
                'LineWidth',2,'MarkerSize',5,'MarkerFaceColor',Colormap(lcondcounter,:));
            h(lcondcounter)=plot(FeedingRadii(1,:),TtimeSqr_m,'-b',...%'-b',...
                'Color',Colormap(lcondcounter,:),'LineWidth',2);

            hold on
            
%             jbfill(FeedingRadii(1,:),[TtimeSqr_m+TtimeSqr_errup]',...
%                 [TtimeSqr_m-TtimeSqr_errdown]',...
%                 Cmap_patch(lcondcounter,:),Cmap_patch(lcondcounter,:),0,0.5);
            if ltype==2
                font_style([params.Subs_Names{lsubscounter} ': (r_1-1) \leq r_f \leq x'],...
                    ['ROI radius, centered in  ' params.Subs_Names{lsubscounter} ' spots [mm]'],...
                    'Time inside ROI per unit of area [s/mm^2]','normal','calibri',FntSiz)
            elseif ltype==1
                font_style([params.Subs_Names{lsubscounter} ': r_f \leq x'],...
                    ['ROI radius, centered in  ' params.Subs_Names{lsubscounter} ' spots [mm]'],...
                    'Time inside ROI per unit of area [s/mm^2]','normal','calibri',FntSiz)
            end
            xlim([FeedingRadii(1,1) FeedingRadii(1,end)])
            %% Plotting number of crossings
           
            subplot(1,2,2)
             hline=line([FeedingRadii(1,:);FeedingRadii(1,:)],...
                [[num_cross_m+num_cross_errup]';...
                [num_cross_m-num_cross_errdown]']);
            set(hline,'LineWidth',2,'Color',Colormap(lcondcounter,:))
            hold on
            plot(FeedingRadii(1,:),num_cross_m,'ob',...'-b',...
                'Color',Colormap(lcondcounter,:),...
                'LineWidth',2,'MarkerSize',5,'MarkerFaceColor',Colormap(lcondcounter,:));
            plot(FeedingRadii(1,:),num_cross_m,'-b',...'-b',...
                'Color',Colormap(lcondcounter,:),'LineWidth',2);
            hold on
%             jbfill(FeedingRadii(1,:),[num_cross_m+num_cross_errup]',...
%                 [num_cross_m-num_cross_errdown]',...
%                 Cmap_patch(lcondcounter,:),Cmap_patch(lcondcounter,:),0,0.5);
            
            
            if ltype==2
                font_style([params.Subs_Names{lsubscounter} ': (x-1) \leq r_f \leq x'],...
                    ['ROI radius, centered in  ' params.Subs_Names{lsubscounter} ' spots [mm]'],...
                    'Number of crossings, corrected & normalized','normal','calibri',FntSiz)
            elseif ltype==1
                font_style([params.Subs_Names{lsubscounter} ': r_f \leq x'],...
                ['ROI radius, centered in  ' params.Subs_Names{lsubscounter} ' spots [mm]'],...
                'Number of crossings, corrected & normalized','normal','calibri',FntSiz)
            end
            xlim([FeedingRadii(1,1) FeedingRadii(1,end)])
            
            lcondcounter=lcondcounter+1;
        end
        legend(h,params.Labels(Conditions),'FontSize',FntSiz-1,'Location','Best');%,'Box','Off');
        subplot(1,2,1)
        legend('boxoff')
        lsubscounter=lsubscounter+1;
        figname=[Exp_num Exp_letter ' ' Substrates{lsubs} ' Time density and crossings, changing rad'];
        saveplots(Dropbox_choicestrategies,SubFolder_name,figname,DataSaving_dir_temp,Exp_num,share)
    end
end
save([DataSaving_dir_temp Exp_num '\Variables\Time_Density' Exp_num Exp_letter ' ' date '.mat'],'time_density','num_cross','Intimes');
