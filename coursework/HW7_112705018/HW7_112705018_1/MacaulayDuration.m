function [P,Value,MD] = MacaulayDuration(r,n,c,F)
    Value=0;
    P=0;%債券價格
    %r:債券殖利率 ; n:期數 ; c:票面利率 ; F:本金
    for i = 1:1:n
        P = P + c * F / ((1 + r) ^ i);
        Value = Value + i * c * F / ((1 + r) ^ i);
        if i == n
            P = P + F / ((1 + r) ^ i);
            Value = Value + n * F / ((1 + r) ^ i);
        end
    end

    MD = Value / P;  
    
end
