function [Etho_Speed_new, Etho_colors_new,Etho_Colors_Labels] = Etho_Speed2New(maxFrame,Etho_Speed,merged)
%% Transforming Etho_Speed in a matrix & merging slow and fast micromovements when merged==1
Etho_Speed_new=nan(length(Etho_Speed),maxFrame);
Color=Colors(3);
for lfly=1:length(Etho_Speed)
    lfly
    Etho_Speed_new(lfly,:)=Etho_Speed{lfly}(1:maxFrame);
end
if merged==1
        Etho_Speed_new(Etho_Speed_new==3)=2;%Fast into micro
        Etho_Speed_new(Etho_Speed_new==4)=3;% Slow walk into merged walk
        Etho_Speed_new(Etho_Speed_new==5)=3;% Walk into merged walk
        Etho_Speed_new(Etho_Speed_new==6)=4;% Turn into new turn
        Etho_Speed_new(Etho_Speed_new==7)=5;% Jump into new jump
        
     Etho_colors_new=[...
    [.8 .8 .8]*255;...%1 - Gray (Resting)[0.6 0.6 0.6]
    204 121 167;...%2&3 --> 2 - Fucsia (Micromovement)243 7 198
    Color(3,:)*255;...%4&5 --> 3 - Light Blue (Walking)86 180 233
    Color(2,:)*255;...%6 --> 4 - Green (Turn)0 158 115
    0 114 178]/255;...%7 --> 5 - Blue (Jump)
    
%     Etho_Colors_Labels={'Sh<0.05 mm/s (Rest)','Sh<2 mm/s (Micromov)',...
%     'Sc<2 mm/s (Walk)','Sc<4 mm/s & Ang.speed>3º/fr (Sharp Turn)','Sc>30 mm/s(Jump)'};
    Etho_Colors_Labels={'Rest','Micromov',...
        'Walk','Sharp Turn','Jump'};
    
else
    Etho_colors_new=[...
    [0.6 0.6 0.6]*255;...%1 - Gray (Resting)
    Color(1,:)*255;...%2 - Purple (slow micromovement)
    204 140 206;...%3 - Light Purple (fast-micromovement)
    124 143 222;...%4 -  Blueish violet (Slow walk)
    Color(3,:)*255;...%5 - Light Blue (Walking)
    Color(2,:)*255;...%6 - Green (Turn)
    255 0 0]/255;...%7 - Red (Jump)
    Etho_Colors_Labels={'Sh<0.05 mm/s (Rest)','Sh<1 mm/s (Slow Micromov)','Sh<2 mm/s (Fast Micromov)',...
    'Sc<4 mm/s (Slow walk)',...
    'Sc>4 mm/s (Walk)','Sc<4 mm/s & Ang.speed>3º/fr (Sharp Turn)','Sc>30 mm/s(Jump)'};
end



