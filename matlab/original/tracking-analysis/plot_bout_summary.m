%% Plotting bouts summary
%% Plotting Rank-Freq distributions
Tracking_var='Overlapping bouts'
close all
for lsubs=1:2
figure('Position',[100 50 params.scrsz(3)-450 params.scrsz(4)-150],...
                'Color','w','Name',[params.Subs_Names{lsubs} ' Tracking ' Tracking_var]);
            
            %%% Rank-Freq distributions for Tracking
            hold on
            Inline=hist_bout_duration(DurInOB,Conditions,params,0);
            plot_rank_freq(Inline,params,lsubs,[],CondColors,FontSize,1,Fontname);
            set(gca,'box', 'off')
            xlabel('')
            ylims=get(gca,'YLim');xlims=get(gca,'XLim');
            
end
savefig_withname(1,'600','png',DataSaving_dir_temp,Exp_num,Exp_letter,'Bouts')