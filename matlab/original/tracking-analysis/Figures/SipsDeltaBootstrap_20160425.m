%% FlyPAD DATA - Number of sips on yeast
% load('E:\Analysis Data\Experiment 0011\FlyPAD\26&27JointAnalysis\Tbh_1_12_Conds2,4,6,8\VCSTbhHuntS_1_12_20160424\VCSTbhHuntS_1_12_20160424_Full.mat')
ConditionsFlyPAD=[1:4];
lsubs=2;%2-yeast, 1-sucrose in Tbh experiment!
substratename={'yeast';'sucrose'};
Channels_num=[1:2:64;2:2:64];%[Yeast;Sucrose];
MaxSample=360000;

%% FlyPAD DATA - Number of sips on yeast
nsips_vector=nan(size(Events.Ons,1)*size(Events.Ons,2)/2,1);
Cond_Idx_PAD=nan(size(Events.Ons,1)*size(Events.Ons,2)/2,1);
counter=1;
for lrun=1:size(Events.Ons,1)
    for lchannel=Channels_num(lsubs,:)
        nsips_vector(counter)=numel(Events.Ons{lrun,lchannel});
        Cond_Idx_PAD(counter)=Events.Condition{lrun}(lchannel);
        counter=counter+1;
    end

end
nsips_vector=nsips_vector(~isnan(Cond_Idx_PAD));
Cond_Idx_PAD=Cond_Idx_PAD(~isnan(Cond_Idx_PAD));


