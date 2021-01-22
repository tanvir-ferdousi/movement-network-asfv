function [edgeList]=edgeListGenDirected(A)
    % Generates the edge list from the adjacency matrix
    N = length(A);

    edgeList = zeros((N*(N-1)), 2);

    k = 0;
    for i=1:N
        for j=1:N
            if A(i,j) ~= 0
                k = k + 1;
                edgeList(k,1) = i;
                edgeList(k,2) = j;
            end
        end
    end
    
    edgeList = edgeList(1:k,:);

end