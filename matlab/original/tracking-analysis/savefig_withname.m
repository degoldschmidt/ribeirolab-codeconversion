function savefig_withname(save_fig,fig_res,fig_format,DataSaving_dir_temp,Exp_num,Exp_letter,SubFolder_name)
%savefig_withname(fig_res,fig_format,DataSaving_dir_temp,Exp_num,subfolder_name)
%Default: fig_res=600 and fig_format=png;
if nargin==0||nargin==1,
    savingfolderpath=cd;
    fig_res='600';fig_format='png';
    if nargin==0
        save_fig=0;
    end
else
    savingfolderpath=[DataSaving_dir_temp Exp_num '\Plots\' SubFolder_name];
end

%% Saving all figures
figHandles = findall(0,'Type','figure');
for n=1:numel(figHandles)
    F_handle=figure(figHandles(n));
    figname=get(F_handle,'Name');
    
    exist_log=exist(savingfolderpath,'dir');
    if exist_log==7
        print_fig
    else
        mkdir(savingfolderpath)
        print_fig
    end
end
    function print_fig
        if strfind(fig_format,'eps')
            set(gcf, 'Renderer', 'painters');
            print(F_handle,['-depsc2'],['-r' fig_res],[savingfolderpath '\'...
            Exp_num Exp_letter ' - ' figname '.' fig_format])
            
        else
            print(F_handle,['-d' fig_format],['-r' fig_res],[savingfolderpath '\'...
                Exp_num Exp_letter ' - ' figname '.' fig_format])
        end
        if save_fig
            saveas(F_handle,[savingfolderpath '\' Exp_num Exp_letter ' - ' figname '.fig'],'fig')
        end
    end
end

 
