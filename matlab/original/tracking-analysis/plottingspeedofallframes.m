%% Plotting head speeds for all flies
close all
figure('Color','w','Position',[10   10    2800    900])
flycounter=0
for lfly=65:72
    flycounter=flycounter+1;
    subplot(8,4,flycounter)
    plot(1:params.MinimalDuration,Steplength_Sm_h{lfly}(1:params.MinimalDuration)*params.px2mm*50,'-k')
    axis([0 params.MinimalDuration 0 30])
    title(num2str(lfly))
end
    