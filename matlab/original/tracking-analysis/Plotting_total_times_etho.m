%% Plotting total times etho
FontSize=6;
Fontname='arial';
Conditions=unique(params.ConditionIndex);
[CondColors,Cmap_patch]=Colors(length(Conditions));
numcond=nan(length(Conditions),1);
lcondcounter=0;
for lcond=Conditions
    lcondcounter=lcondcounter+1;
    numcond(lcondcounter)=sum(params.ConditionIndex==lcond);
end

plot_type='Percentage (merged)';%%'In-Out times merged';%'Total times';%'In-Out times all';%
clear Substrates
switch plot_type
    case 'Total times'
        numvariables=11;
        variable_labels={'Total inside Yeast','Total inside Sucrose','Rest',...
            'Slow microm','Fast microm','Slow walk','Walk',...
            'Sharp Turn','Jump','Head Yeast','Head Sucrose'};
        y_label='Time (min)';
        title_label='Total times';
        variables_ethonumber=[0 0 1:7 9 10];%number of variable in Etho_H
        Substrates{1}=[];
    case 'In-Out times all'
        numvariables=8;
        variable_labels={'Total','Head microm','Rest',...
            'Micromovement','Slow walk','Walk',...
            'Sharp Turn','Jump'};
        y_label='Time (min)';
        title_label='Outside (all)';%'Inside (all)';%
        variables_ethonumber=[0 9 1 0 4:7];%number of variable in Etho_H
        if strfind(title_label,'Inside')
            Substrates=params.Subs_Names;
        elseif strfind(title_label,'Outside')
            Substrates{1}=[];
        end
    case 'In-Out times merged'
        numvariables=5;
        variable_labels={'Total','Rest',...
            'Micromovement','Walk',...
            'Sharp Turn'};
        y_label='Time (min)';
        title_label='Inside (merged)';%'Outside (merged)';%
        variables_ethonumber=[0 1 2 5 6];%number of variable in Etho_H
        if strfind(title_label,'Inside')
            Substrates=params.Subs_Names;
        elseif strfind(title_label,'Outside')
            Substrates{1}=[];
        end
    case 'Percentage (merged)'
        numvariables=4;
        variable_labels={'Rest',...
            'Micromovement','Walk',...
            'Sharp Turn'};
        y_label='Fraction of time (%)';
        title_label='Fractions Inside (merged)';%'Fractions Outside (merged)';%
        variables_ethonumber=[1 2 5 6];%number of variable in Etho_H
        if strfind(title_label,'Inside')
            Substrates=params.Subs_Names;
        elseif strfind(title_label,'Outside')
            Substrates{1}=[];
        end
end

xvalues=1:numvariables*(length(Conditions)+1);
xvalues((1:numvariables)*(length(Conditions)+1))=[];
%% Creating vector for boxplots
close all
for lsubs=1:length(Substrates)
    %%% Each column is one subplot
    X=nan(max(numcond),length(xvalues));
    
    lcolcounter=0;
    for lvariable=1:numvariables
        lcondcounter=0;
        
        
        for lcond=Conditions
            lcondcounter=lcondcounter+1;
            lcolcounter=lcolcounter+1;
            
            if strfind(title_label,'Inside')
                logical_subs=logical(CumTimeOB{lsubs}(:,params.ConditionIndex==lcond))';
            elseif strfind(title_label,'Outside')
                logical_subs=~(logical(CumTimeOB{1}(:,params.ConditionIndex==lcond))|...
                    logical(CumTimeOB{2}(:,params.ConditionIndex==lcond)))';
            end
            
            switch plot_type
                case 'Total times'
                    switch lvariable
                        case 1 % Total Y
                            variable_cond=sum(CumTimeOB{1}...
                                (:,params.ConditionIndex==lcond))'/params.framerate/60;%min;%s
                        case 2 % Total S
                            variable_cond=sum(CumTimeOB{2}...
                                (:,params.ConditionIndex==lcond))'/params.framerate/60;%min;%s
                        case {3 4 5 6 7 8 9 10 11}
                            variable_cond=sum(Etho_H(params.ConditionIndex==lcond,:)==...
                                variables_ethonumber(lvariable),2)/params.framerate/60;%min;
                    end
                case 'In-Out times all'
                    switch lvariable
                        case 1 % Total inside substrate
                            if strfind(title_label,'Inside (all)')
                                variable_cond=sum(CumTimeOB{lsubs}...
                                    (:,params.ConditionIndex==lcond))'/params.framerate/60;%min;
                            elseif strfind(title_label,'Outside (all)')
                                variable_cond=sum(~(logical(CumTimeOB{1}(:,params.ConditionIndex==lcond))|...
                                    logical(CumTimeOB{2}(:,params.ConditionIndex==lcond))))'/params.framerate/60;%min;
                            end
                        case {2 3 5 6 7 8}
                            if lvariable==2
                                ethonumber=variables_ethonumber(lvariable)+lsubs-1;
                            else
                                ethonumber=variables_ethonumber(lvariable);
                            end
                            logical_etho=Etho_H(params.ConditionIndex==lcond,:)==ethonumber;
                            variable_cond=sum((logical_subs&logical_etho),2)/params.framerate/60;%min;
                        case 4 %Merge slow and fast micromovement
                            logical_etho=(Etho_H(params.ConditionIndex==lcond,:)==2)|...
                                (Etho_H(params.ConditionIndex==lcond,:)==3);
                            variable_cond=sum((logical_subs&logical_etho),2)/params.framerate/60;%min;
                    end
                case 'In-Out times merged'
                    switch lvariable
                        case 1 % Total inside substrate
                            if strfind(title_label,'Inside (merged)')
                                variable_cond=sum(CumTimeOB{lsubs}(:,params.ConditionIndex==lcond))'/params.framerate/60;%min;
                            elseif strfind(title_label,'Outside (merged)')
                                variable_cond=sum(~(logical(CumTimeOB{1}(:,params.ConditionIndex==lcond))|...
                                    logical(CumTimeOB{2}(:,params.ConditionIndex==lcond))))'/params.framerate/60;%min;
                            end
                        case {2,5} %Rest and Sharp turns
                            logical_etho=Etho_H(params.ConditionIndex==lcond,:)==variables_ethonumber(lvariable);
                            variable_cond=sum((logical_subs&logical_etho),2)/params.framerate/60;%min;
                        case 3 %Merge slow and fast micromovement and head micromovements
                            logical_etho=(Etho_H(params.ConditionIndex==lcond,:)==2)|...
                                (Etho_H(params.ConditionIndex==lcond,:)==3)|...
                                (Etho_H(params.ConditionIndex==lcond,:)==9)|...
                                (Etho_H(params.ConditionIndex==lcond,:)==10);
                            variable_cond=sum((logical_subs&logical_etho),2)/params.framerate/60;%min;
                        case 4 %Merge slow walk, walk and jumps
                            logical_etho=(Etho_H(params.ConditionIndex==lcond,:)==4)|...
                                (Etho_H(params.ConditionIndex==lcond,:)==5)|...
                                (Etho_H(params.ConditionIndex==lcond,:)==7);
                            variable_cond=sum((logical_subs&logical_etho),2)/params.framerate/60;%min;
                    end
                case 'Percentage (merged)'
                    if strfind(title_label,'Inside (merged)')
                        Totaltime=sum(CumTimeOB{lsubs}(:,params.ConditionIndex==lcond))';%s
                    elseif strfind(title_label,'Outside (merged)')
                        Totaltime=sum(~(logical(CumTimeOB{1}(:,params.ConditionIndex==lcond))|...
                            logical(CumTimeOB{2}(:,params.ConditionIndex==lcond))))';%s
                    end
                    switch lvariable
                        case {1,4} %Rest and Sharp turns
                            logical_etho=Etho_H(params.ConditionIndex==lcond,:)==...
                                variables_ethonumber(lvariable);
                            variable_cond=sum((logical_subs&logical_etho),2)./Totaltime*100;
                        case 2 %Merge slow and fast micromovement and head micromovements
                            logical_etho=(Etho_H(params.ConditionIndex==lcond,:)==2)|...
                                (Etho_H(params.ConditionIndex==lcond,:)==3)|...
                                (Etho_H(params.ConditionIndex==lcond,:)==9)|...
                                (Etho_H(params.ConditionIndex==lcond,:)==10);
                            variable_cond=sum((logical_subs&logical_etho),2)./Totaltime*100;
                        case 3 %Merge slow walk, walk and jumps
                            logical_etho=(Etho_H(params.ConditionIndex==lcond,:)==4)|...
                                (Etho_H(params.ConditionIndex==lcond,:)==5)|...
                                (Etho_H(params.ConditionIndex==lcond,:)==7);
                            variable_cond=sum((logical_subs&logical_etho),2)./Totaltime*100;
                    end
            end
            X(1:numcond(lcondcounter),lcolcounter)=variable_cond;
        end
    end
    
    %% plotting box plots
    figname=['Boxplot ' title_label ' ' Substrates{lsubs}];
    figure('Position',[100 50 params.scrsz(3)-450 params.scrsz(4)-150],...
        'Color','w','Name',figname);
    [~,lineh] = plot_boxplot_tiltedlabels(X,cell(length(xvalues),1),xvalues,...
        repmat(Cmap_patch(1:length(Conditions),:),numvariables,1),repmat(CondColors(1:length(Conditions),:),numvariables,1),...
        'k',.8,6,'arial','.');
    ax=get(gca,'Ylim');
    thandle=text((1:numvariables)*(length(Conditions)+1)-floor(length(Conditions)/2),...
        ax(1)*ones(1,numvariables),variable_labels);
    set(thandle,'HorizontalAlignment','right','VerticalAlignment','top',...
        'Rotation',20,'FontSize',FontSize,'FontName',Fontname);
    xlim([0 numvariables*(length(Conditions)+1)])
    font_style([title_label ' ' Substrates{lsubs}],[],y_label,'normal',Fontname,FontSize)
    legend(lineh(1:length(Conditions)),params.LabelsShort,...
        'box','off','FontSize',FontSize-1)
    legend('boxoff')
    
    savefig_withname(1,'600','png',DataSaving_dir_temp,Exp_num,Exp_letter,'Total times & Ethogram')
    
    %% Saving stats text file
    title_pvalue=['Uncorrected Mann Whitney p-values for ' title_label ' ' Substrates{lsubs}];
display(title_pvalue)
fid=fopen([DataSaving_dir_temp Exp_num '\Plots\Total times & Ethogram\',...
            Exp_num Exp_letter ' - ' figname '.txt'],'w');


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
        end
    end
end
fclose(fid);
end