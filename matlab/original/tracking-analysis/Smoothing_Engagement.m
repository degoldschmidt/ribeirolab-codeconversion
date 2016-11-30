function Engagement_p_2=Smoothing_Engagement(Engagement_p,InSpot,frames_range)
if nargin==2,frames_range=1:size(Engagement_p,1);end
range_conv=8;%50;
mu=0;
sigma=0.9;%6;

f2=@(sigma,mu,x) (1/sqrt(2*pi*(sigma^2)))*exp((-1/(2*sigma^2))*((x-mu).^2));%Gaussian
v=f2(sigma,mu,-range_conv/2:range_conv/2);v(1)=0;v(end)=0;
Engagement_p_2=zeros(size(Engagement_p));
errorcounter=1;
for lfly=1:size(Engagement_p,2)
    display(lfly)
    subs_logs=false(size(Engagement_p,1),size(Engagement_p,3));
    for lsubs=1:size(Engagement_p,3)
        filt_temp=conv(Engagement_p(:,lfly,lsubs),v);
%         Engagement_p_sm(:,lfly,lsubs)=filt_temp(1+range_conv/2:end-range_conv/2);
                Engagement_p_2(:,lfly,lsubs)=Engagement_p(:,lfly,lsubs);
        subs_logs(:,lsubs)=Engagement_p_2(:,lfly,lsubs)>0;
    end
    
    %% Sanity Check: Fly must not be engaged in two spots at the same time
    InAll_log=false(size(Engagement_p,1),1);
    for lsubs=1:size(Engagement_p,3)
        InAll_log=InAll_log|(subs_logs(:,lsubs));%Logical with true
        % when p_corr is > 0 for any substrate
    end
    
    TempIn=find(conv(double(InAll_log),[1 -1])==1);%Row vector
    TempOut=find(conv(double(InAll_log),[1 -1])==-1);%Row vector
    TempOut(TempOut==size(Engagement_p,1)+1)=...
        size(Engagement_p,1);
    if ~isempty(TempIn)
        for l_in=TempIn'
            temp=InSpot(l_in:TempOut(l_in==TempIn)-1,lfly);
            InSpots=unique(temp(temp~=0));
            if length(InSpots)>1
                display('Error: Simultaneous engagement in 2 spots')
                display(['frames: ' num2str(frames_range(l_in)) ' to ',...
                    num2str(frames_range(TempOut(l_in==TempIn)-1))])
                display(['Spots: ' num2str(unique(temp(temp~=0))')])
                %             clf
                %             plot(Engagement_p_corr(l_in:TempOut(l_in==TempIn)-1,lfly,1),'-b','LineWidth',2)
                %             clear maxp
                %             maxp(1)=max(Engagement_p_corr(l_in:TempOut(l_in==TempIn)-1,lfly,1));
                %             maxp(2)=max(Engagement_p_corr(l_in:TempOut(l_in==TempIn)-1,lfly,2));
                %             hold on
                %             plot(Engagement_p_corr(l_in:TempOut(l_in==TempIn)-1,lfly,2),'-r','LineWidth',2)
                %             font_style(['Fly Nº ' num2str(lfly) ', frames: ',...
                %                 num2str(l_in) ' to ' num2str(TempOut(l_in==TempIn)-1)],...
                %                 ['Duration[fr]'],['p(engagement)'])
                %             for lspot=InSpots'
                %                 htext=text(find(temp==lspot,1,'first'),0.1*max(maxp),num2str(lspot));
                %                 set(htext,'FontName','calibri','FontSize',20,'FontWeight','bold','Color','m')
                %             end
                %             pause
                %             errorcounter=errorcounter+1;
            end
        end
    else 
        display('This fly has no bouts for any substrate')
    end
end

% close all
% subplot(2,1,1)
% plot(v)
% subplot(2,1,2)
% plot(range_engagem,Engagement_p{lsubs}(range_engagem,lfly),'b')
% hold on
% plot(range_engagem,Engagement_p_corr{lsubs}(range_engagem,lfly),'-r')

% %% Finding Smoothing parameters manually
% close all
% figure
% lfly=1;%7;%32;%
% lsubs=1;%2;
% range_engagem=332663:345000;%296836:296854;%15988:25973;%
% range_sec=range_engagem/50/60;%min
% 
% range_conv=3000;%8;%34;
% p_engagement32=Engagement_p(range_engagem,lfly);%,lsubs);
% mu=0;
% sigma=range_conv/10;%0.9%4;
% 
% f2=@(sigma,mu,x) (1/sqrt(2*pi*(sigma^2)))*exp((-1/(2*sigma^2))*((x-mu).^2));
% 
% v=f2(sigma,mu,-range_conv/2:range_conv/2);
% v(1)=0;v(end)=0;%v(1:2)=0;v(end-2:end)=0;
% 
% filt=conv(p_engagement32,v);
% filt2=fastsmooth(p_engagement32,range_conv/2,3,1);
% 
% 
% display(size(p_engagement32))
% display(size(v))
% display(size(filt))
% display(max(filt))
% clf
% % subplot(2,1,1)
% % plot(v,'LineWidth',2)
% % font_style([],'frames',[],'normal','calibri',14)
% % subplot(2,1,2)
% plot(range_sec,filt(range_conv/2+1:end-range_conv/2),'-r','LineWidth',5)
% hold on
% 
% plot(range_sec,filt2,'-m','LineWidth',4)
% plot(range_sec,p_engagement32,'b','LineWidth',2)
% font_style([],'Time of Assay (min)','p(engagement)','normal','calibri',14)
% 
% % plot((range_engagem(1)-range_conv/2):(range_engagem(end)+range_conv/2),filt,'-r')
% % plot(range_engagem,filt(range_conv/2+1:end-range_conv/2),'-r','LineWidth',3)
% 
% plot([range_sec(find(filt(range_conv/2+1:end-range_conv/2)>0,1,'first')),...
%     range_sec(find(filt(range_conv/2+1:end-range_conv/2)>0,1,'first'))],...
%     [0 max(filt)],'--k')
% plot([range_sec(find(p_engagement32>0,1,'first')),...
%     range_sec(find(p_engagement32>0,1,'first'))],[0 max(filt)],'--g')
% delay_inzero=range_sec(find(p_engagement32>0,1,'first'))-range_sec(find(filt(range_conv/2+1:end-range_conv/2)>0,1,'first'))
% % ylim([0 1])