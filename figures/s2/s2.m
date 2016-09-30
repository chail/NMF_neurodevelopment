%% 1 - network_averages size size 15 x 6
% use figure 1 & 2 from nmf pipeline
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

