function [BondP,Yield] = Yield(F,coupon,T,n,LB,UB,MarketP)
% HW7 第2題：債券價格隨殖利率遞減，因此價格過高時提高下界。
validateattributes(F,{'numeric'},{'scalar','real','finite','positive'});
validateattributes(coupon,{'numeric'},{'scalar','real','finite','nonnegative'});
validateattributes(T,{'numeric'},{'scalar','real','finite','positive'});
validateattributes(n,{'numeric'},{'scalar','integer','positive'});
validateattributes(MarketP,{'numeric'},{'scalar','real','finite','positive'});
validateattributes(LB,{'numeric'},{'scalar','real','finite'});
validateattributes(UB,{'numeric'},{'scalar','real','finite'});
dt=T/n; threshold=0.001;
if LB>=UB || 1+LB*dt<=0
    error('Yield:InvalidBracket','需 LB < UB 且 1+LB*T/n > 0。');
end
lowerP=Bond(LB); upperP=Bond(UB);
if MarketP>lowerP+threshold || MarketP<upperP-threshold
    error('Yield:Unbracketed','市場價格不在指定殖利率區間所涵蓋的價格範圍。');
end
if abs(lowerP-MarketP)<=threshold, Yield=LB; BondP=lowerP; return; end
if abs(upperP-MarketP)<=threshold, Yield=UB; BondP=upperP; return; end
for iteration=1:200
    Yield=(LB+UB)/2; BondP=Bond(Yield);
    if abs(BondP-MarketP)<=threshold, return; end
    if BondP>MarketP, LB=Yield; else, UB=Yield; end
end
error('Yield:NoConvergence','二分法未於200次內達到價格誤差要求。');
    function P=Bond(y)
        cf=repmat(F*coupon*dt,1,n); cf(end)=cf(end)+F;
        P=sum(cf./(1+y*dt).^(1:n));
    end
end
