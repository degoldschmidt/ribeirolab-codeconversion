%% 
%problem goes from 32737 to 32744
%frames=32701:32800;
% problem should be from 37 to 44
Binary_OB_test=nan(length(frames),1);
for lframe=frames
        
        if mod(lframe,5000)==0
            display(lframe)
        end
        
        %% ellipse_x_y are [X,Y] describing the ellipse of the fly
        %         ellipse_x_y = calculateEllipse(Cx(lframe),...
        %             Cy(lframe),...
        %             (Median_MjMnAx(lfly,1)+3)/2,...
        %             (Median_MjMnAx(lfly,2)+3)/2, 180-H(lframe),NOP);
        
        %% circle_x_y are [X,Y] describing a circle around the fly
        [X,Y] = pol2cart(linspace(0,2*pi,NOP),ones(1,NOP)*(Median_MjAx/1.5));
        circle_x_y=[X'+Cx(lframe),Y'+Cy(lframe)];
        %% Distance to spots
        for n=7%1:size(f_spot,1)
            Dist2fSpot=sqrt(sum(((circle_x_y-...
                repmat(f_spot(n,:),NOP,1)).^2),2)).*px2mm;
            DistCenter=sqrt(sum((([Cx(lframe),Cy(lframe)]-...
                (f_spot(n,:))).^2),2))*px2mm;
            if (sum(Dist2fSpot<=spot_thr_OB)>=1)||(DistCenter<=spot_thr_OB)
                InSpot_test=spots_idxs(n);
                Binary_OB_test(frames==lframe,1)=1;%frames
            end
        end
end

%%
clf
hold on
hc(2)=plot_tracks_single(FlyDB,Heads_Sm{lfly},lfly,Spots,params,1,...
            Color(1,:),frames,FtSz,1,2*LineW);
        
        plot_tracks_single(FlyDB,Heads_Sm{lfly},lfly,Spots,params,1,...
            'k',frames,FtSz,0,LineW);
        
        plot_tracks_single(FlyDB,Centroids_Sm{lfly},lfly,Spots,params,1,...
            Color(2,:),frames,FtSz,0,2*LineW);
        plot_tracks_single(FlyDB,[Cx,Cy],lfly,Spots,params,1,...
            Color(3,:),frames,FtSz,0,2*LineW);
%         plot(circle_x_y(:,1).*px2mm,circle_x_y(:,2).*px2mm,'-k');