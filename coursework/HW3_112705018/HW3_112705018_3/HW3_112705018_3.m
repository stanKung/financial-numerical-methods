X = [1 2 3]';
Y = [4 5 6]';

Z = cat(2, X, ones(3, 1))
coef = Z \ Y
A = coef(1)
b = coef(2)