%%
fileID=fopen('C:\Users\Vero\Dropbox (Behavior&Metabolism)\Personal\Scripts\Python\First_Tail.csv');
        H=textscan(fileID,'%s %d %d %d %d %d %d');
        % H={filename X_head_left, Y_head_left,...
%                     X_head_center, Y_head_center,...
%                     X_head_right, Y_head_right,...};%Head positions from python
fclose(fileID);