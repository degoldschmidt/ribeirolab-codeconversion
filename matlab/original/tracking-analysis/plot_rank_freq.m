function [ h ] = plot_rank_freq(Inline,params,lsubs,x_label,CondColors,FtSz,MarkerSize,FntName)
%[ h ] = plot_rank_freq(Inline,params,lsubs,x_label,CondColors)
%Inline must be in seconds
if nargin==3, x_label='Durations';CondColors=Colors(size(Inline,2));FtSz=14;MarkerSize=4;FntName='arial';end
if nargin==4, CondColors=Colors(size(Inline,2));FtSz=14;MarkerSize=4;FntName='arial';end
if nargin==5,FtSz=14;MarkerSize=4;FntName='arial';end
if nargin==6,MarkerSize=4;FntName='arial';end
if nargin==7,FntName='arial';end

h=zeros(size(Inline,2),1);
x_max=nan(size(Inline,2),1);
y_min=nan(size(Inline,2),1);

for lcond=1:size(Inline,2)
    clear x
    x=Inline{lsubs==params.Subs_Numbers,lcond};%/60;
    n = length(x);
    c = [sort(x) (n:-1:1)'./n];
    h(lcond)=plot(c(:,1),c(:,2),'o','MarkerSize',MarkerSize,'MarkerEdgeColor',CondColors(lcond,:),...
        'MarkerFaceColor',CondColors(lcond,:)); hold on;
    set(gca,'XScale','log','YScale','log')
    x_max(lcond)=max(c(:,1));
    y_min(lcond)=min(c(:,2));
    
end

%     loglog([min(x) max(x)],[0.05 0.05],'--','Color',Color_text,'LineWidth',2)
%         text(1,0.04,' \uparrow p = 0.05','Color',Color_text,...
%                             'FontWeight','bold','FontSize',20);
axis([0 max(x_max) min(y_min) 1])
font_style(params.Subs_Names{lsubs==params.Subs_Numbers},[x_label ' (s)'],...
    ['Pr(X \geq x)'],'normal',FntName,FtSz)
%         'Complementary Cumulative distribution, Pr(X \geq x)','bold',FntName,36)
end

