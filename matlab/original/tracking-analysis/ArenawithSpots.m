%% Plotting arena with all colors
plotarena=1
figure
Geometry = FlyDB(97).Geometry;

CmapSubs=[238 96 8;0 0 0]/255;%Orange and Black [0 0 1;1 0 0];%[Blue;Red]
EdgeColor='w';%[0 166 0]/255;
CmapSubs_Patch=[250 234 176;240 240 240]/255;%[201 215 255;255 197 197]/255;%[108 161 238;255 121 121]/255;%Semi-dark[225 236 251;255 235 235]/255;%Very Soft

%% Plotting Arena's edge and Outer Area
if plotarena==1
    [c1,xc,yc]=circle_([0,0],31,100,'-');%33
    hold on
    patch(xc,yc,EdgeColor,'EdgeColor',[0.8 0.8 0.8])
    set(c1,'Color',[0.7 0.7 0.7],'LineWidth',3)

    [c1,xc,yc]=circle_([0,0],params.OuterRingRadious,100,'--');
    patch(xc,yc,'w','EdgeColor','w')
    set(c1,'Color',[0.7 0.7 0.7],'LineWidth',3)
    
    [c1,xc,yc]=circle_([0,0],95*params.px2mm,100,'--k');
%     patch(xc,yc,'b','EdgeColor','b')
    
    
end

%% Plotting Food Spots
if plotarena==1
    YSpots=find(Geometry==1);
    SSpots=find(Geometry==2);
    for nspot=YSpots
        [c,xc,yc]=circle_([FlyDB(lfly).WellPos(nspot,1)*params.px2mm,...
            FlyDB(lfly).WellPos(nspot,2)*params.px2mm],...
            1.5,100,'-b');
%         set(c,'Color',CmapSubs(1,:),'LineWidth',1)
        set(c,'Color',CmapSubs(1,:),'LineWidth',1)
        patch(xc,yc,CmapSubs(1,:),'EdgeColor',CmapSubs(1,:))
        
%         if nspot==1 || nspot==7
        [c,xc,yc]=circle_([FlyDB(lfly).WellPos(nspot,1)*params.px2mm,...
            FlyDB(lfly).WellPos(nspot,2)*params.px2mm],...
           10,100,'--b');%16
%         set(c,'Color',CmapSubs(1,:),'LineWidth',3)
%         end    
    end

    for nspot=SSpots
        [c,xc,yc]=circle_([FlyDB(lfly).WellPos(nspot,1)*params.px2mm,...
            FlyDB(lfly).WellPos(nspot,2)*params.px2mm],...
            1.5,100,'-r');%16
%         set(c,'Color',CmapSubs(2,:),'LineWidth',2)
        set(c,'Color',CmapSubs(2,:),'LineWidth',1)
        patch(xc,yc,CmapSubs(2,:),'EdgeColor',CmapSubs(2,:))
        
                [c,xc,yc]=circle_([FlyDB(lfly).WellPos(nspot,1)*params.px2mm,...
            FlyDB(lfly).WellPos(nspot,2)*params.px2mm],...
           10,100,'--r');%16

    end
end

    axis equal
    axis off