%% Prepare variables for Python-aided visual inspection of videos
% load([Variablesfolder 'ManualAnnotation0003A 01-Dec-2014.mat'])
% 
% Vartoplot='Grooming';%'Grooming';%'Revisits';%'Rest';%'Not_engage_Y';
% rows2plot=1:size(ManualAnnotation.(Vartoplot)(:,1),1);
% 
% numflies2ann=length(rows2plot);
% numevents=1;
% 
% Filenames=cell(numflies2ann,1);
% Arenas=nan(numflies2ann,1);
% Start_frames=nan(numevents*numflies2ann,1);
% End_frames=nan(numevents*numflies2ann,1);
% 
% lrowcounter=1;
% for lrow=rows2plot
%     Start_frames(lrowcounter)=ManualAnnotation.(Vartoplot)(lrow,1);
%     End_frames(lrowcounter)=ManualAnnotation.(Vartoplot)(lrow,2);
%     display([Vartoplot ' Bout ' num2str(find(ltrace==ManualAnnotation.(Vartoplot)(:,1)))])
%     lfly=ManualAnnotation.(Vartoplot)(lrow,4);
%     Filenames{lrowcounter}=FlyDB(lfly).Filename;
%     Arenas(lrowcounter)=FlyDB(lfly).Arena;
%     
%     range=ltrace-deltaf:ManualAnnotation.(Vartoplot)(lrow,2)+deltaf;
%     lrowcounter=lrowcounter+1;
% end
% Filenames
% Arenas
% Start_frames
% End_frames
% %% Manual annotation
% %%% For each fly, select 1 visit and 1 grooming event inside the four
% %%% periods: [1 - 90000; 90001 - 180000; 180001 - 270000; 270001 - 360000]
% % Annotation_micromovements=struct('Info',cell(params.numflies*12,1),'Feeding',[],'Grooming',[],...
% %     'Resting',[],'Turning',[],'Walking',[],'Stopping',[],'Other',[]);
% 
% % load([Variablesfolder 'Annotation_micromovements_' Exp_num Exp_letter ' 13-Jan-2015.mat'])
% spot_thr=2.2;
% Frames=cell(params.numflies,1);
% for lfly=1:params.numflies
%     lfly
%     tempsubs=zeros(4,8);
%     for lsubs=1:2
%         
%         Temp_Food=zeros(size(Heads_Sm{lfly},1),1);
%         Geometry = FlyDB(lfly).Geometry;
%         spots_idxs=find(Geometry==lsubs);
%         f_spot=FlyDB(lfly).WellPos(spots_idxs,:);
%         
%         for n=1:size(f_spot,1)
%             Diff2fSpot=Heads_Sm{lfly}-...
%                 repmat(f_spot(n,:),...
%                 size(Heads_Sm{lfly},1),1);
%             
%             Dist2fSpot=sqrt(sum(((Diff2fSpot).^2),2)).*params.px2mm;
%             Temp_Food(Dist2fSpot<=spot_thr)=1;%s
%         end
%         
%         F_starts=find(conv(double(Temp_Food(:)~=0),[1 -1])==1);
%         F_ends=find(conv(double(Temp_Food(:)~=0),[1 -1])==-1)-1;
%         
%         if ~isempty(F_starts)
%             temp_Framestoconsider=nan(200,4);
%             framecounter=ones(1,4);
%             for lFbout=1:length(F_starts)
%                 fr_start=F_starts(lFbout);
%                 fr_end=F_ends(lFbout);
%                 
%                 if (fr_end-fr_start)>50
%                     if fr_start<=90000
%                         temp_Framestoconsider(framecounter(1),1)=fr_start;
%                         framecounter(1)=framecounter(1)+1;
%                     elseif (fr_start>90000)&&(fr_start<=180000)
%                         temp_Framestoconsider(framecounter(2),2)=fr_start;
%                         framecounter(2)=framecounter(2)+1;
%                     elseif (fr_start>180000)&&(fr_start<=270000)
%                         temp_Framestoconsider(framecounter(3),3)=fr_start;
%                         framecounter(3)=framecounter(3)+1;
%                     elseif (fr_start>270000)&&(fr_start<=360000)
%                         temp_Framestoconsider(framecounter(4),4)=fr_start;
%                         framecounter(4)=framecounter(4)+1;
%                     end
%                 end
%             end
%             for lcol=1:4
%                 if framecounter(lcol)-1>=4
%                     tempsubs(:,lsubs*4-4+lcol)=temp_Framestoconsider(randperm(framecounter(lcol)-1,4),lcol);
%                 else
%                     tempsubs(1:framecounter(lcol)-1,lsubs*4-4+lcol)=temp_Framestoconsider(1:framecounter(lcol)-1,lcol);
%                 end
%             end
%         else
%             tempsubs(:,lsubs*4-3:lsubs*4)=nan(4,4);
%         end
%         
%         
%     end
%     Frames{lfly}=zeros(5,9);
%     Frames{lfly}(1,:)=[90 180 270 360 0 90 180 270 360];
%     Frames{lfly}(2:5,1:4)=tempsubs(:,1:4);
%     Frames{lfly}(2:5,6:9)=tempsubs(:,5:8);
% end

%% Passing pre-annotation from excel to Matlab array
% from='1';until='20';
% Preannotation_frames=xlsread('E:\Dropbox (Behavior&Metabolism)\Personal\Preannotation.xlsx',...
%     'Sheet1',['A' from ':A' until]);
% [~,Preannotation_labels]=xlsread('E:\Dropbox (Behavior&Metabolism)\Personal\Preannotation.xlsx',...
%     'Sheet1',['B' from ':B' until]);
% Preannotation_flies=xlsread('E:\Dropbox (Behavior&Metabolism)\Personal\Preannotation.xlsx',...
%     'Sheet1',['C' from ':C' until]);
% Preannotation_spots=xlsread('E:\Dropbox (Behavior&Metabolism)\Personal\Preannotation.xlsx',...
%     'Sheet1',['D' from ':D' until]);
% rowtocontinue=find(cell2mat(cellfun(@(x)isempty(x),{Annotation_micromovements(:).Info}','uniformoutput',false)),1,'first');
% 
% for lfly_row= find(~isnan(Preannotation_flies))'
%     counter=lfly_row;
%     Annotation_micromovements(rowtocontinue).Info=nan(1,4);
%     Annotation_micromovements(rowtocontinue).Info(1)=Preannotation_frames(counter);
%     Annotation_micromovements(rowtocontinue).Info(3)=Preannotation_spots(counter);
%     Annotation_micromovements(rowtocontinue).Info(4)=Preannotation_flies(counter);
%     while isempty(strfind(Preannotation_labels{counter},'End'))
%         Annotation_micromovements(rowtocontinue).(Preannotation_labels{counter})=...
%             [Annotation_micromovements(rowtocontinue).(Preannotation_labels{counter});...
%             [Preannotation_frames(counter) Preannotation_frames(counter+1)-1]];
%         counter=counter+1;
%     end
%     Annotation_micromovements(rowtocontinue).Info(2)=Preannotation_frames(counter);
%     rowtocontinue=rowtocontinue+1;
% end
%%
save([Variablesfolder 'Annotation_micromovements_' Exp_num Exp_letter ' 26-Feb-2015.mat'],...
    'Annotation_micromovements','Frames')
save(['Annotation_micromovements_' Exp_num Exp_letter ' 26-Feb-2015.mat'],...
    'Annotation_micromovements','Frames')
c=clock;
display(['Annotation saved ' date ' ' num2str(c(4)) ':' num2str(c(5))])