%% temporal derivative vs. entropy
clear;
dir = pwd;
cd ../../
addpath('./matlab_functions')


t = h5read('./ts36_wavelets_highpass/PNC_ts36_highpass_NMF_output.hdf5', ...
    '/timeseries');


nSubjects = 200;
nComponents = size(t, 1);

temporal_derivative = zeros(nComponents, nSubjects);
entropy = zeros(nComponents, nSubjects);

for ii = 1:nSubjects
    for jj = 1:nComponents
        timeseries = t(jj, ii*51-50:ii*51);
        temporal_derivative(jj,ii) = mean(abs(diff(timeseries)));
        entropy(jj,ii) = signal_entropy(timeseries);
    end
end


figure;
mean_temporal_derivative = mean(temporal_derivative, 2);
mean_entropy = mean(entropy, 2);
h=scatter(mean_temporal_derivative, mean_entropy,'d');
lsline;
[r,p] = corr(mean_temporal_derivative, mean_entropy);
xlabel('Temporal Derivative')
ylabel('Entropy')
title(['r=' num2str(r) ' p=' num2str(p)])

%% null model of temporal coefficients
clearvars -except dir

t = h5read('./ts36_wavelets_highpass/PNC_ts36_highpass_NMF_output.hdf5', ...
    '/timeseries');
nSubjects = 200;
nComponents = size(t, 1);
nTW = 51;

num_permutations = 100;

perms_temporal_derivative = zeros(num_permutations, nSubjects);
perms_entropy = zeros(num_permutations, nSubjects);

for ii = 1:num_permutations
    entropy = zeros(nComponents, nSubjects);
    temporal_derivative = zeros(nComponents, nSubjects);
    for jj = 1:nSubjects
        for kk = 1:nComponents
            x = randperm(nTW);
            timeseries = t(kk, jj*51-50:jj*51);
            time_permuted = timeseries(x);
            temporal_derivative(kk,jj) = mean(abs(diff(time_permuted)));
            entropy(kk,jj) = signal_entropy(time_permuted);
        end
    end
    mean_temporal_derivative_per_subject = mean(temporal_derivative);
    perms_temporal_derivative(ii, :) = mean_temporal_derivative_per_subject;
    mean_entropy_per_subject = mean(entropy);
    perms_entropy(ii, :) = mean_entropy_per_subject;
end

%actual temporal derivative
temporal_derivative = zeros(10, 200);
for ii = 1:nSubjects
    for jj = 1:nComponents
        timeseries = t(jj, ii*51-50:ii*51);
        temporal_derivative(jj,ii) = mean(abs(diff(timeseries)));
    end
end
mean_temporal_derivative_per_subject = mean(temporal_derivative);

avg_perms_temporal_derivative = mean(perms_temporal_derivative);

%actual entropy
entropy = zeros(10, 200);
for ii = 1:nSubjects
    for jj = 1:nComponents
        timeseries = t(jj, ii*51-50:ii*51);
        entropy(jj,ii) = signal_entropy(timeseries);
    end
end
mean_entropy_per_subject = mean(entropy);

avg_perms_entropy = mean(perms_entropy);

figure;
subplot(121);
boxplot([mean_temporal_derivative_per_subject', ...
    avg_perms_temporal_derivative'], ...
    'labels', {'actual', 'permuted'});
ylabel('temporal derivative')
set(gca, 'ylim', [0 5]);
subplot(122);
boxplot([mean_entropy_per_subject', avg_perms_entropy'], ...
    'labels', {'actual', 'permuted'});
set(gca, 'ylim', [0 5]);
ylabel('entropy')
[h1, p1, ~, stats1] = ttest2(mean_temporal_derivative_per_subject, ...
    avg_perms_temporal_derivative);
[h2, p2, ~, stats2] = ttest2(mean_entropy_per_subject, avg_perms_entropy);

%% modifying optimization parameters
clearvars -except dir

%use the subgraphs figure
start = 1:51:51*200;
stop = 51:51:51*200;

%zero beta
nmf_pipeline('./ts36_wavelets_highpass/PNC_ts36_highpass_NMF_output_zero_beta.hdf5', 200, 0, 2, 5,start,stop)

%k = 8
nmf_pipeline('./ts36_wavelets_highpass/PNC_ts36_highpass_NMF_output_k8.hdf5', 200, 0, 2, 4,start,stop)

%k = 12
nmf_pipeline('./ts36_wavelets_highpass/PNC_ts36_highpass_NMF_output_k12.hdf5', 200, 0, 3, 4,start,stop)

%k = 45
filename = './ts36_wavelets_highpass/PNC_ts36_highpass_NMF_output_k45.hdf5';
s = h5read(filename, '/subnetworks');
t = h5read(filename, '/timeseries');
[~, ~, num_components] = size(s);
expr_order = components_ordered_by_expression(t);
means = compute_cognitive_system_averages(s);

% plot components on 5 different figures
for ii = 1:num_components
    if mod(ii, 10) == 1
        figure;
    end
    
    %plot index
    idx = mod(ii, 10);
    if idx == 0
        idx = 10;
    end
    subplot(2, 5, idx);
    imagesc(means(:,:,expr_order(ii))); %order by expression
    axis equal on
    set(gca, 'YTick', 2:2:13);
    title(['Subgraph ' num2str(ii)]);
    cb = colorbar;
    v = caxis;
    set(cb, 'ytick', [v(1) v(2)]);
    yt = get(cb, 'ytick');
    set(cb, 'yticklabel', sprintf('%1.3f|', yt));
end
%% modifying motion regression

start = 1:51:51*200;
stop = 51:51:51*200;
%motion regression on time coefficients
nmf_pipeline('./ts36_wavelets_highpass/PNC_ts36_highpass_NMF_output_no_motion_regression.hdf5', ...
    200, 1, 2, 5, start, stop)


%% with motion censoring
clearvars -except dir

%censor w/o added motion regression, and not truncated
load('./ts36_wavelets_censor/num_windows');

censor_variable_stop = cumsum(num_windows);
censor_variable_start = [1; censor_variable_stop(1:end-1) + 1];
nmf_pipeline('./ts36_wavelets_censor/PNC_ts36_censor_NMF_output_no_motion_regression.hdf5', ...
    200, 0, 2, 5, censor_variable_start, censor_variable_stop)

subnetworks = h5read('./ts36_wavelets_highpass/PNC_ts36_highpass_NMF_output.hdf5', '/subnetworks');
subnetworks_censor = h5read('./ts36_wavelets_censor/PNC_ts36_censor_NMF_output_no_motion_regression.hdf5', ...
    '/subnetworks');
timeseries = h5read('./ts36_wavelets_highpass/PNC_ts36_highpass_NMF_output.hdf5', '/timeseries');
timeseries_censor = h5read('./ts36_wavelets_censor/PNC_ts36_censor_NMF_output_no_motion_regression.hdf5', ...
    '/timeseries');
expr_order = components_ordered_by_expression(timeseries);
expr_order_censor = components_ordered_by_expression(timeseries_censor);

%in the despiking step node 10 is excluded, resulting in a 263x263 matrix
%insert NaN for node 10 to restore original node to system assignments
s_original = subnetworks_censor;
num_nodes = 263;
num_components = 10;
subnetworks_censor = NaN(num_nodes+1, num_nodes+1, num_components);
subnetworks_censor(1:9, 1:9, :) = s_original(1:9, 1:9, :);
subnetworks_censor(1:9, 11:end, :) = s_original(1:9, 10:end, :);
subnetworks_censor(11:end, 1:9, :) = s_original(10:end, 1:9, :);
subnetworks_censor(11:end, 11:end,:) = s_original(10:end, 10:end,:);

cog_avg = compute_cognitive_system_averages(subnetworks(:, :, expr_order));
cog_avg_censor = compute_cognitive_system_averages(subnetworks_censor(:, :, expr_order));

%correlation between original 1st subgraph and censored 1st subgraph
[r, p] = corr(reshape(cog_avg(:,:,1), 1, [])', reshape(cog_avg_censor(:,:,1), 1, [])');

cd(dir)








