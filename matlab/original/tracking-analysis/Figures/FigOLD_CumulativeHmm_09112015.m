%% Cumulative
MaxFrames=180000;
[Color,Color_patch]=Colors(4);
[CondColors,Cmap_patch]=Colors(length(unique(params.ConditionIndex)));%
newcondcolors=nan(length(Conditions),3);
for lcond=Conditions
    newcondcolors(lcond==Conditions,:)=CondColors(ismember(unique(params.ConditionIndex),lcond),:);
end
h=nan(2,1);
lsubs=1
FtSz=8;
FntName='arial';
figure('Position',[100,9,1600,985],'Color','w',...
    'Name',['Cumulative Yeast Head micromovements - cond ' num2str(Conditions) ' ' date],...
    'PaperUnits','centimeters','PaperPosition',[0 0 3 3])
Conditions=[1 3];
lcondcounter=0;
for lcond=Conditions
    % subplot('Position',Positions_temp{lsubs}(4,:))%[0.1 0.67 0.2 0.15]);%Tracking on top
    [h(1),CumTimes_mean]=plot_Cumulative(CumTimeH,lcond,lsubs,MaxFrames,params,[],...
        FtSz,FntName,Color(lcond,:),Color_patch(lcond,:));
    %             ylims=get(gca,'YLim');
    if lsubs==1,ylims=[0 25];
    elseif lsubs==2, ylims=[0 1];
    end
    ylabel({'Cumulative time';'Y microm (min)'})
end
axis([0 ceil(MaxFrames/params.framerate/60) 0 ylims(2)])
box off
savefig_withname(1,'600','png',DataSaving_dir_temp,Exp_num,Exp_letter,...
    'Figures')

%% FirstRV comes from Lagphase script (remember to set Conditions=all)
ranges_str='lagphase+3r_until115';%'lagphase';
ranges_fly=cell(params.numflies,1);
for lfly=params.IndexAnalyse
    lcondcounter=find(Conditions==params.ConditionIndex(lfly));
    FirstRangefly=FirstRV(FirstRV_Idx(:,lcondcounter)==lfly,lcondcounter)-1;
    if ~isnan(FirstRangefly)
    ranges_fly{lfly}=[1 FirstRangefly;...
            FirstRangefly+[1 30000;30001 90000;90001 180000]];
    else
        ranges_fly{lfly}=[1 2;...
            2+[1 30000;30001 90000;90001 180000]];
    end
        
end