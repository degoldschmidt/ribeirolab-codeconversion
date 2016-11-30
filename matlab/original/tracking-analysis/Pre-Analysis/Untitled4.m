%%
Movies_idx=find(MATLAB2Bonsai(1:41)==0)';
counter=1;
for lfile=Movies_idx%(32:end)%1:length(Files)
    %%
%     filename='0003A01R03Cam02P0WT-CantonS.avi';%'0003A02R01Cam01P0WT-CantonS.avi';
    filename=Allfilenames{lfile}
    load([Heads_SteplengthDir 'DB-Heads ' filename(1:end-4) '.mat'],'DB')
      
    
    for arenaside=1:3
        Jumps_Idx=DB(arenaside).Uncorrected(:,1);%JumpStart;%find(log_jump);%Use JumpStart for smoothed
        if size(Jumps_Idx,1)>=5
            counter=counter+1;
        end
    end
end
display(counter)
%%
wrongframes{1}=[];
wrongframes{2}=[201306, 201320, 201324];
wrongframes{3}=[292164,292240,292245,292248,292250,292252,296582];
wrongframes{4}=[188287,280503];
wrongframes{5}=[56425, 56427, 56431, 56521, 56525, 57737, 57742, 57746, 57748, 58139, 88001];
wrongframes{6}=[106916, 282209,285499];
wrongframes{7}=[];
wrongframes{8}=[];
wrongframes{9}=[7343, 23189, 42984, 157340];
wrongframes{10}=[9626, 13073, 13103, 15158, 15497, 15584, 16469, 16568, 17507, 19094, 21083, 21092, 21239, 21281, 21578, 21584, 23840, 44006, 44012, 45620, 45629, 47816];
wrongframes{11}=[11225, 11297, 11300,11303, 11312, 11321, 11327, 11390, 14318, 14327, 14558, 14564, 14573, 14585, 14729, 15746, 16010, 16445, 16448, 16484, 16487, 16490, 16496, 16568, 16574, 17294, 17297, 17303, 17306];
