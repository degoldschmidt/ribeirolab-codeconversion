function plot_traj_etho_video2(Heads_Sm,range,etho_segments,colormap_segments,LineW)

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
            hold on
            plot(Heads_Sm(frames_etho,1),...
                Heads_Sm(frames_etho,2),...
                'LineWidth',LineW,'Color',Colormicromovement)
            
    
        end
        
    end
end


