function [p_engagement_given_speed,InactDur]=speed_engagement(speed,params)
% p_engagement_given_dist2spot=speed_engagement(speed)
% input in mm/s.
% speed is a col vector
% %% Defining Straight Line params
f=@(b,x) (b(1).*x) + b(2);
% % fitparams = nlinfit([params.Microm_Vel params.Walk_Vel],[1 0],...
% %     f,[-1 1],statset('Display','final'));%Linear decay from Micromovement
% %     %to walking
% fitparams=[-0.5,2];
% %%% Computing R2
% % yresid = y2fit - f(fitparams,x2fit);
% % SSresid = sum(yresid.^2);
% % SStotal = (length(y2fit)-1) * var(y2fit);
% % Rsq = 1 - SSresid/SStotal; % Compute R2
% 
% %% Function
% p_engagement_given_dist2spot=zeros(size(speed,1),1);
% p_engagement_given_dist2spot((speed>params.Stop_Vel)&(speed<=params.Microm_Vel))=1;
% p_engagement_given_dist2spot((speed>params.Microm_Vel)&(speed<=params.Walk_Vel))=...
%     f(fitparams,speed((speed>params.Microm_Vel)&(speed<=params.Walk_Vel)));
%% Using Gaussian
% speed=(0:5/999999:5)';% Uncomment to plot
SpeedLowLim=2;%1;%
x_displacement=SpeedLowLim-0.10122;
sigma=0.335;
mu=-0.0968+x_displacement;


f2=@(sigma,mu,x) (1/sqrt(2*pi*(sigma^2)))*exp((-1/(2*sigma^2))*((x-mu).^2));
% %%% Finding Speed low limit:
% % % p_eng_temp=f2(sigma,mu,speed);
% % % [~,min_idx]=min(abs(p_eng_temp-1));
% % % SpeedLowLim=speed(min_idx+1);%1;%2.7;%params.Microm_Vel;%
% % % f2(sigma,mu,SpeedLowLim)
% % % SpeedLowLim=0.10122;
SpeedMaxLim=4;%params.Walk_Vel;
%%
p_engagement_given_speed=zeros(size(speed,1),1);
p_engagement_given_speed((speed>params.Stop_Vel)&(speed<=SpeedLowLim))=1;
p_engagement_given_speed((speed>SpeedLowLim)&(speed<=SpeedMaxLim))=...
   f2(sigma,mu,speed((speed>SpeedLowLim)&(speed<=SpeedMaxLim)));
p_engagement_given_speed((speed<=params.Stop_Vel))=1;%%% Without Removing the Long Inactivity Periods

%%% plot --> Uncomment to visualize function
% figure
% line(speed,p_engagement_given_speed,'Color',[228 108 10]/255,'LineWidth',3);%[84 130 53]/255
% font_style([],[],...
%         'p(engagement|speed)','bold','calibri',20)
% set(gca,'XColor',[228 108 10]/255,'YColor',[228 108 10]/255)%[84 130 53]/255
% xlim([speed(1) speed(end)])
%% Long inactivity Periods
log_inact=speed<=params.Stop_Vel;
tempconv=conv(double(log_inact),[1 -1]);
tempInOut=diff(find(tempconv));
InactDur=tempInOut(1:2:end);
% 
% %%% Removing Long inactivity Periods
% InactIn=find(tempconv==1);
% InactOut=find(tempconv==-1);
% InactOut(InactOut==length(speed)+1)=length(speed);
% 
% LongInactThr=10;%s 200 bins, 20s for all trajectory. 3.5;%s Calculated with 200 bins maxtime=20s. >99%. mean.
% % % % f=@(b,x) (b(1).*x) + b(2);%%
% % % % fitparams2 = nlinfit([0 LongInactThr],[1 0],...
% % % %     f,[-1 1],statset('Display','final'));% x=Inactive time, y=prob.
% % % % Linear decay from 0 s inactive until Long Inactivity Threshold
% fitparams2=[-0.1 1];%for LongInactThr=10; %[-0.2872 1];%for LongInactThr=3.5;
% if ~isempty(InactIn)
% for l_in=InactIn'
%     x_temp=cumsum(log_inact(l_in:InactOut(InactIn==l_in)-1)/params.framerate);
%     x=x_temp(x_temp<LongInactThr);
%     p_engagement_given_speed(l_in:l_in+length(x)-1)=f(fitparams2,x);
%     if ~isempty(find(x_temp>=LongInactThr,1,'First'))
%         p_engagement_given_speed(l_in+find(x_temp>=LongInactThr,1,'First')-1:InactOut(InactIn==l_in)-1)=0;
%     end
% end
% end
%% Fitting Gaussian Function into Histogram Data
% lcond=3;
% y_Exp=Condfr_mean(:,lcond);
% y_Exp=y_Exp/max(y_Exp);
% x_ymax=x_Exp(y_Exp==max(y_Exp));
% x_Exp=Speed_range';
% %%% Using Gaussian
% b(2)=0.3133;%Sigma
% mu=x_ymax%mu=Peak of the distribution 2.7;%params.Microm_Vel;%
% SpeedMaxLim=5;%params.Walk_Vel;
% % f2=@(b,x) b(1)*exp((-1/(2*b(2)^2))*((x-b(3)).^2))+b(4);
% f2=@(b,x) (1/sqrt(2*pi*(b(1)^2)))*exp((-1/(2*b(1)^2))*((x-b(2)).^2));
% 
% %%% Fitting
% % fitparams2 = nlinfit(x_Exp(find(x_Exp==x_ymax):find(x_Exp==1.2)), y_Exp(find(x_Exp==x_ymax):find(x_Exp==1.2)),...
% %     f2,[1 mu],statset('Display','final'));% x=Inactive time, y=prob.
% %%% plot --> Uncomment to visualize function
% figure
% fitparams2=[0.335 -0.0968];
% line(x_Exp(find(x_Exp==x_ymax):find(x_Exp==2)),y_Exp(find(x_Exp==x_ymax):find(x_Exp==2)),'Color','k','LineWidth',3);%[84 130 53]/255
% hold on
% line(x_Exp(find(x_Exp==x_ymax):find(x_Exp==2)),f2(fitparams2,x_Exp(find(x_Exp==x_ymax):find(x_Exp==2))),'Color',[228 108 10]/255,'LineWidth',2);%[84 130 53]/255
% 
% font_style([],[],...
%         'p(engagement|speed)','bold','calibri',20)
% set(gca,'XColor',[228 108 10]/255,'YColor',[228 108 10]/255)%[84 130 53]/255
% xlim([x_Exp(1) x_Exp(find(x_Exp==2))])

    