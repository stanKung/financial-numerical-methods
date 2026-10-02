load(fullfile(fileparts(mfilename('fullpath')),'cprice10.txt'))
a = cprice10([1, 3], [1, 3, 5])
writematrix(a, fullfile(fileparts(mfilename('fullpath')),'a.xls'))