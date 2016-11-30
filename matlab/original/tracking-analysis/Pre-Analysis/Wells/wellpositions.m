function [wellpos]=wellpositions(LengthInner,DispAngle)
%% [wellpos]=wellpositions(LengthInner,DispAngle) for one arena
if nargin==0,LengthInner=[1.27]*50;DispAngle=0;end
if nargin==1,DispAngle=0;end

wellpos=zeros(19,2);
for arena_side=1%:3

    for well=1:6
        % Wells 1-6 positions
        wellpos(well,2*arena_side-1)=LengthInner(arena_side)*cosd((60*(well-1))+30+DispAngle(arena_side)); % X positions % With 30 degrees rotation counterclock-wise to the one described 13th Dec/2012 in Lab book.
        wellpos(well,2*arena_side)=LengthInner(arena_side)*sind((60*(well-1))+30+DispAngle(arena_side)); % Y positions
        % Wells 7-12 positions
        wellpos(well+6,2*arena_side-1)=2*LengthInner(arena_side)*cosd((15+30*(well-1))+30+DispAngle(arena_side)); % X positions
        wellpos(well+6,2*arena_side)=2*LengthInner(arena_side)*sind((15+30*(well-1))+30+DispAngle(arena_side)); % Y positions
        % Wells 13-18 positions
        wellpos(well+12,2*arena_side-1)=2*LengthInner(arena_side)*cosd((-15-30*(well-1))+30+DispAngle(arena_side)); % X positions
        wellpos(well+12,2*arena_side)=2*LengthInner(arena_side)*sind((-15-30*(well-1))+30+DispAngle(arena_side)); % Y positions
    end

end

