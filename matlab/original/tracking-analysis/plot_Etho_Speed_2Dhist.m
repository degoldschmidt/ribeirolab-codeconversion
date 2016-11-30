%% %% PLOTTING 2D HISTOGRAMS OF BEHAVIOURS %% %%

%% Merging fast-slow into one
if ~exist('Etho_Speed_new','var')
    [Etho_Speed_new,~,Etho_Colors_Labels] = Etho_Speed2New(params.MinimalDuration,Etho_Speed,merged);
end
%% Creating new Head Etho
% % % Etho_H_merged=Etho_Speed_new;%unique(Etho_Speed_new)-->0:5
% % % Etho_H_merged(Etho_H==9)=6;%Yeast head micromovement
% % % Etho_H_merged(Etho_H==10)=7;%Sucrose head micromovement
% % % Etho_Colors_Labels{6}='HeadY';
% % % Etho_Colors_Labels{7}='HeadS';
% % % EthoH_colors_new=[...
% % %     [0.6 0.6 0.6]*255;...%1 - Gray (Resting)
% % %     Color(1,:)*255;...%2 - Purple (Micromovement)
% % %     Color(3,:)*255;...%3 - Light Blue (Walking)
% % %     Color(2,:)*255;...%4 - Green (Turn)
% % %     255 0 0;......%5 - Red (Jump)
% % %     238 96 8;...%6 - Orange(Yeast head slow&Fast micromovements)
% % %     0 0 0]/255;...%7- Black (Sucrose head slow&Fast micromovements)
%% Postitions
% Elements_Labels={'Rest','Microm','Walk','Turns','Y Head microm','S Head microm'};
h_dist=0.07;
v_dist=0.07;
width=(1-6*h_dist)/4;
height=(1-4*v_dist)/2;
AxesPosit=[h_dist 3*v_dist+height width height;...
    2*h_dist+width 3*v_dist+height width height;...
    4*h_dist+2*width 3*v_dist+height width height;...
    5*h_dist+3*width 3*v_dist+height width height;...
    h_dist v_dist width height;...
    2*h_dist+width v_dist width height;...
    4*h_dist+2*width v_dist width height;...
    5*h_dist+3*width v_dist width height];
% close all
% figure('Position',[100 50 1400 930],'Color','w')
% 
% for lplot=1:size(AxesPosit,1)
%     subplot('Position',AxesPosit(lplot,:))
%     axis equal
% end
%%
close all
saveplot=0;
FntName='arial';
FtSz=8;
dist_thr=4.8;%4;%mm
xrange=-dist_thr/params.px2mm:dist_thr/params.px2mm;%every pixel

Elements_Labels=Etho_Colors_Labels(1:end-1);
var_etho_number=[1 2 3 4];
Entropies=cell(length(Elements_Labels),1);
Totaltimes=cell(length(Elements_Labels),1);
Outsidetimes=cell(length(Elements_Labels),1);

for lvariable=2%1:length(Elements_Labels)
    Entropies{lvariable}=nan(length(params.Subs_Numbers),length(Conditions));
    Totaltimes{lvariable}=nan(params.numflies,length(Conditions),length(params.Subs_Names));
    Outsidetimes{lvariable}=nan(params.numflies,length(Conditions),length(params.Subs_Names));
   plotcounter=0;
    figure('Position',[2100 50 1400 930],'Color','w','Name',[Elements_Labels{lvariable} '2D p(TimeSpent_givensubs and behav) all cond onlyout'])
    lcondcounter=0;
    for lcond=Conditions
        lcondcounter=lcondcounter+1;
        display(['---- ' params.LabelsShort{lcond} ' -----'])
        for lsubs=params.Subs_Numbers
            Hist2D_Var_data=zeros(length(xrange));
            
            plotcounter=plotcounter+1;
            subplot('Position',AxesPosit(plotcounter,:))%(2,ceil(length(Conditions)/2),lcondcounter)

            logical_subs=logical(CumTimeV{lsubs==params.Subs_Numbers}(:,params.ConditionIndex==lcond))';
            ethonumber=var_etho_number(lvariable);
            logical_etho=Etho_Speed_new(params.ConditionIndex==lcond,:)==ethonumber;
            

            lflycounter=0;
            for lfly=find(params.ConditionIndex==lcond)
                temptotal=0;tempoutside=0;
                display(lfly)
                lflycounter=lflycounter+1;
                Geometry = FlyDB(lfly).Geometry;
                WellPos = FlyDB(lfly).WellPos;
                logical_vec=logical_subs(lflycounter,:)&...
                    logical_etho(lflycounter,:);
                
                for lspot=find(Geometry==lsubs)
                    Heads_temp=repmat(WellPos(lspot,:),params.MinimalDuration,1) -...
                        Heads_Sm{lfly}(1:params.MinimalDuration,:);%
                    Dist2fSpot=sqrt(sum(((Heads_temp).^2),2)).*params.px2mm;
                    logical_dist_thr=(Dist2fSpot<=dist_thr);
                    logical_dist_thr2=(Dist2fSpot<=dist_thr)&(Dist2fSpot>=3);
                    logical_all=logical_vec'&logical_dist_thr2;
                    count_fly= hist3([Heads_temp(logical_all,2) Heads_temp(logical_all,1)],{xrange xrange});
%                     count_fly(count_fly>0)=1;
                    Hist2D_Var_data=Hist2D_Var_data+count_fly;
                    temptotal=temptotal+nansum(logical_dist_thr);
                    tempoutside=tempoutside+nansum(logical_dist_thr2);
                end
                Totaltimes{lvariable}(lflycounter,lcondcounter,lsubs==params.Subs_Numbers)=temptotal;
                Outsidetimes{lvariable}(lflycounter,lcondcounter,lsubs==params.Subs_Numbers)=tempoutside;
            end
            
            Freq=Hist2D_Var_data/sum(sum(Hist2D_Var_data));
            
            Entropies{lvariable}(lsubs==params.Subs_Numbers,lcond==Conditions)=-sum(sum(Freq(Freq~=0).*log2(Freq(Freq~=0))));
            if (lcondcounter==1)&&(lsubs==params.Subs_Numbers(1))
                maxvalue1=max(max(Freq));
            end
            imagesc(xrange*params.px2mm,xrange*params.px2mm,Freq,[0 .7*maxvalue1])%0.004])
            
            axis equal
            axis off
            if plotcounter==size(AxesPosit,1)
                hcb=colorbar;
                set(hcb, 'Position',[5*h_dist+4*width+0.01 2*v_dist 0.01 height/2])
            end
            font_style({params.Labels{lcond};params.Subs_Names{lsubs==params.Subs_Numbers}},params.Subs_Names{lsubs==params.Subs_Numbers},[],'normal',FntName,FtSz)
        end
    end
    th=suptitle(Elements_Labels{lvariable});
    set(th,'FontName',FntName,'FontSize',FtSz+2)
    

end
SubFolder_name='Behaviours';
if saveplot==1
    savefig_withname(0,'600','png',DataSaving_dir_temp,Exp_num,Exp_letter,...
        SubFolder_name)
end
%% Changing colormap in all subplots
% axesHandles = get(gcf,'children');
% axesHandles(1)
% colormap(gray)

%% Plotting Entropies
% close all
% figure('Position',[2100 50 1400 930],'Color','w','Name','Entropies p(TimeSpent_givensubs and behav) all cond')
% for lvariable=1:length(Elements_Labels)
%     subplot(2,ceil(length(Elements_Labels)/2),lvariable)
%     bar(Entropies{lvariable})
%     set(gca,'Xtick',[1:length(params.Subs_Names)],'XTicklabel',params.Subs_Names)
%     if lvariable==1
%         legend(params.LabelsShort)
%     end
%     font_style(Elements_Labels{lvariable},[],'Entropy','normal',FntName,FtSz)
%     set(gca,'Ylim',[0 12])
% end
%% Plotting Total Micromovement Times
% close all
% figure('Position',[2100 50 1400 930],'Color','w','Name','Comparison Micromovements outside spot all cond')
% for lvariable=2%1:length(Elements_Labels)
%     for lsubs=1:2
%         subplot(2,2,lsubs)
%         [~,lineh] = plot_boxplot_tiltedlabels(Outsidetimes{lvariable}(:,:,lsubs)/50/60,params.LabelsShort);
%         font_style(params.Subs_Names{lsubs},[],'Total time outside spot (min) - Micromovements','normal',FntName,FtSz)
%     end
%     
%     for lsubs=1:2
%         subplot(2,2,lsubs+2)
%         [~,lineh] = plot_boxplot_tiltedlabels(100*Outsidetimes{lvariable}(:,:,lsubs)./Totaltimes{lvariable}(:,:,lsubs),params.LabelsShort);
%         font_style(params.Subs_Names{lsubs},[],'Proportion of micromovements outside spot (%)','normal',FntName,FtSz)
%     end
%    
% end
%%
% ranksum(100*Outsidetimes{lvariable}(:,1,lsubs)./Totaltimes{lvariable}(:,1,lsubs),...
%     100*Outsidetimes{lvariable}(:,3,lsubs)./Totaltimes{lvariable}(:,3,lsubs))