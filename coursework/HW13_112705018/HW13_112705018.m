S0 = 100;
K = 110;
T = 2;
StepN = 50;
SigmaofV = 0.3;
rf = 0.1;
Barrier =90; %此處設定為下界失效型障礙選擇權(Barrier不應設定高於S0與K)
payout = 0;
[VCallPrice,OCallPrice,ICallPrice] = CRR_Barrier_Price(S0,K,T,StepN,SigmaofV,rf,Barrier);

knockinCallPrice = ICallPrice;

knockoutCallPrice = OCallPrice;

vanillaCallPrice = VCallPrice;
%By In-Out Parity, knock-in call =vanilla call - knockout call
knockinCall = vanillaCallPrice - knockoutCallPrice;


disp(['使用in-out parity算出的knock-in call price與直接算knock-in call price相差 : ',num2str(knockinCallPrice - knockinCall)])
error_term = 1e-6; %誤差
if abs(knockinCallPrice - knockinCall ) < error_term
    disp('In-Out Parity 成立')
else
    disp('In-Out Parity 不成立')
end


