function []=savePigsNodeList(fileName,pigData)
    
    %NP = sum(pigData);
    NF = length(pigData);
    % Generates a file with a list of edges
    fid = fopen(fileName, 'w');
    
    pig = 1;
    for farm=1:NF
        np = pigData(farm);
        if np > 0
            for i=1:np
                fprintf(fid, '%d\t%d\n',pig,farm);
                pig = pig + 1;
            end
        end
    end
    
    fclose(fid);
end