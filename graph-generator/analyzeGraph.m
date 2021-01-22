TOT_ITER = 1000;
NF = 237;
M = 5;      % Node types

% Boar Stud, Farrow, Finishing, Market, Nursery
M_COUNT = [3 64 123 17 30]';
M_PROB = M_COUNT/sum(M_COUNT);


% Directed Association Model
DA_MATRIX = [0 0 0 0.01 0; 0 0.03 0.09 0.10 0.04; 0.01 0.10 0.07 0.40 0; 0 0 0 0.02 0; 0 0 0.13 0 0];

INDEG = zeros(M,TOT_ITER);
OUTDEG = zeros(M,TOT_ITER);

for iter=1:TOT_ITER
    % Node Generation
    F_TYPE = FTypeGen(M_PROB,NF);

    A = DAGraph(DA_MATRIX, NF, F_TYPE);

    K_IN = sum(A);
    K_OUT = sum(A,2);

    for i=1:M
        if sum(F_TYPE == i) == 0
            INDEG(i,iter) = 0;
            OUTDEG(i,iter) = 0;
        else
            INDEG(i,iter) = sum(K_IN(find(F_TYPE == i)))/sum(F_TYPE == i);
            OUTDEG(i,iter) = sum(K_OUT(find(F_TYPE == i)))/sum(F_TYPE == i);
        end
    end

end

ID = mean(INDEG,2)
OD = mean(OUTDEG,2)