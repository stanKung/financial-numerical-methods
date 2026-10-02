% HW10：算術平均亞式賣權的模擬估價。
% 離散幾何平均控制變量與 randomized Sobol 區間估計。
% 觀察設定：平均包含 t=0 與其後60個觀察點。
clear; clc; close all;
S0=50; K=52; r=0.01; T=3/12; vol=0.22; Step=60;
SimuPath=200:50:10000;
ResultsRandomMC=zeros(3,numel(SimuPath)); ResultsQMC_CV=ResultsRandomMC;
R=exp(-r*T); rng(15,'twister');
times=(0:Step)*T/Step;
meanLogG=log(S0)+(r-vol^2/2)*mean(times);
varLogG=vol^2*sum(min(times(:),times),'all')/numel(times)^2;
sdLogG=sqrt(varLogG); d2=(meanLogG-log(K))/sdLogG; d1=d2+sdLogG;
Price_G_Analytical=R*(K*normcdf(-d2)-exp(meanLogG+varLogG/2)*normcdf(-d1));
% 以獨立pilot估計CV係數，額外成本另列，不計入圖上估價路徑數。
PilotPaths=4096;
[pilotA,pilotG]=asianPayoffs(randn(PilotPaths,Step),S0,K,r,T,vol);
covAG=cov(pilotA,pilotG);
if var(pilotG)>eps, beta=covAG(1,2)/var(pilotG); else, beta=0; end
Replicates=10; % 每個N分成10組獨立scramble，总估價路徑為N。
startTime=tic;
for i=1:numel(SimuPath)
    N=SimuPath(i);
    [payA,~]=asianPayoffs(randn(N,Step),S0,K,r,T,vol);
    discounted=R*payA; mcMean=mean(discounted); mcSE=std(discounted)/sqrt(N);
    ResultsRandomMC(:,i)=[mcMean;mcMean-norminv(.975)*mcSE;mcMean+norminv(.975)*mcSE];
    repMeans=zeros(Replicates,1);
    for rep=1:Replicates
        stream=scramble(sobolset(Step),'MatousekAffineOwen');
        U=net(stream,N/Replicates); Z=norminv(min(max(U,eps),1-eps));
        [payA,payG]=asianPayoffs(Z,S0,K,r,T,vol);
        repMeans(rep)=mean(R*payA-beta*(R*payG-Price_G_Analytical));
    end
    qMean=mean(repMeans); qSE=std(repMeans)/sqrt(Replicates);
    halfWidth=tinv(.975,Replicates-1)*qSE;
    ResultsQMC_CV(:,i)=[qMean;qMean-halfWidth;qMean+halfWidth];
end
elapsedTime=toc(startTime);
figure('Color','w','Position',[100 100 1100 620]); hold on;
set(gca,'Color','w','XColor','k','YColor','k','GridColor',[.65 .65 .65]);
plot(SimuPath,ResultsRandomMC(3,:),'r--','DisplayName','MC: 95% CI upper');
plot(SimuPath,ResultsRandomMC(2,:),'r-.','DisplayName','MC: 95% CI lower');
plot(SimuPath,ResultsQMC_CV(3,:),'b-','DisplayName','Randomized Sobol + CV: 95% CI upper');
plot(SimuPath,ResultsQMC_CV(2,:),'b:','DisplayName','Randomized Sobol + CV: 95% CI lower');
plot(SimuPath,ResultsQMC_CV(1,:),'k-','LineWidth',1.4,'DisplayName','Randomized Sobol + CV: mean');
xlabel('Total pricing paths (pilot: 4096 additional paths)','Color','k'); ylabel('Asian put price','Color','k');
title('Asian put: MC and randomized Sobol + CV','Color','k');
legend('show','Location','best','TextColor','k','Color','w','EdgeColor',[.5 .5 .5]); grid on; hold off;
outputDir=fileparts(mfilename('fullpath'));
exportgraphics(gcf,fullfile(outputDir,'HW10_112705018.png'),'Resolution',180,'BackgroundColor','white');
save(fullfile(outputDir,'HW10_112705018_results.mat'),'SimuPath','ResultsRandomMC','ResultsQMC_CV', ...
    'Price_G_Analytical','beta','PilotPaths','Replicates','elapsedTime','S0','K','r','T','vol','Step');

function [arithmeticPayoff,geometricPayoff]=asianPayoffs(Z,S0,K,r,T,vol)
dt=T/size(Z,2);
logPaths=log(S0)+[zeros(size(Z,1),1),cumsum((r-vol^2/2)*dt+vol*sqrt(dt)*Z,2)];
arithmeticPayoff=max(K-mean(exp(logPaths),2),0);
geometricPayoff=max(K-exp(mean(logPaths,2)),0);
end
