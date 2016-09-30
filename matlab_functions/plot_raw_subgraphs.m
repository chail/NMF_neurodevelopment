function plot_raw_subgraphs(s, t, plot_rows, plot_cols)
% PURPOSE: plot the subgraphs obtained from NMF decomposition
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

[~, ~, num_components] = size(s);
[names, idx] = load_system_names;
expr_order = components_ordered_by_expression(t);

% group nodes by system
num_systems = max(idx);
node_assignments = cell(num_systems, 2);
for ii = 1:num_systems
    node_assignments{ii} = find(idx == ii);
end
node_assignments(:, 2) = names;

% reorder ordering of cognitive systems back to original ordering, rather
% than alphabetical ordering
node_assignments = node_assignments([12 9 10 3 1 4 7 14 6 8 11 13 2 5], :);

% determine a new ordering of the nodes in which nodes are grouped by
% cognitive system
node_order = [];
for ii = 1:num_systems
    node_order = [node_order node_assignments{ii}'];
end


% plot raw subgraphs
figure;
for ii = 1:num_components
    
    subplot(plot_rows,plot_cols,ii); 
    
    % normalize color scale by dividing by max ([0 1] color
    A = s(node_order,node_order,expr_order(ii));
    normalized = (A - min(min(A)))/(max(max(A)) - min(min(A)));
    imagesc(normalized);

    axis equal on;
    set(gca, 'xtick', 50:50:250);
    set(gca, 'ytick', 50:50:250);
    caxis([0 1]);
    colorbar;
    title(['Subgraph' num2str(ii)])
end
end
