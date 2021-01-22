function [K_IN,K_OUT] = generateDegrees(NF,F_TYPE)
    %BS Fa Fi M N
    M = 5;
    M_COUNT = zeros(5,1);
    for i=1:M
        M_COUNT(i) = sum(F_TYPE == i);
    end
    %M_COUNT = [3 64 123 17 30]';

    % AVG Degrees for different types
    K_IN_AVG = [0.67 0.92 1.05 11.73 0.77]';
    K_OUT_AVG = [1 2.08 1.74 0.46 3.07]';

    K_IN_MAX = [2 5 5 57 2];
    K_OUT_MAX = [1 8 12 3 12];

    K_IN_SE = [0.67 0.14 0.07 3.59 0.1]';
    K_OUT_SE = [0 0.26 0.15 0.18 0.62]';

    K_IN_SD = K_IN_SE.*sqrt(M_COUNT);
    K_OUT_SD = K_OUT_SE.*sqrt(M_COUNT);

    K_IN = zeros(NF,1);
    K_OUT = zeros(NF,1);
    
    for m=1:M
        farms = find(F_TYPE == m);
        
        nf = length(farms);
        
        if nf == 0
            continue
        end
        
        mn = K_IN_AVG(m);
        vr = (K_IN_SD(m))^2;
        mu_in = log((mn^2)/sqrt(vr+mn^2));
        sigma_in = sqrt(log(vr/(mn^2)+1));
        
        mn = K_OUT_AVG(m);
        vr = (K_OUT_SD(m))^2;
        mu_out = log((mn^2)/sqrt(vr+mn^2));
        sigma_out = sqrt(log(vr/(mn^2)+1));
        
        
        for n=1:(nf-1)
            done = 0;
            while done == 0
                rin = round(lognrnd(mu_in,sigma_in));
                if rin >= 0 && rin <= K_IN_MAX(m)
                    K_IN(farms(n)) = rin;
                    done = 1;
                end
            end
            
            done = 0;
            while done == 0
                rout = round(lognrnd(mu_out,sigma_out));
                if rout >= 0 && rout <= K_OUT_MAX(m)
                    K_OUT(farms(n)) = rout;
                    done = 1;
                end
            end 
        end
        
        skin = sum(K_IN(farms(1:(nf-1))));
        skout = sum(K_OUT(farms(1:(nf-1))));
        
        if skin < (nf*K_IN_AVG(m))
            dif = nf*K_IN_AVG(m) - skin;
            if dif < K_IN_MAX(m)
                K_IN(farms(nf)) = round(dif);
            else
                K_IN(farms(nf)) = K_IN_MAX(m);
            end
        end
        
        if skout < (nf*K_OUT_AVG(m))
            dif = nf*K_OUT_AVG(m) - skout;
            if dif < K_OUT_MAX(m)
                K_OUT(farms(nf)) = round(dif);
            else
                K_OUT(farms(nf)) = K_OUT_MAX(m);
            end
        end
        
    end

%     for n=1:NF
%         m = F_TYPE(n);
%         
%         mn = K_IN_AVG(m);
%         vr = (K_IN_SD(m))^2;
%         mu = log((mn^2)/sqrt(vr+mn^2));
%         sigma = sqrt(log(vr/(mn^2)+1));
%         
%         done = 0;
%         while done == 0
%             rin = round(lognrnd(mu,sigma));
%             if rin >= 0 && rin <= K_IN_MAX(m)
%                 K_IN(n) = rin;
%                 done = 1;
%             end
%         end
% 
%         mn = K_OUT_AVG(m);
%         vr = (K_OUT_SD(m))^2;
%         mu = log((mn^2)/sqrt(vr+mn^2));
%         sigma = sqrt(log(vr/(mn^2)+1));
%         
%         done = 0;
%         while done == 0
%             rout = round(lognrnd(mu,sigma));
%             if rout >= 0 && rout <= K_OUT_MAX(m)
%                 K_OUT(n) = rout;
%                 done = 1;
%             end
%         end
%     end
end