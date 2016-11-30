%%
% load('E:\Analysis Data\Experiment 0003\FlyPAD\2016-04-18\Analysis 2_1\MVYaaHuntS_Full.mat')

%% Merge all flies and extract condition index
Channels_num=[1:2:64;2:2:64];%[Yeast;Sucrose];
Dur=360000;
Cond_Idx_PAD=nan(size(Events.Ons,1)*size(Events.Ons,2)/2,1);%Condition index vector, each entry corresponds to 1 entry
lsubs=1;
flycounter=0;
for lrun=1:size(Events.Ons,1)
    for lchannel=Channels_num(lsubs,:)
        flycounter=flycounter+1;
        Cond_Idx_PAD(flycounter)=Events.Condition{lrun}(lchannel);
        
    end
end
valid_fly_idx=find(~isnan(Cond_Idx_PAD));
Cond_Idx_PAD=Cond_Idx_PAD(valid_fly_idx);

on_off_vector_temp1=2*ones(size(Events.Ons,1)*size(Events.Ons,2)/2,Dur);%cell(length(Cond_Idx_PAD),1);
flycounter=0;
for lrun=1:size(Events.Ons,1)
    for lchannel=Channels_num(lsubs,:)
         flycounter=flycounter+1;
%         on_off_vector_temp{flycounter}=2*ones(1,Dur);
        for lsip = 1:length(Events.Ons{lrun,lchannel})
            on_off_vector_temp1(flycounter,Events.Ons{lrun,lchannel}(lsip):Events.Offs{lrun,lchannel}(lsip))=1;
        end
    end
end
on_off_vector=on_off_vector_temp1(valid_fly_idx,:);%Entries are flies. Col1=Onset, Col2=Offset of sips.

%% Plot Ethogram
close all
Conditions=1:length(Events.ConditionLabel);
lcondcounter=0;
for lcond=Conditions
    lcondcounter=lcondcounter+1;
    subplot(2,ceil(length(Conditions)/2),lcondcounter)
    image(on_off_vector(Cond_Idx_PAD==lcond,:))
    colormap(gray(2))
    title(Events.ConditionLabel{lcond})
end

% 
% 
% SIPSBinary=2*ones(1,360000);
% for lsip=1:length(Events.Ons{1,1})
%     SIPSBinary(Events.Ons{1,1}(lsip):Events.Offs{1,1}(lsip))=1;
% end
% 
% BURSTSBinary=2*ones(1,360000);
% for lburst=1:length(Events.FeedingBurstOns{1,1})
%     BURSTSBinary(Events.FeedingBurstOns{1,1}(lburst):Events.FeedingBurstOffs{1,1}(lburst))=1;
% end

