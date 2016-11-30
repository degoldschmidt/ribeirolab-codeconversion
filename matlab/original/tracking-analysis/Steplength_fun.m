function [Steplength,Steplength_X_Y] = Steplength_fun(X_Y)
%Steplength_fun generates a cell array with Steplength in px for a fly in
%each entry
% Steplength = Steplength_fun(X_Y)
% Inputs
% X_Y   Cell array, each entry is 2-col vector [X Y], for each fly.

Steplength=cell(size(X_Y,1),1);
Steplength_X_Y=cell(size(X_Y,1),1);

lflycounter=1;
for lfly=1:size(X_Y,1)
    Steplength_X_Y{lflycounter}=diff(X_Y{lfly});%cols:diffx,diffy. Rows:frames-1.
    Steplength{lflycounter}=sqrt(sum((Steplength_X_Y{lflycounter}).^2,2));%px
    display(lfly)
    lflycounter=lflycounter+1;
end



