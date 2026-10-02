function [E0,D0,TB,BC,verify] = Merton(V0,D,T,r,S,C,t,a)
    K1 = D + (1 - t) * C * D * T;
    K2 = 0;

    [call1, ~] = blsprice(V0, K1, r, T, S);

    E0 = call1;

    d1 = (log(V0/K1) + (r + 0.5 * S^2) * T) / (S * sqrt(T));
    d2 = d1 - S * sqrt(T);

    N_d2 = normcdf(d2);
    N_minus_d1 = normcdf(-d1);

    D0 = (D + C * D * T) * exp(-r * T) * N_d2 + V0 * (1 - a) * N_minus_d1;
    
    TB = (t * C * D * T) * exp(-r * T) * N_d2;

    BC = a * V0 * N_minus_d1;

    VL1 = E0 + D0;
    VL2 = V0 + TB - BC;
    if abs(VL1 - VL2) < 1e-6
        verify = 'these two price are same.\n'
    else
        verify = 'they are different.\n'
    end
end
