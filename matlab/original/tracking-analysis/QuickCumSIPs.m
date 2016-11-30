%% Cumulative Number of Feeding Events - FlyPAD
close all
Subs_Names={'Sucrose 18%';'Yeast 18%'};
LabelsShort={'CS Mated, FF';...
    'CS Virgin, FF';...
    'CS Mated, AA-';...
    'CS Virgin, AA-';...
    'T\betah Mated, FF';...
    'T\betah Virgin, FF';...
    'T\betah Mated, AA-';...
    'T\betah Virgin, AA-'};
Conditions=1:length(LabelsShort);
[Colormap,Cmap_patch]=Colors(length(Conditions),1);
Colors_PAD=cell(length(Conditions),1);
for lcond=Conditions
    Colors_PAD{lcond==Conditions,1}=Colormap(lcond==Conditions,:);
    Colors_PAD{lcond==Conditions,2}=Cmap_patch(lcond==Conditions,:);
end
scrsz=get(0,'ScreenSize');
figure('Position',[100 50 scrsz(3)-450 scrsz(4)-150],'Color','w');
for lsubs=1:length(Subs_Names)
subplot(1,length(Subs_Names),lsubs)
CumulativeFeedingEvents(Events,lsubs,1,LabelsShort,Colors_PAD,320000);
font_style(Subs_Names{lsubs},'Recording time(min)','Cumulative Number of Sips',...
    'bold','calibri',20)
% ylims=get(gca,'YLim');
xlim([0 320000/100/60])
end