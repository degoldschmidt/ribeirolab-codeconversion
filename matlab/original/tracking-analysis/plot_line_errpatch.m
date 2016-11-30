function h=plot_line_errpatch(x,y,stderr,linecolor,patchcolor)
%%% Input column vectors!!
x=x';
h=plot(x,y,'-',...
    'Color',linecolor,'LineWidth',1);
hold on
upper=[y+stderr]';
lower=[y-stderr]';

filled=[upper,fliplr(lower)];
xpoints=[x,fliplr(x)];
fillhandle=fill(xpoints,filled,patchcolor);%plot the data
set(fillhandle,'EdgeColor',patchcolor,'FaceAlpha',.5,'EdgeAlpha',.5);%set edge color
end