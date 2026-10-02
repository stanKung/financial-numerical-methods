function [IV,verify] = implied_vol(S,Z,r,T,LB,UB,MarketP,Option)
% HW8：二分法反推波動率，並以相同 BS 公式驗證市場價格。
validateattributes(S,{'numeric'},{'scalar','real','finite','positive'});
validateattributes(Z,{'numeric'},{'scalar','real','finite','positive'});
validateattributes(r,{'numeric'},{'scalar','real','finite'});
validateattributes(T,{'numeric'},{'scalar','real','finite','positive'});
validateattributes(LB,{'numeric'},{'scalar','real','finite','nonnegative'});
validateattributes(UB,{'numeric'},{'scalar','real','finite','positive'});
validateattributes(MarketP,{'numeric'},{'scalar','real','finite','nonnegative'});
Option=validatestring(Option,{'call','put'}); threshold=0.0001;
if LB>=UB, error('implied_vol:InvalidBracket','需 LB < UB。'); end
lowP=BSoption(LB); highP=BSoption(UB);
if MarketP<lowP-threshold || MarketP>highP+threshold
    error('implied_vol:Unbracketed','市場價格不在指定波動率区間的價格範圍。');
end
if abs(lowP-MarketP)<=threshold, IV=LB; verify='these two price are same.'; return; end
if abs(highP-MarketP)<=threshold, IV=UB; verify='these two price are same.'; return; end
for iteration=1:200
    IV=(LB+UB)/2; P=BSoption(IV);
    if abs(P-MarketP)<=threshold, verify='these two price are same.'; return; end
    if P>MarketP, UB=IV; else, LB=IV; end
end
error('implied_vol:NoConvergence','二分法未於200次內達到價格誤差要求。');
    function P=BSoption(sigma)
        if sigma==0
            c=max(S-Z*exp(-r*T),0); p=max(Z*exp(-r*T)-S,0);
        else
            d1=(log(S/Z)+(r+sigma^2/2)*T)/(sigma*sqrt(T)); d2=d1-sigma*sqrt(T);
            c=S*normcdf(d1)-Z*exp(-r*T)*normcdf(d2);
            p=Z*exp(-r*T)*normcdf(-d2)-S*normcdf(-d1);
        end
        if strcmp(Option,'call'), P=c; else, P=p; end
    end
end
