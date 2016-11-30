%% Cum probab
% figure, clear h
% Color_graph=[.5 0.5 0.5];
% Labels_graph={'80 bins, 500 max';'80 bins, 400 max';'80 bins, 100 max';'100 bins, 100 max';'100 bins, 600 max';'50 bins, 50 max'};
% lfly=1;lsubs=1;
% nbins=50;maxtime=50;%
% Hist_range=0:maxtime/(nbins-1):maxtime; % Time range in s %bins=80 for Vmax=4, non-zero
% 
% HistCount_Inact=hist(RawRevisits_Dur{lfly}{lsubs},Hist_range);
% frqs=HistCount_Inact/sum(HistCount_Inact);
% bout_idx=find(cumsum(frqs)>0.95, 1, 'first');
% if ~isempty(bout_idx)
%             binfly{lsubs}(lfly)=Hist_range(bout_idx)
% end
% h(6)=plot(Hist_range,cumsum(frqs),'LineWidth',2,'Color',Color_graph)
% hold on
% plot([binfly{lsubs}(lfly) binfly{lsubs}(lfly)],[0 1],'--','Color',Color_graph,'LineWidth',1)
% plot([0 maxtime],[0.95 0.95],'k')
% legend(h,Labels_graph)
% display(binfly{lsubs}(lfly))
% font_style('Fly Nº 1 - Yeast','Duration of revisits [s]','Cumulative Probability','normal','calibri',16)
%% Long Revisits
flycounter=1;
lsubs=1;
LongRev_Num=nan(length(flies_idx),1);
for lfly=flies_idx
    LongRev_Num(flycounter)=sum(RawRevisits_Dur{lfly}{lsubs}>binfly_Rev{lsubs}(lfly));
    flycounter=flycounter+1;
end
plot_bar(LongRev_Num,'Number of long Yeast revisits',Conditions,params)
saveas(gcf,[DataSaving_dir_temp Exp_num '\Plots\Bouts\Repeated Visits\After engagement\Num of long Y Revisits_',...
    num2str(maxtime) 'max', num2str(nbins)  'b.bmp'],'bmp') 
% plot_bar(binfly_Rev{lsubs},'Revisit length with p \leq 0.05 [s]',Conditions,params)
% saveas(gcf,[DataSaving_dir_temp Exp_num '\Plots\Bouts\Repeated Visits\After engagement\Long Y Revisits p0,05_',...
%     num2str(maxtime) 'max', num2str(nbins)  'b.bmp'],'bmp')