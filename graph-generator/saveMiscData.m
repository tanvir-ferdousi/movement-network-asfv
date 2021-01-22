function []=saveMiscData(fileName,nf,snp,np)
    
    % Generates a file with a list of edges
    fid = fopen(fileName, 'w');
    
    fprintf(fid, '%d\t%d\t%d\n',nf,snp,np);
    
    fclose(fid);
end