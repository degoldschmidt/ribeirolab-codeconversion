%% Plotting trajectories
% lcond=1;
% MAtedHunt=find(params.ConditionIndex==lcond);
% [Totalt_sorted,Idx_sort]=sort(Totaltimes{lsubs}(params.ConditionIndex==lcond),...
%         'descend');
% SortedMatedHunt=MAtedHunt(Idx_sort)';    
% % Walking_vec=walking_fun(Steplength_Sm_c,flies_idx,params);

%%
saveplot=0;
fliestoplot=97;%1:params.numflies;%find(params.ConditionIndex==2)%Flies_cluster{3}';%flies_idx;%SortedMatedHunt';%SortedMatedYaa(:)';%SortedMatedDep(:)';%[4:6 41:44];
% ranges=[2 5600;5600 120000; 120000 240000;240000 345000];%1:size(Heads_Sm{lfly},1);%[188300:188700];%[eng_fr_1:eng_fr_end];%[143422:150939];
ranges=29284:36000;%112600:115200;%5250:50000;%1:1000;%398000;%(76601:76701);%(fr_start: fr_end);
Spots=9;%current_spot;%[1,5,9,14];
FtSz=8;
LineW=1;

plotarena=1;

Color=Colors(3);%hsv(length(flies_idx));%
States_Colors=[238 96 8;0 0 0;0 166 0; 255 255 255]/255;%[Orange, Black, Green, White]
WalkingEtho_Colors=[Color(3,:);[1 1 1];[0.5 0.5 0.5]];%[blue, white, gray]

xlim_=[-33 33];%[11 16.2];%
ylim_=[-33 33];%[-17.2 -11.5];%
%%
if ~exist('Etho_Speed_new','var')
    [Etho_Speed_new,Etho_colors_new,Etho_Colors_Labels] = Etho_Speed2New(params.MinimalDuration,Etho_Speed,1);
end

Etho_H_Speed=Etho_Speed_new;
Etho_H_Speed(Etho_H==9)=6;%YHmm
Etho_H_Speed(Etho_H==10)=7;%SHmm
EthoH_Colors=[Etho_colors_new;...
    [240 228 66]/255;%[250 244 0]/255;...%6 - Yellow (Yeast micromovement)
    0 0 0];%7 - Sucrose
%%
close all
if size(ranges,1)>1
    figure('Position',[100 50 1400 930],'Color','w')
else
    figure('Position',[100 50 1400 930],'Color','w')%1200
end
hold on
flycounter=0;
for lfly=fliestoplot
%     clf
    flycounter=flycounter+1
%     subplot(5,7,flycounter)
    if size(ranges,1)>1
        for lrow=1:4
            hold on
            range=ranges(lrow,1):ranges(lrow,2);
            %% Ethograms location
            switch lrow
                case 1
                    subplot('Position',[0.05    0.68    0.2    0.05])
                    
                case 2
                    subplot('Position',[0.28    0.68    0.2    0.05])
                case 3
                    subplot('Position',[0.51    0.68    0.2    0.05])
                case 4
                    subplot('Position',[0.74    0.68    0.2    0.05])
            end
            image(Ethogram_matr{Conditions==params.ConditionIndex(lfly)}...
                (params.IndexAnalyse(params.ConditionIndex==params.ConditionIndex(lfly))==lfly,range))
            colormap(States_Colors);
            freezeColors
            set(gca,'XTickLabel',[],'Box','off','XTick',[],'YTickLabel',[],'YTick',[])
            xlim([0 range(end)-range(1)])
            
            if lrow==1
                font_style({[params.LabelsShort{params.ConditionIndex(lfly)},...
        '; Fly Nº' num2str(lfly)]; ['0 - ' num2str(floor(range(end)/params.framerate/60)) ' min']},...
        [],[],'normal','arial',FtSz)
                ylabel('Location','FontSize',FtSz-2,'FontName','arial')
            else
                title([num2str(floor(range(1)/params.framerate/60)) ' - ',...
                    num2str(range(end)/params.framerate/60) ' min'],...
                    'FontSize',FtSz,'FontName','arial')
            end
        
            %% Ethogram activity
            switch lrow
                case 1
                    subplot('Position',[0.05    0.61    0.2    0.05])
                case 2
                    subplot('Position',[0.28    0.61    0.2    0.05])
                case 3
                    subplot('Position',[0.51    0.61    0.2    0.05])
                case 4
                    subplot('Position',[0.74    0.61    0.2    0.05])
            end
            %%% Raster walking or not
%             image(Walking_Etho{Conditions==params.ConditionIndex(lfly)}...
%                 (params.IndexAnalyse(params.ConditionIndex==params.ConditionIndex(lfly))==lfly,range))
%             colormap(WalkingEtho_Colors);
%             if lrow==1
%                font_style([],[],'Walking','normal','arial',FtSz-2)
%             end
%             set(gca,'XTickLabel',[],'Box','off','XTick',[],'YTickLabel',[],'YTick',[])
%             xlim([0 range(end)-range(1)])
            %%% Steplength
            hold on
            severalplots=0;
            clear X
            X=Steplength_Sm_c{lfly}*params.px2mm*params.framerate;
            
                %% Plot of shaded area where walking bout
                yspeedlim=20;
                walkstarts=find(conv(double(Walking_vec{lfly}==1),[1 -1])==1);
                walkends=find(conv(double(Walking_vec{lfly}==1),[1 -1])==-1);
                %%% Find walking bouts surrounding time segment
                boutstart=find(walkstarts<range(1),1,'last');
                boutend=find(walkends>range(end),1,'first');
                for lwalkingbout=boutstart:boutend
                    
                        fillh=fill([walkstarts(lwalkingbout);walkstarts(lwalkingbout);...
                        walkends(lwalkingbout); walkends(lwalkingbout)],...
                        [0;yspeedlim;...
                        yspeedlim;0],...
                        Color(3,:));
                    
                    set(fillh,'EdgeColor',Color(3,:),'FaceAlpha',.3,...
                    'EdgeAlpha',.3);
                end
                plot(range,X(range),'LineWidth',1,'Color',Color(3,:));
                plot(range,X(range),'LineWidth',0.5,'Color','k');   
            
            if lrow~=1
                set(gca,'XTickLabel',[],'XTick',[],'Box','off','YTickLabel',[])
            else
                font_style([],[],{'Speed'; '(mm/s)'},'normal','arial',FtSz-2)
                set(gca,'XTickLabel',[],'XTick',[],'Box','off')
            end
            axis([range(1) range(end) 0 yspeedlim])
            xlabel([]) 
                        %% Trajectories
            switch lrow
                case 1
                    subplot('Position',[0.05    0.3    0.2    0.3])
                case 2
                    subplot('Position',[0.28    0.3    0.2    0.3])
                case 3
                    subplot('Position',[0.51    0.3    0.2    0.3])
                case 4
                    subplot('Position',[0.74    0.3    0.2    0.3])
            end
            
            plot_tracks_single(FlyDB,Heads_Sm{lfly},lfly,Spots,params,1,...
                Color(1,:),range,FtSz,1,1);%Plotting selected flies
            plot_tracks_single(FlyDB,Heads_Sm{lfly},lfly,Spots,params,1,...
                'k',range,FtSz,0,0.3);
            title([])
            axis([xlim_ ylim_])
            axis off
        end
    else
           range=ranges;
            hold on
            if saveplot==1
                LinWidth=.8;
                FtSz=5;
            else
                LinWidth=3;
                
            end
            range_h=range(1:2:end);
            plot_heading(Centroids_Sm{lfly},Heads_Sm{lfly},Tails_Sm{lfly},1,...
                Color(1,:),params,range_h,2,0.05)%2,0.09)%Colormap(3,:);%Colormap(lflycounter,:) %[0.7 0.7 0.7]
            plot_tracks_single(FlyDB,Centroids_Sm{lfly},lfly,Spots,params,1,...
                Color(1,:),range,FtSz,1,LinWidth)%Plotting selected flies
            plot_tracks_single(FlyDB,Heads_Sm{lfly},lfly,Spots,params,1,...
                'k',range,FtSz,0,LinWidth/2)
            plot_tracks_single(FlyDB,Heads_Sm{lfly},lfly,Spots,params,1,...
                Color(2,:),range,FtSz,0,LinWidth)%[0.7 0.7 0.7]%Plotting selected flies
%             plot_tracks_single(FlyDB,Tails_Sm{lfly},lfly,Spots,params,1,...
%                 Color(3,:),range,FtSz,0,3)%[0.7 0.7 0.7]%Plotting selected flies            
%         hc(2)=plot_tracks_single(FlyDB,Centroids_Sm{lfly},lfly,Spots,params,1,...
%             [.7 .7 .7],range,FtSz,1,2*LineW);
%         colormap_segments=EthoH_Colors;%Etho_Tr_Colors;%
%         etho_segments=Etho_H_Speed(lfly,:);%Etho_Tr(lfly,:);%
%         plot_traj_etho(Heads_Sm,lfly,range,etho_segments,colormap_segments,...
%             2*LineW,params,Centroids_Sm,Tails_Sm)
%         hc(2)=plot_tracks_single(FlyDB,Heads_Sm{lfly},lfly,Spots,params,1,...
%             [.5 .5 .5],range,FtSz,0,LineW);
%              axis([xlim_ ylim_])
%             
%             axis off
    end
    figname=[params.LabelsShort{params.ConditionIndex(lfly)},...
        '; Fly Nº' num2str(lfly) ', ' num2str(range(1)) ' to ' num2str(range(end))];
    SubFolder_name='Manual Ann';
    if saveplot==1
%         print('-dpng','-r600',[DataSaving_dir_temp Exp_num '\Plots\Manual Ann\',...
%             figname '.png'])
    end
if lfly~=fliestoplot(end)
    pause
    clf
end

end
if saveplot==1
%         print('-dtiff','-r150',[DataSaving_dir_temp Exp_num '\Plots\Manual Ann\' figname '.tif'])
        print('-dpng','-r600',[DataSaving_dir_temp Exp_num '\Plots\Manual Ann\',...
            figname '.png'])
end

