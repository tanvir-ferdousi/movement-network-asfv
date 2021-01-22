function [D] = DistanceGen(A, N_TYPE, N, M, D_AVG_MAT, D_SE_MAT, D_MAX_MAT)
    D = zeros(N,N);
    
    M_COUNT = zeros(5,1);
    for i=1:5
        M_COUNT(i) = sum(N_TYPE == i);
    end
    
    %D_SD_MAT = D_SE_MAT.*sqrt(M_COUNT);
    Edges = zeros(M,M);
    for i=1:M
        for j=1:M
            srcs = find(N_TYPE == i); % Source of type i
            n = 0;
            for k=1:length(srcs)
                n = n + find(A(srcs(k),:) == 1)
                % Find all destinations of type 1:M. Count
            end
        end
    end
    
    for i=1:N
        for j=1:N
            srcType = N_TYPE(i);
            dstType = N_TYPE(j);
            
        end
    end
end