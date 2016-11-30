function [TrEvents,Etho_Tr,Etho_Tr_Colors]=TransitionProb(DurInV,Heads_Sm,FlyDB,params)
%%% Note: Etho_Tr number notation is as follows:
%%% numtypes=size(params.Subs_Names,1)
%%% 1:numtypes --> Fly inside substrate params.Subs_Names(#)
%%% numtypes+1:2*numtypes --> To Adjacent (order given by params.Subs_Numbers
%%% 2*numtypes+1:3*numtypes --> Non-adjacent

% 1 - YEast
% 2 - Sucrose
% 3 - To adjacent yeast
% 4 - To adjacent sucrose
% 5 - To non-adjacent yeast
% 6 - To non-adjacent sucrose
Adj_Thr=16;%mm

Etho_Tr_Colors=[241 195 27;...%1-Yeast Visit
    0 0 0;...%2- Sucrose Visit
    5 16 241;...%3- Dark Blue: IBI Same/Adjacent yeast
    204 0 0;...%4- Dark Red: IBI Same/Adjacent sucrose
    181 184 253;... %5-Light blue: IBI other yeast
    227 190 202;...%6-Light red: IBI other sucrose
    170 170 170]/255;%7-Undefined
if length(params.Subs_Numbers)>2
    error('The Ethogram colorcode was designed only for one or two substrates')
end
%% Transition Probability Matrix
Type_Names=params.Subs_Names;
Type_Numbers=params.Subs_Numbers;%Numbers in Geometry vector
numtypes=length(Type_Names);
TrEvents=nan(numtypes,2*numtypes,size(DurInV,1));%rows:from substrates,cols:to closesubstrates,to farsubstrates
Etho_Tr=7*ones(params.numflies,params.MinimalDuration);

for lfly=1:size(DurInV,1)
    display(lfly)
    Geometry=FlyDB(lfly).Geometry(1:18);
    %% Adjacent and non-adjacent spots
    Adjacent=false(length(Geometry));
    for lspot=1:length(Geometry)
        Diff2fSpot=FlyDB(lfly).WellPos(1:length(Geometry),:)-...
            repmat(FlyDB(lfly).WellPos(lspot,:),...
            length(Geometry),1);
        Dist2fSpots=sqrt(sum(((Diff2fSpot).^2),2)).*params.px2mm;
        Adjacent(lspot,:)=(Dist2fSpots<=Adj_Thr)';
    end
    
    %% Temporary transition matrix: from all spots to all spots
    TrM=zeros(length(Geometry));
    Tr_close_far=zeros(size(TrEvents,1),size(TrEvents,2));
    
    for lvisit=1:size(DurInV{lfly},1)-1
        Spotfrom=DurInV{lfly}(lvisit,4);
        Spotto=DurInV{lfly}(lvisit+1,4);
        % TrM: Number of transitions from element in row i to
        % element in col j happens. Each entry i,j has several elements.
        % Sum of the elements corresponds to the number of times this
        % transition happens: Tr(i,j).
        TrM(Spotfrom,Spotto)=TrM(Spotfrom,Spotto)+1;
        Etho_Tr(lfly,DurInV{lfly}(lvisit,2):DurInV{lfly}(lvisit,3))=find(Type_Numbers==Geometry(Spotfrom));%Geometry(Spotfrom)
        
        %% Transition to close or distant spot?
        Diff2fSpot=Heads_Sm{lfly}(DurInV{lfly}(lvisit,3)+1:DurInV{lfly}(lvisit+1,2)-1,:)-...
            repmat(FlyDB(lfly).WellPos(Spotfrom,:),...
            DurInV{lfly}(lvisit+1,2)-DurInV{lfly}(lvisit,3)-1,1);
        Dist2fSpots=sqrt(sum(((Diff2fSpot).^2),2)).*params.px2mm;
%         distcovered=nansum(Steplength_Sm_c{lfly}(DurInV{lfly}(lvisit,3)+1:DurInV{lfly}(lvisit+1,2)-1))*params.px2mm/10;%cm

        if Adjacent(Spotfrom,Spotto)&&(sum(Dist2fSpots>Adj_Thr)==0)%% IBI to adjacent
            IBItype=numtypes+find(Type_Numbers==Geometry(Spotto));%numtypes+Geometry(Spotto);
            Tr_close_far((Type_Numbers==Geometry(Spotfrom)),(Type_Numbers==Geometry(Spotto)))=Tr_close_far((Type_Numbers==Geometry(Spotfrom)),(Type_Numbers==Geometry(Spotto)))+1;
            
        elseif ~Adjacent(Spotfrom,Spotto)||(sum(Dist2fSpots>Adj_Thr)~=0)%% IBI to ~adjacent
            IBItype=2*numtypes+find(Type_Numbers==Geometry(Spotto));
            Tr_close_far((Type_Numbers==Geometry(Spotfrom)),numtypes+find(Type_Numbers==Geometry(Spotto)))=Tr_close_far((Type_Numbers==Geometry(Spotfrom)),numtypes+find(Type_Numbers==Geometry(Spotto)))+1;
        
        else
                error('There is a type of transition missing')
        end
        Etho_Tr(lfly,DurInV{lfly}(lvisit,3)+1:DurInV{lfly}(lvisit+1,2)-1)=IBItype;
    end
    
    TrEvents(:,:,lfly)=Tr_close_far;
%     %% Final transition info
%     for ltype_from=Type_Numbers
%         type_from_idxs=find(Geometry==ltype_from);% MODIFY FOR TYPES THAT ARE NOT SPOTS
%         for ltype_to=Type_Numbers;% From all types (different spot)
%             type_to_idxs=find(Geometry==ltype_to);%
%             TrM_type=TrM(type_from_idxs,type_to_idxs);
%             Adj_type=Adjacent(type_from_idxs,type_to_idxs);
%             
%             TrEvents(ltype_from==Type_Numbers,ltype_to==Type_Numbers,lfly)=sum(sum(TrM_type(Adj_type)));% All transitions to self and adjacent
%             TrEvents(ltype_from==Type_Numbers,find(Type_Numbers==ltype_to)+numtypes,lfly)=sum(sum(TrM_type(~Adj_type)));% All transitions to other
%         end
%         
%     end
    
end