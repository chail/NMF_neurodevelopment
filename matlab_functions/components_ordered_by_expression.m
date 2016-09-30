function expr_order = components_ordered_by_expression(t)
% PURPOSE: order subgraphs by decreasing average expression across subjects
%
% INPUT:
% t: matrix of temporal coefficients from NMF decomposition
%       ROWS: number of subgraphs
%       COLUMNS: number of subjects x time windows per subject
% 
% OUTPUT:
% expr_order: vector of subgraph indices arranged in decreasing average
% expression order
%--------------------------------------------------------------------------
    mean_time_coefficients = mean(t,2);
    [~,I] = sort(mean_time_coefficients);
    expr_order = flipud(I);
end