function edgeList = pigNetworkGen(scaledPigs, MV_Normal, withinProb)
    NP = sum(scaledPigs);
    NF = length(scaledPigs);
    
    betFarmEdges = 0;
    withFarmEdges = 0;
    
    edgeList = zeros((NP*(NP-1)), 3);
    
    % Within Farm Edges: Erdos Reyni    
    % Between Farm Edges: Based on distance
    
    pGloInd = 1;
    e = 0;
    for fromFarm = 1:NF
        % We are in farm f
        np = scaledPigs(fromFarm);     % no. of pigs in farm f
        
        if np == 0
            continue;
        end
        
        pIndStart = pGloInd;
        pIndEnd = pGloInd+np-1;
        
        for i = pIndStart:pIndEnd
            
            % Step 1: Within Farm edges
            for j = (i+1):pIndEnd
                if j == i
                    continue;
                end
                
                if rand <= withinProb
                    e = e + 1;
                    edgeList(e,1) = i;
                    edgeList(e,2) = j;
                    edgeList(e,3) = 1;
                    
                     e = e + 1;
                     edgeList(e,1) = j;
                     edgeList(e,2) = i;
                     edgeList(e,3) = 1;
                     withFarmEdges = withFarmEdges + 2;
                end
            end
            
        end
        
        pGloInd = pIndEnd+1;
        
    end
    
    % Step 2: Between Farm edges 
    probFromFarms = sum(MV_Normal,2)/max(sum(MV_Normal,2));
    pEndIndices = cumsum(scaledPigs);
    pStartIndices = pEndIndices - scaledPigs+1;
    
    for fromFarm=1:NF
        probFromFarm = probFromFarms(fromFarm);
        if probFromFarm == 0
            continue;
        end
        
        for toFarm = 1:NF
            
            if fromFarm == toFarm
                continue;
            end
            
            probToFarm = MV_Normal(fromFarm,toFarm);
            
            if probToFarm == 0
                continue;
            end


            for i = pStartIndices(fromFarm):pEndIndices(fromFarm)
                for j=pStartIndices(toFarm):pEndIndices(toFarm)
                    
                    if rand <= (probFromFarm*probToFarm)
                        e = e + 1;
                        edgeList(e,1) = i;
                        edgeList(e,2) = j;
                        edgeList(e,3) = 1;
                        
                          e = e + 1;
                          edgeList(e,1) = j;
                          edgeList(e,2) = i;
                          edgeList(e,3) = 1;
                          
                          betFarmEdges = betFarmEdges + 2;
                    end

                end
            end
        
        end
    end
    
    withFarmEdges
    betFarmEdges
    
    edgeList = edgeList(1:e,:);
    
end