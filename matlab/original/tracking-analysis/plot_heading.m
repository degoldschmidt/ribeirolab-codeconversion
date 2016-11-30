function plot_heading(X_Y,Heads,Tails,px,Color_a,params,range,shortening,HeadSz,LnWidth,Color_c)
% Plots arrows correspoding to body orientation Tail to Head. Doesn't clear previous figure
% Use: plot_heading(X_Y_Centers,Heads,Tails,px,ArrowColor,params,range,...
%           shortening,HeadSz,CenterColor)
% Inputs:
% X_Y_Centers       [X Y] positions where the arrow starts. Size=length(range) x n
% Heads             [X Y] Head positions. Size=length(range) x n
% Tails             [X Y] Tail positions. Size=length(range) x n
% px                1 when the input coordinates are in px, 0 otherwise
% ArrowColor        A three-element RGB vector
% range             frames to plot                 
% shortening        Factor to divide vector that goes from tail to head
%                   If shortening = 2; and X_Y are centroids, the arrow
%                   will go from the centroid to the head
% HeadSize          A value determining the maximum size of the arrowhead
%                   relative to the length of the arrow. Default is 0.2
% CenterColor       A three-element RGB vector. If this appears as input, 
%                   this function plots the centers of the arrows X_Y of this color.

if nargin==7,shortening=2;HeadSz=0.2;LnWidth=3;Color_c='k';end
if nargin==8,HeadSz=0.2;LnWidth=3;Color_c='k';end
if nargin==9,LnWidth=3;Color_c='k';end
%% Plotting Trajectory
%     figure
% range=46620:47623;%1:length(Tails);%250000:300025;%
if px==1, 
    X_Y=X_Y*params.px2mm;
    Heads=Heads*params.px2mm;
    Tails=Tails*params.px2mm;
end
if nargin==11
    plot(X_Y(range,1),X_Y(range,2),'-k','LineWidth',3,'Color',Color_c);
    hold on
    plot(X_Y(range,1),X_Y(range,2),'.k','MarkerSize',2)
end
%% Plotting Heading
quiver(X_Y(range,1),X_Y(range,2),...
        (Heads(range,1)-Tails(range,1))/shortening,...%/20
        (Heads(range,2)-Tails(range,2))/shortening,0,...%/20
        'Color',Color_a,'LineWidth',LnWidth,'MaxHeadSize',HeadSz)%0.3


