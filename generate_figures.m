function generate_figures(recomputeAsian)
% Generate all portfolio figures and numerical result tables.
% generate_figures(true): recompute HW10 and all other demonstrations.
% generate_figures(false): reuse results/hw10_asian.mat; recompute the rest.
if nargin==0, recomputeAsian=true; end
root=fileparts(mfilename('fullpath'));
oldPath=path; cleanPath=onCleanup(@()path(oldPath));
addpath(fullfile(root,'demonstrations'));
addpath(genpath(fullfile(root,'coursework')));
oldVisible=get(groot,'defaultFigureVisible');
cleanVisible=onCleanup(@()set(groot,'defaultFigureVisible',oldVisible));
set(groot,'defaultFigureVisible','off');
fprintf('Generating figures in %s\n',fullfile(root,'figures'));
portfolio_figures(root,recomputeAsian);
fprintf('Finished: eight PNG figures and CSV result tables.\n');
end
