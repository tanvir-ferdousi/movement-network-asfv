function [] = saveGephiNodeList(fileName, N)
    % Generates a file with a list of nodes
    fid = fopen(fileName, 'w');
    fprintf(fid, 'Id\n');
    fprintf(fid, '%d\n', 1:N);
    fclose(fid);
end