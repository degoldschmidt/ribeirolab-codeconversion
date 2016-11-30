function [DursFlyPAD_Cond,CumTime_FlyPAD_Cond,OnsFlyPAD_Cond]=plot_FlyPAD_Tracking(Events,...
    FlyPAD_var,Tracking_var,CumTime,DurIn,Conditions,params,plotting,MaxSample,...
    DataSaving_dir_temp,Exp_num,Exp_letter)
% plotting='Boxplot' --> plots boxplots of tracking Total times vs FlyPAD number of sips
% plotting='Cumulative' --> plots cumulative time vs cumulative number of sips
% FlyPAD_var='Sips' --> compares cumulative tracking time with cumulative
%                       number of sips
% FlyPAD_var='Activity Bouts' --> compares cumulative tracking time with
%                            cumulative duration of activity bouts
if nargin==7,MaxSample=360000;DataSaving_dir_temp=cd;Exp_num=' ';end
%% Bar & stderr of Total time plotting params
ColorSpPts=[.6 .6 .6;142/255 185/255 45/255];
FtSz=6;
FntName='arial';
Linewidth=3;
MarkrSz=6;
jitter=0.2;
%% Colors
[CondColors,Cmap_patch]=Colors(length(Conditions));
Colors_PAD=cell(length(Conditions),1);
for lcond=Conditions
    Colors_PAD{lcond==Conditions,1}=CondColors(lcond==Conditions,:);
    Colors_PAD{lcond==Conditions,2}=Cmap_patch(lcond==Conditions,:);
end
%% General FlyPAD Experiment Info
Channels_num=[1:2:64;2:2:64];%[Yeast;Sucrose];
% Dur=320000;

totalnumflies_FlyPAD=size(Events.Ons,1)*size(Events.Ons,2)/2;
DurIn_FlyPAD=cell(totalnumflies_FlyPAD,1);
paramsFlyPAD.ConditionIndex=nan(1,totalnumflies_FlyPAD);
paramsFlyPAD.framerate=100;
paramsFlyPAD.Subs_Names=Events.SubstrateLabel';
paramsFlyPAD.LabelsShort=Events.ConditionLabel';

CumTime_FlyPAD_Cond=cell(2,1);
OnsFlyPAD_Cond=cell(2,1);
DursFlyPAD_Cond=cell(2,1);
NumBoutsH_temp=nan(2,size(CumTime{1},2));
for lsubs=1:length(Events.SubstrateLabel)
    [CumTime_FlyPAD_Cond{lsubs}, OnsFlyPAD_Cond{lsubs}, DursFlyPAD_Cond{lsubs}]=...
        CumulativeActB_or_FeedBurst(Events,lsubs,MaxSample,FlyPAD_var);
    
    %%% Creating a DurIn vector (with the tracking format) from FlyPAD data
    flycounter=0;
    for lcond=1:size(DursFlyPAD_Cond{lsubs},2)
        for lfly=1:size(DursFlyPAD_Cond{lsubs},1)
            flycounter=flycounter+1;
            numofbouts=numel(DursFlyPAD_Cond{lsubs}{lfly,lcond});
            if lsubs==1
                if numofbouts==0
                    DurIn_FlyPAD{flycounter}=double.empty(0,5);
                else
                    DurIn_FlyPAD{flycounter}=[lsubs*ones(numofbouts,4),...
                        DursFlyPAD_Cond{lsubs}{lfly,lcond}];
                end
                paramsFlyPAD.ConditionIndex(flycounter)=lcond;
            else
                if numofbouts==0
                    DurIn_FlyPAD{flycounter}=[DurIn_FlyPAD{flycounter};double.empty(0,5)];
                else
                    DurIn_FlyPAD{flycounter}=[DurIn_FlyPAD{flycounter};[lsubs*ones(numofbouts,4),...
                        DursFlyPAD_Cond{lsubs}{lfly,lcond}]];
                end
                dbstop if warning
            end
            
        end
    end
    if (flycounter==totalnumflies_FlyPAD)&&(sum(isnan(paramsFlyPAD.ConditionIndex))==0)
        display('flycounter equals numflies :)')
    else
        error('flycounter doesn''t numflies :(')
    end
end
%% Tracking Total times vector
MaxFrames=floor(MaxSample/2);%Sample rate in FlyPAD is 100Hz, but in tracking is 50Hz
numflies=size(CumTime{1},2);
Totaltimes=cell(length(params.Subs_Names),1);

close all
for lsubs=1:length(params.Subs_Names);
    display(params.Subs_Names{lsubs})
    switch plotting
        case 'Boxplot' %% Plotting Bar & stderr of Total time
            figure('Position',[100 50 params.scrsz(3)-450 params.scrsz(4)-150],...
                'Color','w','Name',['Boxplot ' params.Subs_Names{lsubs} 'total times - Tracking vs FlyPAD']);
            %% TRACKING DATA - Total times
            Totaltimes{lsubs}=nan(numflies,1);
            for lfly=1:numflies
                Totaltimes{lsubs}(lfly)=...
                    nansum(CumTime{lsubs}(1:MaxFrames),lfly)/params.framerate/60;%min
            end
            Col_tracking_vector=Totaltimes{lsubs};
            plot_bar_track_PAD(Col_tracking_vector,Conditions,ColorSpPts,...
                params.ConditionIndex,1)
            font_style([],[],...
                ['Tracking: Total duration of engagement [min]'],'bold',...
                FntName,FtSz)
            haxes_track=gca;
            haxes_track_pos=get(haxes_track,'Position');
            
            %% FlyPAD DATA - Number of sips
            Col_PAD_vector=nan(size(Events.Ons,1)*size(Events.Ons,2)/2,1);
            Cond_Idx_PAD=nan(size(Events.Ons,1)*size(Events.Ons,2)/2,1);
            counter=1;
            for lrun=1:size(Events.Ons,1)
                for lchannel=Channels_num(lsubs,:)
                    Col_PAD_vector(counter)=numel(Events.Ons{lrun,lchannel});
                    Cond_Idx_PAD(counter)=Events.Condition{lrun}(lchannel);
                    counter=counter+1;
                end
                
            end
            haxes_PAD = axes('Position',haxes_track_pos,...
                'YAxisLocation','right',...
                'Color','none');
            plot_bar_track_PAD(Col_PAD_vector,Conditions,ColorSpPts,Cond_Idx_PAD',2,haxes_PAD)
            
            font_style(params.Subs_Names{lsubs},[],...
                ['FlyPAD: number of sips'],'bold',FntName,FtSz)
            ylimitPAD=max(Col_PAD_vector)+1;
            set(haxes_PAD,'YColor',ColorSpPts(2,:),...
                'Ylim',[0 ylimitPAD],'XLim',[0.5 length(Conditions)+1],...
                'Xtick',[],'XTickLabel',[])
            
            ylimitTrack=ylimitPAD*(nanmean(Col_tracking_vector(params.ConditionIndex==1))/...
                (nanmean(Col_PAD_vector(Cond_Idx_PAD==1))));%Setting mean of condition 1 equal
            set(haxes_track,'YColor',ColorSpPts(1,:),...
                'Ylim',[0 ylimitTrack],'XLim',[0.5 length(Conditions)+1],...
                'Xtick',[],'XTickLabel',[])
            
            ax=axis;
            %%% Rotate x axis labels
            t=text([1:length(Conditions)]+0.25,ax(3)*ones(1,length(Conditions)),...
                params.LabelsShort(Conditions));
            set(t,'HorizontalAlignment','right','VerticalAlignment','top',...
                'Rotation',20,'FontSize',FtSz,'FontName',FntName);
        case 'Cumulative'
            figure('Position',[100 50 params.scrsz(3)-450 params.scrsz(4)-150],...
                'Color','w','Name',['Cumulative ' params.Subs_Names{lsubs} ' time - Tracking vs FLyPAD']);
            %% Cumulative Times - Tracking
            subplot(1,2,1)
            display('Calculating Cumulative Times Tracking')
            h = plot_Cumulative(CumTime,Conditions,lsubs,MaxFrames,params,FlyPAD_var);
            ylims=get(gca,'YLim');
            axis([0 ceil(MaxFrames/params.framerate/60) 0 ylims(2)])
            
            %% Cumulatives - FlyPAD
            %%% Modification of Pasha's code
            subplot(1,2,2)
            switch FlyPAD_var
                case 'Sips'
                    CumulativeFeedingEvents(Events,lsubs,1,params.LabelsShort,Colors_PAD,MaxSample);
                    font_style('FlyPAD','Recording time (min)',[params.Subs_Names{lsubs}(1:end-4),...
                        ' Cumulative Number of Sips'],'normal',FntName,FtSz)
                    set(gca, 'XTick',[0:10:60]*60*100,'XTickLabel',{'0','10','20','30','40','50','60'})
                    %                     xlim([0 ceil(MaxSample/100/60)])
                case 'Activity Bouts'
                    CumulativeActivityBouts(Events,lsubs,MaxSample,1);
                    axis([0 ceil(MaxSample/100/60) 0 ylims(2)])
            end
            legend(h,Events.ConditionLabel,'Location','Best','box','off','FontSize',FtSz-2)
        case 'All'
            figure('Position',[100 50 params.scrsz(3)-450 params.scrsz(4)-150],...
                'Color','w','Name',[params.Subs_Names{lsubs} ' Tracking ' Tracking_var ' vs flyPAD ' FlyPAD_var]);
            %% Plotting cumulative
            subplot('Position',[0.1 0.67 0.2 0.15]);%Tracking on top
            h=plot_Cumulative(CumTime,Conditions,lsubs,MaxFrames,params,[],FtSz,FntName);
            ylims=get(gca,'YLim');
            if lsubs==2, ylims=[0 3.2];end
            axis([0 ceil(MaxFrames/params.framerate/60) 0 ylims(2)])
            set(gca,'XTick',[],'box', 'off')
            xlabel('')
            legend(h,params.LabelsShort,'FontSize',FtSz-1,'Position',[0.1 0.85 0.05 0.05]);
            legend('boxoff')
            text(ceil(MaxFrames/params.framerate/60)/2.5,ylims(2),...
                'Tracking','VerticalAlignment','top','FontSize',FtSz,'FontName',FntName)
            
            subplot('Position',[0.1 0.50 0.2 0.15]);% FlyPAD at bottom
            h=zeros(length(Conditions),1);
            
            for lcond=Conditions
                display(lcond)
                x=(1:MaxSample)'/100/60;
                elem2plot_idx=1:2*5000:MaxSample;
                CumTimes=nanmean(CumTime_FlyPAD_Cond{lsubs}{lcond},2)/100/60;
                stderr=nanstd(CumTime_FlyPAD_Cond{lsubs}{lcond},0,2)./...
                    sqrt(size(CumTime_FlyPAD_Cond{lsubs}{lcond},2))/100/60;
                h(Conditions==lcond)=plot_line_errpatch(x(elem2plot_idx),...
                    CumTimes(elem2plot_idx),stderr(elem2plot_idx),...
                    CondColors((Conditions==lcond),:),Cmap_patch((Conditions==lcond),:));
                
            end
            font_style([],'Time (min)',...
                {'Cumulative Time'},'normal',FntName,FtSz)
            axis([0 ceil(MaxFrames/params.framerate/60) 0 ylims(2)])
            set(gca,'box', 'off')
            text(ceil(MaxFrames/params.framerate/60)/2.5,ylims(2),...
                'FlyPAD','VerticalAlignment','top','FontSize',FtSz,'FontName',FntName)
            h=suptitle([params.Subs_Names{lsubs} ' - FlyPAD ' FlyPAD_var ' vs Tracking ' Tracking_var]);
            set(h,'FontSize',FtSz+2,'FontName',FntName);
            %% Plotting Rank-Freq distributions
            %%% Rank-Freq distributions for Tracking
            subplot('Position',[0.4 0.67 0.2 0.15])%Tracking on top
            hold on
            Inline=hist_bout_duration(DurIn,Conditions,params,0);
            plot_rank_freq(Inline,params,lsubs,[],CondColors,FtSz,1,FntName);
            title([])
            set(gca,'XTick',[],'box', 'off')
            xlabel('')
            ylims=get(gca,'YLim');xlims=get(gca,'XLim');
            
            %%% Rank-Freq distributions for FlyPAD
            subplot('Position',[0.4 0.50 0.2 0.15])% FlyPAD at bottom
            
            hold on
            InlineFlyPAD=hist_bout_duration(DurIn_FlyPAD,Conditions,paramsFlyPAD,0);
            plot_rank_freq(InlineFlyPAD,paramsFlyPAD,lsubs,'Durations',CondColors,FtSz,1,FntName);
            title([])
            axis([xlims ylims])
            set(gca,'box', 'off')
            
            %% Plotting hist of bout durations
            %%% Histogram of bout durations for Tracking
            subplot('Position',[0.7 0.67 0.2 0.15]);%Tracking on top
            max_all=[40 40];
            max_x=max_all(lsubs);
            nbins=80;
            
            step_tr=max_x/(nbins-1);
            for lcondcounter=1:length(Conditions)
                hold on
                [count,xbin]=hist((Inline{lsubs,lcondcounter}),...
                    0:step_tr:max_x);
                count(count==0)=nan;
                plot(xbin,count/nansum(count),'ob','Color',CondColors(lcondcounter,:),...
                    'MarkerFaceColor',CondColors(lcondcounter,:),'LineWidth',1,'MarkerSize',1);
                plot(xbin,count/nansum(count),...
                    '-b','Color',CondColors(lcondcounter,:),'LineWidth',1);
            end
            font_style([],[],{'Ocurrences,';'normalised'},...
                'normal',FntName,FtSz)
            set(gca,'XTick',[],'box', 'off')
            xlabel('')
            axis([-step_tr/2 max_x 0 .5])
            %%% Histogram of bout durations FlyPAD
            subplot('Position',[0.7 0.50 0.2 0.15]);% FlyPAD at bottom
            %             nbins=50;
            step_f=max_x/(nbins-1);
            for lcondcounter=1:length(Conditions)
                hold on
                [count,xbin]=hist((InlineFlyPAD{lsubs,lcondcounter}),...
                    0:step_f:max_x);
                count(count==0)=nan;
                plot(xbin,count/nansum(count),'ob','Color',CondColors(lcondcounter,:),...
                    'MarkerFaceColor',CondColors(lcondcounter,:),'LineWidth',1,'MarkerSize',1);
                plot(xbin,count/nansum(count),...
                    '-b','Color',CondColors(lcondcounter,:),'LineWidth',1);
            end
            xlim([-step_tr/2 max_x])
            font_style([],['Durations (s)'],{'Ocurrences,';'normalised'},...
                'normal',FntName,FtSz)
            axis([-step_tr/2 max_x 0 .5])
            % % %             %% Plotting cumulative YPI --> This doesn't really work because there
            % % %             %%% are many flies that don't start eating from the beginning,
            % % %             %%% generating nans in the variables --> Making the errors
            % % %             %%% variate along time...
            % % %             subplot('Position',[0.7 0.67 0.2 0.15]);%Tracking on top
            % % %             h=zeros(length(Conditions),1);
            % % %             x=(1:MaxFrames)'/params.framerate/60;
            % % %             elem2plot_idx=1:5000:MaxFrames;%params.MinimalDuration;%
            % % %             for lcond=Conditions
            % % %                 display(lcond)
            % % %                 CumY=cumsum(CumTimeAB{1}(1:MaxFrames,params.ConditionIndex==lcond));
            % % %                 CumS=cumsum(CumTimeAB{2}(1:MaxFrames,params.ConditionIndex==lcond));
            % % %                 CumYPI=(CumY-CumS)./(CumY+CumS);
            % % %                 CumTimes=nanmean(CumYPI,2)/params.framerate/60;
            % % %                 stderr=nanstd(CumYPI,0,2)./...
            % % %                     sqrt(sum(params.ConditionIndex==lcond))/params.framerate/60;
            % % %                 h(Conditions==lcond)=plot_line_errpatch(x(elem2plot_idx),...
            % % %                     CumTimes(elem2plot_idx),stderr(elem2plot_idx),...
            % % %                     CondColors((Conditions==lcond),:),Cmap_patch((Conditions==lcond),:));
            % % %
            % % %             end
            % % %             font_style([],'Time (min)',...
            % % %                 {'Act Bouts Cumulative YPI'},'normal',FntName,FtSz)
            % % %             ylims=get(gca,'YLim');
            % % %             xlim([0 ceil(MaxFrames/params.framerate/60)])% -1 1])
            % % %             set(gca,'XTick',[],'box', 'off')
            % % %             xlabel('')
            % % %
            % % %             subplot('Position',[0.7 0.50 0.2 0.15]);% FlyPAD at bottom
            % % %             h=zeros(length(Conditions),1);
            % % %             for lcond=Conditions
            % % %                 display(lcond)
            % % %                 x=(1:MaxSample)'/100/60;
            % % %                 elem2plot_idx=1:2*5000:MaxSample;
            % % %                 CumY=CumTime_FlyPAD_Cond{1}{lcond};
            % % %                 CumS=CumTime_FlyPAD_Cond{2}{lcond};
            % % %                 CumYPI=(CumY-CumS)./(CumY+CumS);
            % % %                 CumTimes=nanmean(CumYPI,2)/100/60;
            % % %                 stderr=nanstd(CumYPI,0,2)./...
            % % %                     sqrt(size(CumTime_FlyPAD_Cond{lsubs}{lcond},2))/100/60;
            % % %                 h(Conditions==lcond)=plot_line_errpatch(x(elem2plot_idx),...
            % % %                     CumTimes(elem2plot_idx),stderr(elem2plot_idx),...
            % % %                     CondColors((Conditions==lcond),:),Cmap_patch((Conditions==lcond),:));
            % % %
            % % %             end
            % % %             font_style([],'Time (min)',...
            % % %                 {['FlyPAD ' FlyPAD_var];'Cumulative YPI'},'normal',FntName,FtSz)
            % % %             xlim([0 ceil(MaxFrames/params.framerate/60)])% -1 1])
            % % %             set(gca,'box', 'off')
            
            %% Plotting box plots comparing certain aspects of the FlyPAD var with the Tracking AB
            %%% Max flies per condition in tracking
            numcond=nan(length(Conditions),1);
            for lcond=Conditions
                numcond(lcond)=sum(params.ConditionIndex==lcond);
            end
            boxes_colormap_FlyPAD=repmat([0.5 0.5 0.5],length(Conditions),1);%Colormap;
            boxes_colormap_Tracking=repmat([1 1 1],length(Conditions),1);%Colormap;
            
            for lsubplot=1:3
                %% Plotting box plot of specific aspect of FlyPAD var
                switch lsubplot
                    case 1 %% Total duration of FlyPAD_var
                        subplot('Position',[0.1 0.20 0.2 0.2])
                        X_FPAD=nan(size(DursFlyPAD_Cond{lsubs},1),length(Conditions));
                        for lcond=Conditions
                            for lfly=1:size(DursFlyPAD_Cond{lsubs},1)
                                X_FPAD(lfly,lcond)=sum(DursFlyPAD_Cond{lsubs}{lfly,lcond})/100/60;
                            end
                        end
                    case 2 %% Mean duration of FlyPAD_var
                        subplot('Position',[0.4 0.20 0.2 0.2])
                        X_FPAD=nan(size(DursFlyPAD_Cond{lsubs},1),length(Conditions));
                        for lcond=Conditions
                            for lfly=1:size(DursFlyPAD_Cond{lsubs},1)
                                X_FPAD(lfly,lcond)=mean(DursFlyPAD_Cond{lsubs}{lfly,lcond})/100;
                            end
                        end
                    case 3 %% Number of FlyPAD_var
                        subplot('Position',[0.7 0.20 0.2 0.2])
                        X_FPAD=nan(size(OnsFlyPAD_Cond{lsubs},1),length(Conditions));
                        for lcond=Conditions
                            for lfly=1:size(OnsFlyPAD_Cond{lsubs},1)
                                X_FPAD(lfly,lcond)=numel(OnsFlyPAD_Cond{lsubs}{lfly,lcond});
                            end
                        end
                end
                x_values_FPAD=[1 6 11 16];
                FlyPADfillhandle=plot_boxplot_tiltedlabels(X_FPAD,cell(4,1),...
                    x_values_FPAD,boxes_colormap_FlyPAD,CondColors,'k',1,FtSz,FntName,'.');
                %% Plotting box plot of specific aspect of Tracking Activity Bouts
                switch lsubplot
                    case 1 %% Total duration of AB Tracking
                        var_label='Total duration';
                        y_label={'Total';'duration (min)'};
                        X_Tr=nan(max(numcond),length(Conditions));
                        for lcond=Conditions
                            X_Tr(1:numcond(lcond),lcond)=sum(CumTime{lsubs}(1:MaxFrames,params.ConditionIndex==lcond))'/params.framerate/60;
                        end
                    case 2 %% Mean duration of AB Tracking
                        var_label='Mean duration';
                        y_label={'Mean';'duration (s)'};
                        X_Tr=nan(max(numcond),length(Conditions));
                        for lcond=Conditions
                            counter=0;
                            for lfly=find(params.ConditionIndex==lcond)
                                counter=counter+1;
                                tempDur=DurIn{lfly}(DurIn{lfly}(:,1)==lsubs,5);
                                starts=DurIn{lfly}(DurIn{lfly}(:,1)==lsubs,2);
                                ends=DurIn{lfly}(DurIn{lfly}(:,1)==lsubs,3);
                                laststart=find(starts<MaxFrames,1,'Last');
                                tempDur=tempDur(1:laststart);
                                if ends(laststart)>MaxFrames
                                    display(['Before: ' num2str(tempDur(end)),...
                                        ', now: ' num2str(MaxFrames-starts(laststart))])
                                    tempDur(end)=MaxFrames-starts(laststart);
                                end
                                NumBoutsH_temp(lsubs,lfly)=numel(tempDur);
                                X_Tr(counter,lcond)=nanmean(tempDur)/params.framerate;
                                
                            end
                        end
                    case 3 %% Number of AB Tracking
                        var_label='Number of bouts';
                        y_label={'Number of';'bouts'};
                        X_Tr=nan(max(numcond),length(Conditions));
                        for lcond=Conditions
                            X_Tr(1:numcond(lcond),lcond)=NumBoutsH_temp(lsubs,params.ConditionIndex==lcond)';
                        end
                end
                x_values_Tr=[3 8 13 18];
                Trackingfillhandle=plot_boxplot_tiltedlabels(X_Tr,cell(4,1),...
                    x_values_Tr,boxes_colormap_Tracking,CondColors,'k',1,FtSz,FntName,'.');
                
                ax=get(gca,'Ylim');
                thandle=text([2 7 12 17],ax(1)*ones(1,length(params.LabelsShort)),params.LabelsShort);
                set(thandle,'HorizontalAlignment','right','VerticalAlignment','top',...
                    'Rotation',20,'FontSize',FtSz,'FontName',FntName);
                
                xlim([0 19])%    xlim([0.5 size(X,2)+0.5])
                font_style([],[],y_label,'normal',FntName,FtSz)
                legend([FlyPADfillhandle(1) Trackingfillhandle(1)],{'FlyPAD','Tracking'},...
                    'box','off','location','none','Position',[0.935 0.35 0.01 0.05],'FontSize',FtSz-1)
                legend('boxoff')
                
                % % % % % % % % % % % % object_handles = findall(gca);%Top are more recent
                % % % % % % % % % % % % get(findall(gca),'Type')
                
                %% Saving stats text file
                title_pvalue=['Uncorrected Mann Whitney p-values for ' var_label ' ' Events.SubstrateLabel{lsubs}];
                display(title_pvalue)
                fid=fopen([DataSaving_dir_temp Exp_num '\Plots\Total times & Ethogram\',...
                    Exp_num Exp_letter 'R01R04 - ' var_label ' ' Events.SubstrateLabel{lsubs} '.txt'],'w');
                
                fprintf(fid,'%s\r\n\r\n',title_pvalue);
                for lgroup=1:length(Conditions)
                    fprintf(fid,'%s\r\n',['---- ' params.LabelsShort{Conditions(lgroup)} ' ----']);
                    p=ranksum(X_FPAD(:,lgroup),X_Tr(:,lgroup));
                    pvaluetext=['FlyPAD ' FlyPAD_var ' vs Tracking ' Tracking_var ' = ' num2str(p)];
                    display(pvaluetext)
                    fprintf(fid,'%s\r\n',pvaluetext);
                    %% Plot line with stats
                    y_lims=get(gca,'YLim');
                    plot([x_values_FPAD(lgroup) x_values_Tr(lgroup)],[.9*y_lims(2) .9*y_lims(2)],'-k','LineWidth',.8)
                    vertical='middle';
                    margin=2;
                    if (p<0.05)&&(p>=0.01)
                        textstring='*';
                    elseif (p<0.01)&&(p>=0.001)
                        textstring='**';
                    elseif (p<0.001)
                        textstring='***';
                    else
                        textstring='ns';
                        vertical='bottom';
                        margin=1;
                    end
                    text(x_values_FPAD(lgroup)+1,.9*y_lims(2),textstring,'HorizontalAlignment','center',...
                        'VerticalAlignment',vertical,'Margin',margin,'FontSize',FtSz,'FontName',FntName)
                end
                fclose(fid);
            end
    end
end


    function plot_bar_track_PAD(Col_vector,Conditions,ColorSpPts,ConditionIndex,...
            SetupNum,haxes_PAD)
        
        if nargin==6
            haxes=haxes_PAD;
        else
            haxes=gca;
        end
        
        xpos=[1:length(Conditions);(1:length(Conditions))+0.4];
        
        for llcond=Conditions
            hold on
            
            stderrY=nanstd(Col_vector(ConditionIndex==llcond))/...
                sqrt(sum(ConditionIndex==llcond));
            
            %% Bar plot
            %     barhandle=bar(xpos(SetupNum,Conditions==lcond),nanmean(Col_vector(ConditionIndex==lcond)),jitter+0.1*jitter);%,0.23);
            %     set(barhandle,'LineWidth', Linewidth,'EdgeColor',Colormap(Conditions==lcond,:),...
            %         'FaceColor','w','Parent',haxes);%FaceColor(lsubs,:));
            %% Plotting SpreadPoints
            plot_spreadpts(Col_vector(ConditionIndex==llcond),xpos(SetupNum,Conditions==llcond),...
                ColorSpPts(SetupNum,:),MarkrSz,jitter)
            %% Line in mean
            plot([xpos(SetupNum,Conditions==llcond)-jitter/2;xpos(SetupNum,Conditions==llcond)+jitter/2],...
                repmat(nanmean(Col_vector(ConditionIndex==llcond)),2,1),...
                'Color',CondColors((Conditions==llcond),:),'LineWidth',Linewidth+2,'Parent',haxes)
            %% Line std error
            line([xpos(SetupNum,Conditions==llcond);xpos(SetupNum,Conditions==llcond)],...
                [nanmean(Col_vector(ConditionIndex==llcond))+stderrY;...
                nanmean(Col_vector(ConditionIndex==llcond))-stderrY],...
                'Color',CondColors((Conditions==llcond),:),'LineWidth',Linewidth-1,'Parent',haxes);
            plot(xpos(SetupNum,Conditions==llcond),nanmean(Col_vector(ConditionIndex==llcond)),...
                '-ob','LineWidth',Linewidth,...
                'MarkerEdgeColor',CondColors((Conditions==llcond),:),...
                'MarkerSize',MarkrSz,'MarkerFaceColor','w','Parent',haxes);
            
            %     ylim([0 160])
            
        end
    end



end