%% Hidden Markov Model
% clear all
% %%% load ethograms (matrix in which each row is one fly)
% %%% Preparing data to run this script independently
% variables_folder='E:\Analysis Data\Experiment 0003\Variables\HMM\';
% load([variables_folder 'EthoH&BinaryBreak&params&clusters0003A 30-Apr-2015.mat'])
% % save([Variablesfolder 'EthoH&BinaryBreak&params&clusters'  Exp_num Exp_letter,...
% %     ' ' date '.mat'],'Etho_Speed','Binary_Break','Etho_H','params','Flies_cluster','clusterdividers','-v7.3')
% [Etho_Speed_new,Etho_colors_new,Etho_Colors_Labels] = Etho_Speed2New(345000,Etho_Speed,1);
% Etho_Speed_new(Etho_H==9)=6;
% Etho_Speed_new(Etho_H==10)=7;
% Etho_Speed_new(Binary_Break'==1)=8;
% Etho_Speed_new(Etho_H==0)=9;
% Etho_Colors_Labels{6}='Head Y';
% Etho_Colors_Labels{7}='Head S';
% Etho_Colors_Labels{8}='Break';
% Etho_Colors_Labels{9}='Undefined';
% SymbolsLabels={'Rest','Mm','Walk','Turn',
% %%
% % Etho_H(Etho_H==0)=8;
% Seqs=Etho_Speed_new;%Etho_H;
% %% Randomly select 90% of data to train
% %%% Select 5 flies of each data set and do six iterations.
% Conditions=1:4;
% numcond=nan(length(Conditions),1);
% Cond_rand_idx=cell(length(Conditions),1);
% lcondcounter=0;
% for lcond=Conditions
%     lcondcounter=lcondcounter+1;
%     temp=find(params.ConditionIndex==lcond);
%     Cond_rand_idx{lcondcounter}=temp(randperm(length(temp)));
%     numcond(lcondcounter)=sum(params.ConditionIndex==lcond);
% end
% %% Selection of number of hidden states (using all data)
% numSearches=5;%200;
% sampling_step=2;
% Time_range=1:sampling_step:40*params.framerate*60;%Only first 40 min.
% tryHS=[2 3 4 5 6];
% numtestflies=5;
% numCVrounds=floor(min(numcond)/numtestflies);
% start_idx=1:numtestflies:numCVrounds*numtestflies;
% numObsSymbols=length(unique(Seqs(:,Time_range)));
% 
% 
% paramsHMM.numSearches=numSearches;
% paramsHMM.sampling_step=sampling_step;
% paramsHMM.Time_range=Time_range;
% paramsHMM.Conditions=Conditions;
% paramsHMM.tryHS=tryHS;
% paramsHMM.numtestflies=numtestflies;
% paramsHMM.numCVrounds=numCVrounds;
% paramsHMM.Cond_rand_idx=Cond_rand_idx;
% paramsHMM.numObsSymbols=numObsSymbols;
% paramsHMM.SymbolsLabels=SymbolsLabels;
% 
% CVrounds=cell(numCVrounds,1);
% 
% for lCVround=1:numCVrounds
%     training_flies=[];
%     Cond_Idx=[];
%     for lcondcounter=1:length(Conditions)
%         test_temp=Cond_rand_idx{lcondcounter}(start_idx(lCVround):start_idx(lCVround)+numtestflies-1);
%         test_flies(numtestflies*lcondcounter-(numtestflies-1):...
%             numtestflies*lcondcounter)=test_temp;
%         training_flies=[training_flies,Cond_rand_idx{lcondcounter}(~ismember(Cond_rand_idx{lcondcounter},...
%             test_temp))];
%         Cond_Idx=[Cond_Idx;Conditions(lcondcounter)*ones(sum(~ismember(Cond_rand_idx{lcondcounter},...
%             test_temp)),1)];
%     end
%     
% %%% Creating structure to save info from different Nº of hidden states and all conditions
% FindnumHS=struct('numHiddenStates',num2cell(tryHS),'training_flies',cell(1,length(tryHS)),...
%     'Cond_Idx',cell(1,length(tryHS)),'test_flies',cell(1,length(tryHS)),'LL',cell(1,length(tryHS)),...
%     'prior_o',cell(1,length(tryHS)),'TransMat',cell(1,length(tryHS)),'EmMat',cell(1,length(tryHS)));
% lHScounter=0;
% for lHS=tryHS
%     
%     lHScounter=lHScounter+1;
%     numHiddenStates=lHS;
%     
%     display(['---- Nº of Hidden States: ' num2str(lHS) ' ----'])
%     
%     FindnumHS(lHScounter).training_flies=training_flies;
%     FindnumHS(lHScounter).Cond_Idx=Cond_Idx;
%     FindnumHS(lHScounter).test_flies=test_flies;
%     FindnumHS(lHScounter).LL=cell(length(Conditions),1);
%     FindnumHS(lHScounter).prior_o=cell(length(Conditions),1);
%     FindnumHS(lHScounter).TransMat=cell(length(Conditions),1);
%     FindnumHS(lHScounter).EmMat=cell(length(Conditions),1);
%     
%     lcondcounter=0;
%     for lcond=Conditions
%         lcondcounter=lcondcounter+1;
%         
%         LLVec = [-inf];
%         for lsearch=2:numSearches
%             %%% Initial guess of parameters
%             prior1 = normalise(rand(numHiddenStates,1));
%             transmat1 = mk_stochastic(rand(numHiddenStates,numHiddenStates));
%             obsmat1 = mk_stochastic(rand(numHiddenStates,numObsSymbols));
%             
%             %%% Improve guess of parameters using EM
            [LL,prior_o , TransMat,EmMat] =...
                dhmm_em(Seqs(training_flies(Cond_Idx==lcond),Time_range),...
                prior1, transmat1, obsmat1, 'max_iter', 100,'verbose',true);
%             %%% Note: this likelihood appears to be the sum of the
%             %%% loglikelihoods of single flies (meaning, the
%             %%% multiplications of the probabilities)
% 
%             LLVec(lsearch) = LL(end);
%             if (LL(end)>max(LLVec(1:(lsearch-1))))
%                 FindnumHS(lHScounter).LL{lcondcounter} = LL(end);
%                 FindnumHS(lHScounter).prior_o{lcondcounter} = prior_o;
%                 FindnumHS(lHScounter).TransMat{lcondcounter} = TransMat;
%                 FindnumHS(lHScounter).EmMat{lcondcounter} = EmMat;
%             end
%             display(['Nº HS: ' num2str(lHS) ', cond: ' num2str(lcond) ', search: ' num2str(lsearch)])
%             [LL(end) FindnumHS(lHScounter).LL{lcondcounter}]
%         end
%         CVrounds{lCVround}=FindnumHS;
%         save([variables_folder 'Finding_num_HS_MergedHeadEtho ' date '.mat'],'Seqs','Etho_Colors_Labels','CVrounds','paramsHMM','params','-v7.3')    
%     end
%     
% end
% CVrounds{lCVround}=FindnumHS;
% save([variables_folder 'Finding_num_HS_MergedHeadEtho ' date '.mat'],'Seqs','Etho_Colors_Labels','CVrounds','paramsHMM','params','-v7.3')
% end
%% BIC to select the number of HS
% clear all

% load(['E:\Analysis Data\Experiment 0003\Variables\HMM\Finding_num_HS_MergedHeadEtho 11-May-2015.mat'],'Seqs','Etho_Colors_Labels','CVrounds','paramsHMM','params')
Conditions=paramsHMM.Conditions;
BIC_rounds=cell(5,1);%One plot for each round

for lCVround=1:5
training_flies=CVrounds{lCVround}(1).training_flies;
Cond_Idx=CVrounds{lCVround}(1).Cond_Idx;

BIC=cell(length(paramsHMM.Conditions),1);
    
lcondcounter=0;
for lcond=Conditions
    lcondcounter=lcondcounter+1;
    display(['---Cond: ' num2str(lcond) '----'])
    BIC{lcondcounter}=nan(sum(Cond_Idx==lcond),length(paramsHMM.tryHS));
    lHScounter=0;
    for lHS=paramsHMM.tryHS
        lHScounter=lHScounter+1;
        display(['---- Nº HS: ' num2str(lHS) '----'])
        
        prior=CVrounds{lCVround}(lHScounter).prior_o{lcondcounter};
        TransMat=CVrounds{lCVround}(lHScounter).TransMat{lcondcounter};
        EmMat=CVrounds{lCVround}(lHScounter).EmMat{lcondcounter};
        num_params=size(prior,1)-1+...
            size(TransMat,1)*(size(TransMat,1)-1)+...
            size(EmMat,1)*(size(EmMat,2)-1);
        
        lflycounter=0;
        for lfly=training_flies(Cond_Idx==lcond)
            lflycounter=lflycounter+1
            Loglike= dhmm_logprob(Seqs(lfly,paramsHMM.Time_range), prior, TransMat, EmMat);

            BIC{lcondcounter}(lflycounter,lHScounter)=-2*Loglike+num_params*log(length(paramsHMM.Time_range));
        end
    end
end
BIC_rounds{lCVround}=BIC;
end
save(['E:\Analysis Data\Experiment 0003\Variables\HMM\BIC ' date '.mat'],'BIC','CVrounds','params','paramsHMM')
%% Plotting BIC for all conditions
FtSz=10;
FntName='arial';
close all
for lCVround=1:5
    figure('Position',[50 50 900 900], 'Name',['BIC 2 3 4 5 6 HS - Training Block ' num2str(lCVround)])
    lcondcounter=0;
    for lcond=Conditions
        lcondcounter=lcondcounter+1;
        subplot(2,ceil(length(Conditions)/2),lcondcounter)
        plot_boxplot_tiltedlabels(BIC_rounds{lCVround}{lcondcounter},{'2 HS','3 HS','4 HS','5 HS','6 HS'})
        font_style(params.LabelsShort{lcond},[],'BIC','normal',FntName,FtSz)
    end
end
% savefig_withname(0,'600','png',DataSaving_dir_temp,Exp_num,Exp_letter,...
%     'HMMs')
%% Plotting Emission matrices for all conditions (4 cols), selected HS (analysed)
close all
FtSz=8;
MkSz=3;
roundHS=[6 4 5 4; 5 3 4 4; 4 3 5 4; 4 4 6 5; 6 3 5 3];
ColorsCond=Colors(length(Conditions));
Short_Symbol_Labels={'R','M','W','T','J','Y','S','B','U'};
for lCVround=1:5
    figure('Position',[50 50 1800 900], 'Name',['Pr(Obs) vs Observations - Training Block ' num2str(lCVround)],'Color','w')
    maxNstates=max(roundHS(lCVround,:));
    lcondcounter=0;
    for lcond=Conditions
        lcondcounter=lcondcounter+1;
        for llHS=1:roundHS(lCVround,lcondcounter)
            subplot(maxNstates,length(Conditions),(llHS-1)*length(Conditions)+lcond)
            EmMat=CVrounds{lCVround}([CVrounds{1}.numHiddenStates]==roundHS(lCVround,lcondcounter)).EmMat{lcondcounter};
            h=plot(1:size(EmMat,2),EmMat(llHS,:),'-o',...
                'Color',ColorsCond(lcondcounter,:),'LineWidth',1,...
                'MarkerFaceColor',ColorsCond(lcondcounter,:),'MarkerSize',MkSz);
           if (lcondcounter==1) &&(llHS)==1
               font_style(params.LabelsShort{lcond},[],'p(Symbol|State)','normal',FntName,FtSz)
           elseif llHS==1
               font_style(params.LabelsShort{lcond},[],[],'normal',FntName,FtSz)
           else
               font_style([],[],[],'normal',FntName,FtSz)
           end
            set(gca,'XTick',[],'XTickLabel',[])
            ax=get(gca,'Ylim');
            thandle=text(1:size(EmMat,2),ax(1)*ones(1,length(Short_Symbol_Labels)),Short_Symbol_Labels);
            set(thandle,'HorizontalAlignment','right','VerticalAlignment','top',...
            'Rotation',20,'FontSize',FtSz-1,'FontName',FntName);
            box('off')
            
        end
    end
    suptitle(['Training Block ' num2str(lCVround)])  
end
savefig_withname(0,'600','png',DataSaving_dir_temp,Exp_num,Exp_letter,...
    'HMMs')
%% Plotting Emission matrices for every condition across CVrounds
close all
FtSz=8;
MkSz=3;
roundHS=[6 4 5 4; 5 3 4 4; 4 3 5 4; 4 4 6 5; 6 3 5 3];
ColorsCond=Colors(length(Conditions));

lcondcounter=0;
for lcond=Conditions
    lcondcounter=lcondcounter+1;
    figure('Position',[50 50 1800 900], 'Name',['Pr(Obs) vs Observations - ' params.LabelsShort{lcond}],'Color','w')
    maxNstates=max(roundHS(:,lcondcounter));
    for lCVround=1:5
        for llHS=1:roundHS(lCVround,lcondcounter)
            subplot(maxNstates,5,(llHS-1)*5+lCVround)
            EmMat=CVrounds{lCVround}([CVrounds{1}.numHiddenStates]==roundHS(lCVround,lcondcounter)).EmMat{lcondcounter};
            h=plot(1:size(EmMat,2),EmMat(llHS,:),'-o',...
                'Color',ColorsCond(lcondcounter,:),'LineWidth',1,...
                'MarkerFaceColor',ColorsCond(lcondcounter,:),'MarkerSize',MkSz);
            if (lCVround==1) &&(llHS)==1
               font_style(['Training Block ' num2str(lCVround)],[],'p(Symbol|State)','normal',FntName,FtSz)
           elseif llHS==1
               font_style(['Training Block ' num2str(lCVround)],[],[],'normal',FntName,FtSz)
           else
               font_style([],[],[],'normal',FntName,FtSz)
           end
            
            set(gca,'XTick',[],'XTickLabel',[])
            ax=get(gca,'Ylim');
            thandle=text(1:size(EmMat,2),ax(1)*ones(1,length(Short_Symbol_Labels)),Short_Symbol_Labels);
            set(thandle,'HorizontalAlignment','right','VerticalAlignment','top',...
            'Rotation',20,'FontSize',FtSz-2,'FontName',FntName);
            box('off')
            
        end
    end
suptitle(params.LabelsShort{lcond})    
end

savefig_withname(0,'600','png',DataSaving_dir_temp,Exp_num,Exp_letter,...
    'HMMs')
%% Classification performance ussing leave-one-out
%%% Randomly selecting training data
% Training_perc=0.2;
