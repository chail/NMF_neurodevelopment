function [means, node_assignments] = compute_cognitive_system_averages(s)
% PURPOSE: compute between-cognitive-system and within-cognitive-system
% averages over all nodes and subgraphs
% 
% INPUT:
% s: matrix of subgraphs with dimensions (nNodes x nNodes x nSubgraphs)
%
% OUTPUT:
% means: matrix of cognitive system averages which capture a summary of
% between-system and within-system connection strength with dimensions 
% (nCognitiveSystems x nCognitiveSystems x nSubgraphs)
%
% node_assignments: 13x2 cell array of cognitive systems and the indicies
% of nodes belonging to each system
%--------------------------------------------------------------------------
[~, ~, num_components] = size(s);
[names, idx] = load_system_names;

% group nodes by system
num_systems = max(idx);
node_assignments = cell(num_systems, 2);
for ii = 1:num_systems
    node_assignments{ii} = find(idx == ii);
end
node_assignments(:, 2) = names;

% reorder grouped nodes back to original ordering by system (rather than
% alphabetical by name ordering
node_assignments = node_assignments([12 9 10 3 1 4 7 14 6 8 11 13 2 5], :);

% determine new ordering of 264 nodes where nodes are grouped by system
% assignments
node_order = [];
for ii = 1:num_systems
    node_order = [node_order node_assignments{ii}'];
end

% combine sensory hand and sensory mouth regions into one sensory system
node_assignments_sensory_uncombined = node_assignments;
node_assignments = cell(num_systems-1, 2);
node_assignments(1,:) = node_assignments_sensory_uncombined(1,:);
node_assignments{2,1} = [node_assignments_sensory_uncombined{2,1}; ...
    node_assignments_sensory_uncombined{3,1}];
node_assignments{2,2} = 'Sensory';
node_assignments(3:end,:) = node_assignments_sensory_uncombined(4:end, :);


% compute between and within system connectivity by taking average of
% connections between 2 different systems or within a system (omitting the
% zero diagonal)
num_systems = length(node_assignments);
means = zeros(num_systems,num_systems,num_components);
for ii = 1:num_components
    x = s(:,:, ii);
    x(1:size(x) + 1:end) = nan; %set diagonal to nan
    for jj = 1:num_systems
        for kk = jj:num_systems
            means(jj, kk, ii) = nanmean(nanmean(x(node_assignments{jj}, ...
                node_assignments{kk})));
        end
    end
    %add transpose to get symmetric matrix
    means(:, :, ii) = means(:,:,ii) + triu(means(:,:,ii),1)';
end
end