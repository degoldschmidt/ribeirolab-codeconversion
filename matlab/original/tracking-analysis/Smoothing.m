function [X_Y_Sm,replacements,problemflies,replac_Sm,problemflies_Sm] =...
    Smoothing(X_Y,window,type_smoothing,r_zeros)
%[X_Y_Sm,replacements,problemflies,replac_Sm,problemflies_Sm] =...
%    Smoothing(X_Y,window,type_smoothing,r_zeros)
% Smoothing applies Nan_Removal function on the cell array X_Y. Then, applies
% fastsmooth on that array and finally removes nans and zeros giving as
% an output another cell array X_Y_Sm with the same size that X_Y.
% window and type_sm are w and type inputs for fastsmooth function.
% The argument "type" determines the smooth type:
%   If type='rectangular', sliding-average or boxcar, using fastsmooth
%   If type='triangular', 2 passes of sliding-average, using fastsmooth
%   If type='pseudo-gaussian', 3 passes of sliding-average, using fastsmooth
%   If type='gaussian', slide gaussian using conv

switch type_smoothing
    case 'rectangular'
        type_sm=1;
        fun2smooth=1;
    case 'triangular'
        type_sm=2;
        fun2smooth=1;
    case 'pseudo-gaussian'
        type_sm=3;
        fun2smooth=1;
    case 'gaussian'
        type_sm=4;
        fun2smooth=2;
        range_conv=window;%16;%Heads
        mu=0;
        sigma=range_conv/10;%1.5;%Heads
        
        f2=@(sigma,mu,x) (1/sqrt(2*pi*(sigma^2)))*exp((-1/(2*sigma^2))*((x-mu).^2));%Gaussian
        v=f2(sigma,mu,-range_conv/2:range_conv/2);v(1)=0;v(end)=0;
end

X_Y_Sm=cell(size(X_Y));
replac_Sm=cell(size(X_Y));
problemflies_Sm=nan(size(X_Y,1),1);
X_Y_corr=cell(size(X_Y));
replacements=cell(size(X_Y));
problemflies=nan(size(X_Y,1),1);
X_Y_Sm_temp=cell(size(X_Y_corr));


for lflycounter=1:size(X_Y,1)
    display(lflycounter)
    [X_Y_corr{lflycounter},replacements{lflycounter},problemflies(lflycounter)]=Nan_Removal(X_Y{lflycounter},r_zeros);
    
    if sum(sum(isnan(X_Y_corr{lflycounter})))~=0 || sum(sum(X_Y_corr{lflycounter}==0,2)==2)~=0
        problemflies(lflycounter)=1;
        display('This fly still has some nans uncorrected --> NOT SMOOTHED!')
        display('Press any key to continue with the following flies')
        pause
    else
        display(['----- ' type_smoothing ' Smoothing-----'])
        X_Y_Sm_temp{lflycounter}=nan(size(X_Y_corr{lflycounter}));
        switch fun2smooth
            case 1
                %% Smoothing using fastsmooth function: Sliding average
                for ldim=1:size(X_Y_corr{lflycounter},2)
                    X_Y_Sm_temp{lflycounter}(:,ldim)=fastsmooth(X_Y_corr{lflycounter}(:,ldim),window,type_sm);
                end
                
            case 2
                %% Smoothing using a gaussian filter
                for ldim=1:size(X_Y_corr{lflycounter},2)
                    filt_temp=conv(X_Y_corr{lflycounter}(:,ldim),v);
                    X_Y_Sm_temp{lflycounter}(1+range_conv/2:end-range_conv/2,ldim)=filt_temp(1+range_conv:end-range_conv);
                end
                
        end
        
    end
    [X_Y_Sm{lflycounter},replac_Sm{lflycounter},problemflies_Sm(lflycounter)]=Nan_Removal(X_Y_Sm_temp{lflycounter},r_zeros);
end

%% Testing parameters of the gaussian smoothing
% close all
% figure('Position',[100 50 params.scrsz(3)-750 params.scrsz(4)-150],'Color','w')
% % range=15565:20000;%30700:30700+100;%30523:30563;%26222:30563;%1:length
% Colormap=Colors(3);
% flies_idx=119;%params.IndexAnalyse;
% Spots=[1];%,5,9,14];
% MkSz=55;
% type_sm=4;
% fun2smooth=2;
% range_conv=16;%50;
% mu=0;
% sigma=1.5;%6;
% 
% f2=@(sigma,mu,x) (1/sqrt(2*pi*(sigma^2)))*exp((-1/(2*sigma^2))*((x-mu).^2));%Gaussian
% v=f2(sigma,mu,-range_conv/2:range_conv/2);v(1)=0;v(end)=0;
% for lfly=flies_idx
% %     clf
%     range=30500:31800;%1:size(Centroids{lfly},1);
%     plot_tracks_single(FlyDB,Heads{lfly},lfly,Spots,params,1,Colormap(1,:),range,MkSz)%Plotting selected flies
%     plot_tracks_single(FlyDB,Heads_Sm{lfly},lfly,Spots,params,1,Colormap(2,:),range,MkSz)%Plotting selected flies
%     %% Smoothing traj range
%     HeadSm=nan(size(Heads{lfly}));
%     range_sm=range(1)+range_conv/2:range(end)-range_conv/2;
%     for ldim=1:2
%         temp=conv(Heads{lfly}(range,ldim),v);
%         HeadSm2(range_sm,ldim)=temp(1+range_conv:end-range_conv);%temp(1+range_conv/2:end-range_conv/2);
%     end
%     plot_tracks_single(FlyDB,HeadSm2,lfly,Spots,params,1,Colormap(3,:),range_sm,MkSz)%Plotting selected flies
% %     axis([xlim_ ylim_])
% end
% % plot_tracks(FlyDB,Centroids_Sm,flies_idx,params)% Plotting trajectories, subplots: conditions
