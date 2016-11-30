function stats_boxplot_tiltedlabels_Fig1EG(X,variable_labels,xvalues,plot_type,lsubs,params,...
    DataSaving_dir_temp,Exp_num,Exp_letter,figname_cond,folder,FtSz,FntName,Labels)

title_pvalue=['Uncorr Mann Whitney for ' plot_type ' ' params.Subs_Names{params.Subs_Numbers==lsubs}];
display(title_pvalue)
fid=fopen([DataSaving_dir_temp Exp_num '\Plots\' folder '\',...
    Exp_num Exp_letter ' - ' plot_type ' ' params.Subs_Names{lsubs==params.Subs_Numbers} figname_cond ' ' date '.txt'],'w');



fprintf(fid,'%s\r\n\r\n',title_pvalue);
fprintf(fid,'%s\r\n',['---- ' variable_labels{1} ' ----']);
p=ranksum(X(:,1),X(:,2));
pvaluetext=[Labels{1} ' vs ' Labels{2} ' = ' num2str(p)];
           
fprintf(fid,'%s\r\n',pvaluetext);
y_pos_stats=(0.9+0.2)*max(prctile(X,75));%.9*y_lims(2);
stats_text(p,y_pos_stats,1,2)
                
fclose(fid);


    function stats_text(p,y_pos_stats,x1,x2)
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
        
        xvals_cond1=xvalues(x1);
        xvals_cond2=xvalues(x2);

        plot([xvals_cond1 xvals_cond2],...
            [y_pos_stats y_pos_stats],'-k','LineWidth',.8);

        text((xvals_cond2-xvals_cond1)/2+xvals_cond1,...
            y_pos_stats,textstring,'HorizontalAlignment','center',...
            'VerticalAlignment',vertical,'Margin',margin,'FontSize',NewFtSz,'FontName',FntName);
    end

end

