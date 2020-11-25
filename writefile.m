code = randi([0,1], 1, 100);
% code = ones(1, 100);
fileID = fopen('data.bin', 'w');
fwrite(fileID, code);
fclose(fileID);