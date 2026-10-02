function [Call_BS,Put_BS,Put_parity,verify] = BS_put_parity(S,Z,r,T,Sigma)
% HW6 第2題：Black-Scholes公式，以 BS 賣權與 put-call parity 交叉驗證。
validateattributes(S,{'numeric'},{'scalar','real','finite','positive'});
validateattributes(Z,{'numeric'},{'scalar','real','finite','positive'});
validateattributes(r,{'numeric'},{'scalar','real','finite'});
validateattributes(T,{'numeric'},{'scalar','real','finite','nonnegative'});
validateattributes(Sigma,{'numeric'},{'scalar','real','finite','nonnegative'});
if T == 0
    Call_BS = max(S-Z,0); Put_BS = max(Z-S,0);
elseif Sigma == 0
    Call_BS = max(S-Z*exp(-r*T),0); Put_BS = max(Z*exp(-r*T)-S,0);
else
    d1 = (log(S/Z)+(r+0.5*Sigma^2)*T)/(Sigma*sqrt(T));
    d2 = d1-Sigma*sqrt(T);
    Call_BS = S*normcdf(d1)-Z*exp(-r*T)*normcdf(d2);
    Put_BS = Z*exp(-r*T)*normcdf(-d2)-S*normcdf(-d1);
end
Put_parity = Call_BS-S+Z*exp(-r*T);
verify = abs(Put_parity-Put_BS) <= 1e-10*max([1,S,Z]);
end
