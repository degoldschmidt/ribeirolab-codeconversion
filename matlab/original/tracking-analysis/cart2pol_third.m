function [Th_Rho3] =cart2pol_third(X_Y,flies_idx)
% Cart2PolFly uses X,Y coordinates in FlyDB and generates a cell array with
% polar coordinates, theta(degrees) and radious(mm).
%
%  [Th_Rho3] = =cart2pol_third(X_Y,flies_idx,params)
%
%   Inputs:
%   X_Y         cell array in which each element is a matrix of 2
%               columns [X,Y] of each fly
%   
%   Outputs:
%   Th_Rho3     cell array in which each element is a matrix of 2
%               columns, theta(degrees) and radius(px), correspondent
%               to one individual fly.

Th_Rho3=cell(length(flies_idx),1); %Cell array with Centroids in Polar coordinates

for lfly=flies_idx
    display(lfly)
    
    [Theta,Rho]=cart2pol(X_Y{lfly}(:,1),...
        X_Y{lfly}(:,2)); % [Theta=radians, Rho= radious in px]
    Theta=Theta/pi*180;% degrees
    
    %%% Transforming angles from [120º,240º) into [0º,120º)
    Theta(Theta>=120)=Theta(Theta>=120)-120;
    Theta(Theta<=-120)=Theta(Theta<=-120)+240;
    
    %%% Transforming angles from [-120º,0º) into [0º,120º)
    Theta((Theta<0)&(Theta>-120))=Theta((Theta<0)&(Theta>-120))+120;
    
    Th_Rho3{lfly}=[Theta,Rho];%Theta = [0º,120º], Rho=px.
    
end



