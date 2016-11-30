%%% Ethogram %%%
%% Plotting big Etho_H
Color_track=Colors(3);
% Etho_Colors=[...
%     [0.6 0.6 0.6]*255;...%1 - Gray (Resting)
%     Color_track(1,:)*255;...%2 - Purple (slow micromovement)
%     204 140 206;...%3 - Light Purple (fast-micromovement)
%     124 143 222;...%4 -  Blueish violet (Slow walk)
%     Color_track(3,:)*255;...%5 - Light Blue (Walking)
%     Color_track(2,:)*255;...%6 - Green (Turn)
%     255 0 0;...%7 - Red (Jump)
%     250 244 0;...%8 - Yellow (Activity Bout)
%     250 234 176;...238 96 8;...%9 - Orange(Yeast head slow micromovement)
%     0 0 0]/255;% 10 - Sucrose (black)
% Etho_Colors_Labels={'Rest','Slow microm','Fast microm','Slow walk','Walk',...
%         'Sharp Turn','Jump','Act Bout','Head Y','Head S'};


Etho_H_new=Etho_H;
Etho_H_new(Etho_H_new==3)=2;%Fast into micro
Etho_H_new(Etho_H_new==4)=3;% Slow walk into merged walk
Etho_H_new(Etho_H_new==5)=3;% Walk into merged walk
Etho_H_new(Etho_H_new==6)=4;% Turn into new turn
Etho_H_new(Etho_H_new==7)=5;% Jump into new jump
Etho_H_new(Etho_H_new==9)=6;% YEast
Etho_H_new(Etho_H_new==10)=7;% Sucrose

Conditions=unique(params.ConditionIndex);

Etho_Colors=[...
    [0.6 0.6 0.6]*255;...%1 - Gray (Resting)
    243 7 198;%2 - Magenta (micromovement)
    Color_track(3,:)*255;...%3 - Light Blue (Walking)
    Color_track(2,:)*255;...%4 - Green (Turn)
    255 0 0;...%5 - Red (Jump)
    250 244 0;...%6 - Yellow (Yeast micromovement)
    0 0 0;...%7 - Sucrose
    255 255 255]/255;% Nothing
Etho_Colors_Labels={'Rest','Microm','Walk',...
    'Sharp Turn','Jump','Head Y','Head S'};

saveplots_=0;
subplots=1;

FtSz=6;
FntName='arial';

close all

ColorsSpeed=Colors(3);
WalkingEtho_Colors=[ColorsSpeed(3,:);[1 1 1];[0.5 0.5 0.5]];%[blue, white, gray]
lsubs=1; %Order ethograms according to Yeast = Substrate 1

if subplots
    figure('Position',[100,9,1600,985],'Color','w',...
        'Name',['Head mm Etho - All ' date])
end

lcondcounter=0;
for lcond=Conditions
    lcondcounter=lcondcounter+1;
    if subplots~=1
        figure('Position',[100,9,1600,985],'Color','w',...
            'Name',['Head mm Etho 60min - ' params.LabelsShort{lcond}])
    else
        subplot(2,ceil(length(Conditions)/2),lcondcounter)

    end

    %% Plotting Ethogram
    Totaltimes_cond=sum(CumTimeV{1}(:,params.ConditionIndex==lcond));%sum(CumTimeH{1}(:,params.ConditionIndex==lcond));
    Etho_H_cond=Etho_H_new(params.ConditionIndex==lcond,:);
    Idx_cond=find(params.ConditionIndex==lcond);
    [Totalt_sorted,Idx_sort]=sort(Totaltimes_cond,...
        'descend');
    image(Etho_H_cond(Idx_sort,1:180000))

    %%% Other settings
    colormap(Etho_Colors);
    freezeColors
    set(gca,'XTick',[1:20*50*60:120*50*60],...
        'XTickLabel',{'0','20','40','60','80','100','120'},...
        'YTick',1:length(Idx_cond),'YTickLabel',cellfun(@(x)num2str(x),num2cell(Idx_cond(Idx_sort)),'uniformoutput',0))%,...
    xlim([0 180000])%xlim([0 params.MinimalDuration])
    ylim([.5 37])



    font_style(params.Labels{lcond},[],...
        'Single Flies','normal',FntName,FtSz)
    if subplots~=1
        set(gca,'Position',[0.1 0.01 0.75 0.9])
    end
    if ((subplots==1)&&(lcondcounter==length(Conditions)))||(subplots~=1)
        plotpos=get(gca,'Position');
%         hcb=colorbar;
        hcb=cbfreeze(colorbar);
        set(hcb,'YTick',(1:10),...
            'YTickLabel',Etho_Colors_Labels,'FontName',FntName,'FontSize',FtSz-2)
        if subplots==1
            set(hcb,'Position',[0.9198 0.1084 0.0139 0.3428])

        end
        set(gca,'Position',plotpos)
    end



    if (saveplots_==1)&&(subplots~=1)
        savefig_withname(0,'600','png',DataSaving_dir_temp,Exp_num,Exp_letter,'Ethograms')
    end

end
% if (saveplots_==1)&&(subplots==1)
%     savefig_withname(1,'600','png',DataSaving_dir_temp,Exp_num,Exp_letter,'Ethograms')
% end
% if saveplots_==1,     display(['Head Ethograms saved2']); end
%% Adding flies color code depending on how much yeast
% if length(Conditions)==4
%     lcondcounter=0;
%     for lcond=Conditions(1:end-1)
%         lcondcounter=lcondcounter+1;
%         Totaltimes_cond=sum(CumTimeV{1}(:,params.ConditionIndex==lcond));%sum(CumTimeH{1}(:,params.ConditionIndex==lcond));
%         Idx_cond=find(params.ConditionIndex==lcond);
%         [Totalt_sorted,Idx_sort]=sort(Totaltimes_cond,'descend');
%         switch lcondcounter
%             case 1
%                 subplot('Position',[0.13+0.3347+0.005 0.5838 0.01 0.3412])
%             case 2
%                 subplot('Position',[0.5703+0.3347+0.005 0.5838 0.01 0.3412])
%             case 3
%                 subplot('Position',[0.13+0.3347+0.005 0.11 0.01 0.3412])
%             case 4
%                 subplot('Position',[0.5703+0.3347+0.005 0.11 0.01 0.3412])
%         end
%         image((length(Idx_cond):-1:1)')
%         colormap(jet(length(Idx_cond)))
%         freezeColors
%         ylim([.5 37])
%         axis off
%         Sorted_Fly=Idx_cond(Idx_sort);
%         for lflycounter=1:length(Idx_cond)
%             text(1,lflycounter,num2str(floor(sum(CumTimeV{1}(:,Sorted_Fly(lflycounter)))/50/60)),...
%                 'FontSize',FtSz,'FontName',FntName,'HorizontalAlignment','center','Color',[.7 .7 .7])
%         end
%     end
% end
% if (saveplots_==1)&&(subplots==1)
%     savefig_withname(1,'600','png',DataSaving_dir_temp,Exp_num,Exp_letter,'Ethograms')
% end
% if saveplots_==1,     display(['Head Ethograms saved2']); end

%% Plotting Transitions Ethogram
if ~exist('Etho_Tr2_2','var')
[~,Etho_Tr2,~, Etho_Tr2_2,Etho_Tr2_2Colors]=TransitionProb2(DurInV,Heads_Sm,FlyDB,params);
end
Etho_Colors_Labels={'Same Y';'Same S';'Close Y';'Close S';'Far Y';'Far S'};
if strfind([Exp_num Exp_letter],'0004A')
    Etho_Tr2_2Colors=[230 159 0;... % 1 - Same Yeast (Orange)
    86 80 233;... %2- Close yeast (light blue)
    0 0 0;... %3- Far yeast (black)
    170 170 170;...%4- First Visit
    255 255 255]/255; %5 - Not a visit
    Etho_Colors_Labels={'Same A';'Close A';'Far A';'First';'No visit'};
end


if subplots
    figure('Position',[100,9,1600,985],'Color','w',...
        'Name','Transition Ethograms - All conditions')
end

lcondcounter=0;
for lcond=Conditions
    lcondcounter=lcondcounter+1;
    if subplots~=1
        figure('Position',[100,9,1600,985],'Color','w',...
            'Name',['Transition Ethograms60min - ' params.LabelsShort{lcond}])
    else
        subplot(2,ceil(length(Conditions)/2),lcondcounter)

    end

    %% Plotting Ethogram
    Totaltimes_cond=sum(CumTimeV{1}(:,params.ConditionIndex==lcond));%sum(CumTimeH{1}(:,params.ConditionIndex==lcond));
    Etho_H_cond=Etho_Tr2_2(params.ConditionIndex==lcond,:);
    Idx_cond=find(params.ConditionIndex==lcond);
    [Totalt_sorted,Idx_sort]=sort(Totaltimes_cond,'descend');
    image(Etho_H_cond(Idx_sort,1:180000))

    %%% Other settings
    colormap(Etho_Tr2_2Colors);
    freezeColors
    set(gca,'XTick',[1:20*50*60:120*50*60],...
        'XTickLabel',{'0','20','40','60','80','100','120'},...
        'YTick',1:length(Idx_cond),'YTickLabel',cellfun(@(x)num2str(x),num2cell(Idx_cond(Idx_sort)),'uniformoutput',0))%,...
    xlim([0 180000])%xlim([0 params.MinimalDuration])
    ylim([.5 37])

    

    font_style(params.Labels{lcond},[],...
        'Single Flies','normal',FntName,FtSz)
    if subplots~=1
        set(gca,'Position',[0.1 0.01 0.75 0.9])
    end
    if ((subplots==1)&&(lcondcounter==length(Conditions)))||(subplots~=1)
        hcb=colorbar;set(hcb,'YTick',(1:6),...
            'YTickLabel',Etho_Colors_Labels,'FontName',FntName,'FontSize',FtSz-2)
        if subplots==1
            set(hcb,'Position',[0.9198 0.1084 0.0139 0.3428])
        end
    end



    if (saveplots_==1)&&(subplots~=1)
        savefig_withname(1,'600','png',DataSaving_dir_temp,Exp_num,Exp_letter,'Ethograms')
    end

end
saveplots_=1;
if (saveplots_==1)&&(subplots==1)
    savefig_withname(1,'600','png',DataSaving_dir_temp,Exp_num,Exp_letter,'Ethograms')
end

