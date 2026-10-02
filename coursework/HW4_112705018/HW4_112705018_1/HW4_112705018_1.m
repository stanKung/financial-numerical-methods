readmatrix(fullfile(fileparts(mfilename('fullpath')),'Read.xls'));
Y9999 = ans(3:end, 2); 
X2300 = ans(3:end, 3); 
X2800 = ans(3:end, 4); 
% [X2300, X2800] C = [Y9999]
C = [X2300, X2800] \ [Y9999] % 最小平方法
x = regress([Y9999], [X2300, X2800]) % 驗證
