function AxesPositions=axespositionsfun(nrows,ncols,h_dist,v_dist)
%AxesPositions=axespositionsfun(nrows,ncols,h_dist,v_dist)
% Default values are: nrows=5, ncols=2, def_v_dist=0.03; def_h_dist=0.07;
%% See graphical diagram in Notebook4, page 122, 01/Oct/2015
def_v_dist=0.03; def_h_dist=0.07;
if nargin==0, nrows=5;ncols=2;h_dist=def_h_dist;v_dist=def_v_dist;end
if nargin==1, ncols=2;h_dist=def_h_dist;v_dist=def_v_dist;end
if nargin==2, h_dist=def_h_dist;v_dist=def_v_dist;end
if nargin==3, v_dist=def_v_dist;end
%%
%%% Width and height
width=(1-(ncols+3)*h_dist)/(ncols);
height=(1-(nrows+5)*v_dist)/(nrows);%Up and down is 2*v_dist

%%% X Distance: col_n*h_dist+(col_n-1)*width
X=ceil((1:ncols*nrows)/nrows)'.*repmat(h_dist,ncols*nrows,1)+h_dist+(ceil((1:ncols*nrows)/nrows)'-1).*repmat(width,ncols*nrows,1);

%%% Y Distance:
Y=repmat((repmat(3*v_dist,nrows,1)+(nrows-(1:nrows)').*(v_dist+height)),ncols,1);

%%% Axes Positions:
AxesPositions=[X Y repmat(width,ncols*nrows,1) repmat(height,ncols*nrows,1)];
%%    
% close all
% figure('Position',[100 50 1400 930],'Color','w')
% 
% for lplot=1:size(AxesPositions,1)
%     subplot('Position',AxesPositions(lplot,:))
% end
