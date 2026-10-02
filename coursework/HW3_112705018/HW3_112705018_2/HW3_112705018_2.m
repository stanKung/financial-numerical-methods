IntTable = readmatrix(fullfile(fileparts(mfilename('fullpath')),'Read_InterestRate.xlsx')) % 輸入利率資料
IntTable(:, 1) = [] % 刪除第一行 留下數值

a = 1 * (1 + IntTable(1, 1) / 12);  % 計算一個月固定定存 12個月 / 12 = 1個月
writematrix(a, fullfile(fileparts(mfilename('fullpath')),'HW3_112705018_result.xlsx'), Range='A1');

a = 1 * (1 + IntTable(2, 1) / 12);  % 計算一個月機動利率定存 12個月 / 12 = 1個月
writematrix(a, fullfile(fileparts(mfilename('fullpath')),'HW3_112705018_result.xlsx'), Range='B1');

a = 1 * (1 + IntTable(1, 2) / 4);  % 計算三個月固定定存，12個月 / 4 = 3個月
writematrix(a, fullfile(fileparts(mfilename('fullpath')),'HW3_112705018_result.xlsx'), Range='C1');

a = 1 * (1 + IntTable(1, 3) / 2);  % 計算六個月固定定存 12個月 / 2 = 6個月
writematrix(a, fullfile(fileparts(mfilename('fullpath')),'HW3_112705018_result.xlsx'), Range='D1');

a = 1 * (1 + IntTable(1, 5) / 2) * (1 + IntTable(1, 5) / 2); % 計算一年固定定存 每半年付息一次 因此先/2再相乘
writematrix(a, fullfile(fileparts(mfilename('fullpath')),'HW3_112705018_result.xlsx'), Range='E1');

a = IntTable(1,:) - IntTable(2,:); % 計算Spread 為固定利率-機動利率 為一個1*7的vector
writematrix(a, fullfile(fileparts(mfilename('fullpath')),'HW3_112705018_result.xlsx'), Range='F1');
