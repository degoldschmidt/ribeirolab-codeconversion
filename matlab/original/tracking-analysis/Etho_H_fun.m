function [Etho_H] =Etho_H_fun(CumTimeH,Etho_Speed,maxframe)
% [Etho_AB,Etho_H] =Etho_AB_H_fun(CumTime,Etho_Speed,Binary_AB)
% Etho_AB is an overlap between Etho_Speed and Binary_AB
% Etho_H is an overlap between Etho_Speed and CumTimeH
% % % Etho_Colors=[...
% % %         [0.6 0.6 0.6]*255;...%1 - Gray (Resting)
% % %         Color(1,:)*255;...%2 - Purple (slow micromovement)
% % %         204 140 206;...%3 - Light Purple (fast-micromovement)
% % %         124 143 222;...%4 -  Blueish violet (Slow walk)
% % %         Color(3,:)*255;...%5 - Light Blue (Walking)
% % %         Color(2,:)*255;...%6 - Green (Turn)
% % %         255 0 0;...%7 - Red (Jump)
% % %         250 244 0;...%8 - Yellow (Activity Bout)
% % %         238 96 8;...%9 - Orange(Yeast head slow micromovement)
% % %         0 0 0]/255;%10 - Black (Exploiting sucrose (Feeding))

display('---- Calculating Etho_AB and Etho_H ----')
Etho_H=nan(size(Etho_Speed,1),maxframe);
for lflycounter=1:size(Etho_Speed,1)
    display(lflycounter)
    Etho_Speed_minimalduration=Etho_Speed{lflycounter}(1:maxframe);
    
    Etho_H(lflycounter,:)=Etho_Speed_minimalduration;
    for lsubs=1:size(CumTimeH,1)
        Etho_H(lflycounter,logical(CumTimeH{lsubs}(:,lflycounter)))=lsubs+8;%Orange (Yeast) or Black (Sucrose)
    end
end

