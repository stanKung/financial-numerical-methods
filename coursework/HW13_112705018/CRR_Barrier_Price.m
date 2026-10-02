function [VCallPrice,OCallPrice,ICallPrice] = CRR_Barrier_Price(S0,K,T,n,SigmaofV,rf,Barrier)
    deltaT=T/n;
    u=SigmaofV*sqrt(deltaT);
    d=-SigmaofV*sqrt(deltaT);
    p=(exp(rf*deltaT)-exp(d)) / (exp(u)-exp(d));
    q=(1-p);
    S=zeros(n+1,n+1);
    PayoffCall=zeros(n+1,n+1,4);
    S(1,1)=S0;
    ud=[u;d];
    pq=[p;q];

    for i=1:n
        for j=1:i
            S([j,j+1],i+1)=S(j,i)*exp(ud);        
        end
    end
    H_index = S(:,end)>Barrier; 
    PayoffCall(:,end,1) = max(S(:,end)-K,0);                
    PayoffCall(:,end,2) = max(S(:,end)-K,0).*H_index;       
    PayoffCall(:,end,3) = max(S(:,end)-K,0);                 
    PayoffCall(:,end,4) = max(S(:,end)-K,0).*(~H_index); % 到期觸障即生效                                
    R = exp(-rf*deltaT);
    for i=n:-1:1
        for j=1:i
            PayoffCall(j,i,1)= ([PayoffCall(j,i+1,1) PayoffCall(j+1,i+1,1)] * pq) * R;
            if S(j,i)>Barrier
                H_it = S(j:j+1,i+1)>Barrier;
                PayoffCall(j,i,2)= ([PayoffCall(j,i+1,2)*H_it(1) PayoffCall(j+1,i+1,2)*H_it(2)] * pq) * R;
            else
                PayoffCall(j,i,2) = 0;
            end
            if S(j,i)<=Barrier 
                PayoffCall(j,i,3)= ([PayoffCall(j,i+1,3) PayoffCall(j+1,i+1,3)] * pq) * R;
                PayoffCall(j,i,4)= PayoffCall(j,i,3); % 已觸障的節點價值等於普通買權
            elseif S(j+1,i+1)<=Barrier && Barrier<S(j,i)
                PayoffCall(j,i,3)= ([PayoffCall(j,i+1,3) PayoffCall(j+1,i+1,3)] * pq) * R;
                PayoffCall(j,i,4)= ([PayoffCall(j,i+1,4) PayoffCall(j+1,i+1,3)] * pq) * R;
            else
                PayoffCall(j,i,3)= ([PayoffCall(j,i+1,3) PayoffCall(j+1,i+1,3)] * pq) * R;
                PayoffCall(j,i,4)= ([PayoffCall(j,i+1,4) PayoffCall(j+1,i+1,4)] * pq) * R;
            end
        end
    end
    VCallPrice = PayoffCall(1,1,1);
    OCallPrice = PayoffCall(1,1,2);
    ICallPrice = PayoffCall(1,1,4);
end