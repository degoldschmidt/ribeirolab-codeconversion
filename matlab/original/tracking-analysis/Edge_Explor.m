function [ Binary_Edge ] = Edge_Explor(Heads_Sm,lfly,params)

[~,R]=cart2pol(Heads_Sm{lfly}(1:end-1,1),Heads_Sm{lfly}(1:end-1,2));
    Binary_Edge=2*ones(params.MinimalDuration,1);%undefined

    Binary_Edge(R*params.px2mm<=24.5)=0;%Not Edge
    Binary_Edge(R*params.px2mm>=26)=1;% Edge
    
    %%% Find all undefined events:
    temp_conv=conv(double((Binary_Edge==2)),[1 -1]);
    Undef_starts=find(temp_conv==1);
    Undef_ends=find(temp_conv==-1)-1;
    
    if Undef_starts(1)==1 % Don't correct the first one, since there is no reference
        Undef_starts2=Undef_starts(2:end)';
    elseif Undef_starts(1)>1
        Undef_starts2=Undef_starts';
    else
        error('Not undefined edge bouts for this fly?! --> Weird!')
    end
    
    for lUndefbout=Undef_starts2
        Binary_Edge(lUndefbout:Undef_ends(lUndefbout==Undef_starts))=Binary_Edge(lUndefbout-1);
    end
    
    Binary_Edge=Binary_Edge==1;



