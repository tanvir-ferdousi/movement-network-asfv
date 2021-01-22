function [F_TYPE]=FTypeGen(M_PROB,N)
    F_TYPE = zeros(N,1);
    CM_PROB = cumsum(M_PROB);
    for i=1:N
        r = rand;
        typeIndices = find(r <= CM_PROB);
        typeIndex = typeIndices(1);
        F_TYPE(i) = typeIndex;
    end
end