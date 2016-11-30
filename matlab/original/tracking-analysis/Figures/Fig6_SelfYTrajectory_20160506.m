%% Trajectory segment - Whole arena
% load('E:\Analysis Data\Experiment 0003\Variables\Y_self_percentiles25   50   75  100_0003D 20-Jan-2016.mat')
fliestoplot=32;%find(params.ConditionIndex==3)
flycounter=0;
for lfly=fliestoplot
flycounter=flycounter+1
lsubs=1;
save_plot=0;

FntName='arial';
FtSz=8;
Spots=0;
LineW=1;

x=0.02;y=0.2;dh=0;w=(1-4*dh-x)/(4+0.2);
h=2*w;dv=0.2;
AxesPositions=[x,y+dv,w*1.2,h;
    x+w*1.2+dh,y+dv,w,h;
    x+w*2.2+2*dh,y+dv,w,h;
    x+w*3.2+3*dh,y+dv,w,h];%1x4 structure
AxesPositions(5,:)=[x+.05,y,3.8*w+3*dh,0.1];

paperpos=[0 0 16 7];

if ~exist('Etho_Speed_new','var')
    [Etho_Speed_new,Etho_colors_new,Etho_Colors_Labels] = Etho_Speed2New(params.MinimalDuration,Etho_Speed,1);
end
if ~exist('Etho_Tr2_2','var')
    [~,~,~,Etho_Tr2_2,Etho_Tr2_2Colors]=TransitionProb2(DurInV,Heads_Sm,FlyDB,params);
end

% Etho_Tr_Colors2(1,:)=[1 0 0];%1- Yeast Visit
% Etho_Tr_Colors2(2,:)=[1 1 1];%2- Sucrose Visit

[Etho_Tr_paper_YColors,Etho_Tr_paper_SColors]=EthoTrColorsPaper_fun;
Tr_Colors_paper={Etho_Tr_paper_YColors,Etho_Tr_paper_SColors};
Tr_Colors_Traj=Tr_Colors_paper{lsubs};
Tr_Colors_Traj(sum(Tr_Colors_Traj,2)==3,:)=repmat([.5 .5 .5],sum(sum(Tr_Colors_Traj,2)==3),1);
% if lfly==32
    Tr_Colors_Traj(7,:)=Tr_Colors_Traj(1,:);
    Tr_Colors_paper{lsubs}(7,:)=Tr_Colors_paper{lsubs}(1,:)
% end

Etho_H_Speed=Etho_Speed_new;
Etho_H_Speed(Etho_H==9)=6;%YHmm
Etho_H_Speed(Etho_H==10)=7;%SHmm
EthoH_Colors=[Etho_colors_new;...
    [240 228 66]/255;...6 - Orange (Yeast micromovements) %[250 244 0]/255;...%6 - Yellow (Yeast micromovement)
    0 0 0];%7 - Sucrose
%%
if strfind(ranges_str,'Hmm')
    vartoanalyse=CumTimeH;
else
    vartoanalyse=CumTimeV;
end
if flycounter==1
    close all

figure('Name',['Fig6_Trajectory2_fly' num2str(lfly) '_' ranges_str date],'Position',[50 50 1200 500],...
    'Color','w','PaperUnits','centimeters','PaperPosition',paperpos)%[1 1 9 9])
else
    clf
    set(gcf,'Name',['Fig6_Trajectory_fly' num2str(lfly) '_' ranges_str date])
end

for lrange=1:size(ranges_fly{lfly},1)
    subplot('Position',AxesPositions(lrange,:))
    hold on
    range=ranges_fly{lfly}(lrange,1):ranges_fly{lfly}(lrange,2);
    
    hc(2)=plot_tracks_single(FlyDB,Heads_Sm{lfly},lfly,Spots,params,1,...
                'k',range,0,1,0);
    
    colormap_segments=[127.5 127.5 127.5;204 0 0]/255;% Tr_Colors_Traj;%Etho_Tr_Colors2;%
    etho_segments=CumTimeH{1}(1:params.MinimalDuration,lfly)'+1;%Etho_Tr2_2(lfly,:);%Etho_Tr2(lfly,:);%
    plot_traj_etho(Heads_Sm,lfly,range,etho_segments,colormap_segments,...
        LineW,params)
%     hc(2)=plot_tracks_single(FlyDB,Heads_Sm{lfly},lfly,Spots,params,1,...
%         [.5 .5 .5],range,0,0,LineW);
    axis off
    display(['Duration Q' num2str(lrange) ': ' num2str((range(end)-range(1))/50/60)])
    display(['Y time Q' num2str(lrange) ': ' num2str(sum(CumTimeH{1}(range,lfly))/50/60)])
end
%% Binary visits
% subplot('Position',AxesPositions(5,:))
% frames=1:params.MinimalDuration;
% % BinaryYSVisits=CumTimeV{1}(frames,lfly);
% % BinaryYSVisits(BinaryYSVisits==0)=3;
% % BinaryYSVisits(CumTimeV{2}(frames,lfly)==1)=2;
% if strfind(ranges_str,'Hmm')
%     image(CumTimeH{1}(1:params.MinimalDuration,lfly)'+1)
%     colormap([255 255 255;204 0 0]/255);%243 164 71
%     Ylabel={'Head';'micromov.'};
% %     image(Etho_H_Speed(lfly,1:params.MinimalDuration))
% %     colormap(EthoH_Colors);
% else
%     % image(BinaryYSVisits')
%     image(Etho_Tr2_2(lfly,:))
%     colormap(Tr_Colors_paper{lsubs});%([243 164 71;170 170 170;255 255 255]/255);%170 170 170
%         Ylabel='Visits';
% end
% 
% freezeColors
% y_limetho=get(gca,'Ylim');
% hold on
% font_style([],...
%     'Time (min)',Ylabel,'normal',FntName,FtSz)
% set(gca,'XTick',[0:10:120]*50*60,'XTickLabel',cellfun(@(x)num2str(x),num2cell([0:10:120]),'uniformoutput',0),'Box','off','YTickLabel',[],'YTick',[])
% xlim([0 120*50*60])
% Visit_Labels={'Yeast','Sucrose','Not a visit'};
% %         hcb=colorbar;set(hcb,'YTick',(1:3),...
% %             'YTickLabel',Visit_Labels,'FontName',FntName,'FontSize',FtSz,'Position',[.915 .3 0.02 0.1])
% % for lrange=1:size(ranges_fly{lfly},1)
% % plot([ranges_fly{lfly}(lrange,2) ranges_fly{lfly}(lrange,2)],[.5 1.5],'-','Color','k')
% % plot([ranges_fly{lfly}(lrange,1) ranges_fly{lfly}(lrange,1)],[.5 1.5],'-','Color','k')
% % end
if save_plot==1
    savefig_withname(1,'600','png',DataSaving_dir_temp,Exp_num,Exp_letter,...
        'SelfY')
    savefig_withname(0,'600','eps',DataSaving_dir_temp,Exp_num,Exp_letter,...
        'Figures')
end
% pause
end

