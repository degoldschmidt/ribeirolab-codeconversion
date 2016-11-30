function [ Color_map,Cmap_patch ] = Colors(num_of_conditions)
% Generates colormaps that I like :P
% So far only up to 4 with patch
% [ Colormap,Cmap_patch ] = Colors(num_of_conditions,pastel)
Cmap_patch=zeros(num_of_conditions,3);
Color_map=zeros(num_of_conditions,3);
switch num_of_conditions
    case {1,2,3}
         Color_map=[179 83 181;0 200 0;0 190 255]/255;%[Orchid;Green;Blue]Blue: 91 212 255;
         Cmap_patch=[242 226 242;209 255 209;209 243 255]/255;%[Orchid;Green;Blue]255 163 255;
%         Colormap=[179 83 181;84 130 53;238 96 8]/255;%[Orchid;DarkGreen;Orange]
%         Cmap_patch=[242 226 242;231 243 205;250 220 184]/255;%[Orchid;Green;Orange]
    case {4,5,6,7,8}
        Color_map=[255 192 0;3,241,253;204,0,0;0,64,255;84 130 53;...
            179 83 181;166 166 166;177 130 37]/255;%[Yellow;Cyan;Red;Blue;Green;Orchid;Gray;Brownish]
        Cmap_patch=[250 220 184;217 255 255;255 197 197;201 215 255;...
                231 243 205;242 226 242;219 219 219;244 229 200]/255; %[Yellow;Blue;Red;Cyan;Green;Orchid;Gray;Brownish]
end

if num_of_conditions>8, 
    Color_map=jet(num_of_conditions);...
    Cmap_patch=jet(num_of_conditions);
end

% Color_map=Color_map(1:num_of_conditions,:);
% Cmap_patch=Cmap_patch(1:num_of_conditions,:);


