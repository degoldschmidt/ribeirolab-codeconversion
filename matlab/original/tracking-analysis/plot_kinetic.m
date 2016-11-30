function h=plot_kinetic(X,framesrange,Xrange,lowthr,uppthr,LineWidth,Color)
% plot_kinetic(X) plots vector X "a la" Vero inside a loop if delay>0,
% generating a dynamic plot. If delay is zero, it just plots vector X and
% var lframe won't be used.
%
%   plot_kinetic(X,range,delay,lowthr,uppthr,LineWidth,Color)

if nargin==1,framesrange=1:length(X);Xrange=framesrange;lowthr=0;uppthr=0;LineWidth=3;Color=[235 135 15]/255;end
if nargin==2,Xrange=framesrange;lowthr=0;uppthr=0;LineWidth=3;Color=[235 135 15]/255;end
if nargin==3,lowthr=0;uppthr=0;LineWidth=3;Color=[235 135 15]/255;end
if nargin==4,uppthr=0;LineWidth=3;Color=[235 135 15]/255;end
if nargin==5,LineWidth=3;Color=[235 135 15]/255;end
if nargin==6,Color=[235 135 15]/255;end


hold on
if ~isnan(lowthr)
plot([Xrange(1) Xrange(end)],[lowthr lowthr],'-.','LineWidth',LineWidth,'Color',[0.7 0.7 0.7])%plot(x_lim,[2 2],'-.b')
plot([Xrange(1) Xrange(end)],[uppthr uppthr],'-.','LineWidth',LineWidth,'Color',[0.7 0.7 0.7])%plot(x_lim,[params.Microm_Vel params.Microm_Vel],'--b')
end

h=plot(Xrange,...
    X(framesrange),...
    'LineWidth',LineWidth,'Color',Color);