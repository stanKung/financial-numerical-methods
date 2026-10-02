function [Premium, diagnostics] = Heston_Leastsquare(kappa,theta,v0,lambda,r,S0,K,rho,paths,steps,T,Option_type)
    
    % r 為貼現率，外國利率設為0。
    % 路徑採反射 Euler；此為離散近似，非精確 Heston 模擬。
    validateattributes(paths,{'numeric'},{'scalar','integer','>=',4});
    validateattributes(steps,{'numeric'},{'scalar','integer','positive'});
    validateattributes(T,{'numeric'},{'scalar','real','finite','positive'});
    validateattributes(S0,{'numeric'},{'scalar','real','finite','positive'});
    validateattributes(K,{'numeric'},{'scalar','real','finite','positive'});
    validateattributes(r,{'numeric'},{'scalar','real','finite'});
    validateattributes(rho,{'numeric'},{'scalar','real','finite','>=',-1,'<=',1});
    validateattributes(v0,{'numeric'},{'scalar','real','finite','nonnegative'});
    validateattributes(kappa,{'numeric'},{'scalar','real','finite','positive'});
    validateattributes(theta,{'numeric'},{'scalar','real','finite','positive'});
    validateattributes(lambda,{'numeric'},{'scalar','real','finite','nonnegative'});
    Option_type=validatestring(Option_type,{'p','c'});
    rng(20,'twister');
    
    if 2*kappa*theta<lambda^2
        error('The Feller condition falls');
    end
    dt = T / steps;
    
    [P, sigs] = gen_Heston_path(S0, T, r, kappa, theta, v0, rho, lambda, steps, paths);

    Cash_Space = zeros(paths, steps + 1);

    if Option_type == 'p'
        Cash_Space(:, end) = max(K - P(:, end), 0);
    elseif Option_type == 'c'
        Cash_Space(:, end) = max(P(:, end) - K, 0);
    else
        error('Option_type must be "p" or "c"');
    end

    for t = steps:-1:2
       
        if Option_type == 'p'
            InMoney = P(:, t) < K;
        elseif Option_type == 'c'
            InMoney = P(:, t) > K;
        end
        InMoney_index = find(InMoney);
        
        if ~isempty(InMoney_index)
            S_in_t = P(InMoney_index, t);
            
            DisCF_dt = Cash_Space(InMoney_index, t + 1) * exp(-r * dt);
            % 縮放不改變三次多項式空間，避免 normal equations 放大條件數。
            x=(S_in_t-mean(S_in_t))/max(std(S_in_t),eps);
            X=[ones(length(x),1),x,x.^2,x.^3];
            if size(X,1)<4 || rank(X)<4
                Beta=pinv(X)*DisCF_dt;
            else
                Beta=X\DisCF_dt;
            end
            CondExpValue = X * Beta;
      
            if Option_type == 'p'
                EarlyExValue = max(K - S_in_t, 0);
            elseif Option_type == 'c'
                EarlyExValue = max(S_in_t - K, 0);
            end
            
            EarlyExind = EarlyExValue > CondExpValue;
            Cash_Space(InMoney_index, t) = max(EarlyExind .* EarlyExValue, (1 - EarlyExind) .* DisCF_dt);
        end
        Cash_Space(~InMoney, t) = Cash_Space(~InMoney, t + 1) * exp(-r * dt);
    end

    Cash_Space(:, 1) = Cash_Space(:, 2) * exp(-r * dt);
    
    if Option_type=='p', immediate=max(K-S0,0); else, immediate=max(S0-K,0); end
    Premium = max(immediate,mean(Cash_Space(:,1)));
    if nargout > 1
        if Option_type=='p'
            terminal=max(K-P(:,end),0);
        else
            terminal=max(P(:,end)-K,0);
        end
        diagnostics=struct('prices',P,'variance',sigs, ...
            'europeanPrice',mean(terminal)*exp(-r*T), ...
            'europeanSE',std(terminal)*exp(-r*T)/sqrt(paths), ...
            'immediate',immediate);
    end
end

function [P, sigs] = gen_Heston_path(S0, T, r, kappa, theta, v0, rho, lambda, steps, NPaths)
    dt = T / steps;
    P = zeros(NPaths, steps + 1);
    sigs = zeros(NPaths, steps + 1);
    P(:, 1) = S0;    
    sigs(:, 1) = v0; 
    for i = 1:steps
        WT = mvnrnd([0, 0], [dt, rho * dt; rho * dt, dt], NPaths);
        P(:, i + 1) = P(:, i) .* exp((r - 0.5 * sigs(:, i)) * dt + sqrt(sigs(:, i)) .* WT(:, 1));
        sigs(:, i + 1) = abs(sigs(:, i) + kappa * (theta - sigs(:, i)) * dt + lambda * sqrt(sigs(:, i)) .* WT(:, 2));
    end
end