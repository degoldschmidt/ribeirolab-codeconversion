function [Engagement_p,Engagement_p_dist,InSpot,Engagement_p_speed]=Engagement(Heads_Sm,Steplength_Sm_c,...
    FlyDB,params,frames_range)
% Engagement    Probability of a fly being engaged in a food spot
%   For cell arrays Heads_Sm and Steplength_Sm_c of size mx1, with m being
%   the number of flies, Engagement(Heads_Sm,Steplength_Sm_c,params) is a
%   fxmxs matrix with f=params.MinimalDuration or f=length(frames_range) if
%   the fourth argument is included and s=length(params.Subs_Names). This
%   matrix contains the engagement probabilities of each fly for each
%   subtrate at all frames.
%
%   [Engagement_p,Engagement_p_dist]=Engagement(Heads_Sm,Steplength_Sm_c,...
%   FlyDB,params)
%   assumes frames_range=params.MinimalDuration
%
%   [Engagement_p,Engagement_p_dist]=Engagement(Heads_Sm,Steplength_Sm_c,...
%   FlyDB,params,frames_range)
%
%   including workingdir and dir2savefigs means that a plot of long
%   inactivity bouts on food will be generated and saved in the specified
%   directory.

%% Calculating Engagement for all the flies
if nargin==4,frames_range=1:params.MinimalDuration;end
Engagement_p_temp=zeros(length(frames_range),size(Heads_Sm,1));
Engagement_p_dist=zeros(length(frames_range),size(Heads_Sm,1));
Engagement_p_speed=zeros(length(frames_range),size(Heads_Sm,1));
InSpot=zeros(length(frames_range),size(Heads_Sm,1),1);

%%% If want to use a different geometry that the one in FlyDB, uncomment
%%% next three lines and the "if logicComp1(lfly)~=1" loop below.
% logicComp1=cell2mat(cellfun(@(x)~isempty(strfind(x,'4A')),{FlyDB.Filename},'uniformoutput',false));
% Geometry_temp=[1,2,1,2,1,2,1,2,1,2,1,2,2,1,2,1,2,1];%3];% Geometry used in EXPs 3 & 4BC
% Geometry=[Geometry_temp,3]; %Follow same geometry as other experiments.
%%

for lfly=1:size(Heads_Sm,1)
    display(lfly)
    
    [temp_speed]=speed_engagement(Steplength_Sm_c{lfly}(frames_range)*params.px2mm*params.framerate,params);
    
%     for lsubs=1:length(params.Subs_Names)
%         if logicComp1(lfly)~=1% --> Uncomment to use a different geometry
%             Geometry = FlyDB(lfly).Geometry;
%         end
%         Geometry = FlyDB(lfly).Geometry;
        spots_idxs=1:18;%find(Geometry==lsubs);
        f_spot=FlyDB(lfly).WellPos(spots_idxs,:);
        
        for n=1:size(f_spot,1)
            Diff2fSpot=Heads_Sm{lfly}(frames_range,:)-...
                repmat(f_spot(n,:),...
                length(frames_range),1);
            
            Dist2fSpots=sqrt(sum(((Diff2fSpot).^2),2)).*params.px2mm;
            temp_dist=dist2spot_engagement(Dist2fSpots);
            temp=temp_dist.*temp_speed;
            Engagement_p_temp(temp>0,lfly)=temp(temp>0);
            Engagement_p_dist(temp_dist>0,lfly)=temp_dist(temp_dist>0);
            Engagement_p_speed(temp_speed>0,lfly)=temp_speed(temp_speed>0);
            InSpot((Dist2fSpots)<4.7,lfly)=spots_idxs(n);%% Be careful if
            % there is a different geometry, that the spots don't overlap
            
            
        end
%     end
    
end
% subplot(3,1,1)
% plot(Engagement_p{32}(range(1):range(end),1))
% hold on
% subplot(3,1,2)
% plot(range,p_engagement_given_dist2spot(range(1):range(end)),'-r')
% subplot(3,1,3)
% plot(range,p_engagement_given_speed(range(1):range(end)),'-k')
%% Gaussian Smoothing to remove very short time scale fluctuations: peaks in speed
Engagement_p=Engagement_p_temp;
% Engagement_p=Smoothing_Engagement(Engagement_p_temp,InSpot,frames_range);
%% Comparing Engagement with manually annotated Feeding events
% Plottingfly32
%% Engagement Probability Function - Plotting
% dist2spot=(0:4.5/299:4.5)';
% speed=(0:5/299:5)';
% p_engagement=zeros(length(speed),length(dist2spot));
% [temp_speed]=speed_engagement(speed,params);
% temp_dist=dist2spot_engagement(dist2spot);
% for lspeed=speed'
%     display(lspeed)
%     for ldist2spot=dist2spot'
%         p_engagement(lspeed==speed,ldist2spot==dist2spot)=temp_speed(lspeed==speed).*temp_dist(ldist2spot==dist2spot);
%     end
% end
% 
% close all
% figure('Position',[100 50 params.scrsz(3)-150 params.scrsz(4)-150],'Color','w')
% subplot(2,3,[1,2,4,5])
% % % imagesc(dist2spot,speed,p_engagement,[0 1])%);%,);%For VelGamma,clims);% or log(Condfr)) %
% % % colorbar
% % % font_style('Pr(engagement|speed,distance to spot)','Distance to Spot [mm]','Speed [mm/s]','normal','calibri',20)
% % % set(gca,'YDir','normal')
% % % colormap(pink)
% % %%
% surf(dist2spot,speed,p_engagement)
% font_style('Pr(Engagement|Speed, Distance to spot)','Distance to Spot [mm]','Speed [mm/s]','normal','calibri',20)
% shading interp
% xlim([0 4.5])
% subplot(2,3,3)
% p_engagement_given_dist2spot=dist2spot_engagement(dist2spot);
% line(dist2spot,p_engagement_given_dist2spot,'Color',[228 108 10]/255,'LineWidth',3);%[84 130 53]/255
% font_style([],'Distance to Spot [mm]',...
%         'Pr(Engagement|Distance to Spot)','bold','calibri',20)
% set(gca,'XColor',[228 108 10]/255,'YColor',[228 108 10]/255)%[84 130 53]/255
% xlim([dist2spot(1) dist2spot(end)])
% subplot(2,3,6)
% p_engagement_given_speed=speed_engagement(speed,params);
% line(speed,p_engagement_given_speed,'Color',[228 108 10]/255,'LineWidth',3);%[84 130 53]/255
% font_style([],'Speed [mm/s]',...
%         'Pr(Engagement|Speed)','bold','calibri',20)
% set(gca,'XColor',[228 108 10]/255,'YColor',[228 108 10]/255)%[84 130 53]/255
% xlim([speed(1) dist2spot(end)])

