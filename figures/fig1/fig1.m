%% panel 1- BrainNetView image 

% generate .node file for BrainNetViewer
Power2011nodes_system
% surface file: BrainMesh_Ch2withCerebellum.nv

%% panel 2
% size 10 x 20 cm

load('../../pnc_data/ts_36_ev.mat')

s = [ts_36_ev(:, 1, 1) (ts_36_ev(:, 2, 1) + 300)...
    (ts_36_ev(:, 3, 1)+500)];

figure;
plot(1:120, s)
set(gca, 'YTick', [])


%% panel 3
% size 10 x 30 cm
load(['../../ts36_wavelets_highpass/Aij_subj' ...
    num2str(1) '_rest_t020_o018.mat'], 'Aij');

%every other window
a = [Aij{1} Aij{3} Aij{51}];
figure;
subplot(1, 3, 1);
imagesc(Aij{1});
axis equal on;
caxis([min(min(a)) max(max(a))]);
colorbar
set(gca, 'YLim', [1 264]);

subplot(1, 3, 2);
imagesc(Aij{2});
axis equal on;
caxis([min(min(a)) max(max(a))]);
colorbar
set(gca, 'YLim', [1 264]);

subplot(1,3,3);
imagesc(Aij{3});
axis equal on;
caxis([min(min(a)) max(max(a))]);
colorbar
set(gca, 'YLim', [1 264]);

%% panel 4 -- illustration of columns from demeaned matrix
% size 0.05 x 10 cm
figure;
load(['../../ts36_wavelets_highpass/Aij_subj' ...
    num2str(1) '_rest_t020_o018.mat'], 'configuration_demean');
imagesc(configuration_demean(1:100, 1:2));
set(gca, 'YTick', []);
set(gca, 'XTick', []);

figure;
imagesc(configuration_demean(1:100, end));
set(gca, 'YTick', []);
set(gca, 'XTick', []);

%% panel 5

path = '../../ts36_wavelets_highpass/';
s = h5read([path 'PNC_ts36_highpass_NMF_output.hdf5'], '/subnetworks');
t = h5read([path 'PNC_ts36_highpass_NMF_output.hdf5'], '/timeseries');

% unshape subgraphs into vector form
s1 = triu(s(:,:,1),1);
s1 = s1(s1~=0);
s10 = triu(s(:,:,10),1);
s10 = s10(s10~=0);

% plot basis vectors- size 1 x 10 cm
figure;
subplot(1, 2, 1);
imagesc(s1(1:100))
set(gca, 'YTick', []);
set(gca, 'XTick', []);
subplot(1, 2, 2);
imagesc(s10(1:100));
set(gca, 'YTick', []);
set(gca, 'XTick', []);

% plot expr - size 5 x 15 cm
figure
t1 = [t(1, 1:200)+ 15; t(10, 1:200)];
plot(t1')
set(gca, 'YTick', []);
set(gca, 'XTick', []);

% plot subnetwork - size 5 x 5
figure;
imagesc(s(:,:,3));
set(gca, 'YTick', []);
set(gca, 'XTick', []);
axis equal on






