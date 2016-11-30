function [Beta] = Beta_fun(Diff2Spots,Heading,lfly)
%% Beta: Angle between Body Orientation and Pointing spot
        Pointing_Spot=atand(Diff2Spots(:,2)./Diff2Spots(:,1));
        %%% Correction for other quadrants and conversion from [0,360] to [-180,180]
        logicalII_IIIQ=(Diff2Spots(:,1)<0);
        logicalIVQ=(Diff2Spots(:,1)>0)&(Diff2Spots(:,2)<0);

        Pointing_Spot(logicalII_IIIQ)=180+Pointing_Spot(logicalII_IIIQ); % Correction for vectors in II and III quandrant
        Pointing_Spot(logicalIVQ)=360+Pointing_Spot(logicalIVQ);  % Correction for vectors in IV quandrant
        Pointing_Spot=Pointing_Spot-floor(Pointing_Spot./360)*360; % Angle in degrees=[0,360]
        Pointing_Spot(Pointing_Spot>180)=Pointing_Spot(Pointing_Spot>180)-360; % Angle in degrees=[-180,180]
        
        Beta=CircleDiff(Heading{lfly},Pointing_Spot); %Angle in degrees=[-180,180]
%         Beta=abs(Beta);%Since it's simmetrical, 
        % it's the same turning left or right. Uncomment to use for 0-180
        % range
end

