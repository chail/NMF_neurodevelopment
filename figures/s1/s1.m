%% A-D) - parameter size 3x3
dir = pwd;
cd ../../

load('./parameter_space/parameter_sweep.mat')
load('./parameter_space/beta_range.mat')
load('./parameter_space/k_range.mat')
load('./parameter_space/beta_exponent.mat')


figure;
subplot(2, 2, 1);
imagesc(parameter.parameter_space);

set(gca, 'XTick', [1 3 5 7]);
set(gca, 'XTickLabel', {'10^{-1.6}', '10^{-2}', '10^{-2.4}', ...
    '10^{-2.8}'});
xlabel('\beta')
ylabel('k')
cb = colorbar

subplot(2, 2, 2);
plot(mean(parameter.parameter_space, 2));
ylabel('rss')
xlabel('k')

subplot(2, 2, 3);
plot(diff(mean(parameter.parameter_space, 2)));
ylabel('\Delta rss')
xlabel('k')

subplot(2, 2, 4);
plot(parameter.parameter_space(10, :));
set(gca, 'XTick', [1 3 5 7]);
set(gca, 'XTickLabel', {'10^{-1.6}', '10^{-2}', '10^{-2.4}', ...
    '10^{-2.8}'});
xlabel('\beta')
ylabel('rss')

cd(dir)
