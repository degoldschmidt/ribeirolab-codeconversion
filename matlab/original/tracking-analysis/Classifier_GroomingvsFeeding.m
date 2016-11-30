%% Grooming or feeding classification
cum_gauss=@(sigma,mu,x) (1/sqrt(2*pi*(sigma^2)))*sum(exp((-1/(2*sigma^2))*((-(-1e5:x)-mu).^2)));




% 
% xlowlim=2;%
% xuplim=4;
% % fitparams = nlinfit([xlowlim xuplim],[1 0],...
% %     f,[1 1],statset('Display','final'));%Exponential decay from 3.5 mm until 4.5
% fitparams=[-0.5,2];