% use figure 4 from nmf pipeline
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


%% second figure -- example of timeseries
clear;
dir = pwd;
cd ../../
filename = './ts36_wavelets_highpass/PNC_ts36_highpass_NMF_output.hdf5';
t = h5read(filename, '/timeseries');

figure;
plot(1:51, t([1, 2, 10], 52:102));
xlabel('Time windows')
ylabel('Expression')

cd(dir)

%% permutation test on energy and entropy
clear;
dir = pwd;
cd ../../
filename = './ts36_wavelets_highpass/PNC_ts36_highpass_NMF_output.hdf5';
start = 1:51:51*200;
stop = 51:51:51*200;
t = h5read(filename, '/timeseries');
s = h5read(filename, '/subnetworks');
num_components = size(t, 1);
num_subjects = 200;
actual_correlation = energy_entropy_skewness_plots(s, t, num_subjects, ...
    start, stop);

numperms = 1000;
perms = zeros(1, numperms);

for kk = 1:numperms
    disp(kk)
    % compute energy and entropy values
    energy = zeros(num_components, num_subjects);
    entropy = zeros(num_components, num_subjects);
    
    [a, b] = size(t);
    x = numel(t);
    permuted_t = reshape(t(randperm(x)), a, b);

    
    for ii = 1:num_subjects
        for jj = 1:num_components
            timeseries = permuted_t(jj, start(ii):stop(ii));
            energy(jj,ii) = sum(timeseries.^2);
            entropy(jj,ii) = signal_entropy(timeseries);
        end
    end
    mean_energy = mean(energy, 2); % average across subjects
    mean_entropy = mean(entropy, 2); % average across subjects
    [r1,p] = corr(mean_energy, mean_entropy, 'type', 'pearson');
    perms(kk) = r1;
end

pval = length(find(perms < actual_correlation)) / length(perms);
1-pval
cd(dir)

