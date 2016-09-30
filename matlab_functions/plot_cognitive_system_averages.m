function plot_cognitive_system_averages(s,t, plot_rows, plot_cols)
% PURPOSE: plot the cognitive-system-wide summary of subgraphs obtained
% from NMF decomposition
% 
% INPUT:
% s: matrix of subgraphs with dimensions (nNodes x nNodes x nSubgraphs)
% 
% t: matrix of temporal coefficients
%       ROWS: number of subgraphs
%       COLUMNS: number of subjects x number of time windows per subject
% 
% plot_rows: number of rows in the resulting figure panel of subgraphs
%
% plot_cols: number of columns in the resulting figure panel of subgraphs
%
% OUTPUT:
% no output
%--------------------------------------------------------------------------
means = compute_cognitive_system_averages(s);

% order by decreasing average expression
expr_order = components_ordered_by_expression(t);
[~, ~, num_components] = size(s);

figure;
for ii = 1:num_components
    subplot(plot_rows, plot_cols, ii);
    % order by expression and normalize between 0 and 1
    A = means(:,:,expr_order(ii));
    normalized = (A - min(min(A)))/(max(max(A)) - min(min(A)));
    imagesc(normalized);
    axis equal on
    set(gca, 'YTick', 2:2:13);
    title(['Subgraph ' num2str(ii)]);
    caxis([0, 1]);
    colorbar;
end
end