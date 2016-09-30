function [r1, r2] = energy_entropy_skewness_plots(s, t, num_subjects, start, stop)
% PURPOSE: plot the relationship between energy and entropy averaged across
% subjects, and between energy and skewness of system-wide subgraphs
% 
% INPUT:
% s: matrix of subgraphs with dimensions (nNodes x nNodes x nSubgraphs)
% 
% t: matrix of temporal coefficients
%       ROWS: number of subgraphs
%       COLUMNS: number of subjects x number of time windows per subject
% 
% num_subjects: total number of subjects
%
% start: a 1 x num_subjects vector containing the start index within the
% timeseries matrix of the expression for each subject
%
% stop: a 1 x num_subjects vector containing the stop index within the
% timeseries matrix of the expression for each subject 
%
% OUTPUT:
% r1: correlation between energy and entropy
% r2: correlation between energy and subgraph skewness
%--------------------------------------------------------------------------

num_components = size(t, 1);

% compute energy and entropy values
energy = zeros(num_components, num_subjects);
entropy = zeros(num_components, num_subjects);

for ii = 1:num_subjects
    for jj = 1:num_components
        timeseries = t(jj, start(ii):stop(ii));
        energy(jj,ii) = sum(timeseries.^2);
        entropy(jj,ii) = signal_entropy(timeseries);
    end
end


% plot energy and entropy relationship
figure;
subplot(121)
mean_energy = log10(mean(energy, 2)); % average across subjects
mean_entropy = mean(entropy, 2); % average across subjects
scatter(mean_energy, mean_entropy,'d');
lsline;
[r1,p] = corr(mean_energy, mean_entropy, 'type', 'pearson');
xlabel('Log(Energy)')
ylabel('Entropy')
str = sprintf(['energy entropy relationship \n pearson r=' num2str(r1) ...
    ' p=' num2str(p)]);
title(str)


% plot energy and subgraph skewness relationship
subplot(122)
means = compute_cognitive_system_averages(s);
sk = zeros(1,num_components);
for ii = 1:num_components
    % due to symmetry, take only upper triangular 
    v = triangular_to_vector(means(:,:,ii), 1);
    sk(ii) = skewness(v);
end

h=scatter(mean_energy, sk,'d');
lsline;
[r2,p] = corr(mean_energy, sk', 'type', 'pearson');
xlabel('Log(Energy)')
ylabel('Skewness')
str = sprintf(['energy skewness relationship \n pearson r=' num2str(r2) ...
    ' p=' num2str(p)]);
title(str)
end