function [Etho_Tr_paper_YColors,Etho_Tr_paper_SColors]=EthoTrColorsPaper_fun
Etho_Tr_paper_YColors=[213 94 0;... % 1 - Same Yeast (Orange)230 159 0
    255 255 255;... %2 - Same sucrose (white)
    0 114 178;... %3- Close yeast (light blue)86 80 233
    255 255 255;... %4- Close sucrose (white)
    0 0 0;... %5- Far yeast (black)
    255 255 255;... %6- Far sucrose (white)
    170 170 170;...%7- First Visit
    255 255 255]/255; %8 - Not a visit
Etho_Tr_paper_SColors=[255 255 255;... % 1 - Same Yeast (white)
    118 181 49;... %2 - Same sucrose (Orange)
    255 255 255;... %3- Close yeast (white)
    92 250 254;... %4- Close sucrose (light blue)
    255 255 255;... %5- Far yeast (white)
    255 0 255;... %6- Far sucrose (black)
    170 170 170;...%7- First Visit
    255 255 255]/255; %8 - Not a visit