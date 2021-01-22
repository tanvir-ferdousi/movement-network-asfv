function [] = saveFarmList(fileName, N, N_TYPE)
    % Generates a file with a list of nodes
    fid = fopen(fileName, 'w');
    fprintf(fid, 'Id,Label\n');
    for n=1:N
        if N_TYPE(n) == 1
            fprintf(fid, '%d,BS\n',n);
        elseif N_TYPE(n) == 2
            fprintf(fid, '%d,Fa\n',n);
        elseif N_TYPE(n) == 3
            fprintf(fid, '%d,Fi\n',n);
        elseif N_TYPE(n) == 4
            fprintf(fid, '%d,M\n',n);
        elseif N_TYPE(n) == 5
            fprintf(fid, '%d,N\n',n);
        end
    end
    fclose(fid);
end