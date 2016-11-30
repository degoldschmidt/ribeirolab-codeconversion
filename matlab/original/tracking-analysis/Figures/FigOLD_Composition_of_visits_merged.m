%% Composition of Visits - merged slow and fast micromovements

FtSz=6;
FntName='arial';
saveplot=0;
new_plot=1;
num_prev_plots=5;
print_stats=1;
normalised=1;%0 for Total duration, 1 for percentages, 2 for average durations
merged=1;

if normalised==0
    norm_label=' -Total';
elseif normalised==1
    norm_label=' -Norm';
elseif normalised==2
    norm_label=' -Av Dur';
end

Conditions=[1 3];%unique(params.ConditionIndex);%
if length(Conditions)<length(unique(params.ConditionIndex))
    figname_cond=[];
    for lcond=Conditions
        figname_cond=[figname_cond ' - ' params.LabelsShort{lcond} norm_label];
    end
else
    figname_cond=[' - All conditions' norm_label];
end
[CondColors,Cmap_patch]=Colors(length(params.Labels));%Colors(length(Conditions));

%% Transforming Etho_Speed in a matrix & merging slow and fast micromovements
maxFrame=size(Etho_H,2);
if ~exist('Etho_Speed_new','var')
[Etho_Speed_new,~,Etho_Colors_Labels] = Etho_Speed2New(maxFrame,Etho_Speed,merged);
end
Elements_Labels={'Breaks','Head mm','Rest','Microm','Walk','Turns'};

%%
if new_plot==1
    close all
    num_prev_plots=0;
    h_dist=[0 0.04 0.02 0.02 0 0.04 0.02 0.02];
    v_dist=2*0.03;
    width=0.12;%0.08;
    heightfactor=3;%1.5;
    loc_x=0.1; loc_y=0.7;
end

widths=[1 3 .7 .7 1 3 .7 .7]*width;
heights=repmat(heightfactor*width,1,size(widths,2));
rows=[1 1 1 1 2 2 2 2];
Pos_CompV=nan(length(widths),4);
Pos_CompV(1,:)=[loc_x loc_y widths(1) heights(1)];

for lplot=2:length(widths)
    if rows(lplot)==rows(lplot-1)
        new_locx=Pos_CompV(lplot-1,1)+Pos_CompV(lplot-1,3)+h_dist(lplot);
        new_locy=Pos_CompV(lplot-1,2);
    else
        new_locx=Pos_CompV(1,1);
        new_locy=Pos_CompV(1,2)-heights(lplot)-v_dist;% only if all the heights are the same
    end
    Pos_CompV(lplot,:)=[new_locx new_locy widths(lplot) heights(lplot)];
end
%         Pos_CompV=[new_locx new_locy widths(lplot) heights(lplot);... 'N of visits'
%         loc_x+width+h_dist loc_y 4*width 2*width;...'N of elements'
%         loc_x+5*width+2*h_dist loc_y width 2*width;...'N Head mm'
%         loc_x+6*width+3*h_dist loc_y width 2*width;...'N Breaks'
%         loc_x loc_y-width-h_dist width width;...'Total duration'
%         loc_x+width+h_dist loc_y-width-h_dist 3*width width;...'Dur of elements'
%         ;...'Fr Head mm'
%         ;...'Fr Breaks'
%         ];

pos_legend=[Pos_CompV(length(widths)/2,1)+Pos_CompV(length(widths)/2,3)+0.03 Pos_CompV(length(widths)/2,2)+.8*Pos_CompV(length(widths)/2,4) 0.04 0.02];

numcond=nan(length(Conditions),1);
lcondcounter=0;
for lcond=Conditions
    lcondcounter=lcondcounter+1;
    numcond(lcondcounter)=sum(params.ConditionIndex==lcond);
end

plot_types={'N of visits','N of elements','N Head mm','N Breaks',...
    'Total duration','Dur of elements','Fr Head mm','Fr Breaks'};
for lsubs=params.Subs_Numbers
    if new_plot==1
        figname=['Composition of ' params.Subs_Names{lsubs==params.Subs_Numbers} ' visits ' figname_cond ' ' date];
        
        figure('Position',[100 50 params.scrsz(3)-450 params.scrsz(4)-150],...
            'Color','w','Name',figname,'PaperUnits','centimeters','PaperPosition',[2 10 17 10]);
    end
    
    for lplot=1:length(plot_types)
        plot_type=plot_types{lplot};
        display(['------- ' plot_type ' -------'])
        switch plot_type
            case 'N of visits' %Total Number of Visits
                variable_labels={'Visits'};
                y_label='Nº of visits';
            case 'N of elements' %If normalised, then is Number of elements per visit
                variable_labels=Elements_Labels(3:end);
                var_ethoSpeed_new_number=[1 2 3 4];
                if normalised==1
                    y_label='Nº per visit';
                elseif normalised==0
                    y_label='Total Nº';
                elseif normalised==2
                    y_label='Av Nº';
                end
            case 'N Head mm'
                variable_labels=Elements_Labels(2);
                y_label=[];
            case 'N Breaks'
                variable_labels=Elements_Labels(1);
                y_label=[];
            case 'Total duration' %Total duration of visits
                variable_labels={'Visits'};
                y_label={'Total duration';'of visits (min)'};
            case 'Dur of elements' %If normalised, then is % of each element
                variable_labels=Elements_Labels(3:end);
                var_ethoSpeed_new_number=[1 2 3 4];
                if normalised==1
                    y_label='Fraction of time (%)';
                elseif normalised==0
                    y_label='Total duration (min)';
                elseif normalised==2
                    y_label='Av duration (s)';
                end
            case 'Fr Head mm'
                variable_labels=Elements_Labels(2);
                y_label=[];
            case 'Fr Breaks'
                variable_labels=Elements_Labels(1);
                y_label=[];
        end
        
        numvariables=length(variable_labels);
        xvalues=1:numvariables*(length(Conditions)+1);
        xvalues((1:numvariables)*(length(Conditions)+1))=[];
        patch_element_xs=[0 (1:numvariables)*(length(Conditions)+1)];
        
        X=nan(max(numcond),length(xvalues));
        clear variable_cond
        lcolcounter=0;
        for lvariable=1:numvariables
            variable_label=variable_labels{lvariable};
            display(['----- ' variable_label ' -----'])
            lcondcounter=0;
            for lcond=Conditions
%                 display(['Condition ' num2str(lcond)])
                lcondcounter=lcondcounter+1;
                lcolcounter=lcolcounter+1;
                
                logical_subs=logical(CumTimeV{lsubs==params.Subs_Numbers}(:,params.ConditionIndex==lcond))';
                if normalised==1
                    DenominatorN=NumBoutsV(lsubs==params.Subs_Numbers,params.ConditionIndex==lcond)';
                    DenominatorT=sum(CumTimeV{lsubs==params.Subs_Numbers}(:,params.ConditionIndex==lcond))'/100;%conversion to %
                elseif normalised==0 
                    DenominatorN=ones(sum(params.ConditionIndex==lcond),1);
                    DenominatorT=ones(sum(params.ConditionIndex==lcond),1)*params.framerate*60;%conversion from fr to min
                elseif normalised==2
                    DenominatorN=ones(sum(params.ConditionIndex==lcond),1);
                    DenominatorT=ones(sum(params.ConditionIndex==lcond),1)*params.framerate*60;%conversion from fr to sec
                end
                switch plot_type
                    case 'N of visits'
                        variable_cond=NumBoutsV(lsubs==params.Subs_Numbers,params.ConditionIndex==lcond)';
                    case 'N of elements'
                        
                        switch variable_label
                            case Elements_Labels(3:end)
                                ethonumber=var_ethoSpeed_new_number(lvariable);
                                if (~isempty(strfind(variable_label,'Microm')))
                                    logical_etho=(Etho_Speed_new(params.ConditionIndex==lcond,:)==ethonumber)&...
                                        ~(Etho_H(params.ConditionIndex==lcond,:)==9+find(lsubs==params.Subs_Numbers)-1);
                                else
                                    logical_etho=Etho_Speed_new(params.ConditionIndex==lcond,:)==ethonumber;
                                end
                                variable_cond=nan(numcond(lcondcounter),1);
                                lflycounter=0;
                                for lfly=find(params.ConditionIndex==lcond)
                                    lflycounter=lflycounter+1;
                                    
                                    logical_vec=logical_subs(lflycounter,:)&...
                                        logical_etho(lflycounter,:);
                                    num_el=sum(conv(double(logical_vec),[1 -1])==1);
                                    variable_cond(lflycounter)=...
                                        num_el/DenominatorN(lflycounter);
                                end
                                
                        end
                    case 'N Head mm'
                        
                        logical_etho=(Etho_H(params.ConditionIndex==lcond,:)==9+find(lsubs==params.Subs_Numbers)-1);
                        variable_cond=nan(numcond(lcondcounter),1);
                        lflycounter=0;
                        for lfly=find(params.ConditionIndex==lcond)
                            lflycounter=lflycounter+1;
                            
                            logical_vec=logical_subs(lflycounter,:)&...
                                logical_etho(lflycounter,:);
                            num_el=sum(conv(double(logical_vec),[1 -1])==1);
                            variable_cond(lflycounter)=...
                                num_el/DenominatorN(lflycounter);
                        end
                    case 'N Breaks'
                        
                        variable_cond=nan(numcond(lcondcounter),1);
                        lflycounter=0;
                        for lfly=find(params.ConditionIndex==lcond)
                            lflycounter=lflycounter+1;
                            variable_cond(lflycounter)=...
                                sum(Breaks{lsubs==params.Subs_Numbers}(:,4)==lfly)/DenominatorN(lflycounter);
                        end
                    case 'Total duration'
                        variable_cond=sum(CumTimeV{lsubs==params.Subs_Numbers}(:,params.ConditionIndex==lcond))'/params.framerate/60;%min
                    case 'Dur of elements'
                        
                        switch variable_label
                            case Elements_Labels(3:end)
                                ethonumber=var_ethoSpeed_new_number(lvariable);
                                if (~isempty(strfind(variable_label,'Microm')))
                                    logical_etho=(Etho_Speed_new(params.ConditionIndex==lcond,:)==ethonumber)&...
                                        ~(Etho_H(params.ConditionIndex==lcond,:)==9+find(lsubs==params.Subs_Numbers)-1);
                                else
                                    logical_etho=Etho_Speed_new(params.ConditionIndex==lcond,:)==ethonumber;
                                end
                                variable_cond=sum((logical_subs&logical_etho),2)./DenominatorT;
                                
                        end
                    case 'Fr Head mm'
                        logical_etho=(Etho_H(params.ConditionIndex==lcond,:)==9+find(lsubs==params.Subs_Numbers)-1);
                        variable_cond=sum((logical_etho),2)./DenominatorT;
                        
                    case 'Fr Breaks'
                        variable_cond=nan(numcond(lcondcounter),1);
                        lflycounter=0;
                        for lfly=find(params.ConditionIndex==lcond)
                            lflycounter=lflycounter+1;
                            variable_cond(lflycounter)=...
                                    sum(Breaks{lsubs==params.Subs_Numbers}...
                                    (Breaks{lsubs==params.Subs_Numbers}(:,4)==lfly,5))/DenominatorT(lflycounter);
                            
                        end
                end
                X(1:numcond(lcondcounter),lcolcounter)=variable_cond;
            end
            %         if ~isempty(strfind(plot_type,'N of elements'))&&(lsubs==1)&&(~isempty(strfind(variable_label,'Rest')))
            %             return
            %         end
            
        end
        %% Plotting
        subplot('Position',Pos_CompV(lplot,:))
%         for lvariable=1:numvariables
%             patch_element_xs
%         end
        [~,lineh] = plot_boxplot_tiltedlabels(X,cell(length(xvalues),1),xvalues,...
            repmat(Cmap_patch(Conditions,:),numvariables,1),repmat(CondColors(Conditions,:),numvariables,1),...
            'k',.4,FtSz,FntName,'.');
        ax=get(gca,'Ylim');
        
%         if ~isempty(strfind(plot_type,'N of visits'))||~isempty(strfind(plot_type,'Total duration'))
%             thandle=text(xvalues,...
%                 ax(1)*ones(1,length(Conditions)),params.LabelsShort(Conditions));
%         else
            x_ticks=(1:numvariables)*(length(Conditions)+1)-floor(length(Conditions)/2);
            thandle=text(x_ticks,...
                ax(1)*ones(1,numvariables),variable_labels);
%         end
        
        set(thandle,'HorizontalAlignment','right','VerticalAlignment','top',...
            'Rotation',20,'FontSize',FtSz,'FontName',FntName);
        xlim([0 numvariables*(length(Conditions)+1)])
        font_style([],[],y_label,'normal',FntName,FtSz)
        if lplot==length(widths)
            legend(lineh(1:length(Conditions)),params.LabelsShort(Conditions),...
                'box','off','FontSize',FtSz-1,'Position',pos_legend)
            legend('boxoff')
        end
        
%         if (~isempty(strfind(plot_type,'N of elements')))||(~isempty(strfind(plot_type,'N Head mm')))%&&(lsubs==1)
%             y_lim=get(gca,'YLim');
%             if lsubs==1
%                 ylim([y_lim(1) 10])
%             elseif lsubs==2
%                 ylim([y_lim(1) 2])
%             end
%         elseif (~isempty(strfind(plot_type,'N Breaks')))&&(lsubs==1)
%             ylim([0 2])
%         elseif (~isempty(strfind(plot_type,'Fr Breaks')))&&(lsubs==1)
%             ylim([0 .5])  
%             elseif (~isempty(strfind(plot_type,'Dur of elements')))&&(lsubs==2)
%             ylim([0 60])
%         elseif (~isempty(strfind(plot_type,'N of visits')))&&(lsubs==1)
%             ylim([0 100])
%         elseif (~isempty(strfind(plot_type,'Total duration')))&&(lsubs==2)
%             ylim([0 10])
%         end
        %% Saving stats text file
        if print_stats==1
            stats_boxplot_tiltedlabels(X,variable_labels,Conditions,xvalues,plot_type,lsubs,params,...
                DataSaving_dir_temp,Exp_num,Exp_letter,figname_cond,'Visits',FtSz,FntName)
        end
    end
    title_h=suptitle(figname);
    set(title_h,'FontSize',FtSz,'FontName',FntName)
end

if saveplot==1
    savefig_withname(1,'600','png',DataSaving_dir_temp,Exp_num,Exp_letter,'Visits')
end