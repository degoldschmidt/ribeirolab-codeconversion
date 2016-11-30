%% plot_spot_detection:
%%% Detected
% % h = viscircles(centers,radii,'DrawBackgroundCircle',false);
NOP=100;
ColorDetected=[0 176 240]/255;
for lcircle=1:size(Detected{larena},1)
    text(Detected{larena}(lcircle,1)+15,Detected{larena}(lcircle,2),num2str(lcircle))
    hold on
    [hc,xc,yc]=circle_(Detected{larena}(lcircle,:),radii(lcircle),NOP);
    set(hc,'Color',[0.5 0.5 0.5])
    patch(xc,yc,ColorDetected,'FaceAlpha',0.5,'EdgeAlpha',0)
end
%%% Plotting yeast spots from well postitions template
ColorTemplate=[255 255 0]/255;
for lcircle=1:size(Template{larena},1)
    [hc,xc2,yc2]=circle_(Template{larena}(lcircle,:),1.5/params.px2mm,NOP);
    set(hc,'Color',[0.5 0.5 0.5])
    patch(xc2,yc2,ColorTemplate,'FaceAlpha',0.5,'EdgeAlpha',0)
end
