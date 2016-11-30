function [TrP_Median,TrP_Mean,TrP_Stderr,barhandle] = plot_TrPr(TrEvents,...
    Conditions,Type_Names,plotting,var_type,stat,params,FtSz,FntName)
%plot_Trans_Prob generates a bar plot with standard error bars of
%transition probabilities to Substrates in Subs_Names
%
%   Inputs:
%   Events      3D Matrix with number of bouts coming from substrate in row i
%               to substrate in col j. Pages are single flies.
%   plotting    1 --> 2D bar plot
%               2 --> 3D bar plot
%%
switch var_type
    case 'Transition Probabilities'
        TrPrM=TrEvents./repmat(sum(TrEvents,2),[1,size(TrEvents,2),1])*100;
    case 'Origin'
    case 'Area'
        TrPrM=TrEvents;
end
%% Median of Y-S-E Empirical Transition Probabilities
TrP_Median=zeros(size(TrPrM,1),size(TrPrM,2),length(Conditions));
NormalityTest_TP=nan(size(TrPrM,1),size(TrPrM,2),length(Conditions));
TrP_Mean=zeros(size(TrPrM,1),size(TrPrM,2),length(Conditions));
TrP_Stderr=zeros(size(TrPrM,1),size(TrPrM,2),length(Conditions));

scrsz = get(0,'ScreenSize');
figname=[var_type ', all flies, ' stat ', ' date];
figure('Position',[100 50 scrsz(3)-600 scrsz(4)-150],'Color','w','Name',figname)
plotcounter=1;
FaceColor=[5 16 241;204 0 0;181 184 253;227 190 202]/255;
% FaceColor=[179 197 218;227 190 202;231 188 41; 191 191 191]/255; % blue, red and yellow
% EdgeColor=[79 129 189;192 0 0;183 147 21;191 191 191]/255;
if size(FaceColor,1)<size(TrPrM,2)
    FaceColor=hsv(size(TrPrM,2));
end

labels=cell(2*size(TrPrM,1),1);
for ltype=1:size(TrPrM,1)
    labels{ltype}=['To same/close ' Type_Names{ltype}];
    labels{ltype+size(TrPrM,1)}=['To far ' Type_Names{ltype}];
end

numcond=nan(length(Conditions),1);
lcondcounter=0;
for lcond=Conditions
    lcondcounter=lcondcounter+1;
    numcond(lcondcounter)=sum(params.ConditionIndex==lcond);
end
lcondcounter=0;
for lcond=Conditions
    lcondcounter=lcondcounter+1;
    %% Median
    TrP_Median(:,:,lcond)=nanmedian(TrPrM(:,:,params.ConditionIndex==lcond),3);
    %     display([params.LabelsShort{lcond} ' - pvalue E-Y vs E-S'])
    %     ranksum(squeeze(TrPrM(3,1,params.ConditionIndex==lcond)),squeeze(TrPrM(3,2,params.ConditionIndex==lcond)))
    %% Mean & StdErr
    TrP_Mean(:,:,lcond)=nanmean(TrPrM(:,:,params.ConditionIndex==lcond),3);
    TrP_Stderr(:,:,lcond)=nanstd(TrPrM(:,:,params.ConditionIndex==lcond),0,3)/...
        sqrt(sum(params.ConditionIndex==lcond));
    %% Normality Test
    %     for lsubsfrom=1:size(TrPrM,1)
    %         for lsubsto=1:size(TrPrM,2)
    %             tempTP=zeros(sum(params.ConditionIndex==lcond),1);
    %             tempTP(:)=TrPrM(lsubsfrom,lsubsto,params.ConditionIndex==lcond);
    %             NormalityTest_TP(lsubsfrom,lsubsto,lcond)=jbtest(tempTP);
    %         end
    %     end
    %% Bar Plot
    subplot(2,ceil(length(Conditions)/2),plotcounter)
    FontSize=8;
    if size(TrPrM,1)>1;
        if plotting==1% Using [%]
            switch var_type
                case {'Transition Probabilities','Area'}
                    switch stat
                        case 'Mean'
                            if ~isempty(strfind(var_type,'Area'))
                                error('I''ve only written this function for median of mean distances')
                            else
                                barhandle=barwitherr(TrP_Stderr(:,:,lcond),TrP_Mean(:,:,lcond));%For transition probability
                                %                     barhandle=bar(TrP_Median(:,:,lcond));%For transition probability
                                font_style(params.LabelsShort{lcond},'From','Transition Probability [%]','normal',FntName,FtSz)
                                if plotcounter==1
                                    legend(barhandle(1:size(TrPrM,2)),labels)%Transition Probabilities
                                    legend('boxoff')
                                end
                                ylim([0 100])
                                xlim([0.5 2.5])
                            end
                        case 'Median'
                            numvariables=size(TrPrM,1);
                            xvalues=1:numvariables*(size(TrPrM,2)+1);
                            xvalues((1:numvariables)*(size(TrPrM,2)+1))=[];
                            X=nan(numcond(lcondcounter),length(xvalues));
                            lcolcounter=0;
                            for lvariable=1:numvariables
                                for lcol=1:size(TrPrM,2)
                                    lcolcounter=lcolcounter+1;
                                    X(:,lcolcounter)=squeeze(TrPrM(lvariable,lcol,params.ConditionIndex==lcond));
                                end
                            end
                            patch_h = plot_boxplot_tiltedlabels(X,cell(length(xvalues),1),xvalues,...
                                repmat(FaceColor,numvariables,1),repmat([0 0 0],length(xvalues),1),[.8 .8 .8],.6,FtSz,FntName);
                            ax=get(gca,'Ylim');
                            thandle=text((1:numvariables)*(size(TrPrM,2)+1)-floor(size(TrPrM,2)/2),...
                                ax(1)*ones(1,numvariables),params.Subs_Names);
                            set(thandle,'HorizontalAlignment','right','VerticalAlignment','top',...
                                'Rotation',20,'FontSize',FtSz,'FontName',FntName);
                            xlim([0 numvariables*(size(TrPrM,2)+1)])
                            if plotcounter==1
                                legend(patch_h(1:size(TrPrM,2)),labels,'color','none','FontSize',FtSz-2)%Transition Probabilities
                                legend('boxoff')
                            end
%                             
                            barhandle=patch_h;
                            if ~isempty(strfind(var_type,'Area'))
                                y_label='Mean area (px*10^-^3)';
                                ylim([0 12])
                            else
                                y_label='Transition Probability (%)';
                                ylim([0 100])
                            end
                            font_style(params.LabelsShort{lcond},'From',y_label,'normal',FntName,FtSz)
                    end
                case 'Origin'
                    %             barhandle=barwitherr(TrP_Stderr(:,:,lcond)',TrP_Mean(:,:,lcond)');%Comment for stacked bar plot
                    barhandle=bar(TrP_Mean(:,:,lcond)','stacked');%Uncomment for stacked bar plot
                    font_style(params.LabelsShort{lcond},'Arriving to','% Explained','bold',FntName,FtSz)
                    legend(barhandle(1:size(TrPrM,1)),fromLabels,'Location','Best')
                    legend('boxoff')
                    ylim([0 100])
                    xlim([0.5 2.5])
                
            end
            
            
        elseif plotting==2 %Using Num Bouts
            %             barhandle=barwitherr(TrP_Stderr(:,:,lcond)',TrP_Mean(:,:,lcond)');%Comment if plotting stacked
            barhandle=bar(TrP_Mean(:,:,lcond)','stacked'); %Uncomment for
            % %             stacked bar plot and comment barwitherr
            font_style(params.LabelsShort{lcond},'Arriving to','Number of Visits','bold',FntName,FontSize)%
            if plotcounter==1
                legend(barhandle(1:size(TrPrM,1)),fromLabels,'Location','Best')
                legend('boxoff')
            end
            ylim([0 100])
            xlim([0.5 2.5])
            
        elseif plotting==3
            barhandle=bar3(TrP_Mean(:,:,lcond));
            set(gca,'YTickLabel',Type_Names,'YTick',1:size(TrPrM,2),'FontSize',FontSize,'FontName',FntName)
            zlabel('Final Tr Prob [%]','FontSize',FontSize,'FontName',FntName,'FontWeight','bold')
            font_style(params.LabelsShort{lcond},'Arriving to','From','bold',FntName,FontSize)
            %             zlim([0 100])%
        elseif plotting==4
            %% Plotting Origin of visits using imagesc
            imagesc(TrP_Mean(:,:,lcond),[0 .8]),colorbar
            font_style(params.LabelsShort{lcond},'Arriving to','From','bold',FntName,FontSize)
            set(gca,'XTickLabel',Type_Names,'XTick',1:size(TrPrM,2),...
                'YTickLabel',fromLabels,'YTick',1:size(TrPrM,1),'FontSize',FontSize,'FontName',FntName,'box','off')
            
        end
    else
        barhandle=bar(TrP_Median(:,:,lcond)');
        
    end
    if (plotting~=4)&&isempty(strfind(stat,'Median'))
        switch var_type
            case 'Transition Probabilities'
                for lto=1:size(TrPrM,2)
                    set(barhandle(lto),'FaceColor',FaceColor(lto,:),'LineWidth', 1,'EdgeColor',FaceColor(lto,:));%,'BarWidth',0.4);
                end
            case 'Origin'
                for lsubs=1:size(TrPrM,1)
                    set(barhandle(lsubs),'FaceColor',FaceColor(lsubs,:),'LineWidth', 3,'EdgeColor',EdgeColor(lsubs,:),'BarWidth',0.4);
                end
        end
        
        set(gca,'XTickLabel',Type_Names,'XTick',1:size(TrPrM,2),'FontSize',FtSz,'FontName',FntName)
        %     set(gca,'XTickLabel',fromLabels,'XTick',1:size(TrPrM,1),'FontSize',FontSize,'FontName',FntName)
    end
    plotcounter=plotcounter+1;
    
end
title_h=suptitle(figname);set(title_h,'FontSize',FtSz,'FontName',FntName);
display(TrP_Median)
% display(NormalityTest_TP)
%%
% lfly=119;
% range=30000:150001;
% LineW=2;
% close all
% figure('Position',[100 50 1400 930],'Color','w')
% hold on
% plot_tracks_single(FlyDB,Heads_Sm{lfly},lfly,Spots,params,1,...
%             [.7 .7 .7],range,FtSz,1,0.5*LineW);%Plotting selected flies
%         %%% Find micromovement bouts surrounding time segment
%         for letho=1:size(Etho_Tr_Colors,1)
%
%             starts=find(conv(double(Etho_Tr(lfly,:)==letho),[1 -1])==1);
%             ends=find(conv(double(Etho_Tr(lfly,:)==letho),[1 -1])==-1)-1;
%
%             bout_start1=find(starts<range(1),1,'last');
%             bout_start2=find(starts<range(end),1,'last');
%             bout_start3=find(starts>=range(1),1,'first');
%             bout_start=min([bout_start1,bout_start2,bout_start3]);
%             bout_end1=find(ends>range(end),1,'first');
%             bout_end2=find(ends>range(1),1,'first');
%             bout_end3=find(ends<=range(end),1,'last');
%             bout_end=max([bout_end1,bout_end2,bout_end3]);
%             Colormicromovement=Etho_Tr_Colors(letho,:);
%             for lmicrobout=bout_start:bout_end
%                 frames_etho=starts(lmicrobout):ends(lmicrobout);
%
%                 frames_etho(frames_etho<range(1))=[];
%                 frames_etho(frames_etho>range(end))=[];
%                 if ~isempty(frames_etho)
%                     plot(Heads_Sm{lfly}(frames_etho,1)*params.px2mm,...
%                         Heads_Sm{lfly}(frames_etho,2)*params.px2mm,...
%                         'LineWidth',LineW,'Color',Colormicromovement)
%
%                 end
%
%             end
%         end
%
%         axis([xlim_ ylim_])
%         axis off
%         figname=[ num2str(rows2plot(ltracecounter)) ' - ' Vartoplot 'Trans_Etho - Fly ' num2str(lfly),...
%             ', ' num2str(range(1)-delay) ' to ' num2str(range(end)+delay)];
%         print('-dpng','-r600',[DataSaving_dir_temp Exp_num '\Plots\Manual Ann\',figname '.png'])%,'.png' or '-dtiff','-r600' ..