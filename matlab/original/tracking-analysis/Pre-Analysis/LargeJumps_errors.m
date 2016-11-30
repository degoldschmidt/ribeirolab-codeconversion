function LargeJumps_errors(Allfilenames,Movies_idx,videoPath,Heads_SteplengthDir,Largejump_thr)
% LargeJumps_errors(Allfilenames,Movies_idx,videoPath,Heads_SteplengthDir,Largejump_thr)
% Detect large jumps due to video acquisition errors
px2mm=1/6.4353; % mm in 1 px
framerate=50;
for lfile=Movies_idx%1:length(Files)
    %%
%     filename='0003A01R02Cam03P0WT-CantonS.avi';%'0003A02R01Cam01P0WT-CantonS.avi';
    filename=Allfilenames{lfile}
    clear DB
    load([Heads_SteplengthDir 'DB-Heads ' filename(1:end-4) '.mat'])
    MovieObj=VideoReader([videoPath filename]);
    
    %%
    for arenaside=1:3
        arenaside
        BigJumps=find((DB(arenaside).Steplength/framerate/px2mm>=30)&(DB(arenaside).Steplength/framerate/px2mm<Largejump_thr))
        for jumpframe=BigJumps'
            jumpframe
            display(['Jumplength: ' num2str(DB(arenaside).Steplength(jumpframe)/framerate/px2mm)])
            clf
            if jumpframe>1
                Rawimage=read(MovieObj,[jumpframe-1 jumpframe+1]);
                imshow(Rawimage(:,:,1,1))%lframe))
                hold on
                plot(DB(arenaside).cBon(jumpframe-1,1),...
                    DB(arenaside).cBon(jumpframe-1,2),'om','MarkerSize',5,...
                    'MarkerFaceColor','m','LineWidth',1)
                pause
                secondf=2;
            else
                Rawimage=read(MovieObj,[jumpframe jumpframe+1]);
                secondf=1;
            end
            clf
            imshow(Rawimage(:,:,1,secondf))%lframe))
            hold on
            plot(DB(arenaside).cBon(jumpframe,1),...
                DB(arenaside).cBon(jumpframe,2),'or','MarkerSize',5,...
                'MarkerFaceColor','r','LineWidth',1)
            pause
            clf
            imshow(Rawimage(:,:,1,secondf+1))%lframe))
            hold on
            plot(DB(arenaside).cBon(jumpframe+1,1),...
                DB(arenaside).cBon(jumpframe+1,2),'oc','MarkerSize',5,...
                'MarkerFaceColor','c','LineWidth',1)
            
            pause
        end
    end
end