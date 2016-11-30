function p_engagement_given_dist2spot=dist2spot_engagement(dist2spot)
% p_engagement_given_speed=dis2spot_engagement(dist2spot)
% input in mm.
% dist2spot is a col vector

% %% Defining Straight Line params
% f=@(b,x) (b(1).*x) + b(2);
% 
% xlowlim=2;%
% xuplim=4;
% % fitparams = nlinfit([xlowlim xuplim],[1 0],...
% %     f,[1 1],statset('Display','final'));%Exponential decay from 3.5 mm until 4.5
% fitparams=[-0.5,2];
% 
% %%% Computing R2
% % yresid = y2fit - f(fitparams,x2fit);
% % SSresid = sum(yresid.^2);
% % SStotal = (length(y2fit)-1) * var(y2fit);
% % Rsq = 1 - SSresid/SStotal; % Compute R2
% 
% %% Function
% p_engagement_given_speed=zeros(size(dist2spot,1),1);
% p_engagement_given_speed(dist2spot<=xlowlim)=1;
% p_engagement_given_speed((dist2spot>xlowlim)&(dist2spot<=xuplim))=...
%    f(fitparams,dist2spot((dist2spot>xlowlim)&(dist2spot<=xuplim)));


%% Using Gaussian
% dist2spot=(0:4.5/299:4.5)'; % Uncomment to plot
f2=@(sigma,mu,x) (1/sqrt(2*pi*(sigma^2)))*exp((-1/(2*sigma^2))*((x-mu).^2));
xlowlim=1.9;%2.5;
xuplim=4;%3.5;
p_engagement_given_dist2spot=zeros(size(dist2spot,1),1);
p_engagement_given_dist2spot(dist2spot<=xlowlim)=1;
p_engagement_given_dist2spot((dist2spot>xlowlim)&(dist2spot<=xuplim))=...
   f2(0.4,xlowlim,dist2spot((dist2spot>xlowlim)&(dist2spot<=xuplim)));
%%% plot --> Uncomment to visualize function
% line(dist2spot,p_engagement_given_dist2spot,'Color',[228 108 10]/255,'LineWidth',3);%[84 130 53]/255
% font_style([],[],...
%         'p(engagement|distance to spot)','bold','calibri',20)
% set(gca,'XColor',[228 108 10]/255,'YColor',[228 108 10]/255)%[84 130 53]/255
% xlim([dist2spot(1) dist2spot(end)])
