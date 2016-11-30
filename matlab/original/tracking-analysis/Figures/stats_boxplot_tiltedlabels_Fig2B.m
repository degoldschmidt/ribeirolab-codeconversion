function stats_boxplot_tiltedlabels_Fig2B(X,variable_labels,MergedConditions,xvalues,plot_type,lsubs,params,...
    DataSaving_dir_temp,Exp_num,Exp_letter,figname_cond,folder,FtSz,FntName,Labels)

title_pvalue=['Uncorr Mann Whitney for ' plot_type ' ' params.Subs_Names{params.Subs_Numbers==lsubs}];
display(title_pvalue)
fid=fopen([DataSaving_dir_temp Exp_num '\Plots\' folder '\',...
    Exp_num Exp_letter ' - ' plot_type ' ' params.Subs_Names{lsubs==params.Subs_Numbers} figname_cond ' ' date '.txt'],'w');

numvariables=size(variable_labels,2);
fprintf(fid,'%s\r\n\r\n',title_pvalue);
for lvariable=1:numvariables
    fprintf(fid,'%s\r\n',['---- ' variable_labels{lvariable} ' ----']);
    for lcompar1=1:length(MergedConditions)-1
        for lcompar2=lcompar1+1:length(MergedConditions)
            lcond1=MergedConditions(lcompar1);
            lcond2=MergedConditions(lcompar2);
            lcol1=(lvariable)*length(MergedConditions)-(length(MergedConditions)-lcompar1);
            lcol2=(lvariable)*length(MergedConditions)-(length(MergedConditions)-lcompar2);
            try
                p=ranksum(X(:,lcol1),X(:,lcol2));
            catch
                p=nan;
            end
            pvaluetext=[Labels{lcond1} ' vs ' Labels{lcond2} ' = ' num2str(p)];
            %                         display(pvaluetext)
            fprintf(fid,'%s\r\n',pvaluetext);
            %% Plot line with stats
            if strfind([Exp_num,Exp_letter],'0008B')
                if lcond1==1
                    p=p*(length(MergedConditions)-1);
                    y_pos_stats=(0.9+0.2*lcond2)*max(prctile(X,75));%.9*y_lims(2);
                    stats_text(p,y_pos_stats,lcond1,lcond2)
                end
            elseif strfind([Exp_num,Exp_letter],'0011A')
                 if (lcompar2==lcompar1+1)&&(lcompar2~=3)
                    y_pos_stats=(0.9+0.2*lcompar1)*max(prctile(X,75));%.9*y_lims(2);
                    stats_text(p*2,y_pos_stats,lcond1,lcond2)
                 
                 end
                 if lcompar1==2&&lcompar2==4
                     y_pos_stats=(0.9+0.2*lcompar2)*max(prctile(X,75));%.9*y_lims(2);
                    stats_text(p*2,y_pos_stats,lcond1,lcond2)
                 end    
            else
                if (lcond2==lcond1+1) && (lcond2~=3)%((lcond1==1)&&(lcond2==2))||((lcond1==1)&&(lcond2==3))
                    y_pos_stats=(0.9+0.2*lcond1)*max(prctile(X,75));%.9*y_lims(2);
                    stats_text(p*2,y_pos_stats,lcond1,lcond2)

                elseif lcond2==3 && lcond1==1
                    y_pos_stats=(0.9+0.2*(lcond1+1))*max(prctile(X,75));%.9*y_lims(2);
                    stats_text(p*2,y_pos_stats,lcond1,lcond2)

                end
            end
        end
    end
end
fclose(fid);


    function stats_text(p,y_pos_stats,lcond1,lcond2)
        vertical='middle';
        margin=2;
        if (p<0.05)&&(p>=0.01)
            textstring='*';
            NewFtSz=FtSz+6;
        elseif (p<0.01)&&(p>=0.001)
            textstring='**';
            NewFtSz=FtSz+6;
        elseif (p<0.001)
            textstring='***';
            NewFtSz=FtSz+6;
        elseif isnan(p)
            textstring='nan';
            vertical='bottom';
            margin=1;
            NewFtSz=FtSz;
        else
            textstring='ns';
            vertical='bottom';
            margin=1;
            NewFtSz=FtSz;
        end
        
        xvals_cond1=xvalues(find(MergedConditions==lcond1):length(MergedConditions):end);
        xvals_cond2=xvalues(find(MergedConditions==lcond2):length(MergedConditions):end);

        plot([xvals_cond1(lvariable) xvals_cond2(lvariable)],...
            [y_pos_stats y_pos_stats],'-k','LineWidth',.8);

        text((xvals_cond2(lvariable)-xvals_cond1(lvariable))/2+xvals_cond1(lvariable),...
            y_pos_stats,textstring,'HorizontalAlignment','center',...
            'VerticalAlignment',vertical,'Margin',margin,'FontSize',NewFtSz,'FontName',FntName);
    end

end

