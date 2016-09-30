load('../pnc_data/n780_censor.mat')
load('../subject_indices/idx_old.mat')
load('../subject_indices/idx_young.mat')
addpath(genpath('../matlab_functions'))

subjects = [young; old];

for ii = 1:length(subjects)
    T = ts_36_censor(subjects(ii)).TIMESERIES;
    % splice out 10th node because not present in all subjects
    T = T(:, [1:9, 11:end]);
    subject_name = ['subj' num2str(subjects(ii))];
    Aij = run_timeSeries2mat_highpass(T', 3, 20, 18, 'wavelet', './', subject_name, 'rest');
    clear Aij T subject_name
end
