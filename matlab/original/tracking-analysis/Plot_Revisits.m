%% Default geometry in case there is no food in the spots
logicComp1=cell2mat(cellfun(@(x)~isempty(strfind(x,'4A')),{FlyDB.Filename},'uniformoutput',false));
Geometry_temp=[1,2,1,2,1,2,1,2,1,2,1,2,2,1,2,1,2,1];%3];% Geometry used in EXPs 3 & 4BC
% Geometry_temp=[2,2,2,1,1,1,2,2,2,2,2,1,2,1,1,1,1,1];%3];% Geometry used in EXPs 3 & 4BC

Geometry=[Geometry_temp,3]; %Follow same geometry as other experiments.
CmapSubs=[201 215 255;255 197 197]/255;
figure('Position',[100 50 params.scrsz(3)-250 params.scrsz(4)-250],'Color','w');
Colormap=Colors(3);
for lfly=flies_idx
    if logicComp1(lfly)~=1
        Geometry = FlyDB(lfly).Geometry;
    end
    for lspot=find(Geometry~=3)
        
    start_end=BoutsInfo.Revisits{lfly}{lspot};
    for lrevisit=find(start_end(:,3)>0.5)'
        clf
               plot_tracks_single(FlyDB,Heads_Sm{lfly},lfly,lspot,...
                   params,1,Colormap(1,:),start_end(lrevisit,1):start_end(lrevisit,2),20);
%                plot_tracks_single(FlyDB,Centroids_Sm{lfly},lfly,lspot,...
%                    params,1,Colormap(2,:),start_end(lrevisit,1):start_end(lrevisit,2),20);
%                plot_heading(Centroids_Sm{lfly},Heads_Sm{lfly},Tails_Sm{lfly},1,'w',...
%                             Colormap(3,:),params,start_end(lrevisit,1):start_end(lrevisit,2),2,0.1)%
                title_=[params.LabelsShort{params.ConditionIndex(lfly)} ', Fly Nº',...
                   num2str(lfly) ', frames ' num2str(start_end(lrevisit,1)),...
                   ' to ' num2str(start_end(lrevisit,2)),...
                   ', p=' num2str(start_end(lrevisit,3))];               
                title(title_)
                axis off
               pause
    end
    end
end