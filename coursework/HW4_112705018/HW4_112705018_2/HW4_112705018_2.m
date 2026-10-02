readmatrix(fullfile(fileparts(mfilename('fullpath')),'Read.xls'));

% 讀取數據
Y9999 = ans(3:end, 2); 
X2300 = ans(3:end, 3); 
X2800 = ans(3:end, 4);

% 分割訓練與測試資料
train_size = 1 : 50;
test_size = 51 : 101;

% 利用訓練集計算迴歸係數
r = ones(size(X2300(train_size)));
A = [X2300(train_size), X2800(train_size), r];
C = A \ Y9999(train_size);
x = regress(Y9999(train_size), [X2300(train_size), X2800(train_size), r]);

% 預測測試集價格
r_test = ones(size(X2300(test_size)));
A_test = [X2300(test_size), X2800(test_size), r_test];
Z = A_test * C; % 預測值

% 設定交易成本
tax = 200 * 0.00002;  % 交易稅
fee = 20;  % 手續費
threshold = tax * Y9999(test_size) + r_test * fee;

% 進場條件：假設進出場各一次成本；僅產生訊號，並非獲利保證。
% 成本設定；合約乘數及稅費／指數點數換算需另行釐清。
long_entry = (Z - Y9999(test_size) - threshold * 2) > 0;  % Long
short_entry = (Y9999(test_size) - Z - threshold * 2) > 0; % Short

% 使用 find 尋找進場時間 (訓練集為前50筆 求正確index加回來)
long_entry_time = find(long_entry) + 50;
short_entry_time = find(short_entry) + 50;

% 輸出結果
disp("Long entry time:")
disp(long_entry_time)
disp("Short entry time:")
disp(short_entry_time)
