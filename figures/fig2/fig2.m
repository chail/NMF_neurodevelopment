%% 1 - network_averages size size 15 x 6
% use figure 1 & 3 from nmf pipeline
dir = pwd;
cd ../../

addpath('./matlab_functions')

% start and stop indices for timewindows for each subject
start = 1:51:51*200;
stop = 51:51:51*200;

% pipeline used in the main text
nmf_pipeline('./ts36_wavelets_highpass/PNC_ts36_highpass_NMF_output.hdf5', ...
    200, 0, 2, 5,start,stop)

% navigate back to directory
cd(dir)

%% 2 - permutation tests to generate .node plots
clear;
dir = pwd;
cd ../../
addpath('./matlab_functions')
filename = './ts36_wavelets_highpass/PNC_ts36_highpass_NMF_output.hdf5';
s = h5read(filename, '/subnetworks');
t = h5read(filename, '/timeseries');
[nNodes, ~, nComp] = size(s);

[means, node_assignments] = compute_cognitive_system_averages(s);
expr_order = components_ordered_by_expression(t);

% take average of system-wide column
actual_sum = squeeze(mean(means, 1));

nSystems = length(node_assignments);

permutation_tests = cell(nComp, 1);
for component = 1:nComp
    matrix = s(:,:,component);
    values = zeros(nSystems, 1000);
    disp(num2str(component));
    for permutation = 1:1000
        % create random shuffling of raw subgraphs
        x = randperm(length(matrix));
        y = randperm(length(matrix));
        upper_triangular = triu(matrix(x, y),1);
        permuted_matrix = upper_triangular + upper_triangular';
        % set nan on diagonal
        permuted_matrix(1:size(permuted_matrix) + 1:end) = nan;
        % compute cognitive system averages on permuted matrix
        permuted_system = zeros(13, 13);
        for jj = 1:nSystems
            for kk = jj:nSystems
                permuted_system(jj, kk) = ...
                    nanmean(nanmean(permuted_matrix( ...
                    node_assignments{jj}, node_assignments{kk})));
            end
        end
        % add transpose for symmetrtic matrix
        permuted_system = permuted_system + triu(permuted_system,1)';
        % take the average of each system-wide column
        column_mean = mean(permuted_system);
        values(:,permutation) = column_mean;
    end
    permutation_tests{component} = values;
end

pvalues = zeros(size(actual_sum));
for component = 1:nComp
    %get distribution of column sum for all systems and permutations
    distribution = sort(reshape(permutation_tests{component}, 1, []));
    for system = 1:nSystems
        value = actual_sum(system, component);
        %permutation test
        pvalues(system, component) = length(find(distribution <= value)) ...
            / length(distribution);
    end
end

pvalues_threshold = pvalues >=0.95;
%% write to systems

%reorder by activation
actual_sum = actual_sum(:, expr_order);
pvalues_threshold = pvalues_threshold(:,expr_order);

load('./pnc_data/coordinatesXYZ.mat')

[~, txt, ~ ] = xlsread('./pnc_data/neuralSystem.xlsx', 'B2:B265');
[names, ~, system_to_node_assignment] = unique(txt);

% non-alphabetical ordering
ordering = [12 9 10 3 1 4 7 14 6 8 11 13 2 5];
A = [12 9 10 3 1 4 7 14 6 8 11 13 2 5; 1:14]';
[~,I]=sort(A(:,1));
% the first column of map is the alphabetical system number according to
% 'names' variable
% the second column of map is the system number according to the original
% order
map=A(I,:);

% navigate back to figure directory
cd(dir)

for component = 1:nComp
    f = fopen(['Power2011nodes_component' num2str(component) '.node'], 'w');
    for ii = 1:length(txt)
        pvalue_system_idx = map(system_to_node_assignment(ii), 2);
        if (pvalue_system_idx >=3) 
            % shift due to 2nd & 3rd combined sensory systems
            pvalue_system_idx = pvalue_system_idx - 1;
        end
        value = pvalues_threshold(pvalue_system_idx, component);
        fprintf(f,'% 3d % 3d % 3d % 2d % 1.3f \t- \n', X(ii), Y(ii), Z(ii), ...
            map(system_to_node_assignment(ii), 2), value);
    end
    fclose(f);
end

%% t-test on significant systems
nSystems_per_subgraph = sum(pvalues_threshold);
% hypothesis: mean = 1 
[~, p, ~, stats] = ttest(nSystems_per_subgraph, 1);

cd(dir)

