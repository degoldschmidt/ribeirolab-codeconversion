%% %% What is a long IVI? %% %%

%% Obtaining IVIs in Cell vector
Visit_Var=cell(1,1);
Visit_Var{1}=cell(params.numflies,1);
MeanIVI=nan(params.numflies,1);
for lfly=1:params.numflies
    F_starts=find(conv(double(Binary_V(:,lfly)~=0),[1 -1])==1);
    F_ends=find(conv(double(Binary_V(:,lfly)~=0),[1 -1])==-1)-1;
    
%     F_starts=find(conv((CumTimeV{1}(:,lfly)),[1 -1])==1);
%     F_ends=find(conv((CumTimeV{1}(:,lfly)),[1 -1])==-1)-1;
    if length(F_starts)>1
        Visit_Var{1}{lfly}=(F_starts(2:end)-F_ends(1:end-1))/params.framerate; 
    end
    MeanIVI(lfly)=nanmean(Visit_Var{1}{lfly});
end
%% Long IVI (>95%)
[Counts_Cond,binfly]=hist_boutlength(Visit_Var,1,Conditions,params);
close all
saveplot=1;
MarkrSz=4;
FontSz=10;
LnWdth=2;
fontName='arial';

figure('Position',[100 50 params.scrsz(3)-250 params.scrsz(4)-250],'Color','w',...
    'Name',['IVI with p_0.05']);
for lsubs=1
    plot_bar(binfly{lsubs}'/60,[,...params.Subs_Names{lsubs}(1:end-4)
        ' IVI with p \leq 0.05 [min]'],[,...params.Subs_Names{lsubs}
        ' IVI with p_0.05'],Conditions, params,'Macrostructure',...
        Dropbox_choicestrategies,DataSaving_dir_temp,Exp_num,Exp_letter,0,1,MarkrSz,FontSz,LnWdth,fontName)
end
if (saveplot==1)
    savefig_withname(1,'600','png',DataSaving_dir_temp,Exp_num,Exp_letter,'Macrostructure')
end   
%% Mean IVI
saveplot=1;
MarkrSz=4;
FontSz=10;
LnWdth=2;
fontName='arial';
figure('Position',[100 50 params.scrsz(3)-250 params.scrsz(4)-250],'Color','w',...
    'Name','Mean IVI');
for lsubs=1
    plot_bar(MeanIVI/60,[,...params.Subs_Names{lsubs}(1:end-4)
        ' mean IVI (min)'],[,...params.Subs_Names{lsubs}
        ' mean IVI'],Conditions, params,'Macrostructure',...
        Dropbox_choicestrategies,DataSaving_dir_temp,Exp_num,Exp_letter,0,1,MarkrSz,FontSz,LnWdth,fontName)
end
if (saveplot==1)
    savefig_withname(1,'600','png',DataSaving_dir_temp,Exp_num,Exp_letter,'Macrostructure')
end    

