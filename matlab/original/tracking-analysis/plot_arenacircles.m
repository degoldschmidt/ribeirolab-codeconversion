% clear all
% close all
% clc

filenumber=1;
params.px2mm=1/6.4353;
params.Feedingradious=19; 
WellPos=FlyDB(filenumber).WellPos;
% WellPos(FlyDB(filenumber).Geometry==1,1)

FoodType_1=WellPos(FlyDB(filenumber).Geometry==1,:);
FoodType_2=WellPos(FlyDB(filenumber).Geometry==2,:);
FeedRad=2.2/params.px2mm;%1.9/params.px2mm;%px
varRad=[-.3 -.2 -.1 -.05 0.05 .1 .2 .3 .4];

% for ll=0.6%varRAd

wellRadius=1.5/params.px2mm;
% params.Feedingradious=19; % 2X Radious
% params.OuterVicinityRadious=10/params.px2mm;%(1.5/params.px2mm)*3.3;

NewRadius=2.5/params.px2mm;%2.2/params.px2mm;%wellRadius;%  FeedRad+ll*FeedRad;
arenaside=1;

% close all
figure('Color','w')
hold on
for n=1:9
    %% Type 1 spots (yeast)
    plotwell=circle_(FoodType_1(n,:),wellRadius,1000,'b-');
% % % %     set(plotwell,'LineWidth',1,'Color',[.4 .4 .4]) % Dark gray
%     plotfeed=circle_(FoodType_1(n,:),params.Feedingradious,1000,':k');
%     if n==4
        plotprox=circle_(FoodType_1(n,:),NewRadius,1000,':k');
    %     set(plotfeed,'Color',[.7 .7 .7],'Linewidth',2) % Light Gray, dotted line surrounding the wells.
        set(plotprox,'Color',[93 128 225]/255,'Linewidth',2)
%     end
    %% Type2 spots (Sucrose)
    plotwell=circle_(FoodType_2(n,:),wellRadius,1000,'r-');
% % % %     set(plotwell,'LineWidth',1,'Color',[.4 .4 .4]) % Dark gray Light:0.7
%     plotfeed=circle_(FoodType_2(n,:),params.Feedingradious,1000,':k');
%     if sum(n==[1 9])~=0
        plotprox=circle_(FoodType_2(n,:),NewRadius,1000,':k');
    % % % %     set(plotfeed,'Color',[.4 .4 .4],'Linewidth',2)
    %     set(plotfeed,'Color',[.7 .7 .7],'Linewidth',2) % Light Gray, dotted line surrounding the wells.
        set(plotprox,'Color',[233 85 85]/255,'Linewidth',2) % Light Gray, dotted line surrounding the wells.

%     end

FeedingArea=circle_([0,0],24.5/params.px2mm,1000,'--k');
set(FeedingArea,'Color',[.4 .4 .4], 'LineWidth',1) % Dark gray
FeedingArea=circle_([0,0],26/params.px2mm,1000,'--k');
set(FeedingArea,'Color',[.4 .4 .4], 'LineWidth',1) % Dark gray
Arena=circle_([0,0],31/params.px2mm,1000,'-k');
set(Arena,'LineWidth',3)
plot(0,0,'ok','MarkerFaceColor','k')

%% plotting Voronoi
h=voronoi(WellPos(:,1),WellPos(:,2));
set(h, 'Color','g', 'LineWidth',1)%[.4 .4 .4]
[vx,vy]=voronoi(WellPos(:,1),WellPos(:,2));
circle_([0,0], pdist2([vx(1,24) vy(1,24)],[ 0 0 ] ),1000,'-k')
axis off
end
axis equal
%% Finding intersections between Outer voronoi delimiters and edge
% outerarea=25;%px
% statopts=statset('Display','final');
% counter=1;
% min_idx=nan(length(31:42),1);
% intersections=nan(length(31:42),2);
% point=nan(4,2);
% for linters=[31:42]
%     b = nlinfit(vx(:,linters),vy(:,linters),@(b,x)(b(1)*x+b(2)),[1;0],statopts);
%     x_int(1)=(-(2*b(1)*b(2))+sqrt((2*b(1)*b(2))^2-4*(1+b(1)^2)*(b(2)^2-(outerarea/params.px2mm)^2)))/(2*(1+b(1)^2));
%     x_int(2)=(-(2*b(1)*b(2))-sqrt((2*b(1)*b(2))^2-4*(1+b(1)^2)*(b(2)^2-(outerarea/params.px2mm)^2)))/(2*(1+b(1)^2));
%     y_int(1)=sqrt((outerarea/params.px2mm)^2-x_int(1)^2);
%     y_int(2)=-y_int(1);
%     point(1,:)=[x_int(1),y_int(1)];
%     point(2,:)=[x_int(1),y_int(2)];
%     point(3,:)=[x_int(2),y_int(1)];
%     point(4,:)=[x_int(2),y_int(2)];
%     for l=1:4
%         dist(l)=pdist2(point(l,:),[vx(1,linters),vy(1,linters)]);
%     end
%     [~,min_idx(counter)]=min(dist);
%     intersections(counter,:)=point(min_idx(counter),:);
% %     plot(vx(:,linters),vy(:,linters),'-m')
% %     plot(intersections(counter,1),intersections(counter,2),'*m')
%     counter=counter+1;
% %     pause(0.5)
% end
% % display(intersections)
%% Finding point inside polygon area
% % clf
% numofpoints=1000;%even
% x=rand(numofpoints,1)*60/params.px2mm-30/params.px2mm;
% y=rand(numofpoints,1)*60/params.px2mm-30/params.px2mm;
% line_num=[7 16 25 7;...
%     10 9 26 10;...
%     13 12 27 13;...
%     23 15 28 23;...
%     20 22 29 20;...
%     18 19 30 18;...
%     nan(12,4);...
%     25 27 29 25];%Lines forming polygon around Food Spot
% ROI=cell(19,1);
% plot(x,y,'*','Color',[.7 .7 .7])
% color_spot=[108 141 248;247 109 122;233 228 123]/255;
% for lspot=[1:6 19]
%     ROI{lspot}=[reshape(vx(:,line_num(lspot,:)),size(line_num,2)*2,1),...
%         reshape(vy(:,line_num(lspot,:)),size(line_num,2)*2,1)];
% end
% counter=1;
% innerline=[nan(1,6),7,9 10 12 13 15 16 18 19 20 22 23];
% for lspot=7:11%19
%     ROI{lspot}=[intersections(counter,1),intersections(counter,2);...
%         intersections(counter+1,1),intersections(counter+1,2);...
%         vx(:,innerline(lspot)),vy(:,innerline(lspot));...
%         intersections(counter,1),intersections(counter,2)];
%     counter=counter+1;
% end
% for lspot=12
%     ROI{lspot}=[intersections(6,1),intersections(6,2);...
%         intersections(12,1),intersections(12,2);...
%         vx(:,innerline(lspot)),vy(:,innerline(lspot));...
%         intersections(6,1),intersections(6,2)];
% end
% for lspot=13
%     ROI{lspot}=[intersections(7,1),intersections(7,2);...
%         intersections(1,1),intersections(1,2);...
%         vx(:,innerline(lspot)),vy(:,innerline(lspot));...
%         intersections(7,1),intersections(7,2)];
%     
% end
% counter=7;
% for lspot=14:18
%     ROI{lspot}=[intersections(counter+1,1),intersections(counter+1,2);...
%         intersections(counter,1),intersections(counter,2);...
%         vx(:,innerline(lspot)),vy(:,innerline(lspot));...
%         intersections(counter+1,1),intersections(counter+1,2)];
%     
%     counter=counter+1;
% end
% %% Plotting Voronoi diagrams and locations inside them
% for lspot=1:19
%     if sum(lspot==find(FlyDB(filenumber).Geometry==2))==1
%         col_spot=2;
%     elseif sum(lspot==find(FlyDB(filenumber).Geometry==1))==1 
%         col_spot=1;
%     else
%         col_spot=3;
%     end
%     in=inpolygon(x,y,ROI{lspot}(:,1),ROI{lspot}(:,2));
%     plot(x(in),y(in),'o','Color',color_spot(col_spot,:))
%     plot(ROI{lspot}(:,1),ROI{lspot}(:,2),'Color',[.4 .4 .4], 'LineWidth',1)
% end