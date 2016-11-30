function plotstatsFig7(p,Perc_selfY,l1,l2,yposstats,FtSz,FntName)
vertical='middle';
margin=2;
if (p<0.05)&&(p>=0.01)
    textstring='*';
    NewFtSz=FtSz+6;
elseif (p<0.01)&&(p>=0.001)
    textstring='**';
    NewFtSz=FtSz+6;
elseif (p<0.001)
    textstring='***';
    NewFtSz=FtSz+6;
elseif isnan(p)
    textstring='nan';
    vertical='bottom';
    margin=1;
    NewFtSz=FtSz;
else
    textstring='ns';
    vertical='bottom';
    margin=1;
    NewFtSz=FtSz;
end

plot([Perc_selfY(l1) Perc_selfY(l2)],...
    [yposstats yposstats],'-k','LineWidth',.8);

text((Perc_selfY(l2)-Perc_selfY(l1))/2+Perc_selfY(l1),...
    yposstats,textstring,'HorizontalAlignment','center',...
    'VerticalAlignment',vertical,'Margin',margin,'FontSize',NewFtSz,'FontName',FntName);