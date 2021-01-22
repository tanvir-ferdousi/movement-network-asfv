function []=savePigsEdgeList(fileName,edgeList)

    % Generates a file with a list of edges
    fid = fopen(fileName, 'w');
    %fprintf(fid, 'Source,Target,Type\n');
    fprintf(fid, '%d\t%d\t1\n', edgeList(:,1:2)');
    fclose(fid);

end