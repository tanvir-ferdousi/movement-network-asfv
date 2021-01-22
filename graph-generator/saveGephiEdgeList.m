function [] = saveGephiEdgeList(fileName, edgeList)
    % Generates a file with a list of edges
    fid = fopen(fileName, 'w');
    fprintf(fid, 'Source,Target,Type\n');
    fprintf(fid, '%d,%d,Undirected\n', edgeList(:,1:2)');
    fclose(fid);
end