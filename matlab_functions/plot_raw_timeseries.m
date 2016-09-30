function plot_raw_timeseries(t, ~, plot_rows, plot_cols, start, stop)
% PURPOSE: plot the temporal coefficents obtained from NMF decomposition
% for a representative young and old subject
% 
% INPUT:
% t: matrix of temporal coefficients
%       ROWS: number of subgraphs
%       COLUMNS: number of subjects x number of time windows per subject
% 
% plot_rows: number of rows in the resulting figure panel
%
% plot_cols: number of columns in the resulting figure panel
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

num_components = size(t, 1);
young_subject = 50; % index of representative young subject
old_subject = 150; % index of representative old subject


num_windows_young = stop(young_subject) - start(young_subject) + 1;
num_windows_old = stop(old_subject) - start(old_subject) + 1;
   

young_subject_timecoefficients = ...
    t(:,start(young_subject):stop(young_subject));
old_subject_timecoefficients = ...
    t(:,start(old_subject):stop(old_subject));

%reorder by desceding average expression
expr_order = components_ordered_by_expression(t);
young_subject_timecoefficients = ...
    young_subject_timecoefficients(expr_order, :);
old_subject_timecoefficients = ...
    old_subject_timecoefficients(expr_order, :);


max_height = max(max([young_subject_timecoefficients,...
    old_subject_timecoefficients]));

figure;
for ii = 1:num_components
    subplot(plot_rows,plot_cols, ii); 
    plot(1:num_windows_young, young_subject_timecoefficients(ii,:));
    hold on;
    plot(1:num_windows_old, old_subject_timecoefficients(ii, :), 'g');
    set(gca, 'XLim', [1 max(num_windows_young, num_windows_old)]);
    set(gca, 'YLim', [0, max_height]);
    title(['Subgraph' num2str(ii)])
    xlabel('Time Windows')
    ylabel('Expression')
end
end