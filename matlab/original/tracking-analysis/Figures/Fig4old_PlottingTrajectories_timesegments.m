%% Plotting trajectories
MAtedHunt=find(params.ConditionIndex==1);
[Totalt_sorted,Idx_sort]=sort(Totaltimes{lsubs}(params.ConditionIndex==lcond),...
        'descend');
SortedMatedHunt=MAtedHunt(Idx_sort)';    
% Walking_vec=walking_fun(Steplength_Sm_c,flies_idx,params);

%%
flies_idx=32%SortedMatedHunt';%SortedMatedYaa(:)';%SortedMatedDep(:)';%[4:6 41:44];
ranges=[2 12000;12000 120000; 120000 240000;240000 345000];%1:size(Heads_Sm{lfly},1);%[188300:188700];%[eng_fr_1:eng_fr_end];%[143422:150939];

Spots=11;%[1,5,9,14];
FtSz=8;
plotarena=1;

Color=Colors(3);%hsv(length(flies_idx));%
States_Colors=[238 96 8;0 0 0;0 166 0; 255 255 255]/255;%[Orange, Black, Green, White]
WalkingEtho_Colors=[Color(3,:);[1 1 1];[0.5 0.5 0.5]];%[blue, white, gray]

xlim_=[-33 33];%[11 16.2];%
ylim_=[-33 33];%[-17.2 -11.5];%
%%
% close all
if size(ranges,1)>1
    figure('Position',[100 50 1400 930],'Color','w')
else
    figure('Position',[100 50 1200 930],'Color','w')
end
hold on
for lfly=flies_idx
    clf
    
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
        '; Fly Nº' num2str(lfly)]; ['0 - ' num2str(range(end)/params.framerate/60) ' min']},...
        [],[],'normal','arial',FtSz)
                ylabel('Location','FontSize',FtSz-2,'FontName','arial')
            else
                title([num2str(range(1)/params.framerate/60) ' - ',...
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
           range=ranges(1,1):ranges(1,2);%1:size(Heads_Sm{lfly},1);%[188300:188700];%[eng_fr_1:eng_fr_end];%[143422:150939];

        %     plot_tracks_single(FlyDB,Centroids_Sm{lfly},lfly,Spots,params,1,...
        %         Colormap(1,:),range,FtSz,plotarena,3)%[0.7 0.7 0.7]%Plotting selected flies
        %     plot_tracks_single(FlyDB,Tails_Sm{lfly},lfly,Spots,params,1,...
        %         Colormap(3,:),range,FtSz,0,3)%[0.7 0.7 0.7]%Plotting selected flies
        %     range_h=range(1:2:end);
        %     plot_heading(Centroids_Sm{lfly},Heads_Sm{lfly},Tails_Sm{lfly},1,...
        %         Colormap(1,:),params,range_h,2,0.05)%2,0.09)%Colormap(3,:);%Colormap(lflycounter,:) %[0.7 0.7 0.7]
            plot_tracks_single(FlyDB,Heads_Sm{lfly},lfly,Spots,params,1,...
                Color(1,:),range,FtSz,1,3)%Plotting selected flies
            plot_tracks_single(FlyDB,Heads_Sm{lfly},lfly,Spots,params,1,...
                'k',range,FtSz,0,0.3)
             axis([xlim_ ylim_])
            
            axis off
    end
    figname=[params.LabelsShort{params.ConditionIndex(lfly)},...
        '; Fly Nº' num2str(lfly) ', ' num2str(range(1)) ' to ' num2str(range(end))];
    SubFolder_name='Manual Ann';
    print('-dtiff','-r600',[DataSaving_dir_temp Exp_num '\Plots\Manual Ann\' figname '.tif'])
if size(flies_idx,2)>1
    pause
end

end


