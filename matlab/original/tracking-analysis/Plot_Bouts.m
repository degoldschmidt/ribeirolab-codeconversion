%% Plotting bouts in different colors
States_Colors=[238 96 8;0 0 0;0 166 0; 255 255 255]/255;%
% close all
fig=figure('Position',[10 43 1000 930],'Color','w')%2058 on 2nd screen [10...]%On 1st screen

load([Variablesfolder 'ManualAnnotation0003A 01-Dec-2014.mat'])
% ManualAnnotation.YFeedingEvents=[33500 33800 1 97];%[28700 29300 1 97];%[29000 37000 1 97];%[33500 34000 1 97];%
% ManualAnnotation.YFeedingEvents=[88516 91641 1 43];
% ManualAnnotation.YFeedingEvents=[332963 344856 1 1];
% ManualAnnotation.YFeedingEvents=[64000 67000 1 32];%[101768 103219 1 32];
 
Vartoplot='YFeedingEvents';%'Revisits';%
Error_bout=nan(length(ManualAnnotation.(Vartoplot)(:,1)),1);
ltracecounter=0;
for ltrace=ManualAnnotation.(Vartoplot)([1],1)'%[1 6 7 8 16 17 22 37 39 40 43]
    ltracecounter=ltracecounter+1;
    delta=100;%1000;
    clf
    hold on
    boutnumber=find(ManualAnnotation.(Vartoplot)(:,1)==ltrace);
    lfly=ManualAnnotation.(Vartoplot)(ManualAnnotation.(Vartoplot)(:,1)==ltrace,4);
    Spot=ManualAnnotation.(Vartoplot)(ManualAnnotation.(Vartoplot)(:,1)==ltrace,3);
    frames1=ltrace:ManualAnnotation.(Vartoplot)(ManualAnnotation.(Vartoplot)(:,1)==ltrace,2);
    frames=frames1(1)-delta:frames1(end)+delta;
    
    ethogram_temp=4*ones(1,length(frames));
    
    lboutstart=(find(BoutsInfo.DurIn{lfly}(:,2)>frames(1),1,'first'));
    lboutend=(find(BoutsInfo.DurIn{lfly}(:,3)<frames(end),1,'last'));
        
    ColorAUC=hsv(lboutend-lboutstart+1);
    
    subplot('Position',[0.13 0.11 0.77 0.68])
    hold on
    plot(frames/params.framerate/60,Engagement_p(frames,lfly),'-b','LineWidth',3)
    
    EdgeColor={'b';'r'};
    lboutcounter=0;
    Overlaps=nan(lboutend-lboutstart+1,1);
    for lbout=lboutstart:lboutend
        lboutcounter=lboutcounter+1;
        
        lsubs=BoutsInfo.DurIn{lfly}(lbout,1);
        framesbout=BoutsInfo.DurIn{lfly}(lbout,2):BoutsInfo.DurIn{lfly}(lbout,3);
        timebout=framesbout/params.framerate/60;
        
        area(timebout,Engagement_p(framesbout,lfly),...
            'LineWidth',3,'FaceColor',ColorAUC(lboutcounter,:),'EdgeColor',EdgeColor{lsubs})
        plot([timebout(1) timebout(1)],[0 1],':k',...
            [timebout(end) timebout(end)],[0 1],':k','LineWidth',3)
        plot([frames1(1) frames1(1)]/params.framerate/60,[0 1],':g',...
            [frames1(end) frames1(end)]/params.framerate/60,[0 1],':g','LineWidth',3)
        %%% Note: Next piece of code only works for the raw bouts, without merging
        if ~isnan(Revisits_WithinBouts{lfly}(lbout))
            text(timebout(1),1.01,[num2str(Revisits_WithinBouts{lfly}(lbout))...
                's, spot:' num2str(BoutsInfo.DurIn{lfly}(lbout,4))])
%         elseif ~isnan(BoutsInfo.QuickDiseng{lfly}(lbout))
%             text(timebout(1),1.01,[num2str(BoutsInfo.QuickDiseng{lfly}(lbout))...
%                 's, spot:' num2str(BoutsInfo.DurIn{lfly}(lbout,4))],'Color','r')
        else
            text(timebout(1),1.01,'No Rev')
        end
        
        Overlaps(lboutcounter)=sum(ismember(frames1,framesbout));
    end
    xlim([frames(1) frames(end)]/params.framerate/60)
    [~,lboutidx]=max(Overlaps);
    framesbout=BoutsInfo.DurIn{lfly}(lboutstart+lboutidx-1,2):BoutsInfo.DurIn{lfly}(lboutstart+lboutidx-1,3);
    dur_err=100*((framesbout(end)-framesbout(1))-(frames1(end)-frames1(1)))/(frames1(end)-frames1(1));
    Error_bout(ltracecounter)=dur_err;
    
    font_style(['Error: ' num2str(dur_err) ' %'],'Time [min]','Engagement Index')
    
    subplot('Position',[0.13 0.85 0.77 0.05])
    lcondcounter=find(Conditions==params.ConditionIndex(lfly));
    flycondcounter=find(params.IndexAnalyse(params.ConditionIndex==params.ConditionIndex(lfly))==lfly);
    image(Ethogram_matr{lcondcounter}(flycondcounter,frames))
    colormap(States_Colors)
    
    figname=[Exp_num Exp_letter  ' - Bout' num2str(boutnumber) ' - Fly ' num2str(lfly),...
        ', ' num2str(frames(1)) ' to ' num2str(frames(end)) 'Spot ' num2str(Spot) '- Err ' num2str(ceil(dur_err))];
    font_style(figname,[],[])
    % xlim([frames(1) frames(end)])
    axis off
    
%     saveplots(Dropbox_choicestrategies,'Manual Ann',figname,DataSaving_dir_temp,Exp_num,0,0)
    
%     pause
end

