function nmf_pipeline(filename, num_subjects, add_regression, plot_rows, plot_cols,start,stop)
% PURPOSE: setup and load NMF output for plots and further analysis
%
% INPUT:
% filename: name of hdf5 output file containing /subnetworks and
% /timeseries datasets
% 
% num_subjects: number of subjects 
%
% add_regression: setting to 1 adds an additional regression step in which
% movement is regressed out of each element of the timeseries matrix after
% NMF decomposition, motion is regressed based on the subject indices from
% the 100 youngest and 100 oldest subjects, otherwise set to 0
% 
% plot_rows: number of rows in the resulting figure panel of subgraphs
%
% plot_cols: number of columns in the resulting figure panel of subgraphs
%
% start: a 1 x num_subjects vector containing the start index within the
% timeseries matrix of the expression for each subject
%
% stop: a 1 x num_subjects vector containing the stop index within the
% timeseries matrix of the expression for each subject 
%
% OUTPUT:
% no output
%--------------------------------------------------------------------------

s = h5read(filename, '/subnetworks');
t = h5read(filename, '/timeseries');
[num_nodes, ~, num_components] = size(s);

num_windows = length(t) / num_subjects;


% in the despiking step node 10 is excluded, resulting in a 263x263 matrix
% the following shift inserts NaN for node 10 to restore original
% node-to-system assignments
if (num_nodes == 263)
    s_original = s;
    s = NaN(num_nodes+1, num_nodes+1, num_components);
    s(1:9, 1:9, :) = s_original(1:9, 1:9, :);
    s(1:9, 11:end, :) = s_original(1:9, 10:end, :);
    s(11:end, 1:9, :) = s_original(10:end, 1:9, :);
    s(11:end, 11:end,:) = s_original(10:end, 10:end,:);
end

%regress motion on timeseries
if (add_regression == 1)
    load('./pnc_data/mvmt.mat')
    load('./subject_indices/idx_young.mat')
    load('./subject_indices/idx_old.mat')
    subjects = [young; old];
    mvt = mvmt(subjects);
    for ii = 1:num_components
        for jj = 1:num_windows
            idx = (0:num_windows:(num_windows*num_subjects-1)) + jj;
            timeseries = t(ii, idx);
            t(ii, idx) = regress_mvt(mvt, timeseries');
        end
    end
end

plot_raw_subgraphs(s, t, plot_rows, plot_cols);
plot_raw_timeseries(t,num_subjects,plot_rows, plot_cols, start, stop);
plot_cognitive_system_averages(s,t,plot_rows, plot_cols)
energy_entropy_skewness_plots(s,t,num_subjects,start,stop)
plot_energy_neurodevelopment(t,num_subjects,plot_rows, ...
    plot_cols,start,stop)
plot_entropy_neurodevelopment(t,num_subjects,plot_rows, ...
    plot_cols,start,stop)
end
