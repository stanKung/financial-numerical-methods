load(fullfile(fileparts(mfilename('fullpath')),'RainBowData.mat'),'FCHI','Nikin225','SP500','Date');
%{
using FCHI Nikin225 SP500 data (2022/05/06 ~ 2022/05/27(Fri.)) to forecast a call
maturity date = 2022/06/15, 2022/05/30(Mon.)~2022/06/15(Wed.) = 13 trading
days
%}
rng(20,'twister');
Obs = length(FCHI);
SD = [FCHI Nikin225 SP500];
TradingDayPerYear=252;
SimuPath = 20000;
SD_log=log(SD);
Sreturn = SD_log(2:end,:)-SD_log(1:end-1,:);
mu = mean(Sreturn)*TradingDayPerYear;
Vol = std(Sreturn)*sqrt(TradingDayPerYear);
SigMa = corr(Sreturn);
K = min(SD(1,:));
TradingDayPerYear=252;
dt=1/TradingDayPerYear;
B = chol(SigMa,'lower');
Z = zeros(3,13);
payoff = zeros(1,SimuPath);
r = 0.0274;% risk free rate in May 2022
for Spi=1:SimuPath
    for Fpi=1:13
        %Zt = (μ-0.5σ^2)t + σWt
        Z(:,Fpi) = (r-0.5*Vol.^2)*dt + sqrt(dt)*Vol.*(B*randn(3,1))';
    end
    %St = S0*exp( (μ-0.5σ^2)t + σWt )
    %St = exp( LN(S0) + Zt) 
    S_forecast = exp(cumsum( [SD_log(end,:);Z(:,:)'], 1));
	% 題目為 min-of-arithmetic-averages call；平均只含預測的13個交易日。
    a = mean(S_forecast(2:end,:),1); % 不包含2022/05/27的起始價格
    payoff(Spi) = max(min(a)-K,0);
end

dT = 13 / 252;
CallPrice = mean(payoff*exp(-r*dT));
SimuStdError = std(payoff*exp(-r*dT))/sqrt(SimuPath);
CI95 = CallPrice + [-1,1]*norminv(0.975)*SimuStdError;
fprintf('CallPrice = %.8f, standard error = %.8f\n',CallPrice,SimuStdError);
