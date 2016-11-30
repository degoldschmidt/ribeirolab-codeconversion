%% Heatmap for Cartesian coordinates
flies_idx=params.IndexAnalyse;
minX=-33; %minimum value in X that a fly can reach
maxX=33;%maximum value in X that a fly can reach
minY=-33;%same in Y
maxY=33;
numberofbins=100;
histparams.paramname='X_Y p';
histparams.X_range=minX:((maxX-minX)/(numberofbins-1)):maxX;% Beta range in degrees
histparams.Y_range=minY:((maxY-minY)/(numberofbins-1)):maxY;% Distance to Spot range in mm.
histparams.xlabel='X positions (mm)';
histparams.ylabel='Y positions (mm)';
figure('Position',[100 50 params.scrsz(3)-750 params.scrsz(4)-150],'Color','w')

%%% Allocate space for histogram results
VarHist=zeros(length(histparams.Y_range),length(histparams.X_range),length(flies_idx));

flycounter=1;
for lfly=flies_idx
    display(lfly);
    %%% Histogram for 2 variables
    n= hist3([Y{lfly}  X{lfly}],{histparams.Y_range histparams.X_range});
    VarHist(:,:,flycounter)=n;
    flycounter=flycounter+1;
end
% % % % Jointcount=sum(VarHist,3);
% % % % Jointfr=Jointcount./sum(sum(Jointcount));% Transform counts in frequency (probability)
%% Plotting per condition
figure('Position',[100 50 params.scrsz(3)-450 params.scrsz(4)-150])
lcondcounter=1;
Conditions=1:4;
for lcond=Conditions
    %%% Remember that length(flies_idx)==length(params.ConditionIndex)
    %%% should be true
    Condtmp=sum(VarHist(:,:,params.ConditionIndex==lcond),3);
    Cond_fr=Condtmp./sum(sum(Condtmp));
    
    subplot(2,ceil(length(Conditions)/2),lcondcounter)
    
    imagesc(histparams.X_range,histparams.Y_range,(Cond_fr))%,[0 0.7e-3]);%[0 2e-3]
    colorbar
    font_style(params.Labels(lcond),histparams.xlabel,histparams.ylabel,'normal','calibri',20)
    set(gca,'YDir','normal')
    lcondcounter=lcondcounter+1;
end