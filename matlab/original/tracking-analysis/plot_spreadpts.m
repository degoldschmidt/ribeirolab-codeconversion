function varargout=plot_spreadpts(y,x,colordots,dotsize,jitter)
% PlottingSpreadPoints2(Data_Col_vector,Positions_colvector,colordots,dotsize,jitter)

error(nargchk(0,6,nargin))

if nargin<5 || isempty(jitter)
    jitter=0.3; %larger value means greater amplitude jitter
end

[uX,~,b]=unique(x);

hold on
h=[];
for ii=1:length(uX)
    f=find(b==ii);
    h=[h,Spreaddatapoints(x(f),y(:,f))];
end
% hold off
if nargout==1
    varargout{1}=h;
end

function h=Spreaddatapoints(X,Y)

%The plot colors to use for multiple sets of points on the same x
%location
    cols=jet(length(X)+1)*0.5;
    cols(1,:)=0;
    
    for k=1:length(X)
        thisY=Y(:,k);
        thisY=thisY(~isnan(thisY));    
        thisX=repmat(X(k),1,length(thisY));

    %Plot jittered raw data
        C=cols(k,:);
        J=(rand(size(thisX))-0.5)*jitter;
        h(k).data=plot(thisX+J,...
                       thisY,'o','MarkerSize',dotsize,...
                     'markeredgecolor',[0.4 .4 .4],'markerfacecolor',colordots);  
%                        'color',C,'markerfacecolor',C+(1-C)*0.65);
                   
                       
    end

end
end