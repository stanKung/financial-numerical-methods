function portfolio_figures(root,recomputeAsian)
figDir=fullfile(root,'figures'); resultDir=fullfile(root,'results');
if ~isfolder(figDir),mkdir(figDir);end
if ~isfolder(resultDir),mkdir(resultDir);end
blue=[.12 .32 .58]; teal=[.0 .52 .50]; orange=[.83 .36 .13]; gray=[.42 .46 .51];
checks=struct('Name',{},'Passed',{},'Evidence',{});

%% HW7: price-yield and duration approximation
y=linspace(.005,.12,101)'; prices=zeros(size(y));
for j=1:numel(y),prices(j)=MacaulayDuration(y(j),5,.04,100);end
[P0,~,MD]=MacaulayDuration(.05,5,.04,100); modified=MD/1.05;
approx=P0-P0*modified*(y-.05);
f=canvas(); tiledlayout(1,2,'TileSpacing','compact','Padding','loose');
nexttile; plot(y*100,prices,'Color',blue,'LineWidth',2);hold on;
plot(y*100,approx,'--','Color',orange,'LineWidth',1.6);
scatter(5,P0,40,teal,'filled');
xlabel('Yield (%)');ylabel('Bond price');title('Price and first-order approximation');
legend('Exact discounted cash flows','Duration approximation','Reference yield','Location','southwest');
nexttile; plot((y-.05)*100,prices-approx,'Color',teal,'LineWidth',2);yline(0,':','Color',gray);
xlabel('Yield change (percentage points)');ylabel('Exact minus approximate price');title('Approximation error');
heading(sprintf('Bond sensitivity | 5 years, 4%% coupon | Macaulay duration %.3f years',MD));
saveFigure(f,figDir,'hw07_bond_duration');
writetable(table(y,prices,approx,prices-approx,'VariableNames',{'Yield','ExactPrice','DurationApproximation','Error'}),fullfile(resultDir,'hw07_bond_duration.csv'));
[~,~,zeroMD]=MacaulayDuration(.05,5,0,100);
checks(end+1)=result('Bond identities',abs(zeroMD-5)<1e-12 && all(diff(prices)<0),sprintf('Zero coupon duration %.8f; coupon bond MD %.8f',zeroMD,MD));

%% HW8: synthetic IV recovery and bisection trace
S=100;r=.03;T=1;vol=.24; strikes=(75:5:125)'; recovered=zeros(size(strikes));errors=recovered;
for j=1:numel(strikes)
    [c,~]=blsprice(S,strikes(j),r,T,vol);
    recovered(j)=implied_vol(S,strikes(j),r,T,0,1,c,'call');
    [repriced,~]=blsprice(S,strikes(j),r,T,recovered(j));errors(j)=abs(repriced-c);
end
[target,~]=blsprice(100,105,r,T,vol); lower=0;upper=1; trace=[];
for j=1:200
    mid=(lower+upper)/2;[price,~]=blsprice(100,105,r,T,mid);
    trace(end+1,:)=[j,mid,abs(price-target)]; %#ok<AGROW>
    if abs(price-target)<=1e-4,break;end
    if price>target,upper=mid;else,lower=mid;end
end
f=canvas();tiledlayout(1,2,'TileSpacing','compact','Padding','loose');
nexttile;plot(strikes,recovered*100,'o-','Color',blue,'LineWidth',1.6);hold on;yline(24,'--','Color',orange);
ylim([23.95,24.05]);xlabel('Strike');ylabel('Implied volatility (%)');title('Recovering the synthetic input');legend('Recovered IV','Input: 24%','Location','best');
nexttile;semilogy(trace(:,1),max(trace(:,3),eps),'o-','Color',teal,'LineWidth',1.6);hold on;yline(1e-4,'--','Color',orange);
xlabel('Bisection iteration');ylabel('Absolute repricing error');title('One example: strike = 105');legend('Price error','Stopping tolerance','Location','best');
heading('Implied volatility | synthetic Black-Scholes quotes, not a market smile');saveFigure(f,figDir,'hw08_implied_volatility');
writetable(table(strikes,recovered,errors,'VariableNames',{'Strike','RecoveredIV','AbsolutePriceError'}),fullfile(resultDir,'hw08_iv_recovery.csv'));
writetable(array2table(trace,'VariableNames',{'Iteration','IV','AbsolutePriceError'}),fullfile(resultDir,'hw08_bisection.csv'));
checks(end+1)=result('IV recovery',all(errors<=1e-4) && all(abs(recovered-vol)<1e-4),sprintf('Maximum repricing error %.9g',max(errors)));

%% HW9: European Monte Carlo convergence with common payoff paths
rng(15,'twister');S=50;K=48;r=.01;T=1/12;vol=.22;
Ns=[200,500,1000,2000,5000,10000,20000,50000]';
terminal=S*exp((r-vol^2/2)*T+vol*sqrt(T)*randn(Ns(end),1));R=exp(-r*T);
cp=R*max(terminal-K,0);pp=R*max(K-terminal,0); prices=zeros(numel(Ns),2);ses=prices;
for j=1:numel(Ns),prices(j,:)=[mean(cp(1:Ns(j))),mean(pp(1:Ns(j)))];ses(j,:)=[std(cp(1:Ns(j))),std(pp(1:Ns(j)))]/sqrt(Ns(j));end
[bsCall,bsPut]=blsprice(S,K,r,T,vol);
f=canvas();tiledlayout(1,2,'TileSpacing','compact','Padding','loose');
nexttile;errorbar(Ns,prices(:,1),norminv(.975)*ses(:,1),'o-','Color',blue,'LineWidth',1.3);hold on;yline(bsCall,'--','Color',orange);
set(gca,'XScale','log');xlabel('Paths');ylabel('Call price');title('MC estimate with pointwise 95% intervals');legend('Monte Carlo','Black-Scholes','Location','best');
nexttile;residual=prices(:,1)-prices(:,2)-(S-K*R);paritySE=zeros(size(Ns));
for j=1:numel(Ns),paritySE(j)=std(R*(terminal(1:Ns(j))-K))/sqrt(Ns(j));end
errorbar(Ns,residual,norminv(.975)*paritySE,'o-','Color',teal,'LineWidth',1.3);hold on;yline(0,'--','Color',orange);
set(gca,'XScale','log');xlabel('Paths');ylabel('C - P - (S - K exp(-rT))');title('Theoretical put-call parity residual');
heading('European options | one fixed-seed simulation, nested sample sizes');saveFigure(f,figDir,'hw09_monte_carlo');
writetable(table(Ns,prices(:,1),prices(:,2),ses(:,1),ses(:,2),residual,paritySE,'VariableNames',{'Paths','CallPrice','PutPrice','CallSE','PutSE','ParityResidual','ParitySE'}),fullfile(resultDir,'hw09_monte_carlo.csv'));
checks(end+1)=result('European MC benchmark',abs(prices(end,1)-bsCall)<4*ses(end,1) && abs(residual(end))<4*paritySE(end),sprintf('Call %.8f; BS %.8f; MC SE %.8f',prices(end,1),bsCall,ses(end,1)));

%% HW10: Asian option convergence and interval widths
cache=fullfile(resultDir,'hw10_asian.mat');
if recomputeAsian || ~isfile(cache)
    fprintf('Running full HW10 simulation...\n');
    runScript(fullfile(root,'coursework','HW10_112705018','HW10_112705018.m'));
    copyfile(fullfile(root,'coursework','HW10_112705018','HW10_112705018_results.mat'),cache);close all;
end
A=load(cache);mc=A.ResultsRandomMC;qc=A.ResultsQMC_CV;
f=canvas();tiledlayout(1,2,'TileSpacing','compact','Padding','loose');
nexttile;plot(A.SimuPath,mc(3,:),'--','Color',orange);hold on;plot(A.SimuPath,mc(2,:),':','Color',orange);
plot(A.SimuPath,qc(3,:),'-','Color',blue);plot(A.SimuPath,qc(2,:),':','Color',blue);plot(A.SimuPath,qc(1,:),'-','Color',teal,'LineWidth',1.6);
xlabel('Pricing paths');ylabel('Asian put price');title('Estimates and approximate 95% intervals');
legend('MC upper','MC lower','Sobol + CV upper','Sobol + CV lower','Sobol + CV mean','Location','best','FontSize',9);
nexttile;loglog(A.SimuPath,mc(3,:)-mc(2,:),'Color',orange,'LineWidth',1.6);hold on;loglog(A.SimuPath,qc(3,:)-qc(2,:),'Color',blue,'LineWidth',1.6);
xlabel('Pricing paths');ylabel('95% interval width');title('Uncertainty versus sample size');legend('MC','Randomized Sobol + CV','Location','best');
heading('Arithmetic Asian put | 10 scrambles; CV pilot: 4096 additional paths');saveFigure(f,figDir,'hw10_asian_convergence');
writetable(table(A.SimuPath',mc(1,:)',mc(2,:)',mc(3,:)',qc(1,:)',qc(2,:)',qc(3,:)','VariableNames',{'Paths','MCPrice','MCLower','MCUpper','QMCPrice','QMCLower','QMCUpper'}),fullfile(resultDir,'hw10_asian.csv'));
checks(end+1)=result('Asian intervals',all(isfinite([mc(:);qc(:)])) && all(mc(2,:)<=mc(1,:) & mc(1,:)<=mc(3,:)) && all(qc(2,:)<=qc(1,:) & qc(1,:)<=qc(3,:)),sprintf('Final Sobol+CV %.8f; MC width %.8f; QMC width %.8f',qc(1,end),mc(3,end)-mc(2,end),qc(3,end)-qc(2,end)));

%% HW11: diagnostic paths and American/European comparison on same model
fprintf('Running Heston/LSMC demonstrations...\n');
[premium,D]=Heston_Leastsquare(2,.04,.04,.2,.03,100,100,-.5,12000,60,1,'p');
time=(0:60)/60;
f=canvas();tiledlayout(1,2,'TileSpacing','compact','Padding','loose');
nexttile;plot(time,D.prices(1:10,:)','LineWidth',1);xlabel('Years');ylabel('Underlying price');title('Ten simulated price paths');
nexttile;plot(time,100*sqrt(D.variance(1:10,:))','LineWidth',1);xlabel('Years');ylabel('Instantaneous volatility (%)');title('Volatility on the same paths');
heading('Heston dynamics | mean reversion and correlated price / variance shocks');saveFigure(f,figDir,'hw11_heston_paths');
spots=(70:5:130)';american=zeros(size(spots));european=american;ese=american;
for j=1:numel(spots)
    [american(j),diag]=Heston_Leastsquare(2,.04,.04,.2,.03,spots(j),100,-.5,12000,60,1,'p');
    european(j)=diag.europeanPrice;ese(j)=diag.europeanSE;
end
intrinsic=max(100-spots,0);
f=canvas();tiledlayout(1,2,'TileSpacing','compact','Padding','loose');
nexttile;plot(spots,american,'o-','Color',blue,'LineWidth',1.7);hold on;plot(spots,european,'s--','Color',teal,'LineWidth',1.5);plot(spots,intrinsic,':','Color',gray,'LineWidth',1.6);
xlabel('Initial underlying price');ylabel('Put value');title('American exercise versus maturity-only payoff');legend('American: LSMC','European: same Heston paths','Immediate exercise','Location','best');
nexttile;plot(spots,american-european,'o-','Color',orange,'LineWidth',1.7);yline(0,':','Color',gray);
xlabel('Initial underlying price');ylabel('American estimate minus European estimate');title('Estimated early-exercise premium');
heading('Heston put | K=100, T=1, r=3%, foreign rate=0 | 12000 paths / 60 steps');saveFigure(f,figDir,'hw11_american_put');
writetable(table(spots,american,european,ese,intrinsic,american-european,'VariableNames',{'Spot','AmericanLSMC','EuropeanMC','EuropeanSE','ImmediateExercise','EstimatedEarlyExercisePremium'}),fullfile(resultDir,'hw11_american_put.csv'));
writetable(array2table([time',D.prices(1:10,:)',D.variance(1:10,:)']),fullfile(resultDir,'hw11_sample_paths.csv'));
checks(end+1)=result('American immediate exercise',all(american>=intrinsic-1e-10) && all(isfinite(american)) && all(D.variance(:)>=0),sprintf('ATM American %.8f; same-path European %.8f; regression is in-sample',premium,D.europeanPrice));

%% HW12: correlated forecasts and discounted payoff distribution
fprintf('Running rainbow option demonstration...\n');
Q=runScript(fullfile(root,'coursework','HW12_112705018','HW12_112705018.m'));
rng(44,'twister'); paths=zeros(14,3,10);paths(1,:,:)=repmat(reshape(Q.SD(end,:),1,3,1),1,1,10);
for k=1:10
    for t=2:14
        z=randn(1,3)*Q.B';paths(t,:,k)=paths(t-1,:,k).*exp((Q.r-.5*Q.Vol.^2)*Q.dt+sqrt(Q.dt)*Q.Vol.*z);
    end
end
f=canvas();tiledlayout(1,2,'TileSpacing','compact','Padding','loose');
nexttile;hold on;colors=[blue;orange;teal]; labels={'FCHI','Nikkei 225','S&P 500'};
for j=1:3
    for k=1:10
        h=plot(0:13,100*paths(:,j,k)/paths(1,j,k),'Color',colors(j,:),'LineWidth',.8);
        if k==1,h.DisplayName=labels{j};else,h.HandleVisibility='off';end
    end
end
xlabel('Forecast trading day');ylabel('Normalized price (day 0 = 100)');title('Correlated GBM: ten paths per asset');legend('show','Location','best');
nexttile;discounted=Q.payoff*exp(-Q.r*Q.dT);histogram(discounted,35,'FaceColor',blue,'EdgeColor','none');hold on;xline(Q.CallPrice,'--','Color',orange,'LineWidth',1.8);
xlabel('Discounted option payoff');ylabel('Simulated paths');title(sprintf('Price %.2f | MC standard error %.2f',Q.CallPrice,Q.SimuStdError));
heading('Rainbow call on minimum arithmetic average | 13 forecast days, 20000 paths');saveFigure(f,figDir,'hw12_rainbow_option');
writetable(table(Q.CallPrice,Q.SimuStdError,Q.CI95(1),Q.CI95(2),Q.K,'VariableNames',{'Price','StandardError','Lower95','Upper95','Strike'}),fullfile(resultDir,'hw12_rainbow_summary.csv'));
writetable(table(discounted','VariableNames',{'DiscountedPayoff'}),fullfile(resultDir,'hw12_discounted_payoffs.csv'));
checks(end+1)=result('Rainbow sampling error',abs(Q.SimuStdError-std(discounted)/sqrt(Q.SimuPath))<1e-12 && numel(Q.a)==3 && size(Q.S_forecast,1)==14,sprintf('Price %.8f; SE %.8f; 13 forecast observations',Q.CallPrice,Q.SimuStdError));

%% HW13: barrier sensitivity and independent in-out identity
barriers=(50:1:100)';vanilla=zeros(size(barriers));out=vanilla;inside=vanilla;
for j=1:numel(barriers),[vanilla(j),out(j),inside(j)]=CRR_Barrier_Price(100,110,2,50,.3,.1,barriers(j));end
residual=inside+out-vanilla;[v90,o90,i90]=CRR_Barrier_Price(100,110,2,50,.3,.1,90);
f=canvas();tiledlayout(1,2,'TileSpacing','compact','Padding','loose');
nexttile;plot(barriers,out,'Color',blue,'LineWidth',2);hold on;plot(barriers,inside,'Color',teal,'LineWidth',2);plot(barriers,vanilla,'--','Color',gray,'LineWidth',1.6);xline(90,':','Color',orange);
xlabel('Down barrier');ylabel('Call option value');title('Barrier sensitivity on a 50-step CRR tree');legend('Knock-out','Knock-in','Vanilla','Assignment barrier: 90','Location','southoutside','NumColumns',2);
nexttile;b=bar(categorical({'Knock-in','Knock-out','Sum','Vanilla'},{'Knock-in','Knock-out','Sum','Vanilla'}),[i90,o90,i90+o90,v90],'FaceColor','flat');b.CData=[teal;blue;orange;gray];
ylabel('Call option value');title(sprintf('In-out parity | max residual %.2g',max(abs(residual))));
heading('Down-barrier calls | S=100, K=110, T=2, volatility=30%, r=10%');saveFigure(f,figDir,'hw13_barrier_options');
writetable(table(barriers,vanilla,out,inside,residual,'VariableNames',{'Barrier','Vanilla','KnockOut','KnockIn','ParityResidual'}),fullfile(resultDir,'hw13_barrier_options.csv'));
checks(end+1)=result('Barrier parity and monotonicity',max(abs(residual))<1e-9 && all(diff(out)<=1e-9) && all(diff(inside)>=-1e-9),sprintf('Barrier 90: vanilla %.8f / out %.8f / in %.8f',v90,o90,i90));

writetable(struct2table(checks),fullfile(resultDir,'validation_summary.csv'));
assert(all([checks.Passed]),'A demonstration validation failed; inspect validation_summary.csv.');
settings=struct('MATLAB',version,'GeneratedAt',char(datetime('now','Format','yyyy-MM-dd HH:mm:ss')), ...
    'Heston',struct('kappa',2,'theta',.04,'v0',.04,'lambda',.2,'r',.03,'rho',-.5,'T',1,'K',100,'paths',12000,'steps',60,'seed',20,'foreignRate',0), ...
    'Asian',struct('seed',15,'S0',A.S0,'K',A.K,'r',A.r,'T',A.T,'vol',A.vol,'steps',A.Step,'pilotPaths',A.PilotPaths,'scrambles',A.Replicates), ...
    'European',struct('seed',15,'S0',50,'K',48,'r',.01,'T',1/12,'vol',.22), ...
    'Rainbow',struct('seed',20,'plotSeed',44,'paths',20000,'forecastDays',13,'r',Q.r));
fid=fopen(fullfile(resultDir,'experiment_settings.json'),'w','n','UTF-8');fprintf(fid,'%s',jsonencode(settings,'PrettyPrint',true));fclose(fid);
end

function s=runScript(file)
run(file); names=who;s=struct;
for k=1:numel(names),if ~strcmp(names{k},'file'),s.(names{k})=eval(names{k});end,end
end
function f=canvas
f=figure('Color','w','Position',[100,100,1240,620]);
if isprop(f,'Theme'), f.Theme='light'; end
end
function saveFigure(f,folder,name)
axesList=findall(f,'Type','axes');
for ax=axesList'
    set(ax,'Color','w','XColor',[.15 .18 .23],'YColor',[.15 .18 .23], ...
        'GridColor',[.75 .78 .82],'FontName','Arial','FontSize',11,'Box','off');grid(ax,'on');
end
set(findall(f,'Type','text'),'Color',[.10 .14 .20],'FontName','Arial');
leg=findall(f,'Type','legend');set(leg,'Color','w','TextColor',[.10 .14 .20],'EdgeColor',[.8 .82 .85]);
exportgraphics(f,fullfile(folder,[name,'.png']),'Resolution',220,'BackgroundColor','white');close(f);
fprintf('Saved %s.png\n',name);
end
function r=result(name,passed,evidence)
r=struct('Name',name,'Passed',logical(passed),'Evidence',evidence);
end

function heading(varargin)
h=sgtitle(varargin{:});h.Color=[.1 .14 .2];h.FontName='Arial';h.FontSize=13;
end
