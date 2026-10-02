readmatrix(fullfile(fileparts(mfilename('fullpath')),'Read.xls'));
% 刪除 NaN 的值
ans = rmmissing(ans);
% 刪除最左邊的日期列
ans(:,1) = [];

tai_index = ans(:, 1);  % 台指
elec_index = ans(:, 2); % 電子指

% 過濾條件
indices = find(tai_index > 5000 & elec_index > 260);

filtered_data = ans(indices, :)
