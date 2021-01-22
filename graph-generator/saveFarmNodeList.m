function []=saveFarmNodeList(fileName,ftype)
    fid = fopen(fileName, 'w');
    fprintf(fid, '%d\n', ftype);
    fclose(fid);
end