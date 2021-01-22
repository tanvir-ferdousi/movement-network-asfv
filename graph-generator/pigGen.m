function Pigs = pigGen(PIG_STAT)
    sumStat = sum(PIG_STAT);
    NF = sumStat(1);
    NP = sumStat(2);
    Pigs = zeros(NF,1);
    FarmSizeCat = zeros(NF,1);
    
    %AvgPigs = PIG_STAT(:,2)./PIG_STAT(:,1);
    
    Ranges = [1 24; 25 49; 50 99; 100 199; 200 499; 500 999; 1000 6000];
    
    farmIndex = 1;
    for cat = 1:length(PIG_STAT)
        nfarm = PIG_STAT(cat,1);
        if nfarm ~= 0
            for i = farmIndex:(farmIndex+nfarm-1)
                FarmSizeCat(i) = cat;
            end
            farmIndex = farmIndex+nfarm;
        end
    end
    

    farmIndex = 1;
    for cat =1:length(PIG_STAT)
        rangeCat = Ranges(cat,:);
        lower = rangeCat(1);
        upper = rangeCat(2);
        
        nfarm = PIG_STAT(cat,1);
        npig = PIG_STAT(cat,2);
        
        if nfarm == 0
            continue;
        end
        
        catPigs = zeros(nfarm,1);
        
        pigSum = 0;
        for i=1:nfarm
            dif = npig - pigSum;
            
            if dif > lower
                if dif < upper
                    upper = dif;
                end
                
                catPigs(i) = round((upper-lower)*rand+lower);
                pigSum = pigSum + catPigs(i);
            else
                if dif > 0
                    catPigs(i) = dif;
                    pigSum = pigSum + catPigs(i);
                end
            end
        end
        
        % Adjustment
        dif = npig - pigSum;
        if dif > 0
            if dif > nfarm
                out = diff([0,sort(randperm(dif-1,nfarm-1)),dif]);
                catPigs = catPigs + out';
            else
                catPigs(i) = catPigs(i) + dif;
            end
        end
        
        Pigs(farmIndex:farmIndex+nfarm-1) = catPigs;
        farmIndex = farmIndex+nfarm;
    end

end