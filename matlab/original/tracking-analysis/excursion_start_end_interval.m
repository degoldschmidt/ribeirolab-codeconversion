function Excurstemp3=excursion_start_end_interval(Excurstemp2,range)
%%% This function checks if the excursion finishes before or after the end
%%% of the interval. If it ends after, it creates a new vector in which the
%%% duration of the excursion is truncated: Excurstemp3


Excurboutend1=find(Excurstemp2(:,2)<range(end),1,'last');
if ~isempty(Excurboutend1)
    if (size(Excurstemp2,1)>=Excurboutend1+1)&&(Excurstemp2(Excurboutend1+1,1)<range(end))
        %% If the last excursion is interrupted, last frame analysed is range end    
        Excurstemp3=Excurstemp2(1:Excurboutend1+1,:);
        Excurstemp3(end,2)=range(end);
    else
        %% If the last excursion is fully inside the interval  
        Excurstemp3=Excurstemp2(1:Excurboutend1,:);
    end
else
    %% There is only one interrupted excursion inside the interval
    Excurstemp3=Excurstemp2(1,:);
    Excurstemp3(end,2)=range(end);
end