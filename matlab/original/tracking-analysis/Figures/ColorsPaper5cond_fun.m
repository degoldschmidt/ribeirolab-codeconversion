function [ColorsinPaper,orderinpaper,labelspaper,Yeast_Sucrose]=ColorsPaper5cond_fun(Exp_num, Exp_letter,params)
if nargin==0,Exp_num='0003';Exp_letter='D';end
if strfind([Exp_num Exp_letter],'0008B')
    ColorsinPaper=[3,241,253;... Cyan - 'Or83b-/-, AA-'
    204,0,0;... Red - CS AA-
    227 190 202;... pink - Or83b+/- AA-
    179 83 181;... Orchid - Mated Yaa
    255 192 0;... Yellow - 'Or83b-/-, AA+ (opt.)'
    0 255 255]/255;%'Or83b+/-, AA+ (opt.)'
    orderinpaper=[2 1 3 4 5 6];%
    labelspaper={'CS, AA-';...2
        'Orco^1^/^1, AA-';...1
        'Orco^1^/^+, AA-';...3
    'CS, AA+ (opt.)';...4
    'Orco^1^/^1, AA+';...5
    'Orco^1^/^+, AA+';};
elseif strfind([Exp_num Exp_letter],'0003D')
    ColorsinPaper=[84 130 53;... Green - Virgin Yaa
        0,64,255;... Blue - Virgin AA-
        179 83 181;... Orchid - Mated Yaa
        255 192 0;... Yellow - Mated Hunt
        204,0,0;... Red - Mated AA-
        3,241,253]/255;%Cyan[3,241,253;0,64,255;255 192 0;204,0,0;]/255;%EXP0004A
    orderinpaper=[6 4 5 1 3 2];%
    labelspaper={'Mated, AA+ (subopt.)';...
        'Virgin, AA+ (subopt.)';...
        'Mated, AA-';...
        'Virgin, AA-';...
        'Mated, AA+ (rich)';...
        'Virgin, AA+ (rich)'};
elseif strfind([Exp_num Exp_letter],'0011A')
ColorsinPaper=[0,64,255;... Blue -CS  Virgin AA- (4)
    204,0,0;... Red - CS Mated AA- (3)
    166 166 166;... Gray - Virgin AA- tbh (8)
    177 130 37;... Mustard - Mated AA- tbh (7)
    255 192 0;... Yellow - CS Mated Hunt (1)
    3,241,253;... cyan - cs virgin hunt (2)
    84 130 53;... Green - MAted hunt tbh (5)
    179 83 181]/255;... Orchid - virgin hun tbh (6)
orderinpaper=[4 3 8 7 1 2 5 6];
labelspaper={'Mated, AA+ (subopt.), CS';...
    'Virgin, AA+ (subopt.), CS';...
    'Mated, AA-, CS';...
    'Virgin, AA-, CS';...
    'Mated, AA+ (subopt.), t\betah';...
    'Virgin, AA+ (subopt.), t\betah';...
    'Mated, AA-, t\betah';...
    'Virgin, AA-, t\betah'};
elseif strfind([Exp_num Exp_letter],'0012A')
    ColorsinPaper=[123 178 247;... 
    116 203 244;... 
    13 0 255;... 
    240 146 68;... 
    247 103 168;... 
    204 0 0]/255;
    orderinpaper=[2 3 1 5 6 4];%
    labelspaper={'Poxn>TNT, AA+ subopt.';...1
        'Poxn>-, AA+ subopt.';...2
        'TNT, AA+ subopt.';...3
        'Poxn>TNT, AA-';...%4
        'Poxn>-, AA-';...5
        'TNT, AA-';...6
        };
else
    orderinpaper=unique(params.ConditionIndex);
    ColorsinPaper=Colors(length(orderinpaper));
    labelspaper=params.LabelsShort;
end
%%
Yeast_Sucrose=[230 159 0;170 170 170]/255;