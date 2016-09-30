%% obtain system-wide subgraphs

dir = pwd;
cd ../../

addpath('./matlab_functions')

% start and stop indices for timewindows for each subject
start = 1:51:51*200;
stop = 51:51:51*200;

% pipeline used in the main text
nmf_pipeline('./ts36_wavelets_highpass/PNC_ts36_highpass_NMF_output_next_100.hdf5', ...
    200, 0, 2, 5,start,stop)

% navigate back to directory
cd(dir)

%% compute correlation between replicated subgraph 1 and original subgraph
clearvars -except dir
cd ../../


subnetworks = h5read('./ts36_wavelets_highpass/PNC_ts36_highpass_NMF_output.hdf5', '/subnetworks');
subnetworks_replicate = h5read('./ts36_wavelets_highpass/PNC_ts36_highpass_NMF_output_next_100.hdf5', ...
    '/subnetworks');
timeseries = h5read('./ts36_wavelets_highpass/PNC_ts36_highpass_NMF_output.hdf5', '/timeseries');
timeseries_replicate = h5read('./ts36_wavelets_highpass/PNC_ts36_highpass_NMF_output_next_100.hdf5', ...
    '/timeseries');
expr_order = components_ordered_by_expression(timeseries);
expr_order_replicate = components_ordered_by_expression(timeseries_replicate);


cog_avg = compute_cognitive_system_averages(subnetworks(:, :, expr_order));
cog_avg_replicate = compute_cognitive_system_averages(subnetworks_replicate(:, :, expr_order));

%correlation between original 1st subgraph and censored 1st subgraph
[r, p] = corr(reshape(cog_avg(:,:,1), 1, [])', reshape(cog_avg_replicate(:,:,1), 1, [])');

cd(dir)








