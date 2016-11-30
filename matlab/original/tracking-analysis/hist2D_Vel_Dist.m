function [VarHist] = hist2D_Vel_Dist(X_Y,Y,FlyDB,histparams,Conditions,plotting,params)
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
%  histparams     array structure with fields: X_range, Y_range, xlabel,
%                 ylabel, paramname.

% rows=unique(params.row_n);
% cols=unique(params.col_n);
% ConditionIndex=params.ConditionIndex;
% Conditions=unique(ConditionIndex);

VarHist=zeros(length(histparams.Y_range),length(histparams.X_range),length(params.IndexAnalyse));
% f_spot=[0 0];
% f_spot=[87.3787  -51.4700;...
%    43.6600  -77.1689;...
%    -0.8850 -101.4071;...
%   -45.0002  -76.3951;...
%   -88.2636  -49.9372;...
%   -88.6602    0.7737;...
%    88.6602   -0.7737;...
%    88.2636   49.9372;...
%    45.0002   76.3951;...
%     0.8850  101.4071;...
%   -43.6600   77.1689;...
%   -87.3787   51.4700];
for lfly=1:length(params.IndexAnalyse)
    f_spot=FlyDB(lfly).WellPos(FlyDB(lfly).Geometry==histparams.Substrate,:);
%     f_spot=f_spot([1 3 5 7 9 11 14 16 18],:);%Yeast([2 4 6 8 10 12 13 15 17],:);%Sucrose positions
    counts_temp=zeros(size(histparams.Y_range,2),size(histparams.X_range,2),2);
    
    for n=1:size(f_spot,1)
        Dist2fSpots=sqrt(sum(((X_Y{lfly}-...
            repmat(f_spot(n,:),...
            length(X_Y{lfly}),1)).^2),2));
        log_temp=(Dist2fSpots(1:size(Y{lfly},1))<(4.8/params.px2mm))&(Y{lfly}<=histparams.Y_range(end));%params.StopVel);
        counts_temp(:,:,2)= hist3([Y{lfly}(log_temp),...
            Dist2fSpots(log_temp)*params.px2mm],...
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
Jointfr=Jointfr./sum(sum(Jointfr));% Joint probability p(s,d)
% Jointfr=Jointfr./repmat(sum(Jointfr),size(Jointfr,1),1); % Conditional prob p(v|d)
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
% VarHist=VarHistY;
if plotting ==2 || plotting==3
    figure('Position',[100 50 params.scrsz(3)-350 params.scrsz(4)-150],'Color','w')
    lcondcounter=1;
    for lcond=Conditions

        Condtmp=sum(VarHist(:,:,params.ConditionIndex==lcond),3);
        Cond_fr=Condtmp./sum(sum(Condtmp));
%         Cond_fr=Condtmp./repmat(sum(Condtmp),size(Condtmp,1),1);
        
        subplot(2,ceil(length(Conditions)/2),lcondcounter)
        
        if plotting ==2
            imagesc(histparams.X_range,histparams.Y_range,(Cond_fr),[0 5e-3]);%[0 2e-3]
        elseif plotting ==3
            imagesc(histparams.X_range,histparams.Y_range,log10(Cond_fr),[-4.7 -2.2])%[-5.5 -3])%149Dist&99Vel(upto2)
        end
        colorbar
%         set(gca,'FontSize',14)
%         if mod(lcondcounter,ceil(length(Conditions)/2))==0
%         colorbar
%         end
        font_style(params.LabelsShort(lcond),histparams.xlabel,histparams.ylabel,'normal','calibri',30)
        set(gca,'YDir','normal')
        lcondcounter=lcondcounter+1;
        
        hold on
        Y_axis_lim=get(gca,'YLim');
        plot([1.5 1.5],Y_axis_lim,'--y','Color',[221 126 14]/255,'LineWidth',3)
        
%         plot([0 2.5],[0.1 0.1],'--k','LineWidth',2)
    end
end
% save(['C:\Users\FaisalLab\Documents\Veronica\Data Analysis\Analysis Data\Experiment 3\PolarHistogram_' num2str(length(Theta_range)) 'x' num2str(length(Rad_range)) '_' date '.mat'],'PolarHist');
%% Comparing across conditions
figure('Position',[100 50 params.scrsz(3)-350 params.scrsz(4)-150])
%%% FF minus Deprived
cols=[1 2];
for ltemp=cols
% subplot(2,1,ltemp)
subplot(2,length(cols),ltemp)
Condtmp1=sum(VarHist(:,:,params.ConditionIndex==ltemp),3);
Cond_fr1=Condtmp1./sum(sum(Condtmp1));
% Cond_fr1=Condtmp1./repmat(sum(Condtmp1),size(Condtmp1,1),1);

Condtmp2=sum(VarHist(:,:,params.ConditionIndex==ltemp+2),3);
Cond_fr2=Condtmp2./sum(sum(Condtmp2));
% Cond_fr2=Condtmp2./repmat(sum(Condtmp2),size(Condtmp2,1),1);
imagesc(histparams.X_range,histparams.Y_range,((Cond_fr1)-(Cond_fr2)),[-3e-4 3e-4])%[-3e-4 3e-4])%
colorbar
font_style(['(' params.LabelsShort{ltemp} ') - (' params.LabelsShort{ltemp+2} ')'],...
    histparams.xlabel,histparams.ylabel,'normal','calibri',30)
        set(gca,'YDir','normal')
        hold on
        Y_axis_lim=get(gca,'YLim');
        plot([1.5 1.5],Y_axis_lim,'--k','LineWidth',1)
end 
%%% Mated minus Virgins
tempcounter=3;
for ltemp=[1 3]
subplot(2,2,tempcounter)
Condtmp1=sum(VarHist(:,:,params.ConditionIndex==ltemp),3);
Cond_fr1=Condtmp1./sum(sum(Condtmp1));
Condtmp2=sum(VarHist(:,:,params.ConditionIndex==ltemp+1),3);
Cond_fr2=Condtmp2./sum(sum(Condtmp2));
imagesc(histparams.X_range,histparams.Y_range,((Cond_fr1)-(Cond_fr2)),[-4e-4 4e-4])%[-5e-4 5e-4])
colorbar
font_style(['(' params.LabelsShort{ltemp} ') - (' params.LabelsShort{ltemp+1} ')'],...
    histparams.xlabel,histparams.ylabel,'normal','calibri',30)
        set(gca,'YDir','normal')
        tempcounter=tempcounter+1;
        hold on
        Y_axis_lim=get(gca,'YLim');
        plot([1.5 1.5],Y_axis_lim,'--k','LineWidth',1)
end        
colormap(pink)
%% SURF
% close all
% figure
% surf(log10(Cond_fr))
% % view(0,90)
% %surface(log10(Cond_fr)); %Equivalent to previous 2 lines.
% shading interp
% set(gca,'CLim',[-5.5 -3])%[-6 -3.2])
