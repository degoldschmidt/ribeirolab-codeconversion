%% Composition of Visits all boxplots
%%% Not merging the slow and fast micromovements and plotting them with
%%% boxplots per condition (each data point is a fly)

FtSz=7;
FntName='arial';
saveplot=1;
new_plot=1;
num_prev_plots=5;
print_stats=1;

Conditions=unique(params.ConditionIndex);
[CondColors,Cmap_patch]=Colors(length(Conditions));

%% Transforming Etho_Speed in a matrix
Etho_Speed_new=nan(size(Etho_H));
for lfly=1:size(Etho_H,1)
    Etho_Speed_new(lfly,:)=Etho_Speed{lfly}(1:size(Etho_H,2));
end
%%
if new_plot==1
    close all
    num_prev_plots=0;
    h_dist=0.07;
    width=0.2;
    loc_x=0.1; loc_y=0.7;
    Positions=[loc_x loc_y width width;...
        loc_x+width+h_dist loc_y 3*width width;...
        loc_x loc_y-width-h_dist width width;...
        loc_x+width+h_dist loc_y-width-h_dist 3*width width];
    pos_legend=[loc_x loc_y-4*width-2*h_dist 0.01 0.06];
end

numcond=nan(length(Conditions),1);
lcondcounter=0;
for lcond=Conditions
    lcondcounter=lcondcounter+1;
    numcond(lcondcounter)=sum(params.ConditionIndex==lcond);
end

plot_types={'N of visits','N of elements per visit','Total duration','Fractions'};
for lsubs=1:length(params.Subs_Names)
    if new_plot==1
        
        figname=['Composition of ' params.Subs_Names{lsubs} ' visits'];
        figure('Position',[100 50 params.scrsz(3)-450 params.scrsz(4)-150],...
            'Color','w','Name',figname);
    end
    %% Plot Total Number of Visits per condition
    for lplot=1:4
        plot_type=plot_types{lplot};
        display(['------- ' plot_type ' -------'])
        switch plot_type
            case 'N of visits' %Total Number of Visits
                variable_labels={'Visits'};
                y_label='Nº of visits';
            case 'N of elements per visit' %Number of elements per visit
                variable_labels={'Slow H', 'Fast H', 'Rest','~H Slow mm','Turns','IHI'};
                variables_ethoSpeednumber=[2 3 1 2 6 0];
                y_label='Nº per visit';
            case 'Total duration' %Total duration of visits
                variable_labels={'Visits'};
                y_label={'Total duration';'of visits (min)'};
            case 'Fractions' %Percentage of each element
                variable_labels={'Slow H', 'Fast H', 'Rest','~H Slow mm','Turns','IHI'};
                variables_ethoSpeednumber=[2 3 1 2 6 0];
                y_label='Fraction of time (%)';
        end
        
        numvariables=length(variable_labels);
        xvalues=1:numvariables*(length(Conditions)+1);
        xvalues((1:numvariables)*(length(Conditions)+1))=[];
        
        X=nan(max(numcond),length(xvalues));
        clear variable_cond
        lcolcounter=0;
        for lvariable=1:numvariables
            variable_label=variable_labels{lvariable};
            display(['----- ' variable_label ' -----'])
            lcondcounter=0;
            for lcond=Conditions
                display(['Condition ' num2str(lcond)])
                lcondcounter=lcondcounter+1;
                lcolcounter=lcolcounter+1;
                
                logical_subs=logical(CumTimeV{lsubs}(:,params.ConditionIndex==lcond))';
                
                switch plot_type
                    case 'N of visits'
                        variable_cond=NumBoutsV(lsubs,params.ConditionIndex==lcond)';
                    case 'N of elements per visit'
                        display(plot_type)
                        TotalN=NumBoutsV(lsubs,params.ConditionIndex==lcond)';
                        switch variable_label
                            case {'Slow H','Fast H','Rest','~H Slow mm','Turns'}
                                ethonumber=variables_ethoSpeednumber(lvariable);
                                if ~isempty(strfind(variable_label,'Slow H'))||(~isempty(strfind(variable_label,'Fast H')))
                                    logical_etho=(Etho_Speed_new(params.ConditionIndex==lcond,:)==ethonumber)&...
                                        (Etho_H(params.ConditionIndex==lcond,:)==9+lsubs-1);
                                elseif (~isempty(strfind(variable_label,'~H Slow mm')))
                                    logical_etho=(Etho_Speed_new(params.ConditionIndex==lcond,:)==ethonumber)&...
                                        ~(Etho_H(params.ConditionIndex==lcond,:)==9+lsubs-1);
                                else
                                    logical_etho=Etho_Speed_new(params.ConditionIndex==lcond,:)==ethonumber;
                                end
                                variable_cond=nan(numcond(lcond),1);
                                lflycounter=0;
                                for lfly=find(params.ConditionIndex==lcond)
                                    lflycounter=lflycounter+1;
                                    
                                    logical_vec=logical_subs(lflycounter,:)&...
                                        logical_etho(lflycounter,:);
                                    num_el=sum(conv(double(logical_vec),[1 -1])==1);
                                    variable_cond(lflycounter)=...
                                        num_el/TotalN(lflycounter);
                                end
                            case {'IHI'}
                                variable_cond=nan(numcond(lcond),1);
                                lflycounter=0;
                                for lfly=find(params.ConditionIndex==lcond)
                                    lflycounter=lflycounter+1;
                                    variable_cond(lflycounter)=...
                                        sum(ALERT_IBI_V{lsubs}(:,4)==lfly)/TotalN(lflycounter);
                                end
                        end
                    case 'Total duration'
                        variable_cond=sum(CumTimeV{lsubs}(:,params.ConditionIndex==lcond))'/params.framerate/60;%min
                    case 'Fractions'
                        Totaltime=sum(CumTimeV{lsubs}(:,params.ConditionIndex==lcond))';%fr
                        switch variable_label
                            case {'Slow H','Fast H','Rest','~H Slow mm','Turns'}
                                ethonumber=variables_ethoSpeednumber(lvariable);
                                if (~isempty(strfind(variable_label,'Slow H')))||(~isempty(strfind(variable_label,'Fast H')))
                                    logical_etho=(Etho_Speed_new(params.ConditionIndex==lcond,:)==ethonumber)&...
                                        (Etho_H(params.ConditionIndex==lcond,:)==9+lsubs-1);
                                elseif (~isempty(strfind(variable_label,'~H Slow mm')))
                                    logical_etho=(Etho_Speed_new(params.ConditionIndex==lcond,:)==ethonumber)&...
                                        ~(Etho_H(params.ConditionIndex==lcond,:)==9+lsubs-1);
                                else
                                    logical_etho=Etho_Speed_new(params.ConditionIndex==lcond,:)==ethonumber;
                                end
                                variable_cond=sum((logical_subs&logical_etho),2)./Totaltime*100;%percentage;
                            case {'IHI'}
                                variable_cond=nan(numcond(lcond),1);
                                lflycounter=0;
                                for lfly=find(params.ConditionIndex==lcond)
                                    lflycounter=lflycounter+1;
                                    variable_cond(lflycounter)=...
                                        sum(ALERT_IBI_V{lsubs}(ALERT_IBI_V{lsubs}(:,4)==lfly,5))/Totaltime(lflycounter);
                                end
                                
                        end
                end
                X(1:numcond(lcondcounter),lcolcounter)=variable_cond;
            end
%         if ~isempty(strfind(plot_type,'N of elements per visit'))&&(lsubs==1)&&(~isempty(strfind(variable_label,'Rest')))
%             return
%         end    
            
        end
        %% Plotting
        subplot('Position',Positions(lplot+num_prev_plots,:))
        [~,lineh] = plot_boxplot_tiltedlabels(X,cell(length(xvalues),1),xvalues,...
            repmat(Cmap_patch(1:length(Conditions),:),numvariables,1),repmat(CondColors(1:length(Conditions),:),numvariables,1),...
            'k',.4,FtSz,FntName,'.');
        ax=get(gca,'Ylim');
        thandle=text((1:numvariables)*(length(Conditions)+1)-floor(length(Conditions)/2),...
            ax(1)*ones(1,numvariables),variable_labels);
        set(thandle,'HorizontalAlignment','right','VerticalAlignment','top',...
            'Rotation',20,'FontSize',FtSz,'FontName',FntName);
        xlim([0 numvariables*(length(Conditions)+1)])
        font_style([],[],y_label,'normal',FntName,FtSz)
        if lplot==1
            legend(lineh(1:length(Conditions)),params.LabelsShort,...
                'box','off','FontSize',FtSz-1,'Position',pos_legend)
            legend('boxoff')
        end
        
        if ~isempty(strfind(plot_type,'N of elements per visit'))&&(lsubs==1)
            ylim([0 50])
        end
        %% Saving stats text file
        if print_stats==1
            title_pvalue=['Uncorrected Mann Whitney p-values for ' plot_type ' ' params.Subs_Names{lsubs}];
            display(title_pvalue)
            fid=fopen([DataSaving_dir_temp Exp_num '\Plots\Visits\',...
                Exp_num Exp_letter ' - ' plot_type ' ' params.Subs_Names{lsubs} '.txt'],'w');
            
            
            fprintf(fid,'%s\r\n\r\n',title_pvalue);
            for lvariable=1:numvariables
                fprintf(fid,'%s\r\n',['---- ' variable_labels{lvariable} ' ----']);
                for llcond_BN=1:length(Conditions)-1
                    for lcomparBN=llcond_BN+1:length(Conditions)
                        lcond1=Conditions(llcond_BN);
                        lcond2=Conditions(lcomparBN);
                        lcol1=(lvariable)*length(Conditions)-(length(Conditions)-lcond1);
                        lcol2=(lvariable)*length(Conditions)-(length(Conditions)-lcond2);
                        p=ranksum(X(:,lcol1),X(:,lcol2));
                        pvaluetext=[params.LabelsShort{lcond1} ' vs ' params.LabelsShort{lcond2} ' = ' num2str(p)];
                        display(pvaluetext)
                        fprintf(fid,'%s\r\n',pvaluetext);
                        %% Plot line with stats
                        if ((lcond1==1)&&(lcond2==2))||((lcond1==1)&&(lcond2==3))
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
                            
                            if (lcond1==1)&&(lcond2==2)
                                xvals_cond1=xvalues(1:length(Conditions):end);
                                xvals_cond2=xvalues(2:length(Conditions):end);
                                y_pos_stats=1.1*max(prctile(X,75));%.9*y_lims(2);
                            elseif (lcond1==1)&&(lcond2==3)
                                xvals_cond1=xvalues(1:length(Conditions):end);
                                xvals_cond2=xvalues(3:length(Conditions):end);
                                y_pos_stats=1.3*max(prctile(X,75));%y_lims(2);
                            end
                            y_lims=get(gca,'YLim');
                            plot([xvals_cond1(lvariable) xvals_cond2(lvariable)],...
                                [y_pos_stats y_pos_stats],'-k','LineWidth',LineW)
                            
                            text((xvals_cond2(lvariable)-xvals_cond1(lvariable))/2+xvals_cond1(lvariable),...
                                y_pos_stats,textstring,'HorizontalAlignment','center',...
                                'VerticalAlignment',vertical,'Margin',margin,'FontSize',FtSz,'FontName',FntName)
                        end
                    end
                end
            end
            fclose(fid);
        end
    end
    title_h=suptitle(figname);
    set(title_h,'FontSize',FtSz,'FontName',FntName)
end

if saveplot==1
    savefig_withname(1,'600','png',DataSaving_dir_temp,Exp_num,Exp_letter,'Visits')
end