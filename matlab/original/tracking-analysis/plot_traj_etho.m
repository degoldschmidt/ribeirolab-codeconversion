function plot_traj_etho(Heads_Sm,lfly,range,etho_segments,colormap_segments,LineW,params,...
    Centroids_Sm,Tails_Sm)

%% plot trajectory segments with ethogram color
if size(colormap_segments,1)==1
    lsegments2plot=1;
else
    lsegments2plot=[1:size(colormap_segments,1)];% 2];%
end
for letho=lsegments2plot
    
    starts=find(conv(double(etho_segments==letho),[1 -1])==1);
    ends=find(conv(double(etho_segments==letho),[1 -1])==-1)-1;
    
    bout_start1=find(starts<range(1),1,'last');
    bout_start2=find(starts<range(end),1,'last');
    bout_start3=find(starts>=range(1),1,'first');
    bout_start=min([bout_start1,bout_start2,bout_start3]);
    bout_end1=find(ends>range(end),1,'first');
    bout_end2=find(ends>range(1),1,'first');
    bout_end3=find(ends<=range(end),1,'last');
    bout_end=max([bout_end1,bout_end2,bout_end3]);
    Colormicromovement=colormap_segments(letho,:);
    for lmicrobout=bout_start:bout_end
        frames_etho=starts(lmicrobout):ends(lmicrobout);
        
        frames_etho(frames_etho<range(1))=[];
        frames_etho(frames_etho>range(end))=[];
        if ~isempty(frames_etho)
%             plot(Heads_Sm{lfly}(frames_etho,1)*params.px2mm,...
%                 Heads_Sm{lfly}(frames_etho,2)*params.px2mm,...
%                 'LineWidth',LineW,'Color',Colormicromovement)
            hold on
            if nargin==9
                frames_etho3=frames_etho(1:3:end);
                quiver(Centroids_Sm{lfly}(frames_etho3,1)*params.px2mm,Centroids_Sm{lfly}(frames_etho3,2)*params.px2mm,...
                    (Heads_Sm{lfly}(frames_etho3,1)*params.px2mm-Tails_Sm{lfly}(frames_etho3,1)*params.px2mm)/2,...%/20
                    (Heads_Sm{lfly}(frames_etho3,2)*params.px2mm-Tails_Sm{lfly}(frames_etho3,2)*params.px2mm)/2,0,...%/20
                    'Color',Colormicromovement,'LineWidth',LineW,'MaxHeadSize',.5)%0.3
                plot(Centroids_Sm{lfly}(frames_etho,1)*params.px2mm,...
                Centroids_Sm{lfly}(frames_etho,2)*params.px2mm,...
                'LineWidth',LineW,'Color',Colormicromovement)
            end
    
        end
        
    end
end


