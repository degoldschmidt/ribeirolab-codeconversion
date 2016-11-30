%% Plot area coverage of micromovements per sec (over duration)
x=-33:params.px2mm:33;
Grooming_counter=0;
Feeding_counter=[0 0];
Grooming=nan(500,2);%[Area covered, duration]
Feeding=nan(500,2,2);%[Area covered, duration]. Layer 1= Yeast. Layer 2 = Sucrose

for litem=1:139
    litem
    lfly=Annotation_micromovements(litem).Info(4);
    lsubs=FlyDB(lfly).Geometry(Annotation_micromovements(litem).Info(3));
    %% Grooming
    if ~isempty(Annotation_micromovements(litem).Grooming)
        
        %% Area covered
        for lgrooming=1:size(Annotation_micromovements(litem).Grooming,1)
            Grooming_counter=Grooming_counter+1;
            counts=hist3(Heads_Sm{lfly}...
                (Annotation_micromovements(litem).Grooming(lgrooming,1):...
                Annotation_micromovements(litem).Grooming(lgrooming,2),:)*params.px2mm,...
                'Edges',{x,x});
            areacovered=(sum(sum(counts~=0)));
            Grooming(Grooming_counter,:)=[areacovered,...
                (Annotation_micromovements(litem).Grooming(lgrooming,2)-...
            Annotation_micromovements(litem).Grooming(lgrooming,1))/params.framerate];
            
        end
    end
    %% Feeding
    if ~isempty(Annotation_micromovements(litem).Feeding)
        %% Area covered
        for lFeeding=1:size(Annotation_micromovements(litem).Feeding,1)
            Feeding_counter(lsubs)=Feeding_counter(lsubs)+1;
            counts=hist3(Heads_Sm{lfly}...
                (Annotation_micromovements(litem).Feeding(lFeeding,1):...
                Annotation_micromovements(litem).Feeding(lFeeding,2),:)*params.px2mm,...
                'Edges',{x,x});
            areacovered=(sum(sum(counts~=0)));
            Feeding(Feeding_counter(lsubs),:,lsubs)=[areacovered,...
                (Annotation_micromovements(litem).Feeding(lFeeding,2)-...
            Annotation_micromovements(litem).Feeding(lFeeding,1))/params.framerate];
            
        end
    end
    
end
Grooming=Grooming(1:Grooming_counter,:);
Feeding=Feeding(1:max(Feeding_counter),:,:);
%% Plotting Area covered/px scatter plot
close all
fig=figure('Position',[10 350 700 650],'Color','w');%
hold on
Color=Colors(3);
h=nan(3,1);
h(1)=plot(1:size(Grooming,1),sort(Grooming(:,1)./Grooming(:,2)),'o','MarkerSize',5,...
    'MarkerEdgeColor',Color(1,:),'MarkerFaceColor',Color(1,:));
h(2)=plot(1:Feeding_counter(1),sort(Feeding(1:Feeding_counter(1),1,1)./...
    Feeding(1:Feeding_counter(1),2,1)),'o','MarkerSize',5,...
    'MarkerEdgeColor',Color(2,:),'MarkerFaceColor',Color(2,:));
h(3)=plot(1:Feeding_counter(2),sort(Feeding(1:Feeding_counter(2),1,2)./...
    Feeding(1:Feeding_counter(2),2,2)),'o','MarkerSize',5,...
    'MarkerEdgeColor',Color(3,:),'MarkerFaceColor',Color(3,:));
legend(h,{'Grooming';'Yeast';'Sucrose'},'box','off','location','best')
font_style([],'Event Nº','Area covered per sec (px/s)','normal','arial',14)
figname='Area covered during Feeding Y and S and Grooming - Scatter plot';
% print('-dpng','-r400',[DataSaving_dir_temp Exp_num '\Plots\Manual Ann\',...
%             figname '.png'])%
%% Plotting Area covered/px scatter plot
% close all
fig=figure('Position',[10 350 700 650],'Color','w');%
hold on
Color=Colors(3);
h=nan(3,1);
h(1)=plot(Grooming(:,2),Grooming(:,1),'o','MarkerSize',5,...
    'MarkerEdgeColor',Color(1,:),'MarkerFaceColor',Color(1,:));
h(3)=plot(Feeding(1:Feeding_counter(2),2,2),Feeding(1:Feeding_counter(2),1,2),'o','MarkerSize',5,...
    'MarkerEdgeColor',Color(3,:),'MarkerFaceColor',Color(3,:));
h(2)=plot(Feeding(1:Feeding_counter(1),2,1),Feeding(1:Feeding_counter(1),1,1),'o','MarkerSize',5,...
    'MarkerEdgeColor',Color(2,:),'MarkerFaceColor',Color(2,:));

legend(h,{'Grooming';'Yeast';'Sucrose'})
font_style([],'Duration (s)','Area covered (px)','normal','arial',14)
axis([0 120 0 100])
figname='Area covered vs duration during Feeding yeast and sucrose and Grooming3';
% print('-dpng','-r400',[DataSaving_dir_temp Exp_num '\Plots\Manual Ann\',...
%             figname '.png'])%
%% Histogram of area coverage
% close all
fig=figure('Position',[10 10 700 650],'Color','w');%
hold on
bins=[0:1:15 Inf];
FtSz=14;%20;

[counts_y]=histc(Feeding(1:Feeding_counter(1),1,1)./...
    Feeding(1:Feeding_counter(1),2,1),bins);
[counts_s]=histc(Feeding(1:Feeding_counter(2),1,2)./...
    Feeding(1:Feeding_counter(2),2,2),bins);
[counts_gr]=histc(Grooming(:,1)./Grooming(:,2),bins);

counts_y=counts_y(1:end-1);
counts_s=counts_s(1:end-1);
counts_gr=counts_gr(1:end-1);

h=bar(bins(1:end-1),[(counts_y/sum(counts_y)),...
    (counts_s/sum(counts_s)),...
    (counts_gr/sum(counts_gr))]);

for lhist=1:3
    set(h(lhist),'FaceColor',Color(lhist,:),'EdgeColor',Color(lhist,:));
end
font_style([],'Area covered per sec (px/s)',...
    'Relative Frequency','normal','arial',FtSz)
xlim([bins(1)-1 bins(end-1)+1])
legend(h,{'Yeast';'Sucrose';'Grooming'})
% legend(h,{'At Y edge';'Grooming'})
figname='Area covered during micromovement - Y, S & grooming';
% print('-dpng','-r400',[DataSaving_dir_temp Exp_num '\Plots\Manual Ann\',...
%     figname '.png'])%'-r600'