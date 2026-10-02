S0=50;
K=48;
r=0.01;
T=1/12;
vol=0.22;
SimuPath=2000;

rng(15,'twister')
R = exp(-r * T);
MC_simulation = zeros(2, SimuPath);
S_Maturity = zeros(1, SimuPath);

for j = 1:SimuPath
    epsilon = randn(1, 1);
    S_T = S0 * exp((r - 0.5 * vol^2) * T + vol * sqrt(T) * epsilon);
    MC_simulation(1, j) = max(S_T - K, 0);  
    MC_simulation(2, j) = max(K - S_T, 0);  
    S_Maturity(1, j) = S_T;    
end

CallPrice = R*mean(MC_simulation(1,:));
PutPrice = R*mean(MC_simulation(2,:)); 

PC_parity_left = CallPrice - PutPrice;
PC_parity_right = R*mean(S_Maturity(1,:)) - K*R;

PC_parity = PC_parity_left - PC_parity_right;

verify = abs(PC_parity);
if verify < 1e-6
    verify = 'Put Call Parity holds.';
else
    verify = 'Put Call Parity does not hold.';
end
disp(verify)
% 上方是同一批路徑的現金流恆等式；另檢查理論 put-call parity。
TheoreticalParity = S0-K*R;
TheoryResidual = CallPrice-PutPrice-TheoreticalParity;
ParityStdError = std(R*(S_Maturity-K))/sqrt(SimuPath);
TheoryWithin95CI = abs(TheoryResidual)<=norminv(0.975)*ParityStdError;
fprintf('Theoretical parity residual = %.8f, MC standard error = %.8f\n',TheoryResidual,ParityStdError);
