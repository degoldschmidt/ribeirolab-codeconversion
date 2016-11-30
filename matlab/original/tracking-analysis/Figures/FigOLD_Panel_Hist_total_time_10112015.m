%% Histogram of Distance to Spots
new_figure=1;
save_plot=0;
FtSz=8;
FntName='arial';
lsubs=1;
plot_type='Bars';%'Line';%
Max_range=60;%% min
step=Max_range/10;%10;%Max_range/nbins
variable_label='Total time microm';
Across_flies=0;
Conditions=[1 3];

X_range=0:step:Max_range;%

% if new_figure==1
%     Conditions=unique(params.ConditionIndex);
% end

if length(Conditions)<length(unique(params.ConditionIndex))
    figname_cond=[];
    for lcond=Conditions
        figname_cond=[figname_cond ' - ' params.LabelsShort{lcond}];
    end
else
    figname_cond=' - All conditions';
end

if new_figure==1
    close all
    figname=['Hist ' variable_label ' ' params.Subs_Names{lsubs==params.Subs_Numbers} ' spots ' figname_cond];
    figure('Position',[100 50 params.scrsz(3)-450 params.scrsz(4)-150],...
        'Color','w','Name',figname,'PaperUnits',...
                'centimeters','PaperPosition',[10 10 4 4]);
else
    plotcounter=plotcounter+1;
    subplot('Position',Positions(plotcounter,:))
    hold on
end


%% Dist to spot HIst
fliescond=nan(length(Conditions),1);

% Alldist_Cond=cell(length(unique(params.ConditionIndex)),1);
for lcond=Conditions
    fliescond(lcond)=sum(params.ConditionIndex==lcond);
%     Alldist_Cond{lcond}=[];
end


HistCount=zeros(size(X_range,2),length(Conditions));
Var_Values=cell(length(Conditions),1);
lcondcounter=0;
for lcond=Conditions
    lcondcounter=lcondcounter+1;
    Var_Values{lcondcounter}=sum(CumTimeH{lsubs==params.Subs_Numbers}(:,params.ConditionIndex==lcond))/params.framerate/60;
    HistCount(:,lcondcounter)=hist(Var_Values{lcondcounter},X_range);
end

%% Plot histogram
% close all
inact_thr=0.1;
Symbol_plot={'-o';'-^';'-o';'-o'};%{'-';'--';'-.'};

Freq=HistCount./repmat(nansum(HistCount),length(X_range),1);

[CondColors,Cmap_patch]=Colors(length(unique(params.ConditionIndex)));%
newcondcolors=nan(length(Conditions),3);
for lcond=Conditions
    newcondcolors(lcond==Conditions,:)=CondColors(ismember(unique(params.ConditionIndex),lcond),:);
end

%%% Histogram as Line
h=zeros(length(Conditions),1);
lcondcounter=0;
for lcond=Conditions
    lcondcounter=lcondcounter+1;
    
    if strfind(plot_type,'Line')
        %% Mean and stderr (average across flies)
        h(lcondcounter)=plot(X_range,Freq(:,lcond),Symbol_plot{lcondcounter},...
            'Color',newcondcolors(lcondcounter,:),'LineWidth',1,'MarkerSize',2,'MarkerFaceColor',newcondcolors(lcondcounter,:));
        hold on
        
    end
    
end
%%% Histogram as bars
if strfind(plot_type,'Bars')
    barhandle=bar(X_range,Freq);
    hold on
    for lcondcounter=1:size(Freq,2)
        set(barhandle(lcondcounter),'FaceColor',newcondcolors(lcondcounter,:),...
            'LineWidth', 1,'EdgeColor',newcondcolors(lcondcounter,:));
%          text(nanmedian(Var_Values{lcondcounter}),0.4,'\downarrow',...
%             'Color',newcondcolors(lcondcounter,:),...
%             'FontWeight','bold','fontName',FntName,'FontSize',FtSz+4)
    end
end


font_style([],{variable_label; [params.Subs_Names{lsubs==params.Subs_Numbers} ' (min)']},...params.Subs_Names{lsubs}
    {'Ocurrences';'(normalised)'},'normal',FntName,FtSz)%Uncomment for not subplots

ylim([0 0.4])
xlim([X_range(1)-step/2 X_range(end)+step/2])
set(gca,'Xtick',0:20:Max_range)
box off
if save_plot==1
        savefig_withname(1,'600','png',DataSaving_dir_temp,Exp_num,Exp_letter,...
            'Visits')
end