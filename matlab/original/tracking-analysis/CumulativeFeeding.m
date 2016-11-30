function output=CumulativeFeeding(ONS2,Dur)


% Dur=310000;
if numel(ONS2)<10
  output(1:Dur)=nan;
else
    ONS2(ONS2>Dur)=[];
    
    dummy=false(1,numel(1:Dur));

dummy(ONS2)=1;
output=cumsum(double(dummy));
end