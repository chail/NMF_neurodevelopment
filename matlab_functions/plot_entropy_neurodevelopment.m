function plot_entropy_neurodevelopment(t, num_subjects, plot_rows, ...
    plot_cols,start,stop)
% PURPOSE: plot boxplots for normalize entropy of temporal coefficients
% across the young and old subject groups
%
% INPUT:
% t: matrix of temporal coefficients
%       ROWS: number of subgraphs
%       COLUMNS: number of subjects x number of time windows per subject
% 
% num_subjects: number of subjects 
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

figure;
groups = [repmat({'child'}, 1, 100) repmat({'young adult'}, 1, 100)];
for ii = 1:num_components
    subplot(plot_rows, plot_cols, ii);
    boxplot(entropy(expr_order(ii),:), groups);
    [p,~, stats] = ranksum(entropy(expr_order(ii),1:100), ...
        entropy(expr_order(ii),101:200));
    str = ['component ' num2str(ii) '\n p=' num2str(p) ...
        '\n z=' num2str(stats.zval)];
    title(sprintf(str));
    ylabel('Normalized Entropy')
end
end
