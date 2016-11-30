%% Defining Voronoi bouts
%% Getting and plotting Voronoi vectors
close all
plot_arenacircles
hold on
spotidxs=1:18;
h=voronoi(WellPos(spotidxs,1),WellPos(spotidxs,2));
set(h, 'Color','g', 'LineWidth',1)%[.4 .4 .4]
[vx,vy]=voronoi(WellPos(spotidxs,1),WellPos(spotidxs,2));
% circle_([0,0], pdist2([vx(1,24) vy(1,24)],[ 0 0 ] ),1000,'-k')
axis off

for lspot=1:18
plotprox=circle_(WellPos(lspot,:),10/params.px2mm,1000,':r');
pause
set(plotprox,'Visible','off')
end