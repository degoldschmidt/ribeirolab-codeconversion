function plot_tracks(FlyDB,Centroids,flies_idx,params)
%%% Plots Centroids, creating a subplot for each different condition
%%% Use: plotting_tracks(FlyDB,Centroids,params)
%%% Inputs:
%%% Centroids       Cell array with [X Y] positions in px
%%% flies_idx       Row vector with the indexes of flies to plot

%% Plotting Tracks
rows=unique(params.row_n);
cols=unique(params.col_n);

scrsz = get(0,'ScreenSize');
figure('Position',[100 50 scrsz(3)-150 scrsz(4)-150])
hold on



Cmap=[142 185 45;215 158 45]/255; %[Green;Orange] %length(Cmap)=length(unique(params.Cond_inside_plot))


for lfly=flies_idx
     
    subplot(numel(rows),numel(cols),params.ConditionIndex(lfly))
    
    plot(Centroids{lfly}(:,1)*params.px2mm,...
        Centroids{lfly}(:,2)*params.px2mm,'-k',...
        'LineWidth',3,'Color',Cmap(1,:));%Cmap(unique(params.Cond_inside_plot)==params.Cond_inside_plot(params.IndexAnalyse==filenumber),:)
    
    hold on
    WellPos=FlyDB(lfly).WellPos;
    plot(Centroids{lfly}(:,1)*params.px2mm,Centroids{lfly}(:,2)*params.px2mm,'.k','MarkerSize',2)
    plot(WellPos(FlyDB(lfly).Geometry==1,1)*params.px2mm,...
        WellPos(FlyDB(lfly).Geometry==1,2)*params.px2mm,'ob',...
        'MarkerSize',3,'MarkerFaceColor',[201 215 255]/255,'MarkerEdgeColor',[201 215 255]/255)%'MarkerSize',3
    
    plot(WellPos(FlyDB(lfly).Geometry==2,1)*params.px2mm,...
        WellPos(FlyDB(lfly).Geometry==2,2)*params.px2mm,...
        'or','MarkerSize',3,'MarkerFaceColor',[255 197 197]/255,'MarkerEdgeColor',[255 197 197]/255)

    hold off
    axis equal
%     axis([-205*params.px2mm 205*params.px2mm -205*params.px2mm 205*params.px2mm])
    axis([-30 30 -30 30])%mm
%     xlabel(num2str(filenumber),'FontWeight','bold','FontSize',14)
    xlabel('X coordinate (mm)','FontWeight','bold','FontSize',20)
    ylabel('Y coordinate (mm)','FontWeight','bold','FontSize',20)
    set(gca,'FontSize',20)
    %                     ylabel('Fully Fed','FontWeight','bold','FontSize',24);
    
    title([params.Labels(params.ConditionIndex(lfly)) 'FlyDBNº' num2str(lfly)],'FontWeight','bold','FontSize',14);
    
    pause(0.2)
        
end
