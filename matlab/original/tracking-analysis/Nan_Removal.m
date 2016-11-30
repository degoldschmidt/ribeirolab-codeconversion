function [X_Y_corr,replacements,problemfly]=Nan_Removal(X_Y,r_zeros)
% [X_Y_corr,replacements,problemflies]=Smoothing(X_Y)
% Nan_Removal removes the nans or zeros from the trajectory vectors by
% substituting them with interpolated values. Nans at the beginning or end
% of the vectors will be replaced with the closest non-nan value.
% Correction will happen only if number of nans in data is below 1%.
% Input is a matrix with trajectory data in each column for each dimension,
% e.g. X_Y=[CentroidsX,CentroidsY]. r_zeros=1 when zeros are removed as
% well.
%
% Veronica Corrales, March 2014.
%

%% Subtituting nans in Centroids, Heads & Tails
display('----- Interpolating missing data -------')
replacements=nan(size(X_Y));

problemfly=0;
X_Y_corr=X_Y;
if ((sum(sum(isnan(X_Y))))/(size(X_Y,1)*size(X_Y,2)))>=0.02
    if size(X_Y,1)>360000
        if ((sum(sum(isnan(X_Y))))/(size(X_Y,1)*size(X_Y,2)))>=0.02
            X_Y=[];
            display({['This fly has ' num2str(((sum(sum(isnan(X_Y))))/(size(X_Y,1)*2))*100) '% of nans'];
            '(more than the threshold 2% of nans)'});
            problemfly=1;
        else
            X_Y=X_Y(1:360000,:);
            warning('Cropped to 360000 frames')
        end
    elseif size(X_Y,1)>180000
        if ((sum(sum(isnan(X_Y))))/(size(X_Y,1)*size(X_Y,2)))>=0.02
             X_Y=[];
            display({['This fly has ' num2str(((sum(sum(isnan(X_Y))))/(size(X_Y,1)*2))*100) '% of nans'];
            '(more than the threshold 2% of nans)'});
            problemfly=1;
        else
            X_Y=X_Y(1:180000,:);
            warning('Cropped to 180000 frames')
        end
    else
        display({['This fly has ' num2str(((sum(sum(isnan(X_Y))))/(size(X_Y,1)*2))*100) '% of nans'];
        '(more than the threshold 2% of nans)'});
        X_Y=[];
        problemfly=1;
    end
end
if ~isempty(X_Y)
    X_Y_corr=X_Y;
    replacements=nan(size(X_Y));
    if r_zeros==1
        frames_zeros=sum(X_Y==0,2)==2;
    else
        frames_zeros=false(size(X_Y,1),1);
    end
    
    for dim2corr=1:size(X_Y,2) % For each col of the input matrix
        frames_nans=(isnan(X_Y(:,dim2corr)));% Find nan
        frames_in=find(conv(double(frames_nans|frames_zeros),[1 -1])==1);
        frames_out=find(conv(double(frames_nans|frames_zeros),[1 -1])==-1)-1;
        
        if ~isempty(frames_in)
            for lframe=frames_in'
                
                
                if frames_out(frames_in==lframe)==size(X_Y,1)
                    %%% nans or zeros at the end replace for the last centroid
                    %%% data
                    X_Y_corr(frames_in(end):end,:)=...
                        repmat(X_Y(frames_in(end)-1,:),...
                        frames_out(end)-frames_in(end)+1,1);
                    replacements(frames_in(end):end,:)=...
                        repmat(X_Y(frames_in(end)-1,:),...
                        frames_out(end)-frames_in(end)+1,1);
                else
                    
                    if lframe==1
                        %%% nans or zeros at the beginning replace for the first centroid
                        %%% data
                        X_Y_corr(1:frames_out(1),:)=repmat(X_Y(frames_out(1)+1,:),frames_out(1),1);
                        replacements(1:frames_out(1),:)=repmat(X_Y(frames_out(1)+1,:),frames_out(1),1);
                    else
                        
                        %%% Interpolate for the rest of the cases
                        step=(X_Y(frames_out(frames_in==lframe)+1)-...
                            X_Y(lframe-1))/(frames_out(frames_in==lframe)-lframe+2);
                        counter=(1:frames_out(frames_in==lframe)-lframe+1)';
                        
                        X_Y_corr(lframe:frames_out(frames_in==lframe),dim2corr)=...
                            X_Y(lframe-1,dim2corr)+step*counter;
                        replacements(lframe:frames_out(frames_in==lframe),dim2corr)=...
                            X_Y(lframe-1,dim2corr)+step*counter;
                    end
                    
                end
                
            end
        end
    end
end


