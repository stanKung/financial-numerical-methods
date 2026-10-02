Data = readtable(fullfile(fileparts(mfilename('fullpath')),'Read.xls')); 
idx = find(Data{:,2}>5000 & Data{:,2}<5500);
Result = Data(idx, 2:4) % 題目要求輸出三大指數；日期仍保留在Data中。
