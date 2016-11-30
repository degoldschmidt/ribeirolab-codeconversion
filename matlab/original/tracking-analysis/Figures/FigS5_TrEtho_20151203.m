%% Plotting Transitions Ethogram
save_plot=1;
Conditions=[5 1 3];%[2 1 3 4];%EXP 8B [6 4 5 1 3];%
subnumbers=[1 2];
FtSz=8;%20;
FntName='arial';
LineW=0.8;

close all
x=0.08;%0.18 when ylabels are three lines, 0.13 for single line ylabels
y=0.05;%0.11 when x labels are one line, 0.18 when they are tilted labels
dy=0.03;
heightsubplot=1-1.3*y;
widthsubplot=1-1.2*x;


if ~exist('Etho_Tr2_2','var')
    [~,~,~, Etho_Tr2_2,Etho_Tr2_2Colors]=TransitionProb2(DurInV,Heads_Sm,FlyDB,params);
end

[Etho_Tr_paper_YColors,Etho_Tr_paper_SColors]=EthoTrColorsPaper_fun;
Tr_Colors_paper={Etho_Tr_paper_YColors,Etho_Tr_paper_SColors};


for lsubs=subnumbers
    lcondcounter=0;
    for lcond=Conditions
        lcondcounter=lcondcounter+1;
        figure('Position',[50 50 800 800],'Color','w','PaperUnits','centimeters',...
                'PaperPosition',[1 1 7 7],'Name',['Fig5S1 Visit5mm Tr ' params.Subs_Names{lsubs} ' Etho - cond' num2str(lcond) ' ' date]);%
        %% Plotting Ethogram
        Totaltimes_cond=sum(CumTimeV{1}(:,params.ConditionIndex==lcond));%sum(CumTimeH{1}(:,params.ConditionIndex==lcond));
        Etho_H_cond=Etho_Tr2_2(params.ConditionIndex==lcond,:);
        Idx_cond=find(params.ConditionIndex==lcond);
        [Totalt_sorted,Idx_sort]=sort(Totaltimes_cond,'ascend');%'descend'
        image(Etho_H_cond(Idx_sort,:))
        
        %%% Other settings
        colormap(Tr_Colors_paper{lsubs});
        freezeColors
        set(gca,'XTick',[],...
            'YTick',[])%,...
        xticks=0:30:120;
        set(gca,'XTick',xticks*50*60,'XtickLabel',[],'YDir','normal','Yticklabel',[],'ycolor','k')
%         text(xticks*50*60,repmat(37,1,size(xticks,2)),...
%             cellfun(@num2str,num2cell(xticks),'UniformOutput',0),'FontSize',FtSz,'FontName',FntName,...
%             'VerticalAlignment','top','HorizontalAlignment','center')
        
        xlim([0 120*50*60])
        ylim([0.5 35.5])%ylim([.5 sum(params.ConditionIndex==lcond)+.5])%
        font_style([],[],[],'normal',FntName,FtSz)
        box on
        set(gca,'linewidth',1)
        Etho_Colors_Labels={'Same Y';'Same S';'Close Y';'Close S';'Far Y';'Far S'};
        
        %     hcb=colorbar;set(hcb,'YTick',(1:6),...
        %             'YTickLabel',Etho_Colors_Labels,'FontName',FntName,'FontSize',FtSz-2)
        %         if subplots==1
        %             set(hcb,'Position',[0.9198 0.1084 0.0139 0.3428])
        %         end
        
        
        
        
    end
end

if save_plot==1
    savefig_withname(1,'600','png',DataSaving_dir_temp,Exp_num,Exp_letter,'Ethograms')
end
