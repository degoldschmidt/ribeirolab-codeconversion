function [r2]=Rsquare(x,y,p)
%Ycalculate=(p(1)*x)+p(2);

Ymeasure=y;
Ycalculate=(p(1)*x)+p(2);
meanY=mean(Ymeasure);
deltaY2=sum((Ycalculate-Ymeasure).^2);
distanceY2=sum((Ymeasure-meanY).^2);

% distanceY2=(length(Ycalculate)-1)*var(Ycalculate);

r2=1-(deltaY2/distanceY2);
end

