%% Finding Smoothing parameters manually
saveplot=1;
close all
FntName='arial';
FtSz=8;


lfly=100;%7;%32;%
lsubs=1;%2;
range_engagem=1:345000;%332663:345000;%296836:296854;%15988:25973;%
range_min=range_engagem/50/60;%min
numrows=4;
plotcounter=0;
figure('Position',[2100 50 1500 930],'Color','w',...
    'Name',['Smoothing Head mm test - fly' num2str(lfly) ', fr ' num2str(range_engagem(1)) '-' num2str(range_engagem(end))])

Exploit_Thr=0.1;
range_conv=15000;%8;%34;
p_engagement32=CumTimeV{1}(range_engagem,lfly);%Engagement_p(range_engagem,lfly);%,lsubs);
p_engagement32(logical(CumTimeV{2}(range_engagem,lfly)))=1;
mu=0;
sigma=range_conv/10;%0.9%4;

f2=@(sigma,mu,x) (1/sqrt(2*pi*(sigma^2)))*exp((-1/(2*sigma^2))*((x-mu).^2));

v=f2(sigma,mu,-range_conv/2:range_conv/2);
v(1)=0;v(end)=0;%v(1:2)=0;v(end-2:end)=0;

filt=conv(p_engagement32,v);
% filt2=fastsmooth(p_engagement32,range_conv/2,3,1);


display(size(p_engagement32))
display(size(v))
display(size(filt))
display(max(filt))
clf

%% Plotting Head Speed Ethogram
plotcounter=plotcounter+1;
subplot(numrows,1,plotcounter)

Etho_H_tmp=Etho_H;
Etho_H_tmp(Etho_H_tmp==9)=8;Etho_H_tmp(Etho_H_tmp==10)=9;
Etho_H_tmp_colors=[...
    [0.6 0.6 0.6]*255;...%1 - Gray (Resting)
    Color(1,:)*255;...%2 - Purple (slow micromovement)
    204 140 206;...%3 - Light Purple (fast-micromovement)
    124 143 222;...%4 -  Blueish violet (Slow walk)
    Color(3,:)*255;...%5 - Light Blue (Walking)
    Color(2,:)*255;...%6 - Green (Turn)
    255 0 0;...%7 - Red (Jump)
    238 96 8;...%9 - Orange(Yeast head slow micromovement)
    0 0 0]/255;%10 - Black (Sucrose)
image(Etho_H_tmp(lfly,range_engagem))
colormap(Etho_H_tmp_colors);
xlim(floor([0 length(range_engagem)]))
font_style([params.LabelsShort{params.ConditionIndex(lfly)},...
    ', Fly Nº ' num2str(lfly) ', ' num2str(range_engagem(1)),...
    '-' num2str(range_engagem(end))],'Time of Assay (frames)',...
    'Head-Speed  Etho','normal',FntName,FtSz)
set(gca,'box','off')
%% Plotting Head micromovements
plotcounter=plotcounter+1;
subplot(numrows,1,plotcounter)
hold on

area(range_min,CumTimeH{1}(range_engagem,lfly),'FaceColor',[238 96 8]/255,'EdgeColor',[238 96 8]/255)
area(range_min,CumTimeH{2}(range_engagem,lfly),'FaceColor','k','EdgeColor','k')
xlim(floor([range_engagem(1) range_engagem(end)])/50/60)

font_style([],'Time of Assay (min)','Head Micromovement Etho','normal',FntName,FtSz)
set(gca,'box','off')
%% Plotting Visit Ethogram and Smoothing
plotcounter=plotcounter+1;
X=filt(range_conv/2+1:end-range_conv/2);
subplot(numrows,1,plotcounter)
area(range_min,p_engagement32,'FaceColor','b','EdgeColor','b')
hold on
plot(range_min,X,'-r','LineWidth',2)
set(gca,'box','off')
plot([range_min(1) range_min(end)],[Exploit_Thr Exploit_Thr],'--','Color','m','Linewidth',1)
font_style([],'Time of Assay (min)','Visit Etho','normal',FntName,FtSz)

% % % % %%% Find local maxima
% % % %     temp=diff(X);
% % % %     temp(temp>0)=1;
% % % %     temp(temp<0)=-1;
% % % %     localmaxima=find(diff(temp)==-2);%frames locating local maxima in speed
% % % %     localminima=find(diff(temp)==2);%frames locating local minima in speed
% % % %     X2=X(localminima);
% % % %     X2(X2>Exploit_Thr)=nan;
% % % %     plot(range_min(localminima),X2,'og','MarkerFaceColor','g','MarkerSize',3)

%% Plotting Exploitation Periods
% Exp_starts_temp=find(conv(double(X>Exploit_Thr),[1 -1])==1);
% Exp_ends_temp=find(conv(double(X>Exploit_Thr),[1 -1])==-1)-1;
% 
% if ~isempty(Exp_starts_temp)
%     for lbout=Exp_starts_temp
%         find(
% 
% %     jump_starts=find(temp_conv==1);
% %     jump_ends=find(temp_conv==-1)-1;
% %     
% %     if ~isempty(jump_starts)
% %         for ljumpbout=1:length(jump_starts)
% %             startpoint=find(localminima<=jump_starts(ljumpbout),1,'last');
% %             endpoint=find(localminima>=jump_ends(ljumpbout),1,'first');
% %             Etho_Speed{lfly}(localminima(startpoint):localminima(endpoint))=7;% Classify as Jump
% %         end
% %     end

%% Saving plot
if (saveplot==1)
    savefig_withname(1,'600','png',DataSaving_dir_temp,Exp_num,Exp_letter,'Macrostructure')
end   

