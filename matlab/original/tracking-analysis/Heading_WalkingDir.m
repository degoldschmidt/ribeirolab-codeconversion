function [Heading,WalkDir,HeadingDiff,WalkingDirDiff] =...
    Heading_WalkingDir(Heads,Tails,Centroids)
%Heading_WalkingDir generates cell arrays with the values for each fly in 
%each entry. All values are in degrees =[-180,180]. Note that the Walking
%direction is obtained from the centroids.
% [ Heading ] = Heading_WalkingDir(Heads,Tails,Centroids,flies_idx)
%
% Inputs:
% Heads, Tails   Cell arrays, each entry is 2-col vector [X Y], of heads
%                   or tails, for each fly. In px. To obtain the heading.

display('-----------Calculating Heading and Walking Direction----------')

Heading=cell(size(Heads,1),1);
WalkDir=cell(size(Heads,1),1);
HeadingDiff=cell(size(Heads,1),1);
WalkingDirDiff=cell(size(Heads,1),1);

lflycounter=1;
for lfly=1:size(Heads,1)
    display(lfly)
%% Heading (º)
        DiffHxTx=Heads{lfly}(:,1)-Tails{lfly}(:,1);
        DiffHyTy=Heads{lfly}(:,2)-Tails{lfly}(:,2);
        
        Heading{lfly}=atand(DiffHyTy./DiffHxTx);
        
        %%% Correction given the quadrant: Transform Heading from [-90º,90º] to
        %%% [0º,360º]
        logicalII_IIIQ=(DiffHxTx<0);
        logicalIVQ=(DiffHxTx>0)&(DiffHyTy<0);
        
        Heading{lfly}(logicalII_IIIQ)=180+Heading{lfly}(logicalII_IIIQ); % Correction for vectors in II and III quandrant
        Heading{lfly}(logicalIVQ)=360+Heading{lfly}(logicalIVQ);  % Correction for vectors in IV quandrant
        Heading{lfly}=Heading{lfly}-floor(Heading{lfly}./360)*360; % Angle in degrees=[0,360]
        Heading{lfly}(Heading{lfly}>180)=Heading{lfly}(Heading{lfly}>180)-360; % Angle in degrees=[-180,180]
                
        %% Walking direction (º)
        frames_diff=diff(Centroids{lfly});
        WalkDir{lfly}=atand(frames_diff(:,2)./frames_diff(:,1));
        %%% Correction for other quadrants and conversion from [0,360] to [-180,180]
        logicalII_IIIQ=(frames_diff(:,1)<0);
        logicalIVQ=(frames_diff(:,1)>0)&(frames_diff(:,2)<0);
        WalkDir{lfly}(logicalII_IIIQ)=180+WalkDir{lfly}(logicalII_IIIQ); % Correction for vectors in II and III quandrant
        WalkDir{lfly}(logicalIVQ)=360+WalkDir{lfly}(logicalIVQ);  % Correction for vectors in IV quandrant
        WalkDir{lfly}=WalkDir{lfly}-floor(WalkDir{lfly}./360)*360; % Angle in degrees=[0,360]
        WalkDir{lfly}(WalkDir{lfly}>180)=WalkDir{lfly}(WalkDir{lfly}>180)-360;
                
        %% Calculating Heading differences/Flips
        HeadingDiff{lfly}=CircleDiff(Heading{lfly}(1:end-1),Heading{lfly}(2:end));
        WalkingDirDiff{lfly}=CircleDiff(WalkDir{lfly}(1:end-1),WalkDir{lfly}(2:end));
        
        lflycounter=lflycounter+1;
end

