% use figure 5 & 6 from nmf pipeline
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

%% compute correlation between executive energy and subject motion
clear;
dir = pwd;
cd ../../

addpath('./matlab_functions')

% start and stop indices for timewindows for each subject
start = 1:51:51*200;
stop = 51:51:51*200;

% load file
filename = './ts36_wavelets_highpass/PNC_ts36_highpass_NMF_output.hdf5';
t = h5read(filename, '/timeseries');
num_components = size(t, 1);
num_subjects = 200;

% order by decreasing average temporal coefficient
expr_order = components_ordered_by_expression(t);

% compute average time coefficient over the time windows for each of the
% subgraphs for each subject
t_average = zeros(size(t));
for ii = 1:num_subjects
    num_windows = stop(ii)-start(ii) + 1;
    average = mean(t(:, start(ii):stop(ii)),2);
    average_rep = repmat(average,1,num_windows);
    t_average(:,start(ii):stop(ii))= average_rep;
end

% normalize the temporal coefficients
normalized_t = t ./ t_average;

% compute normalized energy
energy = zeros(num_components,num_subjects);
for ii = 1:num_subjects
    for jj = 1:num_components
        timeseries = normalized_t(jj, start(ii):stop(ii));
        energy(jj,ii) = sum(timeseries.^2);
    end
end

% reorder by expr order
energy = energy(expr_order, :);
executive_energy = energy(1, :);

load('./pnc_data/mvmt')
load('./subject_indices/idx_old')
load('./subject_indices/idx_young')

subject_mvmt = mvmt([young; old]);

[r, p] = corr(executive_energy', subject_mvmt)

% navigate back to directory
cd(dir)

%% compute correlation between executive energy and subject motion
clear;
dir = pwd;
cd ../../

addpath('./matlab_functions')

% start and stop indices for timewindows for each subject
start = 1:51:51*200;
stop = 51:51:51*200;

% load file
filename = './ts36_wavelets_highpass/PNC_ts36_highpass_NMF_output.hdf5';
t = h5read(filename, '/timeseries');
num_components = size(t, 1);
num_subjects = 200;

% order by decreasing average temporal coefficient
expr_order = components_ordered_by_expression(t);

% compute average time coefficient over the time windows for each of the
% subgraphs for each subject
t_average = zeros(size(t));
for ii = 1:num_subjects
        num_windows = stop(ii)-start(ii) + 1;

    average = mean(t(:, start(ii):stop(ii)),2);
    average_rep = repmat(average,1,num_windows);
    t_average(:,start(ii):stop(ii))= average_rep;
end

% normalize the temporal coefficients
normalized_t = t ./ t_average;


%compute normalized entropy
entropy = zeros(num_components,num_subjects);
for ii = 1:num_subjects
    for jj = 1:num_components
        timeseries = normalized_t(jj, start(ii):stop(ii));
        entropy(jj,ii) = signal_entropy(timeseries);
    end
end

% reorder by expr order
entropy = entropy(expr_order, :);
executive_entropy = entropy(1, :);

load('./pnc_data/mvmt')
load('./subject_indices/idx_old')
load('./subject_indices/idx_young')

subject_mvmt = mvmt([young; old]);

[r, p] = corr(executive_entropy', subject_mvmt)

% navigate back to directory
cd(dir)

