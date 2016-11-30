function [VarHist] = hist2D_Beta_Dist(X_Y,Heading,FlyDB,histparams,Conditions,plotting,params)
%Hist3Fly produces a 2D histogram using parameters in VarCell
%   [VarHist] = hist2D(X,Y,histparams,Conditions,plotting,params)
%
%   Outputs:   
%   VarHist     = 3D matrix where every sheet of the third dimension
%                 corresponds to the 2D histogram for each individual fly. 
%                 Given that columns are X parameter (x axis) with range in
%                 histparams.X_range and rows are Y parameter (y axis), each entry of
%                 the matrix are the COUNTS of that individual for each 
%                 pair (X,Y).
%   Inputs:
%   VarCell     = Cell array in which each entry corresponds to a matrix of 
%                 two columns [X,Y] for a single fly.
%   plotting    = 1 for Joint plot of all conditions. Top plot normal scale
%                 and bottom plot logarithmic scale.
%                 2 for plot of VarHist for each condition
%                 3 for logarithmic plot of VarHist for each condition
%                 4 no labels
%                 
%  histparams     array structure with fields: X_range, Y_range, xlabel,
%                 ylabel, paramname.

% rows=unique(params.row_n);
% cols=unique(params.col_n);
% ConditionIndex=params.ConditionIndex;
% Conditions=unique(ConditionIndex);
lsubs=2;

outervicinity=1;
if outervicinity
    thresinneredge=22.1;%mm (ring around 2.5mm of feeding in outer spots)
    ThrSpot=10;%mm
    ThrOuterSpots=95;%px
else
    ThrSpot=5;
end

VarHist=zeros(length(histparams.Y_range),length(histparams.X_range),length(params.IndexAnalyse));
for lfly=1:length(params.IndexAnalyse)
    f_spot_tmp=FlyDB(lfly).WellPos(:,:);
    f_spot=f_spot_tmp(FlyDB(lfly).Geometry(:)==lsubs,:);%1: Yeast,2: Sucrose,3:Agarose
    counts_temp=zeros(size(histparams.Y_range,2),size(histparams.X_range,2),2);

    for n=1:size(f_spot,1)
        Diff2Spots=(-X_Y{lfly}+...
            repmat(f_spot(n,:),...
            length(X_Y{lfly}),1));
        
        Dist2fSpots=sqrt(sum((Diff2Spots.^2),2));
        [Beta] = Beta_fun(Diff2Spots,Heading,lfly);
        
        %% Histogram
        log_temp1=(Dist2fSpots(1:end-1)<(ThrSpot/params.px2mm));%&(Steplength<=params.StopVel)&(Steplength>=0.15);
        
        if outervicinity
            [~,R]=cart2pol(X_Y{lfly}(1:end-1,1),X_Y{lfly}(1:end-1,2));
            log_temp2=R*params.px2mm>=thresinneredge;
            [~,RSpot]=cart2pol(f_spot(n,1),f_spot(n,2));
            log_temp3=RSpot>ThrOuterSpots;
            log_temp=log_temp1&log_temp2&repmat(log_temp3,size(X_Y{lfly},1)-1,1);
        else
            log_temp=log_temp1;
        end
            
        counts_temp(:,:,2)= hist3([Dist2fSpots(log_temp)*params.px2mm,...
            Beta(log_temp)],...
            {histparams.Y_range histparams.X_range});
        counts_temp(:,:,1)=nansum(counts_temp,3);
    end
    
    
    counts=counts_temp(:,:,1);
%     Freq=n./sum(sum(n)); %Counts, not frequecy
    VarHist(:,:,lfly)=counts;
    display(lfly);
end
%% Plotting JointHistogram
Jointfr=sum(VarHist,3);
Jointfr=Jointfr./sum(sum(Jointfr));
if plotting == 1
    figure
    subplot(2,1,1)
    imagesc(histparams.X_range,histparams.Y_range,(Jointfr),[0 16e-4])%);%,);%For VelGamma,clims);% or log(Condfr)) %
    colorbar
    font_style([],histparams.xlabel,histparams.ylabel,'bold','calibri',20)
        
    subplot(2,1,2)
    imagesc(histparams.X_range,histparams.Y_range,log10(Jointfr),[-6 -3]);% For VelGamma,clims);%
    colorbar
    font_style([],histparams.xlabel,histparams.ylabel,'bold','calibri',20)
end
%% SURF
% close all
% figure
% surf((Jointfr))
% view(0,90)
% %surface(log10(Jointfr)); %Equivalent to previous 2 lines.
% shading interp
% set(gca,'CLim',[0 1.5e-4])%[-6 -3.2])
%%
% % axis off
% colorbar
% axis on
% xlabel(histparams.xlabel,'FontSize',14)
% ylabel(histparams.ylabel,'FontSize',14)
% set(gca,'FontSize',14)
% zlim([-9 0])
% view(-110,10)
% % OptionZ.FrameRate=10;OptionZ.Duration=7;OptionZ.Periodic=true;
% %     CaptureFigVid([-20,10;-110,10;-190,80;-290,10;-380,10], ['3D Vel_Gamma not replacing'],OptionZ)


%% Looping across conditions: Likelihood plots--> p(Theta,Rho|Condition)
% VarHist=VarHistBetaY;
if plotting ==2 || plotting==3 || plotting ==4
%     figure('Position',[100 50 params.scrsz(3)-150 params.scrsz(4)-150])
if plotting~=4
    PaperPosition=[1 1 16 9];
    labels='';
else
    PaperPosition=[1 1 14 7];
    labels=' No labels';
end
if outervicinity
    extra=' outer spots';
else
    extra='';
end
 figure('Position',[50 50 900 900],'Color','w','PaperUnits','centimeters',...
        'PaperPosition',PaperPosition,'Name',...
        ['Orientation ' params.Subs_Names{lsubs} '150 bins dlessthan',...
        num2str(ThrSpot) 'mm, [0 2e-4]' extra labels]);
    lcondcounter=1;
    for lcond=Conditions

        Condtmp=sum(VarHist(:,:,params.ConditionIndex==lcond),3);
        Cond_fr=Condtmp./sum(sum(Condtmp));
        
        subplot(2,ceil(length(Conditions)/2),lcondcounter)
        
        if plotting ==2||plotting==4
            imagesc(histparams.X_range,histparams.Y_range,(Cond_fr),[0 2e-4])%[0 0.5e-3]);%[0 2e-3]
        elseif plotting ==3
            imagesc(histparams.X_range,histparams.Y_range,log10(Cond_fr),[-5.5 -3]);%[-6 -2])%[-5.5 -3])%
        end
        
%         set(gca,'FontSize',14)
        if mod(lcondcounter,ceil(length(Conditions)/2))==0
            if plotting~=4
                colorbar
            end
        end
        if plotting~=4
        font_style(params.Labels(lcond),histparams.xlabel,histparams.ylabel,'normal','arial',8)
        else
        font_style([],[],[],'normal','arial',8)
        end
        set(gca,'YDir','REVERSE')
        lcondcounter=lcondcounter+1;
        
        hold on
        X_axis_lim=get(gca,'XLim');
        plot(X_axis_lim,[2.5 2.5],'--k','LineWidth',1,'Color',[230 159 0]/255)
        %%
%         plot([0 2.5],[0.15 0.15],'--k','LineWidth',2)
    end
end

% save(['C:\Users\FaisalLab\Documents\Veronica\Data Analysis\Analysis Data\Experiment 3\PolarHistogram_' num2str(length(Theta_range)) 'x' num2str(length(Rad_range)) '_' date '.mat'],'PolarHist');
%% Comparing across conditions
% figure('Position',[100 50 params.scrsz(3)-150 params.scrsz(4)-150])
% %%% FF minus Deprived
% for ltemp=[1 2]
% % subplot(2,1,ltemp)
% subplot(2,2,ltemp)
% Condtmp1=sum(VarHist(:,:,params.ConditionIndex==ltemp),3);
% Cond_fr1=Condtmp1./sum(sum(Condtmp1));
% Condtmp2=sum(VarHist(:,:,params.ConditionIndex==ltemp+2),3);
% Cond_fr2=Condtmp2./sum(sum(Condtmp2));
% imagesc(histparams.X_range,histparams.Y_range,((Cond_fr1)-(Cond_fr2)),[-4e-4 4e-4])%[-3e-4 3e-4])%
% colorbar
% font_style(['(' params.LabelsShort{ltemp} ') - (' params.LabelsShort{ltemp+2} ')'],histparams.xlabel,histparams.ylabel,'normal','calibri',20)
%         set(gca,'YDir','normal')
%         hold on
%         Y_axis_lim=get(gca,'YLim');
%         plot([2.5 2.5],Y_axis_lim,'--k','LineWidth',2)
% end 
% %%% Mated minus Virgins
% tempcounter=3;
% for ltemp=[1 3]
% subplot(2,2,tempcounter)
% Condtmp1=sum(VarHist(:,:,params.ConditionIndex==ltemp),3);
% Cond_fr1=Condtmp1./sum(sum(Condtmp1));
% Condtmp2=sum(VarHist(:,:,params.ConditionIndex==ltemp+1),3);
% Cond_fr2=Condtmp2./sum(sum(Condtmp2));
% imagesc(histparams.X_range,histparams.Y_range,((Cond_fr1)-(Cond_fr2)),[-4e-4 4e-4])%[-5e-4 5e-4])
% colorbar
% font_style(['(' params.LabelsShort{ltemp} ') - (' params.LabelsShort{ltemp+1} ')'],histparams.xlabel,histparams.ylabel,'normal','calibri',20)
%         set(gca,'YDir','normal')
%         tempcounter=tempcounter+1;
%         hold on
%         Y_axis_lim=get(gca,'YLim');
%         plot([2.5 2.5],Y_axis_lim,'--k','LineWidth',2)
% end        
% colormap(pink)
%% SURF
% close all
% figure
% surf(log10(Cond_fr))
% % view(0,90)
% %surface(log10(Cond_fr)); %Equivalent to previous 2 lines.
% shading interp
% set(gca,'CLim',[-5.5 -3])%[-6 -3.2])
