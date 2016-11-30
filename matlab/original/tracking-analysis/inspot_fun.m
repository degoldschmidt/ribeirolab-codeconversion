function [InSpot]=inspot_fun(FlyDB,Heads_Sm,flies_idx,params)

spot_thr=4.6;%2.2; %mm
px2mm=params.px2mm;

InSpot=zeros(params.MinimalDuration,params.numflies);

for lfly=flies_idx
    display(lfly)
    
    spots_idxs=1:18;%find(Geometry==lsubs);
    Spots_x=FlyDB(lfly).WellPos(spots_idxs,1);
    Spots_y=FlyDB(lfly).WellPos(spots_idxs,2);
        
    Hx=Heads_Sm{lfly}(:,1);
    Hy=Heads_Sm{lfly}(:,2);
    
    parfor lframe=1:params.MinimalDuration
        
        if mod(lframe,5000)==0
            display(lframe)
        end
        
        %% Distance to spots
        for n=1:length(spots_idxs)
            Dist2Spot=sqrt(sum((([Hx(lframe),Hy(lframe)]-[Spots_x(n),Spots_y(n)]).^2),2))*px2mm;
            if (Dist2Spot<=spot_thr)
                InSpot(lframe,lfly)=spots_idxs(n);
            end
        end
    end
    
    
end
