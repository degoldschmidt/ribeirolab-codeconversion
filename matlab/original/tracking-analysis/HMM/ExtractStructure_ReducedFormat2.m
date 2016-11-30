clear
load dataReducedFormat7st.mat

numSearches = 200;
numHiddenStates = 5;
numObsSymbols = length(baseStates);

maxTrials=numSearches;
maxStates =numHiddenStates;


for ll=1:7
   newBaseStates{ll} = baseStates{ll}; % KICK OUT FLAKE DETACH
end
baseStates = newBaseStates;
for ll=1:length(dataC)
   dataC{ll}.n = dataC{ll}.n(dataC{ll}.n<8); % KICK OUT FLAKE DETACH
end



counter = 0
for ll = LevaIndx
    counter = counter+1;
    LevaSeq{counter} = dataC{ll}.n;
end
LevaLLOpt= [];
LevaLLVec = [-inf];
for ll=2:numSearches
    prior1 = normalise(rand(numHiddenStates,1));
    transmat1 = mk_stochastic(rand(numHiddenStates,numHiddenStates));
    obsmat1 = mk_stochastic(rand(numHiddenStates,numObsSymbols));
    [LevaLL, Levaprior, LevaTM, LevaEM] = dhmm_em(LevaSeq, prior1, transmat1, obsmat1, 'max_iter', 100,'verbose',0,'obs_prior_weight',0.1);
    LevaLLVec(ll) = LevaLL(end);
    if (LevaLL(end)>max(LevaLLVec(1:(ll-1))))
        LevaLLOpt = LevaLL(end);
        LevapriorOpt = Levaprior;
        LevaTMOpt = LevaTM;
        LevaEMOpt = LevaEM;
    end
    [ll LevaLL(end) LevaLLOpt]
end
save dataC_HMM_RF7st.mat dataC maxTrials maxStates numObsSymbols

counter = 0
for ll = achuIndx
    counter = counter+1;
    achuSeq{counter} = dataC{ll}.n;
end
AchuLLOpt= [];
AchuLLVec = [-inf];
for ll=2:numSearches
    prior1 = normalise(rand(numHiddenStates,1));
    transmat1 = mk_stochastic(rand(numHiddenStates,numHiddenStates));
    obsmat1 = mk_stochastic(rand(numHiddenStates,numObsSymbols));
    [AchuLL, Achuprior, AchuTM, AchuEM] = dhmm_em(achuSeq, prior1, transmat1, obsmat1, 'max_iter', 100,'verbose',0,'obs_prior_weight',0.1);
    AchuLLVec(ll) = AchuLL(end);
    if (AchuLL(end)>max(AchuLLVec(1:(ll-1))))
        AchuLLOpt = AchuLL(end);
        AchupriorOpt = Achuprior;
        AchuTMOpt = AchuTM;
        AchuEMOpt = AchuEM;
    end
    [ll AchuLL(end) AchuLLOpt]
end
save dataC_HMM_RF7st.mat dataC maxTrials maxStates numObsSymbols

counter = 0
for ll = oldoIndx
    counter = counter+1;
    oldoSeq{counter} = dataC{ll}.n;
end
OldoLLOpt= [];
OldoLLVec = [-inf];
for ll=2:numSearches
    prior1 = normalise(rand(numHiddenStates,1));
    transmat1 = mk_stochastic(rand(numHiddenStates,numHiddenStates));
    obsmat1 = mk_stochastic(rand(numHiddenStates,numObsSymbols));
    [OldoLL, Oldoprior, OldoTM, OldoEM] = dhmm_em(oldoSeq, prior1, transmat1, obsmat1, 'max_iter', 100,'verbose',0,'obs_prior_weight',0.1);
    OldoLLVec(ll) = OldoLL(end);
    if (OldoLL(end)>max(OldoLLVec(1:(ll-1))))
        OldoLLOpt = OldoLL(end);
        OldopriorOpt = Oldoprior;
        OldoTMOpt = OldoTM;
        OldoEMOpt = OldoEM;
    end
    [ll OldoLL(end) OldoLLOpt]
end
save dataC_HMM_RF7st.mat dataC maxTrials maxStates numObsSymbols

for lFile=1:length(dataC)
    [LevaLoglik(lFile),errLeva] = dhmm_logprob(dataC{lFile}.n, LevapriorOpt, LevaTMOpt, LevaEMOpt);
    [achuLoglik(lFile),errAchu] = dhmm_logprob(dataC{lFile}.n, AchupriorOpt, AchuTMOpt, AchuEMOpt);
    [oldoLoglik(lFile),errOldo] = dhmm_logprob(dataC{lFile}.n, OldopriorOpt, OldoTMOpt, OldoEMOpt);
    seqLen(lFile) = length(dataC{lFile}.n);
end

save dataC_HMM_RF7st.mat %dataC maxTrials maxStates numObsSymbols
%%%save dataC_HMM_RF.bak.mat %dataC maxTrials maxStates numObsSymbols


subplot(2,1,1)
vals = [achuLoglik./seqLen; oldoLoglik./seqLen]'
vals(isinf(vals))=nan
minVals = min(vals);
%vals(:,1) = vals(:,1)/minVals(1);
%vals(:,2) = vals(:,2)/minVals(2);
%vals(:,3) = vals(:,3)/minVals(3);
bar(vals)
ylabel('LogLikelihood')
xlabel('Seq')
title('LogLikelihood (avg per symbol)')
legend('Achuelean','Oldowan')

subplot(2,1,2)
vals = [achuLoglik./seqLen - oldoLoglik./seqLen]'
vals(isinf(vals))=nan
minVals = min(vals);
%vals(:,1) = vals(:,1)/minVals(1);
%vals(:,2) = vals(:,2)/minVals(2);
%vals(:,3) = vals(:,3)/minVals(3);
bar(vals)
ylabel('\Delta LogLikelihood')
xlabel('Seq')
title('LogLikelihood difference (evidence for Acheulean)')

predClass = -(vals>0) + 3
trueClass = [3 3 3 2 2 2 2 2 3 3 3 3 3 3 2 2 2 2 2 2 1 2];
for ll=1:length(trueClass)
    text(trueClass(ll),predClass(ll),num2str(ll))
end
axis([0.6 3.4 0.4 3.6])
axis square
xlabel('True class')
ylabel('Predicted class')


% subplot(2,2,1)
% imagesc(oldoTM)
% axis square
% colormap('bone')
% subplot(2,2,2)
% imagesc(oldoEM)
% axis square
% colormap('bone')
% subplot(2,2,3)
% imagesc(achuTM)
% axis square
% colormap('bone')
% subplot(2,2,4)
% imagesc(achuEM)
% axis square
% colormap('bone')




% filesToRead
% for lFile=1:length(dataC)
%     data = dataC{lFile};
%     numObsSymbols = length(dataC{lFile}.tM);
% 
%     % EMprior = ones(numHiddenStates,1)*ones(1,numObsSymbols)/numObsSymbols;%(ones(numHiddenStates,1)*PpriorObs);
%     % TMprior = ones(numHiddenStates)/numHiddenStates;
%     %
%     % PpriorObs=(sum(dataC.tM)/sum(sum(dataC.tM)))
%     %%% Assume that emission matrix has equal prior emission probabilities
%     % [TMest,EMest]=hmmtrain(dataC.n,TMprior,EMprior)
%     % [dummy logPseqEst] = hmmdecode(dataC.n, TMest, EMest);
%     % [dummy logPseqPrior] = hmmdecode(dataC.n, TMprior, EMprior);
%     % [logPseqEst logPseqPrior]
%     %%%likelystates = hmmviterbi(dataC.n, TMest, EMest)
%     % [TMest2,EMest2]=hmmtrain(dataC.n,TMest,EMest)
% 
%     LL={};
%     prior={}
%     TM={}
%     EM={}
%     PSTATES={}
%     maxStates = 5;
%     maxTrials = 5;
% 
%     clear loglik
%     for numHiddenStates = 1:maxStates
%         for lTrial = 1:maxTrials
%             [lFile numHiddenStates lTrial]
%             prior1 = normalise(rand(numHiddenStates,1));
%             transmat1 = mk_stochastic(rand(numHiddenStates,numHiddenStates));
%             obsmat1 = mk_stochastic(rand(numHiddenStates,numObsSymbols));
%             [LL{numHiddenStates,lTrial}, prior{numHiddenStates,lTrial}, TM{numHiddenStates,lTrial}, EM{numHiddenStates,lTrial}] = dhmm_em(dataC{lFile}.n, prior1, transmat1, obsmat1, 'max_iter', 100,'verbose',0);
%             loglik(numHiddenStates,lTrial) = dhmm_logprob(dataC{lFile}.n, prior1, TM{numHiddenStates,lTrial}, EM{numHiddenStates,lTrial});
%         end
%     end
% 
%     dataC{lFile}.LL=LL;
%     dataC{lFile}.prior=prior;
%     dataC{lFile}.TM=TM;
%     dataC{lFile}.EM=EM;
%     save ExtractStructure.mat
% 
%     [maxv,maxi]=max(loglik')
%     for ll=2:maxStates
%         maxTM{ll}=TM{ll,maxi(ll)};
%         maxEM{ll}=EM{ll,maxi(ll)};
%         PSTATES{ll} = HMMDECODE(dataC{lFile}.n,maxTM{ll},maxEM{ll})
%     end
%     dataC{lFile}.maxTM = TM;
%     dataC{lFile}.maxEM = EM;
%     dataC{lFile}.PSTATES = PSTATES;
% 
%     figure
%     plot(loglik,'b.')
%     hold on
%     plot(max(loglik'),'k-')
%     xlabel('# hidden States')
%     ylabel('Log likelihood')
%     title(dataC{lFile}.filename)
% end
% 
% 
% 
