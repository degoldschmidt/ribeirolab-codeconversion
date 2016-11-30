%%
%%% Created by Veronica Corrales, March 2014.
TrackingData_dir=['C:\Users\Vero\Documents\Tracking Data\Experiments\'];
 
HeadStart=xlsread(Vid_info_dir,'Tracking',['R' num2str(from) ':R' num2str(until)]);
MATLAB2Bonsai=xlsread(Vid_info_dir,'Tracking',['Y' num2str(from) ':Y' num2str(until)]);
% FirstHead=cell(size(Allfilenames,1),1);
% FirstTail=cell(size(Allfilenames,1),1);

%% Obtaining Heads in the first Frame
% display('Obtaining Heads from first frame')
% for lfile=Movies_idx
%     %     filename=Files{lfile};%'0007C03R02Cam01P0WT-CantonS.avi'
%     filename=Allfilenames{lfile}
%     if HeadStart(lfile)==1
%         for arenaside=1:3
%             arenaside
%             load(['C:\Users\Vero\Documents\Tracking Data\Experiments\AlexTracking\TotaltrakingNew-'...
%                 filename(1:end-4) '-' sidelabel{arenaside} '.mat'])
%             %% Defining xCrop
%             switch arenaside
%                 case 1
%                     if iscell(FlytracksNewL)
%                         Flytracks=cell2mat(FlytracksNewL);
%                     else
%                         Flytracks=FlytracksNewL;
%                     end
%                     xCrop=1;
%                 case 2
%                     if iscell(FlytracksNewC)
%                         Flytracks=cell2mat(FlytracksNewC);
%                     else
%                         Flytracks=FlytracksNewC;
%                     end
%                     xCrop=param.frameWL;
%                 case 3
%                     if iscell(FlytracksNewR)
%                         Flytracks=cell2mat(FlytracksNewR);
%                     else
%                         Flytracks=FlytracksNewR;
%                     end
%                     xCrop=param.frameWC;
%             end
%             FirstHead{lfile}(arenaside,:)=Flytracks(1,3:4)+[xCrop 0];
%             FirstTail{lfile}(arenaside,:)=Flytracks(1,5:6)+[xCrop 0];
%         end
%     else
%         %% Obtain first Head and Tail by clicking
%         MovieObj=VideoReader([videoPath filename]);
%         Rawimage=read(MovieObj,1);
%         display('Head-tail manual annotation:')
%         display({'6 Clicks: 2 for Left, 2 for Center, 2 for Right Arena';
%             'First, click close to head. Second, close to tail'})
%         close all
%         % Show current image frame to classify
%         figure,
%         imshow(Rawimage)
%         [Hxl,Hyl]=ginput(1);
%         [Txl,Tyl]=ginput(1);
%         [Hxc,Hyc]=ginput(1);
%         [Txc,Tyc]=ginput(1);
%         [Hxr,Hyr]=ginput(1);
%         [Txr,Tyr]=ginput(1);
% 
%         close all
%         FirstHead{lfile}=[Hxl,Hyl;Hxc,Hyc;Hxr,Hyr];
%         FirstTail{lfile}=[Txl,Tyl;Txc,Tyc;Txr,Tyr];
%         imshow(Rawimage)
%         hold on
%         plot(FirstHead{lfile}(:,1),FirstHead{lfile}(:,2),'oc','MarkerFaceColor','c','MarkerSize',3)
%         pause(1)
%         close all
% 
%     end
% end
%% Loading First-Head and -Tail struct
load(['C:\Users\Vero\Documents\Analysis Data\Experiment 0004\Variables\FirstHeads&Tails',...
    Exp_num Exp_letter '.mat'],'FirstHead','FirstTail')
%% Calculating Head positions using distance rule
for lfile=Movies_idx%find(Toprocess==1)'%1:length(Files)
    %     filename=Files{lfile};%'0007C03R02Cam01P0WT-CantonS.avi'
    filename=Allfilenames{lfile}
    
        %% Getting MATLAB tracking data
        for arenaside=1:3
            display(['----Arena ' num2str(arenaside) '----'])
            load([TrackingData_dir 'Totaltraking-'...
                filename(1:end-4) '-' sidelabel{arenaside} '.mat']);
            
            clear Bodytracks FlytracksNew
            switch arenaside
                case 1
                    Bodytracks=BodytracksL;
                case 2
                    Bodytracks=BodytracksC;
                case 3
                    Bodytracks=BodytracksR;
            end
                    
            %FlytracksNewL=[xc yc or MajAx MinAx A];
            FlytracksNew=nan(length(Bodytracks),6);
            for lframe=1:length(Bodytracks)
                Areas=[Bodytracks{lframe}.Area];
                bigobject=find(Areas==max(Areas));
                % and set a threshold in case the animal disappears, not to track a small dirt
                min_A_thr=20; % NOTE: HEURISTIC VALUE (we do not need it if the fly does not ever leave the arena)
                if Areas(bigobject)>min_A_thr
                    FlytracksNew(lframe,:)=[Bodytracks{lframe}(bigobject).Centroid,...
                        Bodytracks{lframe}(bigobject).Orientation,...
                        Bodytracks{lframe}(bigobject).MajorAxisLength,...
                        nan,...
                        Bodytracks{lframe}(bigobject).Area];
                else
                    FlytracksNew(lframe,:)=nan(1,6);
                end
            end
            
            switch arenaside
                case 1
                    FlytracksNewL=FlytracksNew;
                case 2
                    FlytracksNewC=FlytracksNew;
                case 3
                    FlytracksNewR=FlytracksNew;
            end
        end
        
        TransfMatrix1=[-1 -1 0 0 0 0];
        TransfMatrix2=[1 1 -pi()/180 1 1 1];
        
        Cmat=[FlytracksNewL FlytracksNewC FlytracksNewR]+repmat(TransfMatrix1,size(FlytracksNewL,1),3);%[xc yc or MajAx MinAx A];
        Cmat=Cmat.*repmat(TransfMatrix2,size(FlytracksNewL,1),3);%[xc yc or MajAx MinAx A];
        
        
        clear FlytracksNewL FlytracksNewC FlytracksNewR
    

    Finalframe=size(Cmat,1);
    DB(3).filename=filename;

    for arenaside=1:3
        display(['arenaside:' num2str(arenaside)])
        MajAx=nan(size(Cmat,1),4);
        %% Defining xCrop
        switch arenaside
            case 1
                FlytracksB=Cmat(:,1:6);
                xCrop=1;
            case 2
                FlytracksB=Cmat(:,7:12);
                xCrop=456;
            case 3
                FlytracksB=Cmat(:,13:18);
                xCrop=932;
        end

        %% Creating DataBase with image coordinates
        DB(arenaside).cBon=FlytracksB(1:Finalframe,1:2)+repmat([xCrop+1 1],Finalframe,1);
        DB(arenaside).hBon=[FirstHead{lfile}(arenaside,:); nan(size(DB(arenaside).cBon,1)-1,2)];
        DB(arenaside).tBon=[FirstTail{lfile}(arenaside,:); nan(size(DB(arenaside).cBon,1)-1,2)];

        %% Obtaining Head & Tail from Bonsai parameters
        %%% MajAx =[X1,Y1,X2,Y2], containing the 2 extreme
        %%% points of the Major Axis of the Blob
        BodyLength=FlytracksB(1:Finalframe,4);
        Orientation=FlytracksB(1:Finalframe,3);
        MajAx(:,1)=DB(arenaside).cBon(:,1)+BodyLength/2.*cos(Orientation);
        MajAx(:,2)=DB(arenaside).cBon(:,2)+BodyLength/2.*sin(Orientation);
        MajAx(:,3)=DB(arenaside).cBon(:,1)-BodyLength/2.*cos(Orientation);
        MajAx(:,4)=DB(arenaside).cBon(:,2)-BodyLength/2.*sin(Orientation);

        %% Applying distance rule of both Head and Tail
        for lframe=2:size(DB(arenaside).cBon,1)
            %%% if distance to Point A (Old Head=Flytracks(lframe,3:4)) is
            %%% closer than to point B, then point A is head
            PtA=MajAx(lframe,1:2);
            PtB=MajAx(lframe,3:4);
            distvector=[pdist2(PtA,DB(arenaside).hBon(lframe-1,:));...dist(h2,h1)
                pdist2(PtB,DB(arenaside).tBon(lframe-1,:));...dist(t2,t1)
                pdist2(PtA,DB(arenaside).tBon(lframe-1,:));...dist(h2,t1)
                pdist2(PtB,DB(arenaside).hBon(lframe-1,:))];...dist(t2,h1)
                [~,maxidx]= max(distvector);
            if maxidx>2%Meaning: the biggest difference occurs when you switch
                DB(arenaside).hBon(lframe,:)=PtA;
                DB(arenaside).tBon(lframe,:)=PtB;
            else
                DB(arenaside).hBon(lframe,:)=PtB;
                DB(arenaside).tBon(lframe,:)=PtA;
            end
            if mod(lframe,5000)==0
                display(['Frame: ' num2str(lframe) '; '...
                    num2str(ceil(lframe/size(DB(arenaside).cBon,1)*100)) '% Completed'])
            end
        end
        %% Correcting when fly is a blurr (no blob was found)
        DB(arenaside).cBon((DB(arenaside).cBon(:,2)==1),:)=nan;
        DB(arenaside).hBon((DB(arenaside).cBon(:,2)==1),:)=nan;
        DB(arenaside).tBon((DB(arenaside).cBon(:,2)==1),:)=nan;
    end

    save([Heads_SteplengthDir 'DB-Heads_raw ' filename(1:end-4) '.mat'],'DB')
end
%% Calculation and plotting of Steplength and Flips
% Movies_idx=find(Toprocess==1)';
typeofheads='Heads_raw';
Steplength_Jumps
%% Final Correction to Flips %WARNING: UPDATE HEADING AND WALKING DIR
for lfile=Movies_idx%1:length(Files)
%     filename='0003A01R02Cam03P0WT-CantonS.avi';
    filename=Allfilenames{lfile}
    load([Heads_SteplengthDir 'DB-Heads ' filename(1:end-4) '.mat'],'DB')
    
%     DB=rmfield(DB,'NotenoughDistance');
    for arenaside=1:3
        arenaside
        %%% Calculate angle difference between heading and walking
        %%% direction:
        HeadingvsWalk=CircleDiff(DB(arenaside).Heading(1:end-1),DB(arenaside).WalkDir);
        %%% 1) Keep heading until there is a jump:
        %%% Detecting jump "bouts"
        AvWalkingSpeed=nanmean(DB(arenaside).Vel_Filt(DB(arenaside).Vel_Filt>StopVel));
        log_jump=(DB(arenaside).Steplength>(4*AvWalkingSpeed));%&(DB(arenaside).Steplength<=(5*AvWalkingSpeed));%DB(arenaside).Vel_Filt>4*AvWalkingSpeed;%
        InOut=conv(double(log_jump),[1 -1]);%Notebook1 pg148
        JumpStart=find(InOut==1);
        JumpEnd=find(InOut==-1);
        
        %%% 2) Detect 40 px (~2 Bodylengths) distance covered under the
        %%% jump threshold moving forward
        %%
        CorrectedFrames=[];
        Uncorrected=nan(300,2);%Pre-allocating space. 300 is an excessively large number.
        ForwardWalkAngle=90;%Degrees
        ForwardWalkThresh=40;%px
        PercThr=0.75;%Threshold for walking forward most of the time
        lframecounter=1;
        Uncorr_counter=1;
        
        %% Correct segment before first jump
        if ~isempty(JumpStart), endfirstsegment=JumpStart(1)-1;
        else endfirstsegment=size(DB(arenaside).Steplength,1)-1;end
        WindowFrames=1:endfirstsegment;
        
        AllDistCovered_temp=DB(arenaside).Steplength(WindowFrames);

        ForwardWalk_log=(HeadingvsWalk(WindowFrames)>=-ForwardWalkAngle)&...
            (HeadingvsWalk(WindowFrames)<=ForwardWalkAngle);
        BackwardWalk_log=(HeadingvsWalk(WindowFrames)<-ForwardWalkAngle)|...
            (HeadingvsWalk(WindowFrames)>ForwardWalkAngle);
        ForwardDPerc=nansum(AllDistCovered_temp(ForwardWalk_log)/framerate/px2mm)/...
            (nansum(AllDistCovered_temp(ForwardWalk_log)/framerate/px2mm)+nansum(AllDistCovered_temp(BackwardWalk_log)/framerate/px2mm));
        if ForwardDPerc<0.5 % If there is a higher percentage of 
            % backwards walk all this distance, flip
            % head and propagate this direction until last jump and next jump
            if ~isempty(JumpStart), endfirstsegment=JumpEnd(1);
        else endfirstsegment=size(DB(arenaside).Steplength,1);end
            OldHs=DB(arenaside).hBon(1:endfirstsegment,:);% Old Heads within jumps
            OldTs=DB(arenaside).tBon(1:endfirstsegment,:);% Old Tails within jumps
            DB(arenaside).hBon(1:endfirstsegment,:)=OldTs;
            DB(arenaside).tBon(1:endfirstsegment,:)=OldHs;
            display(['FIXED HEADING _ FIRST SEGMENT ' num2str(1) ' to ' num2str(size(DB(arenaside).Steplength,1))])
        end
        
        %% Correct segments after first jump
        if ~isempty(JumpStart)
            for lframe=JumpEnd(1:end-1)'
                %%% a) Slide a window to find fly walking forward for 2
                %%% BodyLengths
                lframe
                if isempty(lframe),break,end
                CurrentFrame=lframe;
                for lstep=lframe:JumpStart(lframecounter+1)
                    lstep
                    DistCovered=nansum(DB(arenaside).Steplength(lstep:CurrentFrame)/framerate/px2mm);
                    while DistCovered<ForwardWalkThresh
                        DistCovered=nansum(DB(arenaside).Steplength(lstep:CurrentFrame)/framerate/px2mm);
                        CurrentFrame=CurrentFrame+1;%Step of sliding window=1
                        
                        %%% Guarantee that speed is below jumping threshold by
                        %%% breaking the loop when next jump is reached
                        if CurrentFrame==JumpStart(lframecounter+1)
                            display('REACHED NEXT JUMP')
                            %%% Do this when we reached the next jump without covering
                            %%% a 40 px distance: If the fly covered more
                            %%% than 60 px in all segment and 60% of the
                            %%% distance was forward[-80º,80º], then, correct segment
                            WindowFrames=lframe:JumpStart(lframecounter+1)-1;
                            AllDistCovered_temp=DB(arenaside).Steplength(WindowFrames);
                            
                            ForwardWalk_log=(HeadingvsWalk(WindowFrames)>-ForwardWalkAngle)&...
                                (HeadingvsWalk(WindowFrames)<ForwardWalkAngle);
                            BackwardWalk_log=(HeadingvsWalk(WindowFrames)<=-ForwardWalkAngle)|...
                                (HeadingvsWalk(WindowFrames)>=ForwardWalkAngle);
                            ForwardDPerc=nansum(AllDistCovered_temp(ForwardWalk_log)/framerate/px2mm)/...
                                (nansum(AllDistCovered_temp(ForwardWalk_log)/framerate/px2mm)+nansum(AllDistCovered_temp(BackwardWalk_log)/framerate/px2mm));
                            if ForwardDPerc<0.5 % If there is a higher percentage of 
                                % backwards walk all this distance, flip
                                % head and propagate this direction until last jump and next jump
                                OldHs=DB(arenaside).hBon(lframe+1:JumpEnd(lframecounter+1),:);% Old Heads within jumps, including next jump
                                OldTs=DB(arenaside).tBon(lframe+1:JumpEnd(lframecounter+1),:);% Old Tails within jumps
                                DB(arenaside).hBon(lframe+1:JumpEnd(lframecounter+1),:)=OldTs;
                                DB(arenaside).tBon(lframe+1:JumpEnd(lframecounter+1),:)=OldHs;
                                display(['FIXED HEADING _ UNCORRECTED ' num2str(lframe) ' to ' num2str(JumpStart(lframecounter+1)-1)])
                                

                            end
                                
                            
                            break
                            
                            
                        end
                        
                    end
                    
                    
                    if CurrentFrame==JumpStart(lframecounter+1)
                        Uncorrected(Uncorr_counter,:)=[lframe CurrentFrame-1];
                        Uncorr_counter=Uncorr_counter+1;
                        ReachNextJump=1; break %stop sliding window
                    else
                        display(['TEST WINDOW, dist:' num2str(DistCovered) 'fr:' num2str(CurrentFrame-1)])
                        %%%% When a distance of 45 px has been reached:
                        %%%% b) Count how many of those frames are moving forward,
                        %%%% meaning Walking Direction and Heading differ less than
                        %%%% 80º. Note:remember there are nans when fly stops
                        WindowFrames=lstep:(CurrentFrame-1);
                        DistWindow_temp=DB(arenaside).Steplength(WindowFrames);
                        ForwardWalk_log=(HeadingvsWalk(WindowFrames)>=-80)&(HeadingvsWalk(WindowFrames)<=80);
                        BackwardWalk_log=(HeadingvsWalk(WindowFrames)<-80)|(HeadingvsWalk(WindowFrames)>80);
                        
                        %%%% c) If PercThr of them are, then establish new heading and
                        %%%% propagate backwards, if not, continue sliding the window
                        ForwardDPerc=nansum(DistWindow_temp(ForwardWalk_log)/framerate/px2mm)/...
                            (nansum(DistWindow_temp(ForwardWalk_log)/framerate/px2mm)+nansum(DistWindow_temp(BackwardWalk_log)/framerate/px2mm));
                        
                        %                         ForwardPerc=sum(ForwardWalk_log)/(sum(ForwardWalk_log)+sum(BackwardWalk_log));
                        display(['Forward: ' num2str(ForwardDPerc*100) '%'])
                        if ForwardDPerc>=PercThr% If they are mostly walking forward
                            % Then do nothing, because heads are correct and no need
                            % to keep sliding the window
                            break
                            
                        elseif (1-ForwardDPerc)>=PercThr % If they walk backwards all this distance
                            % Flip head and propagate this direction until last jump and next jump
                            OldHs=DB(arenaside).hBon(lframe+1:JumpEnd(lframecounter+1),:);% Old Heads within jumps
                            OldTs=DB(arenaside).tBon(lframe+1:JumpEnd(lframecounter+1),:);% Old Tails within jumps
                            DB(arenaside).hBon(lframe+1:JumpEnd(lframecounter+1),:)=OldTs;
                            DB(arenaside).tBon(lframe+1:JumpEnd(lframecounter+1),:)=OldHs;
                            %                     else (ForwardPerc<PercThr)&&(ForwardPerc>(1-PercThr)) %If none of previous
                            %                         % Continue sliding the window
                            display(['FIXED HEADING ' num2str(lframe) ' to ' num2str(JumpStart(lframecounter+1)-1)])
%                             CorrectedFrames=[CorrectedFrames;lframe];
                            break
                        end
                    end
                end
                lframecounter=lframecounter+1;
                
            end
            %% Correct segment after last jump
            for lframe=JumpEnd(end)
                display('LAST JUMP')
                %%% a) Slide a window to find fly walking forward for 2
                %%% BodyLengths
                CurrentFrame=lframe;
                for lstep=lframe:size(DB(arenaside).Steplength,1)
                    lstep
                    DistCovered=nansum(DB(arenaside).Steplength(lstep:CurrentFrame)/framerate/px2mm)
                    while DistCovered<ForwardWalkThresh
                        DistCovered=nansum(DB(arenaside).Steplength(lstep:CurrentFrame)/framerate/px2mm);
                        CurrentFrame=CurrentFrame+1;%Step of sliding window=1
                        
                        %%% Guarantee that speed is below jumping threshold by
                        %%% breaking the loop when next jump is reached
                        if CurrentFrame==size(DB(arenaside).Steplength,1)
                            display('REACHED END')
                            %%% Do this when we reached the next jump without covering
                            %%% a 40 px distance: If the fly covered more
                            %%% than 60 px in all segment and 60% of the
                            %%% distance was forward[-80º,80º], then, correct segment
                            WindowFrames=lframe:size(DB(arenaside).Steplength,1);
                            AllDistCovered_temp=DB(arenaside).Steplength(WindowFrames);
                            
                            ForwardWalk_log=(HeadingvsWalk(WindowFrames)>=-ForwardWalkAngle)&...
                                (HeadingvsWalk(WindowFrames)<=ForwardWalkAngle);
                            BackwardWalk_log=(HeadingvsWalk(WindowFrames)<-ForwardWalkAngle)|...
                                (HeadingvsWalk(WindowFrames)>ForwardWalkAngle);
                            ForwardDPerc=nansum(AllDistCovered_temp(ForwardWalk_log)/framerate/px2mm)/...
                                (nansum(AllDistCovered_temp(ForwardWalk_log)/framerate/px2mm)+nansum(AllDistCovered_temp(BackwardWalk_log)/framerate/px2mm));
                            if ForwardDPerc<0.5 % If there is a higher percentage of 
                                % backwards walk all this distance, flip
                                % head and propagate this direction until last jump and next jump
                                OldHs=DB(arenaside).hBon(lframe+1:size(DB(arenaside).Steplength,1),:);% Old Heads within jumps
                                OldTs=DB(arenaside).tBon(lframe+1:size(DB(arenaside).Steplength,1),:);% Old Tails within jumps
                                DB(arenaside).hBon(lframe+1:size(DB(arenaside).Steplength,1),:)=OldTs;
                                DB(arenaside).tBon(lframe+1:size(DB(arenaside).Steplength,1),:)=OldHs;
                                display(['FIXED HEADING _ UNCORRECTED ' num2str(lframe) ' to ' num2str(size(DB(arenaside).Steplength,1))])


                            end
                                
                            
                            break
                            
                        end
                        
                    end
                    
                    
                    if CurrentFrame==size(DB(arenaside).Steplength,1)
                        Uncorrected(Uncorr_counter,:)=[lframe CurrentFrame-1];
                        Uncorr_counter=Uncorr_counter+1;
                        ReachNextJump=1; break %stop sliding window
                    else
                        display(['TEST WINDOW, dist:' num2str(DistCovered) ' fr: ' num2str(CurrentFrame-1)])
                        %%%% When a distance of 45 px has been reached:
                        %%%% b) Count how many of those frames are moving forward,
                        %%%% meaning Walking Direction and Heading differ less than
                        %%%% 80º. Note:remember there are nans when fly stops
                        WindowFrames=lstep:(CurrentFrame-1);
                        DistWindow_temp=DB(arenaside).Steplength(WindowFrames);
                        ForwardWalk_log=(HeadingvsWalk(WindowFrames)>=-80)&(HeadingvsWalk(WindowFrames)<=80);
                        BackwardWalk_log=(HeadingvsWalk(WindowFrames)<-80)|(HeadingvsWalk(WindowFrames)>80);
                        
                        %%%% c) If PercThr of them are, then establish new heading and
                        %%%% propagate backwards, if not, continue sliding the window
                        ForwardDPerc=nansum(DistWindow_temp(ForwardWalk_log)/framerate/px2mm)/...
                            (nansum(DistWindow_temp(ForwardWalk_log)/framerate/px2mm)+nansum(DistWindow_temp(BackwardWalk_log)/framerate/px2mm));
                        
                        %                         ForwardPerc=sum(ForwardWalk_log)/(sum(ForwardWalk_log)+sum(BackwardWalk_log));
                        display(['Forward: ' num2str(ForwardDPerc*100) '%'])
                        if ForwardDPerc>=PercThr% If they are mostly walking forward
                            % Then do nothing, because heads are correct and no need
                            % to keep sliding the window
                            break
                            
                        elseif (1-ForwardDPerc)>=PercThr % If they walk backwards all this distance
                            % Flip head and propagate this direction until last jump and next jump
                            OldHs=DB(arenaside).hBon(lframe+1:size(DB(arenaside).Steplength,1),:);% Old Heads within jumps
                            OldTs=DB(arenaside).tBon(lframe+1:size(DB(arenaside).Steplength,1),:);% Old Tails within jumps
                            DB(arenaside).hBon(lframe+1:size(DB(arenaside).Steplength,1),:)=OldTs;
                            DB(arenaside).tBon(lframe+1:size(DB(arenaside).Steplength,1),:)=OldHs;
                            %                     else (ForwardPerc<PercThr)&&(ForwardPerc>(1-PercThr)) %If none of previous
                            %                         % Continue sliding the window
                            display(['FIXED HEADING ' num2str(lframe) ' to ' num2str(size(DB(arenaside).Steplength,1)-1)])
                            CorrectedFrames=[CorrectedFrames;lframe];
                            break
                        end
                    end
                end
                
                
            end
        end
        totalnumevents=find(sum(isnan(Uncorrected),2)==2,1,'first')-1;
        DB(arenaside).Uncorrected=Uncorrected(1:totalnumevents,:);
        DB(arenaside).CorrectedFrames=CorrectedFrames;
        
    end
    save([Heads_SteplengthDir 'DB-Heads ' filename(1:end-4) '.mat'],'DB')
end

typeofheads='Heads';
Steplength_Jumps
%% Quality control
% Largejump_thr=40;
ForwardWalkThresh=40;%px
Problem_flies= [7, 9, 15, 16, 17, 20, 48, 69, 101, 108, 112, 113, 114, 116, 144];%flycounter for All EXP3A(80to
% LargeJumps_errors(Allfilenames,Movies_idx,videoPath,Heads_SteplengthDir,Largejump_thr);
% [nofnotcorrected,DistCovered,AvSpeed]=UncorrectedHeading(Allfilenames,...
%     Movies_idx,Heads_SteplengthDir,StopVel,ForwardWalkThresh);
