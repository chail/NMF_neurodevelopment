addpath('./matlab_functions')

% start and stop indices for timewindows for each subject
start = 1:51:51*200;
stop = 51:51:51*200;

% pipeline used in the main text
nmf_pipeline('./ts36_wavelets_highpass/PNC_ts36_highpass_NMF_output.hdf5', 200, 0, 2, 5,start,stop)


%% zero beta
nmf_pipeline('./ts36_wavelets_highpass/PNC_ts36_highpass_NMF_output_zero_beta.hdf5', 200, 0, 2, 5,start,stop)

%% k = 6
nmf_pipeline('./ts36_wavelets_highpass/PNC_ts36_highpass_NMF_output_k6.hdf5', 200, 0, 2, 3,start,stop)

%% k = 8
nmf_pipeline('./ts36_wavelets_highpass/PNC_ts36_highpass_NMF_output_k8.hdf5', 200, 0, 2, 4,start,stop)

%% k = 12
nmf_pipeline('./ts36_wavelets_highpass/PNC_ts36_highpass_NMF_output_k12.hdf5', 200, 0, 3, 4,start,stop)

%% k = 45
nmf_pipeline('./ts36_wavelets_highpass/PNC_ts36_highpass_NMF_output_k45.hdf5', 200, 0, 5, 9,start,stop)

%% motion regression on time coefficients
nmf_pipeline('./ts36_wavelets_highpass/PNC_ts36_highpass_NMF_output_no_motion_regression.hdf5', 200, 1, 2, 5, start,stop)


%% censor w/o added motion regression, and not truncated
load('./ts36_wavelets_censor/num_windows');
censor_variable_stop = cumsum(num_windows);
censor_variable_start = [1; censor_variable_stop(1:end-1) + 1];
nmf_pipeline('./ts36_wavelets_censor/PNC_ts36_censor_NMF_output_no_motion_regression.hdf5', ...
    200, 0, 2, 5, censor_variable_start, censor_variable_stop)

