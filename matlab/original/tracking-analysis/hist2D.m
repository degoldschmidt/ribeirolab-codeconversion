function [VarHist] = hist2D(X,Y,histparams,Conditions,plotting,params)
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

for lfly=1:length(params.IndexAnalyse)
        
    n= hist3([Y{lfly}  X{lfly}],{histparams.Y_range histparams.X_range});
%     Freq=n./sum(sum(n)); %Counts, not frequecy
    VarHist(:,:,lfly)=n;
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
if plotting ==2 || plotting==3
    figure('Position',[100 50 params.scrsz(3)-450 params.scrsz(4)-150])
    lcondcounter=1;
    for lcond=Conditions

        Condtmp=sum(VarHist(:,:,params.ConditionIndex==lcond),3);
        Cond_fr=Condtmp./sum(sum(Condtmp));
        
        subplot(2,ceil(length(Conditions)/2),lcondcounter)
        
        if plotting ==2
            imagesc(histparams.X_range,histparams.Y_range,(Cond_fr),[0 0.7e-3]);%[0 2e-3]
        elseif plotting ==3
            imagesc(histparams.X_range,histparams.Y_range,log10(Cond_fr),[-6 -2.7]);%[-6 -2.3]
        end
        
%         set(gca,'FontSize',14)
        if mod(lcondcounter,ceil(length(Conditions)/2))==0
        colorbar
        end
        font_style(params.Labels(lcond),histparams.xlabel,histparams.ylabel,'normal','calibri',20)
        set(gca,'YDir','normal')
        lcondcounter=lcondcounter+1;
    end
end
% save(['C:\Users\FaisalLab\Documents\Veronica\Data Analysis\Analysis Data\Experiment 3\PolarHistogram_' num2str(length(Theta_range)) 'x' num2str(length(Rad_range)) '_' date '.mat'],'PolarHist');
%% Comparing across conditions
figure('Position',[100 50 params.scrsz(3)-450 params.scrsz(4)-150])
FntSz=26;
%%% FF minus Deprived
for ltemp=[1 2]
% subplot(2,1,ltemp)
subplot(2,2,ltemp)
Condtmp1=sum(VarHist(:,:,params.ConditionIndex==ltemp),3);
Cond_fr1=Condtmp1./sum(sum(Condtmp1));
Condtmp2=sum(VarHist(:,:,params.ConditionIndex==ltemp+2),3);
Cond_fr2=Condtmp2./sum(sum(Condtmp2));
imagesc(histparams.X_range,histparams.Y_range,((Cond_fr1)-(Cond_fr2)),[-0.5e-4 0.5e-4])%[-1.5e-4 1.5e-4])
colorbar
font_style(['(' params.LabelsShort{ltemp} ') - (' params.LabelsShort{ltemp+2} ')'],...
    histparams.xlabel,histparams.ylabel,'normal','calibri',FntSz)
        set(gca,'YDir','normal')
end 
%%% Mated minus Virgins
tempcounter=3;
for ltemp=[1 3]
subplot(2,2,tempcounter)
Condtmp1=sum(VarHist(:,:,params.ConditionIndex==ltemp),3);
Cond_fr1=Condtmp1./sum(sum(Condtmp1));
Condtmp2=sum(VarHist(:,:,params.ConditionIndex==ltemp+1),3);
Cond_fr2=Condtmp2./sum(sum(Condtmp2));
imagesc(histparams.X_range,histparams.Y_range,((Cond_fr1)-(Cond_fr2)),[-1e-4 1e-4])
colorbar
font_style(['(' params.LabelsShort{ltemp} ') - (' params.LabelsShort{ltemp+1} ')'],...
    histparams.xlabel,histparams.ylabel,'normal','calibri',FntSz)
        set(gca,'YDir','normal')
        tempcounter=tempcounter+1;
end        
colormap(bone)
