%% Getting Python motion data
close all

Results_folder=[DataSaving_dir_temp Exp_num '\PixelChange\'];%'E:\Dropbox (Behavior&Metabolism)\Personal\Scripts\Python\Motion Calculator\';
[Color,Colorpatch]=Colors(3);

fig=figure('Position',[196 10 800 1000],'Color','w');
ltracecounter=1;
Vartoplot='Rest';
y_label_plot='Speed';%{'Amount of'; 'pixel change'};%
label_figure='Speed';%'Amount of pixel change';%

pythonfile=1;
for ltrace=1:length(ManualAnnotation.(Vartoplot)(:,4))
    lfly=ManualAnnotation.(Vartoplot)(ltrace,4);
    frames=ManualAnnotation.(Vartoplot)(ltrace,1)-25:ManualAnnotation.(Vartoplot)(ltrace,2)+25;
    if pythonfile==1
        filename=[FlyDB(lfly).Filename(1:end-4) '_',...
            num2str(frames(1)), '_',...
            num2str(frames(end)) '_amountofpixelschanged'];
        
        fileID=fopen([Results_folder filename '.csv']);
        
        try
            Headers=textscan(fileID,'%f %f %f %f');
            if isempty(Headers{1})
                continue
            end
        catch
            continue
        end
        
        %%
        C=cell2mat(Headers);
        frames=C(1:3:end,1);
        Flies_motion=cell(3,1);
        Flies_motion{1}=C(1:3:end,3);
        Flies_motion{2}=C(2:3:end,3);
        Flies_motion{3}=C(3:3:end,3);
        Flies_motion_Sm=Smoothing(Flies_motion,60,'gaussian',0);
        
        Nofly_motion=cell(3,1);
        Nofly_motion{1}=C(1:3:end,4);
        Nofly_motion{2}=C(2:3:end,4);
        Nofly_motion{3}=C(3:3:end,4);
        Nofly_motion_Sm=Smoothing(Nofly_motion,60,'gaussian',0);
        
        if length(frames)==size(Flies_motion_Sm{FlyDB(lfly).Arena},1)
            %% Plotting amount of pixel change, raw and smoothed
            %     subplot(length(ManualAnnotation.(Vartoplot)(:,4)),1,ltracecounter)
            subplot(7,2,ltracecounter)
            hold on
            %     plot(frames,Nofly_motion_Sm{FlyDB(lfly).Arena},'Color',Colorpatch(3,:))
            plot(frames,Flies_motion_Sm{FlyDB(lfly).Arena},...
                'Color',Color(3,:),'LineWidth',2);
            plot(frames,Flies_motion_Sm{FlyDB(lfly).Arena},...
                'Color','k','LineWidth',0.5);
            plot([frames(1)+50 frames(1)+50],[0 2500],'--r','Color',Color(2,:))
            plot([frames(1) frames(end)],[300 300],'-.',...
                [frames(1) frames(end)],[100 100],'-.',...
                'LineWidth',1,'Color',[0.5 0.5 0.5])%[192 0 0]/255)
            if ltracecounter==1
                font_style(Vartoplot,[],y_label_plot,'normal','arial',10)
            else
                font_style([],[],num2str(ltrace),'normal','arial',10)
            end
            set(gca,'XTickLabel',[],'XTick',[])
            xlabel([])
            xlim([frames(1) frames(end)])
            ylim([0 700])%([0 1500])
            ltracecounter=ltracecounter+1;
        end
    else
        subplot(8,3,ltracecounter)
        hold on
        plot(frames,Steplength_Sm_h{lfly}(frames)*params.px2mm*params.framerate,...
            'Color',Color(3,:),'LineWidth',2);
        plot(frames,Steplength_Sm_h{lfly}(frames)*params.px2mm*params.framerate,...
            'Color','k','LineWidth',.5);
        plot([frames(1)+50 frames(1)+50],[0 2500],'--','Color',Color(2,:))
        plot([frames(1) frames(end)],[0.2 0.2],'-.',...
            [frames(1) frames(end)],[0.1 0.1],'-.',...
            'LineWidth',1,'Color',[0.5 0.5 0.5])%[192 0 0]/255)
        if ltracecounter==1
            font_style(Vartoplot,[],y_label_plot,'normal','arial',10)
        else
            font_style([],[],num2str(ltrace),'normal','arial',10)
        end
        set(gca,'XTickLabel',[],'XTick',[])
        xlabel([])
        xlim([frames(1) frames(end)])
        ylim([0 0.4])%([0 1500])
        ltracecounter=ltracecounter+1;
    end
end
figname=[label_figure ' - Annotating ' Vartoplot ' ' date];
print('-dtiff','-r600',['E:\Analysis Data\General Plots\' figname '.tif'])
%% Plotting amount of pixel change, raw and smoothed - All flies in file
% close all
%
% [Color,Colorpatch]=Colors(3);
% figure
% hold on
% h=nan(3,1);
% for lfly=1:3
%     plot(frames,Flies_motion{lfly},'Color',Colorpatch(lfly,:))
% end
% for lfly=1:3
%     h(lfly)=plot(frames,Flies_motion_Sm{lfly},colors_label{lfly},...
%         'Color',Color(lfly,:),'LineWidth',2);
%     font_style([],'Frames','Amount of pixel change','normal','arial',10)
% end
% plot([frames(1)+50 frames(1)+50],[0 2500],'--r')
% legend(h,{'Left','Centre','Right'})
% figname=['Amount of pixel change - 0003A03R03Cam01P0WT-CantonS - 212008 to 212934'];
% % print('-dtiff','-r600',['E:\Analysis Data\General Plots\' figname '.tif'])
%% Plotting amount speed
%
% figure
% hold on
% lflycounter=1;
% h=nan(3,1);
% for lfly=113:115
%     h(lflycounter)=plot(frames,Steplength_Sm_c{lfly}(frames)*params.px2mm*params.framerate,...
%         'Color',Color(lflycounter,:),'LineWidth',2);
%     font_style([],'Frames','Speed','normal','arial',10)
%     ylim([0 0.4])
%     lflycounter=lflycounter+1;
% end
% legend(h,{'Left','Centre','Right'})
% figname=['Smoothed speed - 0003A03R03Cam01P0WT-CantonS - 212008 to 212934'];
% % print('-dtiff','-r600',['E:\Analysis Data\General Plots\' figname '.tif'])