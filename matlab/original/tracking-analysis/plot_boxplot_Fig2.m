function [fillhandle,lineh,thandle] = plot_boxplot_Fig2(X,labels,xvalues,...
    boxcolors,mediancolor,markercolor,boxwidth,FontSz,fontName,markertype)
%[fillhandle,thandle] = plot_boxplot_tiltedlabels(X,labels,xvalues,...
%     boxcolors,mediancolor,markercolor,boxwidth,FontSz,fontName,markertype)
% boxplot_tiltedlabels plots one boxplot per column of X
% length(labels) must be the equal to columns in X

if nargin==2,xvalues=1:size(X,2);boxcolors=repmat([.5 .5 .5],size(X,2),1);mediancolor=zeros(size(X,2),3);markercolor='k';boxwidth=0.25;FontSz=10;fontName='arial';markertype='o';end
if nargin==3,boxcolors=repmat([.7 .7 .7],size(X,2),1);mediancolor=zeros(size(X,2),3);markercolor='k';boxwidth=0.25;FontSz=10;fontName='arial';markertype='o';end
if nargin==4,mediancolor=zeros(size(X,2),3);markercolor='k';boxwidth=0.25;FontSz=10;fontName='arial';markertype='o';end
if nargin==5,markercolor='k';boxwidth=0.25;FontSz=10;fontName='arial';markertype='o';end
if nargin==6,boxwidth=0.25;FontSz=10;fontName='arial';markertype='o';end
if nargin==7,FontSz=10;fontName='arial';markertype='o';end
if nargin==8,fontName='arial';markertype='o';end
if nargin==9,markertype='o';end

%% Plotting shaded IQR box
fillhandle=nan(size(X,2),1);
for lcol=1:size(X,2)
    Y=X(:,lcol);
    fillhandle(lcol)=fill([repmat(xvalues(lcol)-boxwidth/2,2,1);...
        repmat(xvalues(lcol)+boxwidth/2,2,1)],...
        [prctile(Y,25);...
        repmat(prctile(Y,75),2,1);...
        prctile(Y,25)],...
        boxcolors(lcol,:));%plot the data
    set(fillhandle(lcol),'EdgeColor',[.5 .5 .5],'LineWidth',.5)%,...
%                 'FaceAlpha',.2,'EdgeAlpha',.2);%set edge color
    hold on
    
end



%% plotting spread points
plotSpread(X,'xValues',xvalues,'distributionColors',[.5 .5 .5],...[.7 .7 .7]
    'distributionMarkers',markertype,'distributionMarkersSize',3,...5
    'distributionFaceColors',markercolor,'spreadWidth',boxwidth*1.8)
%% plotting line in median
lineh=nan(size(X,2),1);
size_labels=nan(size(X,2),1);
for lcol=1:size(X,2)
    Y=X(:,lcol);
%     plot([xvalues(lcol)-boxwidth-.01*boxwidth;xvalues(lcol)+boxwidth+.01*boxwidth],...
%         repmat(nanmedian(Y),2,1),...
%         'Color','k','LineWidth',2)
    lineh(lcol)=plot([xvalues(lcol)-boxwidth/1.5;xvalues(lcol)+boxwidth/1.5],...
        repmat(nanmedian(Y),2,1),...
        'Color',mediancolor(lcol,:),'LineWidth',1);
    size_labels(lcol)=length(labels{lcol});
end
%% writing tilted labels
set(gca,'XTick',[],'XTickLabel',[])

%%% Rotate x axis labels
if max(size_labels)>20
    angle_labels=15;
else
    angle_labels=20;%0;%
end
set(gca,'box','off')
ax=[0];%get(gca,'Ylim');
thandle=text(xvalues,ax(1)*ones(1,length(labels)),labels);

set(thandle,'HorizontalAlignment','right','VerticalAlignment','top',...'center'
    'Rotation',angle_labels,'FontSize',FontSz,'FontName',fontName);


end

