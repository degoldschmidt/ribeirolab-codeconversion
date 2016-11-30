%% %% Removing Small Peaks %% %%
% 
%% Smoothing Engagement Trace
range_conv=200;%Current=400;%8%34;
mu=0;
sigma=20;%Current=40;%0.9%4;

f2=@(sigma,mu,x) (1/sqrt(2*pi*(sigma^2)))*exp((-1/(2*sigma^2))*((x-mu).^2));

v=f2(sigma,mu,-range_conv/2:range_conv/2);
v(1)=0;v(end)=0;%v(1:2)=0;v(end-2:end)=0;
Engagement_p_sm=zeros(size(Engagement_p));

for lfly=flies_idx
    for lsubs=1:length(params.Subs_Names)
        %% Smoothing engagement
        Engag_temp=conv(Engagement_p(:,lfly,lsubs),v);
        Engagement_p_sm(:,lfly,lsubs)=Engag_temp(range_conv/2+1:end-range_conv/2);
    end
end
% save([Variablesfolder 'Engagement_p_Sm_range200,sig=20, ' Exp_num Exp_letter ' ' date '.mat'],'Engagement_p_sm','-v7.3')
%% Find peaks
% % fig=figure('Position',[100 50 params.scrsz(3)-150 params.scrsz(4)-150],'Color','w');
% % Subs_Color={'-b';'-r'};
% % lfly=1;
% % for lsubs=1
% % xpeaks=find(((diff(sign(diff(Engagement_p_sm(:,lfly,lsubs)))))==-2)|...
% %     ((diff(sign(diff(Engagement_p_sm(:,lfly,lsubs)))))==-1))-1;
% % peaksHeight=Engagement_p_sm(xpeaks,lfly,lsubs);
% % numpeaks=20;
% % for lpeakcounter=1:length(xpeaks)-numpeaks
% %     if (xpeaks(lpeakcounter+numpeaks)-xpeaks(lpeakcounter))<=15000
% %         if sum(peaksHeight(lpeakcounter:lpeakcounter+numpeaks)>0.05)>=(numpeaks/2)
% %             clf
% %             range_engagem=xpeaks(lpeakcounter):xpeaks(lpeakcounter+numpeaks);
% %             Engage_temp=Engagement_p(range_engagem,lfly,lsubs);
% %         Engage_log=Engage_temp'>0;
% %         TempIn=find(conv(double(Engage_log),[1 -1])==1);%Row vector
% %         TempOut=find(conv(double(Engage_log),[1 -1])==-1);%Row vector
% %         TempOut(TempOut==length(range_engagem)+1)=...
% %             length(range_engagem);
% %
% %         ColorAUC=Colors(length(TempIn));
% %         for l_in=TempIn
% %             %             Engag_p=Engagement_p{lsubs}(l_in:TempOut(l_in==TempIn)-1,lfly);
% %             Engag_p_bout=Engage_temp(l_in:TempOut(l_in==TempIn)-1);
% %             % Area under the curve (AUC) <-- Average Time
% %             AUC=trapz(Engag_p_bout)/params.framerate;%s
% %             %%% Identifying the spot
% %             [~,max_idx]=max(Engag_p_bout);
% %             area(l_in+range_engagem(1)-1:TempOut(l_in==TempIn)+range_engagem(1)-2,Engag_p_bout,...
% %     'LineWidth',2,'FaceColor',ColorAUC(l_in==TempIn,:),'EdgeColor','b')
% % hold on
% %         end
% %         xlim([range_engagem(1) TempOut(end)+range_engagem(1)])
% %         plot(range_engagem,Engagement_p(range_engagem,lfly,lsubs),Subs_Color{lsubs},'LineWidth',1)
% %         plot(range_engagem,Engagement_p_sm(range_engagem,lfly,lsubs),'-k','LineWidth',3)
% %
% %     pause
% %
% %         end
% %     end
% %
% % end
% % end
% %% Testing Peak finder
% fig=figure('Position',[100 50 params.scrsz(3)-150 params.scrsz(4)-150],'Color','w');
% lfly=1;
% range_engagem=332963:344856;%296836:296854;%15988:25973;%
% 
% for lsubs=1
%     % Food-bouts Durations %%
%     Engage_temp=Engagement_p(range_engagem,lfly,lsubs);
%     Engage_log=Engage_temp'>0;
%     TempIn=find(conv(double(Engage_log),[1 -1])==1);%Row vector
%     TempOut=find(conv(double(Engage_log),[1 -1])==-1);%Row vector
%     TempOut(TempOut==length(range_engagem)+1)=...
%         length(range_engagem);
%     
%     ColorAUC=Colors(length(TempIn));
%     for l_in=TempIn
%         Engag_p=Engagement_p(l_in:TempOut(l_in==TempIn)-1,lfly,lsubs);
%         Engag_p_bout=Engage_temp(l_in:TempOut(l_in==TempIn)-1);
%         %             Area under the curve (AUC) <-- Average Time
%         AUC=trapz(Engag_p_bout)/params.framerate;%s
%         %% Identifying the spot
%         [~,max_idx]=max(Engag_p_bout);
%         area(l_in+range_engagem(1)-1:TempOut(l_in==TempIn)+range_engagem(1)-2,Engag_p_bout,...
%             'LineWidth',2,'FaceColor',ColorAUC(l_in==TempIn,:),'EdgeColor','b')
%         hold on
%         [maxeng,maxidx]=max(Engage_temp(l_in:TempOut(l_in==TempIn)-1));
%         text(l_in+maxidx+range_engagem(1)-1,maxeng+0.05,num2str(maxeng),...
%             'FontName','calibri','FontSize',14)
%     end
%     xlim([range_engagem(1) TempOut(end)+range_engagem(1)])
%     
% end
% plot(range_engagem,Engagement_p(range_engagem,lfly,1),'-.b','LineWidth',1)
% hold on
% plot(range_engagem,Engagement_p(range_engagem,lfly,2),'-.r','LineWidth',1)
% 
% plot(range_engagem,Engagement_p_sm(range_engagem,lfly,1),'-k','LineWidth',3)
% plot(range_engagem,Engagement_p_sm(range_engagem,lfly,2),'-r','LineWidth',3)
% 
% xpeaks=range_engagem(1)+find(((diff(sign(diff(Engagement_p_sm(range_engagem,lfly,lsubs)))))==-2)|...
%     ((diff(sign(diff(Engagement_p_sm(range_engagem,lfly,lsubs)))))==-1))-1;
% 
% for lpeak=xpeaks'
%     text(lpeak,(Engagement_p_sm(lpeak,lfly,lsubs))+0.05,num2str(Engagement_p_sm(lpeak,lfly,lsubs)),...
%         'FontName','calibri','FontSize',14)
% end
% font_style([],'frames','p(engagement)','normal','calibri',20)
% 
% % %% Finding Smoothing parameters manually
% figure
% lfly=1;%7;%32;%
% lsubs=2;
% range_engagem=332963:344856;%296836:296854;%15988:25973;%
% 
% 
% range_conv=400;%8%34;
% p_engagement32_Y=Engagement_p(range_engagem,lfly,1);
% p_engagement32_S=Engagement_p(range_engagem,lfly,2);
% mu=0;
% sigma=40;%0.9%4;
% 
% f2=@(sigma,mu,x) (1/sqrt(2*pi*(sigma^2)))*exp((-1/(2*sigma^2))*((x-mu).^2));
% 
% v=f2(sigma,mu,-range_conv/2:range_conv/2);
% v(1)=0;v(end)=0;%v(1:2)=0;v(end-2:end)=0;
% 
% filtY=conv(p_engagement32_Y,v);
% filtS=conv(p_engagement32_S,v);
% display(size(p_engagement32_Y))
% display(size(v))
% display(size(filtY))
% display(['max filtY: ' num2str(max(filtY))])
% clf
% subplot(2,1,1)
% plot(v,'LineWidth',2)
% font_style([],'frames',[],'normal','calibri',14)
% subplot(2,1,2)
% plot(range_engagem,p_engagement32_Y,'-.b','LineWidth',1)
% hold on
% plot(range_engagem,p_engagement32_S,'-.r','LineWidth',1)
% font_style([],'frames','p(engagement)','normal','calibri',20)
% hold on
% % plot((range_engagem(1)-range_conv/2):(range_engagem(end)+range_conv/2),filt,'-r')
% plot(range_engagem,filtY(range_conv/2+1:end-range_conv/2),'-b','LineWidth',2)
% plot(range_engagem,filtS(range_conv/2+1:end-range_conv/2),'-r','LineWidth',2)

%% PLOTTING FLY 1 MULTIPLE PEAKS
% load([Variablesfolder 'ManualAnnotation0003A 06-Oct-2014.mat'])
ForVideo=[19500 21500 30];%Fly30

Color=Colors(2);
Param_color=[235 135 15]/255;

close all
ManualAnnotation.YFeedingEvents=[332950 345000 14 1];%[start end spot fly]
plotmanual_ann_edge=0;
ltracecounter=1;
Vartoplot='YFeedingEvents';%'Not_engage_Y';%'Revisits';%'Edge';%Yi_Yj;%Grooming;%Not_engage_Y;%
FtSz=26;%20;
ltrace=ManualAnnotation.(Vartoplot)(1,1)'
lfly=ManualAnnotation.(Vartoplot)(ManualAnnotation.(Vartoplot)(:,1)==ltrace,4);
Geometry=FlyDB(lfly).Geometry;

event_label='YFeeding - ';
deltaf=0;
range=ltrace-deltaf:ManualAnnotation.(Vartoplot)(ManualAnnotation.(Vartoplot)(:,1)==ltrace,2)+deltaf;
insec=1;%0;

timerange=(1:length(range));%s =range;%default in frames%
x_label='Time (frames)';
if insec==1,
    framerate=params.framerate;
    timerange=range/params.framerate;
    delta=deltaf/params.framerate;
    x_label='Time (s)';
else
    framerate=0;
    delta=deltaf;
end
frames=range;%To be the same that the dynamic plot
timerange2=timerange;%To be the same that the dynamic plot
x_lim=[timerange(1) timerange(end)];

Spots=ManualAnnotation.(Vartoplot)(ManualAnnotation.(Vartoplot)(:,1)==ltrace,3);
lsubs=Geometry(Spots);


%%% Plotting tracks top and engagement bottom
fig=figure('Position',[2001 53 1486 930],'Color','w');
fps=20;
step=10;
delay=0;%20;%30;%if larger than zero will show dynamic plot

axeslimstraj=[min(Heads_Sm{lfly}(range,1)) max(Heads_Sm{lfly}(range,1)),...
    min(Heads_Sm{lfly}(range,2)) max(Heads_Sm{lfly}(range,2))]*params.px2mm;

ColorsTraj=Colors(3);

%%% Head Trajectory and dynamic body orientation with delay
subplot('Position',[0.2703,0.4262,0.4172,0.5062])
hold on

%%% Thick and thin line for Heads
hc(2)=plot_tracks_single(FlyDB,Heads_Sm{lfly},lfly,Spots,params,1,...
    Color(1,:),frames,FtSz,1,4);

plot_tracks_single(FlyDB,Heads_Sm{lfly},lfly,Spots,params,1,...
    'k',frames,FtSz,0,1);

axis(axeslimstraj)
axis off

%%% Engagement
subplot('Position',[0.1003,0.0802,0.8277,0.2441])
hold on
severalplots=0;%1 to plot engagement for both substrates
clear X
X=Engagement_p(:,lfly,lsubs);
var_label='Engagement index';
figname=[];
lowthr=nan;uppthr=0;

   plot_kinetic(X,frames,timerange2,lowthr,uppthr,3,[238 96 8]/255);
    plot_kinetic(X,frames,timerange2,lowthr,uppthr,1,'k');

font_style(figname,x_label,var_label,'normal','calibri',FtSz)
xlim(x_lim)
y_lim=[0 1.1];
if plotmanual_ann_edge==1;
    plot([timerange(1)+delta timerange(1)+delta],y_lim,'--k',[timerange(end)-delta,...
        timerange(end)-delta],y_lim,'--k', 'LineWidth',2,'Color',[192 0 0]/255)
end
ylim(y_lim)
%%%
figname=[event_label 'Engage,Dist2Spot,Speed,Traj - Fly ' num2str(lfly),...
    ', ' num2str(range(1)-delay) ' to ' num2str(range(end)+delay) '_LM'];
%     saveplots(Dropbox_choicestrategies,'Manual Ann',figname,DataSaving_dir_temp,Exp_num,0,0)
