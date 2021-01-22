function MV = movementGen(A,meanShipments,medianShipments)
    N = length(A);
    MV = zeros(N,N);
    
    mu = log(medianShipments);
    sigma2 = 2*log(meanShipments/medianShipments);
    
    for i=1:N
        for j=1:N
            if A(i,j) == 1
                MV(i,j) = lognrnd(mu,sqrt(sigma2));
            end
        end
    end
end