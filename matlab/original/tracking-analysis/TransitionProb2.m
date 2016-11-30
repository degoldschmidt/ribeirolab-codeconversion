function [TrEvents2,Etho_Tr2,Etho_Tr_Colors2, Etho_Tr2_2,Etho_Tr2_2Colors]=...
    TransitionProb2(DurInV,Heads_Sm,FlyDB,params)
%%% Note: Etho_Tr2 labels the IVI and number notation is as follows:
%%% numtypes=size(params.Subs_Names,1)
%%% 1:numtypes --> Fly inside substrate params.Subs_Names(#)
%%% numtypes+1:2*numtypes --> To same substrate
%%% 2*numtypes+1:3*numtypes --> To Adjacent (order given by params.Subs_Numbers)
%%% 3*numtypes+1:4*numtypes --> Non-adjacent
%%% 4*numtypes+1 --> Undefined
% Example for 2 subtrates Y and S
% 1 - Y
% 2 - S
% 3 - Same Y
% 4 - Same S
% 5 - Close Y
% 6 - Close S
% 7 - Far Y
% 8 - Far S
% 9 - Undefined
%
%%% Note: Etho_Tr2_2 labels the visits and number notation is as follows:
%%% 1:numtypes --> To same substrate
%%% numtypes+1:2*numtypes --> To Adjacent (order given by params.Subs_Numbers)
%%% 2*numtypes+1:3*numtypes --> Non-adjacent
%%% 3*numtypes+1 --> First visit
%%% 3*numtypes+2 --> Undefined
% Example for 2 substrates Y and S
% 1 - Same Y
% 2 - Same S
% 3 - Close Y
% 4 - Close S
% 5 - Far Y
% 6 - Far Y
% 7 - First Visit
% 8 - Undefined

Adj_Thr=16;%mm

Etho_Tr_Colors2=[120 120 120;...%1-Yeast Visit 241 195 27
    120 120 120;...%2- Sucrose Visit0 0 0
    213 94 0;... % 3 - Same Yeast (Orange)230 159 0
    255 255 255;... %4 - Same sucrose (white)
    0 114 178;... %5- Close yeast (light blue)86 80 233
    255 255 255;... %6- Close sucrose (white)
    0 0 0;... %7- Far yeast (black)
    255 255 255;... %8- Far sucrose (white)
    170 170 170]/255;...%9- First Visit, undefined
    
Etho_Tr2_2Colors=[230 159 0;... % 1 - Same Yeast (Orange)
    118 181 49;... %2 - Same sucrose (white)
    86 80 233;... %3- Close yeast (light blue)
    92 250 254;... %4- Close sucrose (white)
    0 0 0;... %5- Far yeast (black)
    255 0 255;... %6- Far sucrose (white)
    170 170 170;...%7- First Visit
    255 255 255]/255; %8 - Not a visit

%%% Etho_Tr2



if length(params.Subs_Numbers)>2
    error('The Ethogram colorcode was designed only for one or two substrates')
end
%% Transition Probability Matrix
Type_Names=params.Subs_Names;
Type_Numbers=params.Subs_Numbers;%Numbers in Geometry vector
numtypes=length(Type_Names);
TrEvents2=nan(numtypes,3*numtypes,size(DurInV,1));%rows:from substrates,cols:to same, to adjsubstrates,to farsubstrates
Etho_Tr2=(4*numtypes+1)*ones(params.numflies,params.MinimalDuration);
Etho_Tr2_2=(4*numtypes+2)*ones(params.numflies,params.MinimalDuration);

for lfly=1:size(DurInV,1)
    display(lfly)
    Geometry=FlyDB(lfly).Geometry(1:18);
    %% Adjacent and non-adjacent spots
    Adjacent=false(length(Geometry));
    SameSpots=logical(eye(length(Geometry)));
    for lspot=1:length(Geometry)
        Diff2fSpot=FlyDB(lfly).WellPos(1:length(Geometry),:)-...
            repmat(FlyDB(lfly).WellPos(lspot,:),...
            length(Geometry),1);
        Dist2fSpots=sqrt(sum(((Diff2fSpot).^2),2)).*params.px2mm;
        Adjacent(lspot,:)=(Dist2fSpots<=Adj_Thr)';
        Adjacent(lspot,lspot)=false;
    end
    
    %% Temporary transition matrix: from all spots to all spots
    TrM=zeros(length(Geometry));
    Tr_close_far=zeros(size(TrEvents2,1),size(TrEvents2,2));
    
    if size(DurInV{lfly},1)>=2
        for lvisit=1:size(DurInV{lfly},1)-1
            Spotfrom=DurInV{lfly}(lvisit,4);
            Spotto=DurInV{lfly}(lvisit+1,4);
            % TrM: Number of transitions from element in row i to
            % element in col j happens. Each entry i,j has several elements.
            % Sum of the elements corresponds to the number of times this
            % transition happens: Tr(i,j).
            TrM(Spotfrom,Spotto)=TrM(Spotfrom,Spotto)+1;
            Etho_Tr2(lfly,DurInV{lfly}(lvisit,2):DurInV{lfly}(lvisit,3))=find(Type_Numbers==Geometry(Spotfrom));%Geometry(Spotfrom)

            %% Transition to close or distant spot?
            Diff2fSpot=Heads_Sm{lfly}(DurInV{lfly}(lvisit,3)+1:DurInV{lfly}(lvisit+1,2)-1,:)-...
                repmat(FlyDB(lfly).WellPos(Spotfrom,:),...
                DurInV{lfly}(lvisit+1,2)-DurInV{lfly}(lvisit,3)-1,1);
            Dist2fSpots=sqrt(sum(((Diff2fSpot).^2),2)).*params.px2mm;
    %         distcovered=nansum(Steplength_Sm_c{lfly}(DurInV{lfly}(lvisit,3)+1:DurInV{lfly}(lvisit+1,2)-1))*params.px2mm/10;%cm
            

            %%% To count as an adjacent transition, fly needs to be inside the 
            %%% Adj_Thr during the IBI:
            if SameSpots(Spotfrom,Spotto)&&(sum(Dist2fSpots>Adj_Thr)==0)
                
                IBItype=numtypes+find(Type_Numbers==Geometry(Spotto));%numtypes+Geometry(Spotto);
                
                Tr_close_far((Type_Numbers==Geometry(Spotfrom)),(Type_Numbers==Geometry(Spotto)))=...
                    Tr_close_far((Type_Numbers==Geometry(Spotfrom)),(Type_Numbers==Geometry(Spotto)))+1;
                
            elseif    Adjacent(Spotfrom,Spotto)&&(sum(Dist2fSpots>Adj_Thr)==0)
                IBItype=2*numtypes+find(Type_Numbers==Geometry(Spotto));%numtypes+Geometry(Spotto);
                
                Tr_close_far((Type_Numbers==Geometry(Spotfrom)),numtypes+(Type_Numbers==Geometry(Spotto)))=...
                    Tr_close_far((Type_Numbers==Geometry(Spotfrom)),numtypes+(Type_Numbers==Geometry(Spotto)))+1;
                

            elseif ((~Adjacent(Spotfrom,Spotto))&&(~SameSpots(Spotfrom,Spotto)))||(sum(Dist2fSpots>Adj_Thr)~=0)%% IBI to ~adjacent
                IBItype=3*numtypes+find(Type_Numbers==Geometry(Spotto));
                Tr_close_far((Type_Numbers==Geometry(Spotfrom)),2*numtypes+find(Type_Numbers==Geometry(Spotto)))=...
                    Tr_close_far((Type_Numbers==Geometry(Spotfrom)),2*numtypes+find(Type_Numbers==Geometry(Spotto)))+1;
                
            else
                error('There is a type of transition missing')
            end
            Etho_Tr2(lfly,DurInV{lfly}(lvisit,3)+1:DurInV{lfly}(lvisit+1,2)-1)=IBItype;
            Etho_Tr2_2(lfly,DurInV{lfly}(lvisit+1,2):DurInV{lfly}(lvisit+1,3))=IBItype;
            if lvisit==1
                Etho_Tr2_2(lfly,DurInV{lfly}(lvisit,2):DurInV{lfly}(lvisit,3))=4*numtypes+1;
            end
        end
    elseif size(DurInV{lfly},1)==1
        Etho_Tr2_2(lfly,DurInV{lfly}(1,2):DurInV{lfly}(1,3))=4*numtypes+1;
    end
    TrEvents2(:,:,lfly)=Tr_close_far;
    
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
%%
for l=numtypes+1:4*numtypes+2
Etho_Tr2_2(Etho_Tr2_2==l)=l-numtypes;
% 1 - Same Y
% 2 - Same S
% 3 - Close Y
% 4 - Close S
% 5 - Far Y
% 6 - Far Y
% 7 - First Visit
% 8 - Undefined
end

