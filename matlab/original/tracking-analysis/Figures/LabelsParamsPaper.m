function [y_label,y_labelname]=LabelsParamsPaper(TimeSegmentsParams,lparam)
if iscell(TimeSegmentsParams{1}(lparam).YLabel)
    y_labelname=TimeSegmentsParams{1}(lparam).YLabel{1};
else
    y_labelname=TimeSegmentsParams{1}(lparam).YLabel;
end
y_label=TimeSegmentsParams{1}(lparam).YLabel;
if lparam==2,y_label={'Speed outside food';'(mm/s)'};end
if lparam==9,y_label={'Average duration';'of yeast visits';'(min)'};end
if lparam==25,y_label={'Distance traveled';'to next';'yeast visit (mm)'};end
if lparam==30,y_label={'Av. minimum';'distance from';'yeast center (mm)'};end
if lparam==48,y_label={'Total duration';'of yeast visits';'(min)'};end
if lparam==55,y_label={'Angular speed';'outside food';'(º/s)'};end
if lparam==58,y_label={'Speed_b_o_d_y';'during Y visits';'(mm/s)'};end
if lparam==59,y_label={'Angular speed';'during Y visits';'(º/s)'};end
if lparam==60,y_label={'Av. area of';'yeast patch';'covered (px)'};end
if lparam==75,y_label={'Nº of yeast';'encounters'};end
if lparam==89,y_label={'P(yeast';'engagement'};end
if lparam==93,y_label={'Nº of yeast';'encounters';'per min'};end
if lparam==97,y_label={'Rate of yeast';'encounters';'(min^-^1)'};end%per min walking!




