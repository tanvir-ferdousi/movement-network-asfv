function []=saveFarmEdgeList(fileName,A)
    
    N = length(A);
    
    % Generates a file with a list of edges
    fid = fopen(fileName, 'w');
    
    for fromFarm=1:N
        for toFarm=1:N
            if A(fromFarm,toFarm) > 0
                fprintf(fid, '%d\t%d\t%d\n',fromFarm,toFarm,A(fromFarm,toFarm));
            end
        end
    end
    
    fclose(fid);
end