function [Latest_file]=getlatestfile(folder,name)
%% Latest_file=getlatestfile(folder,name)
% Get latest file in folder 
% Output: Full filename (str)
D=dir(strcat(folder,name));
S1=[D(:).datenum];
[~,Sidx]=sort(S1,2,'descend');
S={D(Sidx).name}';
Latest_file=S{1};