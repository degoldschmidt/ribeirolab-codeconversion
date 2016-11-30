% function TransitionProb(Vero,FlyDB,params)
Adj_Thr=16;%mm

Vero{1}=nan(13,4);
Vero{1}(:,4)=[1 2 18 17 9 10 11 12 14 3 11 3 9]';
Etho_Colors=[238 96 8;...% Orange: Same or adjacent yeast
    0 0 0;...%Black: Same or adjacent sucrose
    250 244 0;... %Yellow: Different substrate
    91 212 255]/255;%Light Blue: Different spot same substrate

%% Transition Probability Matrix
Type_Names=params.Subs_Names;
Type_Numbers=params.Subs_Numbers;%Numbers in Geometry vector
numtypes=length(Type_Names);
TrEvents=nan(numtypes,2*numtypes,size(Vero,1));

for lfly=1%:size(Vero,1)
    display(lfly)
    
    %% Temporary transition matrix: from all spots to all spots
    TrM=zeros(length(Geometry));
    for lvisit=1:length(Vero{lfly})-1
        Spotfrom=Vero{lfly}(lvisit,4);
        Spotto=Vero{lfly}(lvisit+1,4);
        % TrM: Number of transitions from element in row i to
        % element in col j happens. Each entry i,j has several elements.
        % Sum of the elements corresponds to the number of times this
        % transition happens: Tr(i,j).
        TrM(Spotfrom,Spotto)=TrM(Spotfrom,Spotto)+1;
    end
    
    %% Adjacent and non-adjacent spots
    Geometry=FlyDB(lfly).Geometry(1:18);
    Adjacent=false(length(Geometry));
    for lspot=1:length(Geometry)
        Diff2fSpot=FlyDB(lfly).WellPos(1:length(Geometry),:)-...
                repmat(FlyDB(lfly).WellPos(lspot,:),...
                length(Geometry),1);
        Dist2fSpots=sqrt(sum(((Diff2fSpot).^2),2)).*params.px2mm;
        Adjacent(lspot,:)=(Dist2fSpots<=Adj_Thr)';
    end
    
    %% Final transition info
    for ltype_from=Type_Numbers
        type_from_idxs=find(Geometry==ltype_from);% MODIFY FOR TYPES THAT ARE NOT SPOTS
        for ltype_to=Type_Numbers;% From all types (different spot)
            type_to_idxs=find(Geometry==ltype_to);%
            TrM_type=TrM(type_from_idxs,type_to_idxs);
            Adj_type=Adjacent(type_from_idxs,type_to_idxs);
            
            TrEvents(ltype_from,ltype_to,lfly)=sum(sum(TrM_type(Adj_type)));% All transitions to self and adjacent
            TrEvents(ltype_from,ltype_to+numtypes,lfly)=sum(sum(TrM_type(~Adj_type)));% All transitions to other
        end
        
    end
end