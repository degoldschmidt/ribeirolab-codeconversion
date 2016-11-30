function [Etho_H_new, EthoH_colors_new,EthoH_Colors_Labels] = HeadEtho2New(Etho_H,Binary_Break,merged)
%% Transforming Etho_Speed in a matrix & merging slow and fast micromovements when merged==1
Etho_H_new=Etho_H;
Color=Colors(3);

if merged==1
        Etho_H_new(Etho_H_new==3)=2;%Fast into micro
        Etho_H_new(Etho_H_new==4)=3;% Slow walk into merged walk
        Etho_H_new(Etho_H_new==5)=3;% Walk into merged walk
        Etho_H_new(Etho_H_new==6)=4;% Turn into new turn
        Etho_H_new(Etho_H_new==7)=5;% Jump into new jump
        Etho_H_new(Etho_H_new==9)=6;% Yeast Head micromov
        Etho_H_new(Etho_H_new==10)=7;% Yeast Head micromov
        Etho_H_new(logical(Binary_Break'))=8;% Break
        
     EthoH_colors_new=[...
    [0.6 0.6 0.6]*255;...%1 - Gray (Resting)
    Color(1,:)*255;...%2&3 --> 2 - Purple (Micromovement)
    Color(3,:)*255;...%4&5 --> 3 - Light Blue (Walking)
    Color(2,:)*255;...%6 --> 4 - Green (Turn)
    255 0 0;......%7 --> 5 - Red (Jump)
    238 96 8;...%9 --> 6 - Orange(Yeast head slow&Fast micromovements)
    0 0 0;...%10 --> 7- Black (Sucrose head slow&Fast micromovements)
    5 16 241]/255; % new --> 8 - Dark Blue (Breaks=Excursions)
    
%     Etho_Colors_Labels={'Sh<0.05 mm/s (Rest)','Sh<2 mm/s (Micromov)',...
%     'Sc<2 mm/s (Walk)','Sc<4 mm/s & Ang.speed>3º/fr (Sharp Turn)','Sc>30 mm/s(Jump)'};
    EthoH_Colors_Labels={'Rest','Micromov',...
        'Walk','Sharp Turn','Jump','HeadY','HeadS','Excursions'};
    
else
    EthoH_colors_new=[...
    [0.6 0.6 0.6]*255;...%1 - Gray (Resting)
    Color(1,:)*255;...%2 - Purple (slow micromovement)
    204 140 206;...%3 - Light Purple (fast-micromovement)
    124 143 222;...%4 -  Blueish violet (Slow walk)
    Color(3,:)*255;...%5 - Light Blue (Walking)
    Color(2,:)*255;...%6 - Green (Turn)
    255 0 0]/255;...%7 - Red (Jump)
    EthoH_Colors_Labels={'Sh<0.05 mm/s (Rest)','Sh<1 mm/s (Slow Micromov)','Sh<2 mm/s (Fast Micromov)',...
    'Sc<4 mm/s (Slow walk)',...
    'Sc>4 mm/s (Walk)','Sc<4 mm/s & Ang.speed>3º/fr (Sharp Turn)','Sc>30 mm/s(Jump)'};
end



