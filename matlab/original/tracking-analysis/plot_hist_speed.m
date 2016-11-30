function h=plot_hist_speed(Steplength,Vel_range,Conditions,FontSz,params,fontName,CumTimeEnc)
%% Speed Histogram
% Vel_range=0:30/50:30; % Velocity range in mm/s %bins=80 for Vmax=4, non-zero
Movingbins=find(Vel_range>params.Microm_Vel,1,'first');
VelHistCount_In=nan(size(Vel_range,2),length(Steplength));
VelHistCount_Out=nan(size(Vel_range,2),length(Steplength));
for lfly=1:size(Steplength,1)
    display(lfly)
    %% Distance to spots
    %     f_spot=FlyDB(lfly).WellPos(1:18,:);%(FlyDB(lfly).Geometry==1,:);%Yeast spots
    
    %     Dist2fSpots=nan(length(Steplength_mod{lfly}),size(f_spot,1));
    %     for n=1:size(f_spot,1)
    %         Dist2fSpots(:,n)=sqrt(sum(((Heads_Sm{lfly}(1:length(Steplength_mod{lfly}),:)-...
    %             repmat(f_spot(n,:),...
    %             length(Steplength_mod{lfly}),1)).^2),2));
    %     end
    %     [~,R]=cart2pol(Heads_Sm{lfly}(1:params.MinimalDuration,1),Heads_Sm{lfly}(1:params.MinimalDuration,2));
    %     log_edge=R*params.px2mm>=params.OuterRingRadious;
    %     log_vectIn=(sum(Dist2fSpots<=(2.5/params.px2mm),2)==1)&(Steplength_mod{lfly}<...
    %         params.StopVel/params.px2mm/params.framerate);%&(Steplength_mod{lfly}>0);%
    %     log_vectOut=(sum(Dist2fSpots<=(2.5/params.px2mm),2)==0)&(Steplength_mod{lfly}<...
    %         params.StopVel/params.px2mm/params.framerate);%&(Steplength_mod{lfly}>0);%
    %     VelHistCount_Out(:,lfly)=hist(Steplength_mod{lfly}*params.px2mm*params.framerate,Vel_range);%Steplength_mod{lfly}(log_vectOut)
    if nargin==7%divide speed inside and outside spots
        logic_subs=false(params.MinimalDuration,1);
        for lsubscounter=1:length(CumTimeEnc)
            logic_subs=logic_subs|CumTimeEnc{lsubscounter}(:,lfly);
        end
        VelHistCount_In(:,lfly)=hist(Steplength{lfly}(logic_subs)*params.px2mm*params.framerate,Vel_range);%Steplength_mod{lfly}(log_vectIn)
        VelHistCount_Out(:,lfly)=hist(Steplength{lfly}(~logic_subs)*params.px2mm*params.framerate,Vel_range);%Steplength_mod{lfly}(log_vectIn)
    else
        VelHistCount_In(:,lfly)=hist(Steplength{lfly}(1:params.MinimalDuration)*params.px2mm*params.framerate,Vel_range);%Steplength_mod{lfly}(log_vectIn)
        
    end
    
    
    
end
if params.Subs_Numbers(1)==4
    paramsA=params;
    VelHistCount_InA=VelHistCount_In;
    VelHistCount_OutA=VelHistCount_Out;
    save(['E:\Analysis Data\Experiment 0004\Variables\VelHistCount_InA ' date '.mat'],'VelHistCount_InA','VelHistCount_OutA','paramsA')
end
%% Plot speed histogram
% close all
inact_thr=0.2;
plots2plot=[1:4];
for currplot=plots2plot%1:In,2
    Symbol_plot={'-';'-.';'-';'-.'};%{'-';'-';'-';'-'};%
    
    subplots=1; %%When plotting each condition in a subplot
    switch currplot
        case 1
            VelHistCount=VelHistCount_In;
            params_plot=params;
        case 2
            VelHistCount=VelHistCount_Out;
            params_plot=params;
        case 3
            load('E:\Analysis Data\Experiment 0004\Variables\VelHistCount_InA 15-Feb-2016.mat')
            VelHistCount=VelHistCount_InA;
            params_plot=paramsA;
        case 4
            load('E:\Analysis Data\Experiment 0004\Variables\VelHistCount_InA 15-Feb-2016.mat')
            VelHistCount=VelHistCount_OutA;
            params_plot=paramsA;
    end
    
    VelFreq=VelHistCount./repmat(nansum(VelHistCount),length(Vel_range),1);
    CondVelfr_mean=nan(size(VelHistCount,1),length(unique(params_plot.ConditionIndex)));
    CondVelfr_stderr=nan(size(VelHistCount,1),length(unique(params_plot.ConditionIndex)));
    
    [Colormap,Cmap_patch]=Colors(length(Conditions));
    if currplot==1,
            figure('Position',[100 50 900 900],'Color','w','Name',['Head speed in&out spots hist cond' num2str(Conditions) ' ' date],...
                'PaperUnits',...
                'centimeters','PaperPosition',[0 0 7.5 5.5])
        if subplots==1
            h=zeros(length(Conditions),3);% 3 for inside Y, outside Y, inside A
        else
            h=zeros(length(Conditions),1);
        end
    end
    
    lcondcounter=1;
    maxMovingFreq=nan(length(Conditions),1);
    for lcond=Conditions
        CondVelfr_mean(:,lcondcounter)=nanmean(VelFreq(:,params_plot.ConditionIndex==lcond),2);
        CondVelfr_stderr(:,lcondcounter)=nanstd(VelFreq(:,params_plot.ConditionIndex==lcond),0,2)./sqrt(sum(params_plot.ConditionIndex==lcond));
        if subplots==1
            if length(Conditions)>1
                subplot(2,ceil(length(Conditions)/2),lcondcounter)
            end
            if currplot>2
                Colorplot=[0 0 0];
                Colorpatch=[233 233 233]/255;
            else
                Colorplot=Colormap(lcondcounter,:);
                Colorpatch=Cmap_patch(lcondcounter,:);
            end
            h(lcondcounter,currplot)=plot(Vel_range,CondVelfr_mean(:,lcondcounter),Symbol_plot{currplot},'Color',Colorplot,...
                'LineWidth',1,'MarkerSize',1);
            
            hold on
            font_style(params.Labels{lcond},'Head speed (mm/s)',...
                'Ocurrences (normalized)','normal',fontName,FontSz+1)%Uncomment for subplots
        else
            Colorpatch=Cmap_patch(lcondcounter,:);
            h(lcondcounter)=plot(Vel_range,CondVelfr_mean(:,lcondcounter),Symbol_plot{lcondcounter},'Color',Colormap(lcondcounter,:),...
                'LineWidth',1,'MarkerSize',2);
            hold on
        end
        jbfill(Vel_range,[CondVelfr_mean(:,lcondcounter)+CondVelfr_stderr(:,lcondcounter)]',...
            [CondVelfr_mean(:,lcondcounter)-CondVelfr_stderr(:,lcondcounter)]',...
            Colorpatch,Colorpatch,0,0.5);
        maxMovingFreq(lcondcounter)=max(CondVelfr_mean(Movingbins:end,lcondcounter)+...
            CondVelfr_stderr(Movingbins:end,lcondcounter));
        
        lcondcounter=lcondcounter+1;
    end
    
    if subplots==1 && currplot==max(plots2plot)
        lcondcounter=1;
        for lcond=Conditions
            if length(Conditions)>1
                subplot(2,ceil(length(Conditions)/2),lcondcounter)
            end
            
            legend(h(lcondcounter,:),{'Inside food patches';'Outside food patches';'Inside agarose patches';'Outside agarose patches';})
%             legend('boxoff')
%             axis([0 2 0 0.15])%for 40 bins axis([0 2 0 0.15])
            axis([0 Vel_range(end) -0.01 0.3])%axis([0 5 0 0.015])
            plot([inact_thr inact_thr],[-.01 1],':','Color',[0.7 0.7 0.7],'LineWidth',.8)
            plot([2 2],[-0.01 1],':','Color',[0.7 0.7 0.7],'LineWidth',.8)
            lcondcounter=lcondcounter+1;
        end
    elseif subplots~=1
        font_style([],'Speed (mm/s)',...['Smoothed (w=20), ' num2str(length(Vel_range)),' bins, Vmax=' num2str(Vel_range(end))]
            'Frequency','bold',fontName,FontSz)%Uncomment for not subplots
        
        Y_axis_lim=get(gca,'YLim');
        plot([params.Microm_Vel params.Microm_Vel],Y_axis_lim,'--k','LineWidth',1)
        htext=text(params.Microm_Vel,0.1*max(maxMovingFreq)/2,'Micromovement');
        set(htext,'FontName',fontName,'FontSize',FontSz);
        plot([params.Walk_Vel params.Walk_Vel],Y_axis_lim,'--m','LineWidth',1)
        htext2=text(params.Walk_Vel,0.2*max(maxMovingFreq)/2,'Walking');
        set(htext2,'FontName',fontName,'FontSize',FontSz,'Color','m');
        % set(gca,'XLim',[4 15],'YScale','log','YLim',[1e-3 5e-3])%0.05])
        % plot([2 2],[1e-3 0.05],'--k','LineWidth',1)
        axis([0 Vel_range(end) 0 max(maxMovingFreq)])%axis([0 5 0 0.015])
        legend(h,params.LabelsShort(Conditions),'Location','Best')%Uncomment for not subplots
        legend('boxoff')
    end
end

savefig_withname(0,'600','png',DataSaving_dir_temp,Exp_num,Exp_letter,'Activity')