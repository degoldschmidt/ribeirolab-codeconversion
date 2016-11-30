%% 
filename_prev='0';
problemflies=nan(params.numflies,2);
problemcounter=0;
for lfly=flies_idx%1:params.numflies
    lfly
    filename=FlyDB(lfly).Filename
    if strfind(filename_prev,filename)
    else
        MovieObj=VideoReader(['F:\PROJECT INFO\Videos\Exp 0011\' filename]);
    end
    diffframes=(MovieObj.NumberOfFrames-length(Centroids_Sm{lfly}));
    if diffframes~=0
        problemcounter=problemcounter+1;
        problemflies(problemcounter,:)=[lfly diffframes];
    end
    filename_prev=filename;
end
problemflies=problemflies(1:problemcounter,:);