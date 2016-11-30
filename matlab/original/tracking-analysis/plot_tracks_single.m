function h=plot_tracks_single(FlyDB,X_Y,lfly,Spots,params,px,Color,range,FontSz,plotarena,LW)
% Plots tracks. Doesn't clear previous figure
% Use:  h=plot_tracks_single(FlyDB,X_Y,lfly,Spots,params,px,Color,range,...
%        FontSz,plotarena,lw)
% Inputs:
% X_Y               2-col matrix with [X Y] positions
% flies_idx         Row vector with the indexes of flies to plot
% Spots             Row vector with Food Spots to highlight
% px                px=1 when Centroids are in px. Any other value means mm
% plotarena         if plotarena=1, plot arena's edge, circle delimiting
%                   edge and all spots

if nargin==8,FontSz=36;plotarena=1;LW=3;end
FtName='arial';%'calibri'
% close all
% scrsz = get(0,'ScreenSize');
% figure('Position',[100 50 params.scrsz(3)-950 params.scrsz(4)-150])
% Colormap=[179 83 181;142 185 45;215 158 45]/255; %[Orchid;Green;Orange]
CmapSubs=[238 96 8;0 0 0]/255;%Orange and Black [0 0 1;1 0 0];%[Blue;Red]
% CmapSubs_Patch=[250 234 176;240 240 240]/255;%[243 164 71;170 170 170]/255;%Fig1C_2016_01_07 [201 215 255;255 197 197]/255;%[108 161 238;255 121 121]/255;%Semi-dark[225 236 251;255 235 235]/255;%Very Soft
CmapSubs_Patch=[250 234 176;220 220 220]/255;%

% range=1:60000;%1:length

% for lfly=flies_idx
%     range=1:size(Centroids{lfly},1);
%     clf
Geometry = FlyDB(lfly).Geometry;

%% Plotting Arena's edge and Outer Area
if plotarena==1
    [c1,xc,yc]=circle_([0,0],33,100,'-');%33
    hold on
    set(c1,'Color',[0.7 0.7 0.7],'LineWidth',0.8)%'w'
    [c1,xc,yc]=circle_([0,0],26,100,'--');
    set(c1,'Color',[0.8 0.8 0.8],'LineWidth',.8)
    
% % % %     patch(xc,yc,[0.8 0.8 0.8],'EdgeColor',[0.8 0.8 0.8])
% % % %     [c1]=circle_([0,0],33,100,'-');
% % % %     [c1,xc,yc]=circle_([0,0],params.OuterRingRadious,100,'--');
% % % %     patch(xc,yc,'w','EdgeColor','w')
% % % %     [c1]=circle_([0,0],params.OuterRingRadious,100,'--');
% % % %     set(c1,'Color',[0.7 0.7 0.7],'LineWidth',2)
% % % %     [c1,xc,yc]=circle_([0,0],24.5,100,'--');
% % % %     set(c1,'Color',[0.8 0.8 0.8],'LineWidth',1)
        
    
end

%% Plotting Food Spots
if plotarena==1
    YSpots=find(Geometry==1);
    SSpots=find(Geometry==2);
    for nspot=YSpots
        [c,xc,yc]=circle_([FlyDB(lfly).WellPos(nspot,1)*params.px2mm,...
            FlyDB(lfly).WellPos(nspot,2)*params.px2mm],...
            1.6,100,'-b');%1.6%2.5
%         set(c,'Color',CmapSubs(1,:),'LineWidth',1)
        set(c,'Color',CmapSubs_Patch(1,:),'LineWidth',0.8)
        patch(xc,yc,CmapSubs_Patch(1,:),'EdgeColor',CmapSubs_Patch(1,:))
        
    end

    for nspot=SSpots
        [c,xc,yc]=circle_([FlyDB(lfly).WellPos(nspot,1)*params.px2mm,...
            FlyDB(lfly).WellPos(nspot,2)*params.px2mm],...
            1.6,100,'-r');%1.6 %2.5
%         set(c,'Color',CmapSubs(2,:),'LineWidth',2)
        set(c,'Color',CmapSubs_Patch(2,:),'LineWidth',0.8)
        patch(xc,yc,CmapSubs_Patch(2,:),'EdgeColor',CmapSubs_Patch(2,:))
    end
end
%% Plotting Agarose Spots
% if plotarena==1
%     ASpots=find(Geometry==4);
%     for nspot=ASpots
%         [c,xc,yc]=circle_([FlyDB(lfly).WellPos(nspot,1)*params.px2mm,...
%             FlyDB(lfly).WellPos(nspot,2)*params.px2mm],...
%             1.6,100,'-b');
%         set(c,'Color',[0.7 0.7 0.7],'LineWidth',0.8)
%     %     patch(xc,yc,CmapSubs(1,:),'EdgeColor',CmapSubs(1,:))
%     end
% end
% % plot(FlyDB(lfly).WellPos(Geometry==1,1)*params.px2mm,...
% %     FlyDB(lfly).WellPos(Geometry==1,2)*params.px2mm,'ob',...
% %     'MarkerSize',MkSz,'MarkerFaceColor',CmapSubs(1,:),'MarkerEdgeColor',CmapSubs(1,:))%'MarkerSize',3
% % plot(FlyDB(lfly).WellPos(Geometry==2,1)*params.px2mm,...
% %     FlyDB(lfly).WellPos(Geometry==2,2)*params.px2mm,...
% %     'or','MarkerSize',MkSz,'MarkerFaceColor',CmapSubs(2,:),'MarkerEdgeColor',CmapSubs(2,:))
%% Highlighting Spots
if sum(Spots)~=0
    for nspot=Spots(Spots~=0)
%         plot(FlyDB(lfly).WellPos(nspot,1)*params.px2mm,...
%             FlyDB(lfly).WellPos(nspot,2)*params.px2mm,'ob',...
%             'MarkerSize',MkSz,'MarkerFaceColor',CmapSubs2(Geometry(nspot),:),'MarkerEdgeColor',CmapSubs(Geometry(nspot),:))%'MarkerSize',3
        
%         c=circle_([FlyDB(lfly).WellPos(nspot,1)*params.px2mm,...
%             FlyDB(lfly).WellPos(nspot,2)*params.px2mm],...
%             params.Feedingradious*params.px2mm,100,'.-');
%         set(c,'Color',CmapSubs2(Geometry(nspot),:),'LineWidth',2)
        c=circle_([FlyDB(lfly).WellPos(nspot,1)*params.px2mm,...
            FlyDB(lfly).WellPos(nspot,2)*params.px2mm],...
           2.5,100,':');% 2.5 %5
        set(c,'Color',[0.7 0.7 0.7],'LineWidth',.8)%CmapSubs_Patch(Geometry(nspot),:)
                c=circle_([FlyDB(lfly).WellPos(nspot,1)*params.px2mm,...
            FlyDB(lfly).WellPos(nspot,2)*params.px2mm],...
           5,100,':');% 2.5 %5
        set(c,'Color',[0.7 0.7 0.7],'LineWidth',.8)%CmapSubs_Patch(Geometry(nspot),:)
        %%% optional to confirm that markersize corresponds to spot rad
%         circle_([FlyDB(lfly).WellPos(nspot,1)*params.px2mm,...
%             FlyDB(lfly).WellPos(nspot,2)*params.px2mm],...
%             1.5,100,'--k');
    end
end
%% Plotting Trajectory
%     figure
if px==1, X_Y=X_Y*params.px2mm;end
if LW~=0
h=plot(X_Y(range,1),X_Y(range,2),'-k','LineWidth',LW,'Color',Color);
else
h=nan;    
end
% plot(X_Y(range,1),X_Y(range,2),'.k','MarkerSize',2)


    %% Plotting Starting and Finishing frame
    %     plot(Centroids{lfly}(1,1),Centroids{lfly}(1,2),'ok','MarkerSize',5,'MarkerFaceColor','k')%Black:Starting
    %     plot(Centroids{lfly}(end,1),Centroids{lfly}(end,2),'ok','MarkerSize',5,'MarkerFaceColor',[.4 .4 .4],'MarkerEdgeColor',[.4 .4 .4])%Gray:Finishing
    
    %%
    %                     hold off%Comment for all trajectories together
    axis equal
%         axis([-32 32 -32 32])%mm
%     axis([FlyDB(lfly).WellPos(Spots,1)*params.px2mm-3,...
%         FlyDB(lfly).WellPos(Spots,1)*params.px2mm+3,...
%         FlyDB(lfly).WellPos(Spots,2)*params.px2mm-3,...
%         FlyDB(lfly).WellPos(Spots,2)*params.px2mm+3])%mmaxis([4.1 4.5 -11.8 -11.3])%mm
if FontSz==0
    font_style([],...
        'X coordinate (mm)','Y coordinate (mm)','normal',FtName,8)
else
       
font_style({[params.LabelsShort{params.ConditionIndex(lfly)},...
        '; Fly Nº' num2str(lfly)]; [num2str(range(1)) ' to ' num2str(range(end))]},...
        'X coordinate (mm)','Y coordinate (mm)','normal',FtName,FontSz)
end
    delta=0;%.5;%6;
    
%     axis([min(X_Y(range,1))-delta max(X_Y(range,1))+delta...
%         min(X_Y(range,2))-delta max(X_Y(range,2))+delta])
    
    % set(gca,'Xtick',[],'ytick',[])
    
    
    % end