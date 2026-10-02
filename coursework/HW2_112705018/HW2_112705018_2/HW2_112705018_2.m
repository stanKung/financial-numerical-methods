% 版本無法使用 xlsread 因此使用 readmatrix
ans = readmatrix(fullfile(fileparts(mfilename('fullpath')),'Read.xls'), 'Sheet', 'Sheet1')

% 刪除 NaN 的值
ans = rmmissing(ans)

% 刪除最左邊的日期列
ans(:,1) = []

% 先計算出各列最大的矩陣再分別取出
max_matrix = max(ans)
Y9999_max = max_matrix(1) % 台指最大
X2300_max = max_matrix(2) % 電子指最大
X2800_max = max_matrix(3) % 金融指最大

min_matrix = min(ans)
Y9999_min = min_matrix(1) % 台指最小
X2300_min = min_matrix(2) % 電子指最小
X2800_min = min_matrix(3) % 金融指最小
 
mean_matrix = mean(ans)  
Y9999_mean = mean_matrix(1) % 台指平均
X2300_mean = mean_matrix(2) % 電子指平均
X2800_mean = mean_matrix(3) % 金融指平均

sum_matrix = sum(ans)
Y9999_sum = sum_matrix(1) % 台指總和
X2300_sum = sum_matrix(2) % 電子指總和
X2800_sum = sum_matrix(3) % 金融指總和

% 依題目要求，執行時重新產生工作區檔案。
save(fullfile(fileparts(mfilename("fullpath")), "workspace.mat"));
