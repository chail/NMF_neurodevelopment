%% temporal derivative null models-accuracy
clear
clc
load('../../pnc_data/go1_go2_cnb_factor_scores_non-age-regressed/GO1_GO2_CNB_Overall_Accuracy_Factor.mat')
load('../../pnc_data/age.mat')
load('../../pnc_data/mvmt.mat')
load('../../pnc_data/cognDataCollection.mat', 'cognBblid')

num_entries=zeros(size(cognBblid));
scores = zeros(size(cognBblid));
bblid_entries = cell(length(cognBblid), 1);
for ii = 1:length(cognBblid)
    if ii == 200 
        % the 200th subject is missing an accuracy score
        continue;
    end
    num_entries(ii) = length(find(bblid==cognBblid(ii)));
    indices = find(bblid==cognBblid(ii));
    bblid_entries{ii} = indices;
    % use the first accuracy score for subjects that have 2 scores, as the
    % second score was collected some time period later
    scores(ii) = Overall_Accuracy(indices(1));
end

%remove missing subject from all data
age=age([1:199 201:end]);
mvmt=mvmt([1:199 201:end]);
scores=scores([1:199 201:end]);

%regress mvmt from scores
p = polyfit(mvmt, scores, 1);
regressed_mean_scores = scores - mvmt * p(1);
exec_scores_780 = regressed_mean_scores;

%read temporal coefficients
executive_temporal_coefficients = zeros(780, 51);
for subj = 1:780
    filename = ['nnls_temporal_weight_subj' num2str(subj) '.mat'];
    load(filename);
    executive_temporal_coefficients(subj,:) = h(1,:);
    clear h
end

%remove missing subject from temporal coefficients
executive_temporal_coefficients(200,:) = [];

%regress mvt from temporal coefficients
regressed_executive_temporal_coefficients = ...
    zeros(size(executive_temporal_coefficients));
for ii = 1:51
    p = polyfit(mvmt, executive_temporal_coefficients(:, ii), 1);
    regressed_executive_temporal_coefficients(:,ii) = ...
        executive_temporal_coefficients(:, ii) - mvmt * p(1);
end

%compute average and normalize
average_time = repmat(mean(regressed_executive_temporal_coefficients, 2), ...
    1, 51);
normalized_t = regressed_executive_temporal_coefficients ./ average_time;

actual_temporal_derivative = mean(abs(diff(normalized_t')))';
[r, p] = corr(actual_temporal_derivative, exec_scores_780, 'type', 'pearson')
actual_correlation = r;
figure;scatter(actual_temporal_derivative,exec_scores_780)


num_null_models = 1000;

null_dist = zeros(num_null_models, 1);
for ii = 1:num_null_models
    temporal_coefficients_null = ...
        zeros(size(normalized_t));
    % permute order of temporal coefficients
    for jj = 1:length(normalized_t)
        x=randperm(size(normalized_t, 2));
        temporal_coefficients_null(jj,:) = ...
            normalized_t(jj,x);
    end
    % compute null temporal derivative from permuted coefficients
    null_temporal_derivative = mean(abs(diff(temporal_coefficients_null')))';
    [r, p] = corr(null_temporal_derivative, exec_scores_780, 'type', 'pearson');
    null_dist(ii) = r;
end

pvalue = numel(find(null_dist < actual_correlation)) / length(null_dist);
disp(num2str(1-pvalue))
figure;hist(null_dist)
