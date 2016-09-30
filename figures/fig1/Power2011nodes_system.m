% PURPOSE: construct .node file of cognitive system to node assignments for
% use in BrainNetViewer
%--------------------------------------------------------------------------
addpath('../../matlab_functions')
load('../../pnc_data/coordinatesXYZ.mat')

f = fopen('Power2011nodes_system.node', 'w');

% load system names
[~, txt, ~ ] = xlsread('../../pnc_data/neuralSystem.xlsx', 'B2:B265');
[names, ~, idx] = unique(txt);

% map alphabetical node-to-system assignments to the original ordering by
% system
order = [12 9 10 3 1 4 7 14 6 8 11 13 2 5];
conversion = [order; 1:14]'; 
[~,I]=sort(conversion(:,1)); % sort by order
map=conversion(I,:); 

for i = 1:length(txt)
    fprintf(f,'% 3d % 3d % 3d % 2d\t2\t- \n', X(i), Y(i), Z(i), map(idx(i),2));
end
fclose(f);