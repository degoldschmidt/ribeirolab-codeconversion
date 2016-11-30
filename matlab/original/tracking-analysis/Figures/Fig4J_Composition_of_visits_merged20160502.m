%% Composition of Visits - merged slow and fast micromovements
save_plot=1;
inset=0;
FtSz=10;%20;
FntName='arial';
LineW=0.8;
[ColorsinPaper,orderinpaper]=ColorsPaper5cond_fun(Exp_num, Exp_letter,params);

Conditions=[1 3];%[4 3 8 7];%EXP 11A[2 1 3];% 4];%EXP 8B  [6 4 5 1 3];%Exp3D[5 1 3];%[2 4 1 3];%EXP 4A
condtag=['cond' num2str(Conditions)];%'All cond';%'cond1 3';%

close all
if inset==0,x=0.2; paperpos=[1 1 7 4];
else x=0.1;paperpos=[1 1 3 2];end
y=0.2;%0.11 when x labels are one line, 0.18 when they are tilted labels
dy=0.03;
heightsubplot=1-1.6*y;
widthsubplot=1-1.1*x;

AllConditions=unique(params.ConditionIndex);
numcond=nan(length(Conditions),1);
[CondColors]=Colors(length(unique(params.ConditionIndex)));%
newcolors=nan(length(Conditions),3);
for lcond=Conditions
    numcond(lcond==Conditions)=sum(params.ConditionIndex==lcond);
    if length(Conditions)<=size(ColorsinPaper,1)%strfind([Exp_num Exp_letter],'0003D')
        newcolors(lcond==Conditions,:)=ColorsinPaper(orderinpaper==lcond,:);%ColorsFig2C(orderinpaper==lcond,:);
    else
        newcolors(lcond==Conditions,:)=CondColors(ismember(AllConditions,lcond),:);
    end
    
end

print_stats=1;
merged=1;

[CondColors,Cmap_patch]=Colors(length(params.Labels));%Colors(length(Conditions));

%% Transforming Etho_Speed in a matrix & merging slow and fast micromovements
maxFrame=size(Etho_H,2);
if ~exist('Etho_Speed_new','var')
    [Etho_Speed_new,~,Etho_Colors_Labels] = Etho_Speed2New(maxFrame,Etho_Speed,merged);
end

for lsubs=1% params.Subs_Numbers
    if inset==0,
        variable_labels={'Rest','Micromovement','Walk','Turn'};
        var_ethoSpeed_new_number=[1 2 3 4];
    else
        variable_labels={'Walk','Turn'};
        var_ethoSpeed_new_number=[3 4];
    end
    y_label='Fraction of time';
    
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
            lcondcounter=lcondcounter+1;
            lcolcounter=lcolcounter+1;
            
            logical_subs=logical(CumTimeV{lsubs==params.Subs_Numbers}(:,params.ConditionIndex==lcond))';
            
           DenominatorT=sum(CumTimeV{lsubs==params.Subs_Numbers}(:,params.ConditionIndex==lcond))';%conversion to %
            ethonumber=var_ethoSpeed_new_number(lvariable);
%             if
%             (~isempty(strfind(variable_label,'Micromovement')))%Separating micromovements inside and outside
%                 logical_etho=(Etho_Speed_new(params.ConditionIndex==lcond,:)==ethonumber)&...
%                     ~(Etho_H(params.ConditionIndex==lcond,:)==9+find(lsubs==params.Subs_Numbers)-1);
%             else
                logical_etho=Etho_Speed_new(params.ConditionIndex==lcond,:)==ethonumber;
%             end
            variable_cond=sum((logical_subs&logical_etho),2)./DenominatorT;
            
            X(1:numcond(lcondcounter),lcolcounter)=variable_cond;
        end
    end
    %% Plotting
    if inset==0, extralabel=[];
    else extralabel='inset';
    end
    figname=['Fig4J Composition of ' params.Subs_Names{lsubs==params.Subs_Numbers} ' ' condtag,...
    ' ' extralabel ' ' date];
    figure('Position',[50 50 800 800],'Color','w','PaperUnits','centimeters',...
        'PaperPosition',paperpos,'Name',figname);
    set(gca,'Position',[x y widthsubplot heightsubplot])
    IQRColor=repmat(newcolors,numvariables,1);
    mediancolor=repmat(zeros(length(Conditions),3),numvariables,1);
    [~,lineh] = plot_boxplot_tiltedlabels(X,cell(length(xvalues),1),xvalues,...
        IQRColor,mediancolor,[.4 .4 .4],.4,FtSz,FntName,'o',1);
    ax=get(gca,'Ylim');
    
    x_ticks=(1:numvariables)*(length(Conditions)+1)-floor(length(Conditions)/2);
    thandle=text(x_ticks,...
        ax(1)*ones(1,numvariables),variable_labels);
    
    set(thandle,'HorizontalAlignment','right','VerticalAlignment','top',...
        'Rotation',20,'FontSize',FtSz,'FontName',FntName);
    xlim([0 numvariables*(length(Conditions)+1)])
    font_style([],[],y_label,'normal',FntName,FtSz)
    if inset==0, ylim([0 1]);set(gca,'ytick',0:0.1:1)
    else ylim([0 0.02]);set(gca,'ytick',0:0.01:0.02);ylabel([]);end
    
    %% Saving stats text file
    if print_stats==1
        stats_boxplot_tiltedlabels(X,variable_labels,Conditions,xvalues,'Fraction of behav',lsubs,params,...
            DataSaving_dir_temp,Exp_num,Exp_letter,figname_cond,'Visits',FtSz,FntName)
    end
   
end

if save_plot==1
    savefig_withname(1,'600','png',DataSaving_dir_temp,Exp_num,Exp_letter,'Visits')
    savefig_withname(0,'600','eps',DataSaving_dir_temp,Exp_num,Exp_letter,'Figures')
end