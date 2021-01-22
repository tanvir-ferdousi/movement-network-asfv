function [A]=DAGraph(DA_MATRIX, NF, F_TYPE)
   
    [K_IN_ALLOC,K_OUT_ALLOC] = generateDegrees(NF,F_TYPE);
    % Edge Generation
    A = zeros(NF,NF);
    
    for srcNode=1:NF
        kOutMax = K_OUT_ALLOC(srcNode);
        srcType = F_TYPE(srcNode);
        
        for k=1:kOutMax
           
           % Compute the latest state of the degrees
           K_IN = sum(A)';
           K_OUT = sum(A,2);
           
           % determine a node type
           dstProbs = DA_MATRIX(srcType,:);
           cDstProbs = cumsum(dstProbs);
           r = intervalRand(min(cDstProbs),max(cDstProbs));
           dstTypes = find(r <= cDstProbs);
           dstType = dstTypes(1);
           
           % find a node with available/lowest kin from that type
           dstNodes = find(F_TYPE == dstType);
           
           K_DIFF = K_IN_ALLOC(dstNodes) - K_IN(dstNodes);
           [v,i] = max(K_DIFF);
           dstNode = dstNodes(i);
           
           % connect
           if srcNode ~= dstNode
               A(srcNode,dstNode) = 1;
           end
        end
    end
    
end