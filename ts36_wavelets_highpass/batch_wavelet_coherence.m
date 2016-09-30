load('../pnc_data/ts_36_ev.mat')
load('../subject_indices/idx_old.mat')
load('../subject_indices/idx_young.mat')
load('../subject_indices/idx_580.mat')
addpath(genpath('../matlab_functions'))

subjects = [young; old; idx_580];

for i = 1:length(subjects)
    T = ts_36_ev(:, :, subjects(i));
    subject_name = ['subj' num2str(subjects(i))];
    Aij = run_timeSeries2mat_highpass(T', 3, 20, 18, 'wavelet', './', subject_name, 'rest')
    clear Aij T subject_name
end
