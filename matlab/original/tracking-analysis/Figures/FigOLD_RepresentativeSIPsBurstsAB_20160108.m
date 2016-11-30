%% 
load('E:\Analysis Data\Experiment 0003\FlyPAD\1_12\1_12_NoSpill_CS_All.mat')
SIPSBinary=2*ones(1,360000);
for lsip=1:length(Events.Ons{1,1})
    SIPSBinary(Events.Ons{1,1}(lsip):Events.Offs{1,1}(lsip))=1;
end

BURSTSBinary=2*ones(1,360000);
for lburst=1:length(Events.FeedingBurstOns{1,1})
    BURSTSBinary(Events.FeedingBurstOns{1,1}(lburst):Events.FeedingBurstOffs{1,1}(lburst))=1;
end

%%
close all
saveplot=1;
samples=84000:86000;%1:360000;%70000:100000;%63520:64210;%63000:64800;
FtSz=8;
FntName='arial';

figure('Position',[2100 50 1500 500],'Color','w','Name',['Fig2A-SIP & Burst representation4 ' date],'PaperUnits',...
                'centimeters','PaperPosition',[0 0 15 5])%[0 0 8.5 3]
%%% Sips
subplot('Position',[0.1 .6 .8 .15])
image(SIPSBinary(samples))
hold on
box off
font_style([],[],'Sips','normal',FntName,FtSz)
colormap(gray(2))

freezeColors
set(gca,'XTick',[],'YTick',[])
% xlims_=[8.4 8.6]*10^4;%[10.5 10.8]*100*60;
% xlim(xlims_)

%%% Bursts
subplot('Position',[0.1 .3 .8 .15])
image(BURSTSBinary(samples))
hold on
box off

colormap([0.3569 0.8314 1; 1 1 1])

freezeColors
xticks=[0:1:length(samples)/100]*100;
set(gca,'XTick',xticks,...
    'XTickLabel',cellfun(@(x)num2str(x),num2cell(xticks/100),'uniformoutput',0),'YTick',[])
% xlim(xlims_)
font_style([],'Time (s)','Bursts','normal',FntName,FtSz)



if saveplot==1
    savefig_withname(0,'600','png','E:\Analysis Data\Experiment ','0003','A',...
        'Figures')
    savefig_withname(0,'600','eps','E:\Analysis Data\Experiment ','0003','A',...
        'Figures')
end