%% Before: Run Fig3_BoxplotParams with param wanted. Output X.
Conditions2=Conditions;
[ColorsinPaper,orderinpaper,labelspaper]=ColorsPaper5cond_fun(Exp_num, Exp_letter,params);

VirFF = nanmedian(X(:,1));
VirDP = nanmedian(X(:,2));
MatFF = nanmedian(X(:,3));
MatDP = nanmedian(X(:,5));

dMat = MatFF - VirFF;
dMet = VirDP - VirFF;

close all
figname=['LinComb DY visit AV dur '];
figure('Position',[50 50 1300 700],'Color','w','PaperUnits','centimeters',...
    'PaperPosition',[1 1 25 10],'Name',[figname date]);%'10minafterLagphase '
%% Param box plot
subplot(1,3,1)
mediancolor=zeros(length(Conditions),3);
IQRcolor=newcolors;
[~,lineh] = plot_boxplot_tiltedlabels(X,labelspaper(Conditions),1:size(X,2),...
    IQRcolor,mediancolor,[.4 .4 .4],.4,FtSz,FntName,'o',markersz);%'k'
font_style([],[],y_label,'normal',FntName,FtSz)
ylim([0 2])
set(gca,'XColor','w')
%% Find linear weights that minimise squared error
subplot(1,3,2)
alphaRange = linspace(-1e5,1e5,1e4);
betaRange = linspace(-1e5,1e5,1e4);
E=zeros(length(alphaRange),length(betaRange));

for lA=1:length(alphaRange)
    for lB=1:length(betaRange)
        alpha = alphaRange(lA);
        beta = betaRange(lB);
        pConstr = VirFF+alpha*dMat+beta*dMet;
        E(lA,lB) = sum(sum((pConstr-MatDP).^2));
    end
end
[r,c]=find(E==min(min(E)));

alphaOpt = alphaRange(r);
betaOpt = betaRange(c);
imagesc(betaRange,alphaRange,E)
colormap(jet)

hold on
ylabel('\alpha')
xlabel('\beta')
plot(betaOpt,alphaOpt,'o','MarkerSize',5,'MarkerFaceColor',[0.9 0.9 0.9])
%% Bar plots
subplot(1,3,3)
bar(1,VirFF,'FaceColor',newcolors(6==Conditions,:),'EdgeColor',newcolors(6==Conditions,:))
hold on 
bar(2,dMat,'FaceColor','w','EdgeColor','k')
bar(3,dMet,'FaceColor','y','EdgeColor','k')
bar(4,MatDP,'FaceColor',newcolors(3==Conditions,:),'EdgeColor',newcolors(3==Conditions,:))
bar(5,VirFF+alphaOpt*dMat+betaOpt*dMet,'FaceColor',[.9 .9 .9],'EdgeColor','k')
font_style(y_label,[],'Time (min)','normal','arial',10)
set(gca,'Xtick',[])
ax=get(gca,'Ylim');
thandle=text(1:5,ax(1)*ones(5,1),{'Virgin AA RICH';'\Delta Mating';'\Delta Metabolic';'Mated NoAA';...
    'VirgRICH + \alpha*\DeltaMat +\beta*\DeltaMet'});
set(thandle,'HorizontalAlignment','right','VerticalAlignment','top',...
    'Rotation',20,'FontSize',10,'FontName','arial');

savefig_withname(1,'600','png',DataSaving_dir_temp,Exp_num,Exp_letter,...
    'Visits')