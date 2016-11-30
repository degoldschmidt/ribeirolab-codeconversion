%% General initial parameters
FtSz=8;%20;
FntName='arial';
LineW=0.8;
ColorsFig2C=ColorsPaper5cond_fun;

Conditions=[1 3];%[6 4 5 1 3];%[5 1 3];%[2 4 1 3];%EXP 4A 

condtag='cond1 3';%'All cond';%'cond5 1 3';%
orderinpaper=[6 4 5 1 3 2];%[2 4 1 3];%EXP 4A 

%% Average duration vs Nº visits
save_plot=1;
sub_folder='Visits';
close all
x=0.15;%0.18 when ylabels are three lines, 0.13 for single line ylabels
y=0.17;%0.11 when x labels are one line, 0.18 when they are tilted labels
dy=0.03;
heightsubplot=1-1.3*y;
widthsubplot=1-1.3*x;
lsubs=1;

close all
figname=['Fig4 Av Dur vs Nº visits _' condtag ' ' date];%num2str(lfig)
figure('Position',[50 50 800 800],'Color','w','PaperUnits','centimeters',...
    'PaperPosition',[1 1 10 5],'Name',[figname date]);%
set(gca,'Position',[x y widthsubplot heightsubplot])

hold on

Var_Labels={{'Nº of yeast visits'};...
    {'Average duration of';'yeast visit (min)'};...
    };
Vars_Values=zeros(params.numflies,length(Var_Labels));
for lfly=params.IndexAnalyse
    lfly
    if ~isempty(DurInV{lfly})
        %% Variable 1: Nº Y Visits / 10 min
        NYVisits=sum(DurInV{lfly}(:,1)==params.Subs_Numbers(1));
        Vars_Values(lfly,1)=...
            NYVisits;%/params.MinimalDuration*30000;% Nº Y Visits (every10 min)
        
        %% Average duration
        DurVector=DurInV{lfly}(DurInV{lfly}(:,1)==params.Subs_Numbers(1),5);
        Vars_Values(lfly,2)=...
            mean(DurVector)/50/60;%s
    end
end

totaltimes=5:15:95;
nvisits=0:.5:210;
colortimes=winter(length(totaltimes)+1);%jet(length(totaltimes));

c=0;
c2=length(totaltimes);
for ltotaltime=totaltimes
    c=c+1;
%     plot(nvisits,ltotaltime./nvisits,'-','LineWidth',LineW,'Color',colortimes(ltotaltime==totaltimes,:))
    plot(nvisits,ltotaltime./nvisits,'-','LineWidth',LineW,'Color',colortimes(c2,:))
    c2=c2-1;
        
%     text(ltotaltime/(3-0.17*c),(3-0.17*c),num2str(ltotaltime),...
%         'FontName',FntName,'FontSize',FtSz,'Color',colortimes(ltotaltime==totaltimes,:),...
%         'Backgroundcolor',[.9 .9 .9])
end   

lcondcounter=0;
for lcond=Conditions
    lcondcounter=lcondcounter+1;
    hold on
    plot(Vars_Values(params.ConditionIndex==lcond,1),...
        Vars_Values(params.ConditionIndex==lcond,2),'o','Color','k',...
        'MarkerFAceColor',ColorsFig2C(orderinpaper==lcond,:),'MarkerSize',5)
end

c=0;
c2=length(totaltimes);

for ltotaltime=totaltimes
    c=c+1;
    text(ltotaltime/(3-0.17*c)+1,(3-0.17*c),num2str(ltotaltime),...
        'FontName',FntName,'FontSize',FtSz,'Color',colortimes(c2,:),...colortimes(ltotaltime==totaltimes,:)
        'Backgroundcolor','none')
    c2=c2-1;

end
font_style([],Var_Labels{1},Var_Labels{2},'normal',FntName,FtSz)
axis([0 210 -0.1 3])
if save_plot==1
    savefig_withname(1,'600','png',DataSaving_dir_temp,Exp_num,Exp_letter,...
        sub_folder)
end
