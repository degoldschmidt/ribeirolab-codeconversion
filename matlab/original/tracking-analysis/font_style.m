function font_style(title_n,x_label,y_label,fontweight,fontname,fontsize)
%font_style get axis handle and apply input properties.
% font_style(title_n,x_label,y_label,fontweight,fontname,fontsize)
if nargin==3,fontsize=10;fontname='arial';fontweight='normal';end
set(gca,'FontSize',fontsize,'FontName',fontname,'tickdir','out','Linewidth',0.8)
xlabel(x_label,'FontWeight',fontweight,'FontSize',fontsize,'FontName',fontname)
ylabel(y_label,'FontWeight',fontweight,'FontSize',fontsize,'FontName',fontname)
title(title_n,'FontWeight',fontweight,'FontSize',fontsize,'FontName',fontname)
box off

