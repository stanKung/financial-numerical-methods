x = [2 3 4
     3 4 5
     5 6 7]
writematrix(x, fullfile(fileparts(mfilename('fullpath')),'b.xls'))
% 版本無法使用 xlsread 因此使用 readmatrix
ans = readmatrix(fullfile(fileparts(mfilename('fullpath')),'Read.xls'), 'Sheet', 'Sheet1')
writematrix(ans, fullfile(fileparts(mfilename('fullpath')),'c.xls'))