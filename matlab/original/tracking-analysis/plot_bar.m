function plot_bar(Col_vector,Y_label,file_name,ConditionLocation,params,SubFolder_name,...
    Dropbox_choicestrategies,DataSaving_dir_temp,Exp_num,Exp_letter,share,...
    subplots,MarkrSz,FontSz,LnWdth,fontName)
%plot_bar plots bars with mean and std error and spreadpoints
% plot_bar(Col_vector,Y_label,Conditions, params,subplots,SubFolder_name,...
%     Dropbox_choicestrategies,DataSaving_dir_temp,Exp_num,MarkrSz,FontSz,LnWdth,fontName)
%% Bar & stderr of Total time
if nargin==10,share=0;subplots=0;MarkrSz=5;FontSz=12;LnWdth=3;fontName='calibri';end
if nargin==11,subplots=0;MarkrSz=5;FontSz=12;LnWdth=3;fontName='calibri';end
if nargin==12,MarkrSz=5;FontSz=12;LnWdth=3;fontName='calibri';end
if nargin==13,FontSz=12;LnWdth=3;fontName='calibri';end
if nargin==14,LnWdth=3;fontName='calibri';end
if nargin==15,fontName='calibri';end

stats=2;
if LnWdth==1,LnWdth=2;end
jitter=0.3;
if subplots~=1
    figure('Position',[100 50 1000 830],'Color','w');
end
Conditions=sort(ConditionLocation);
[Colormap,Cmap_patch]=Colors(4);%(length(Conditions));
% ConditionLocation=1:length(Conditions);
% ConditionLocation=Conditions;%[2 1 3 4];%Position in xaxis--> length of Conditions
lcondcounter=1;

for lcond=Conditions
    
    hold on
    
    stderrY=nanstd(Col_vector(params.ConditionIndex==lcond))/...
        sqrt(sum(params.ConditionIndex==lcond));
    
    %% Bar plot
    %     barhandle=bar(find(ConditionLocation==lcond),nanmean(Col_vector(params.ConditionIndex==lcond)),0.5);
    %     set(barhandle,'LineWidth', LnWdth,'EdgeColor',Colormap(lcondcounter,:),...
    %         'FaceColor','w');%FaceColor(lsubs,:));
    
    if stats==1
        %% Plotting SpreadPoints
        plot_spreadpts(Col_vector(params.ConditionIndex==lcond),...
        find(ConditionLocation==lcond),[0.7 0.7 0.7],MarkrSz,jitter)
        %% Line and spot in mean
        plot([find(ConditionLocation==lcond)-jitter;find(ConditionLocation==lcond)+jitter],...
            repmat(nanmean(Col_vector(params.ConditionIndex==lcond)),2,1),...
            'Color',Colormap((lcondcounter),:),'LineWidth',LnWdth+2)
        plot(find(ConditionLocation==lcond),nanmean(Col_vector(params.ConditionIndex==lcond)),...
            '-ob','LineWidth',LnWdth+2,...
            'MarkerEdgeColor',Colormap((lcondcounter),:),...
            'MarkerSize',MarkrSz,'MarkerFaceColor',Colormap((lcondcounter),:));
        %% Line std error
        line([find(ConditionLocation==lcond);find(ConditionLocation==lcond)],...
            [nanmean(Col_vector(params.ConditionIndex==lcond))+...
            stderrY;...
            nanmean(Col_vector(params.ConditionIndex==lcond))-...
            stderrY],...
            'Color',Colormap((lcondcounter),:),'LineWidth',LnWdth-1);
        
    elseif stats==2
         %% Shaded IQR
        fillhandle=fill([repmat(find(ConditionLocation==lcond)-jitter/2,2,1);...
            repmat(find(ConditionLocation==lcond)+jitter/2,2,1)],...
            [prctile(Col_vector(params.ConditionIndex==lcond),25);...
            repmat(prctile(Col_vector(params.ConditionIndex==lcond),75),2,1);...
            prctile(Col_vector(params.ConditionIndex==lcond),25)],...
            Colormap((lcondcounter),:));%plot the data
        set(fillhandle,'EdgeColor',Colormap((lcondcounter),:),'FaceAlpha',.2,...
            'LineWidth',1,'EdgeAlpha',.2);%set edge color
        %% Plotting SpreadPoints
        plot_spreadpts(Col_vector(params.ConditionIndex==lcond),...
        find(ConditionLocation==lcond),[0.7 0.7 0.7],MarkrSz,jitter)
        %% Line in median
        plot([find(ConditionLocation==lcond)-jitter;find(ConditionLocation==lcond)+jitter],...
            repmat(nanmedian(Col_vector(params.ConditionIndex==lcond)),2,1),...
            'Color',Colormap((lcondcounter),:),'LineWidth',LnWdth+2)
        plot(find(ConditionLocation==lcond),nanmedian(Col_vector(params.ConditionIndex==lcond)),...
            '-ob','LineWidth',LnWdth+2,...
            'MarkerEdgeColor',Colormap((lcondcounter),:),...
            'MarkerSize',MarkrSz,'MarkerFaceColor',Colormap((lcondcounter),:));
       
    end
    
    %     ylim([0 160])
    lcondcounter=lcondcounter+1;
end
font_style([],[],...
    Y_label,'normal',fontName,FontSz)
set(gca,'Xtick',[],'XTickLabel',[],...
    'XAxisLocation','bottom',...
    'YAxisLocation','left',...
    'Color','none');%,'Position',[0.17 0.18 0.775 0.75])
ax=axis;
%%% Rotate x axis labels
t=text(1:length(Conditions),ax(3)*ones(1,length(Conditions)),params.LabelsShort(ConditionLocation));
set(t,'HorizontalAlignment','right','VerticalAlignment','top',...
    'Rotation',20,'FontSize',FontSz-1,'FontName',fontName);
xlim([0 length(Conditions)+1])
pos=get(gca,'Position');
set(gca,'Position',[pos(1) pos(2)+0.2*pos(2) pos(3) pos(4)-0.1*pos(4)])
if subplots~=1
    saveplots(Dropbox_choicestrategies,SubFolder_name,...
        [Exp_num Exp_letter file_name],...
        DataSaving_dir_temp,Exp_num,0,0)
end

%% Mann Whitney test for all possible pairs of conditions & Save text file
title_pvalue=['Uncorrected Mann Whitney p-values for ' Y_label];
display(title_pvalue)
%%% Save text file
Folder_Plots=exist([DataSaving_dir_temp Exp_num '\Plots'],'dir');
if Folder_Plots==7 % If it exists, check if subfolder exists
    SubFolder_Plots=exist([DataSaving_dir_temp Exp_num '\Plots\' SubFolder_name],'dir');
    if SubFolder_Plots==7 % If subfolder exists, save figure
        fid=fopen([DataSaving_dir_temp Exp_num '\Plots\' SubFolder_name '\',...
            Exp_num Exp_letter file_name '.txt'],'w');
    else % if subfolder doesn't exist, create it and save figure
        mkdir([DataSaving_dir_temp Exp_num '\Plots\' SubFolder_name])
        fid=fopen([DataSaving_dir_temp Exp_num '\Plots\' SubFolder_name '\',...
            Exp_num Exp_letter file_name '.txt'],'w');
    end
else % Folder Plots doesn't exist, create one and subfolders
    mkdir([DataSaving_dir_temp Exp_num '\Plots'])
    mkdir([DataSaving_dir_temp Exp_num '\Plots\' SubFolder_name])
    fid=fopen([DataSaving_dir_temp Exp_num '\Plots\' SubFolder_name '\',...
        Exp_num Exp_letter file_name '.txt'],'w');
end

fprintf(fid,'%s\r\n\r\n',title_pvalue);

for llcond_BN=1:length(Conditions)-1
    for lcomparBN=llcond_BN+1:length(Conditions)
        lcond1=Conditions(llcond_BN);
        lcond2=Conditions(lcomparBN);
        p=ranksum(Col_vector(params.ConditionIndex==lcond1),Col_vector(params.ConditionIndex==lcond2));%*length(Conditions);
        pvaluetext=['p-value ' params.LabelsShort{lcond1} ' vs ' params.LabelsShort{lcond2} ' = ' num2str(p)];
        display(pvaluetext)
        fprintf(fid,'%s\r\n',pvaluetext);
    end
end

fclose(fid);

%% If share
if share==1
    %%% Save text file
    fid=fopen([Dropbox_choicestrategies,...
        Exp_num '\',SubFolder_name '\',...
        Exp_num,Exp_letter,file_name '.txt'],'w'); %'w' to overwrite existing contents, 'a' to append in the file.
    
    fprintf(fid,'%s\r\n\r\n',title_pvalue);
    
    for llcond_BN=1:length(Conditions)-1
        for lcomparBN=llcond_BN+1:length(Conditions)
            lcond1=Conditions(llcond_BN);
            lcond2=Conditions(lcomparBN);
            p=ranksum(Col_vector(params.ConditionIndex==lcond1),Col_vector(params.ConditionIndex==lcond2));%*length(Conditions);
            pvaluetext=['p-value ' params.LabelsShort{lcond1} ' vs ' params.LabelsShort{lcond2} ' = ' num2str(p)];
            display(pvaluetext)
            fprintf(fid,'%s\r\n',pvaluetext);
        end
    end
    
    fclose(fid);
end

