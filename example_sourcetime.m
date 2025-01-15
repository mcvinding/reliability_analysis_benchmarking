%% Example of nominal data: an MRI atlas

%% Paths and files
datdir = '/home/mikkel/mri_warpimg/data/0177/170424';
wrkdir = '/home/mikkel/reliability_analysis_proj/reliability_analysis_benchmarking';
figdir = fullfile(wrkdir, '/figures');
outdir = fullfile(wrkdir, '/output');
addpath('~/fieldtrip/fieldtrip')
ft_defaults;

%% Load data
fprintf('Loading data... ')
load(fullfile(datdir, 'mnesource_org.mat'), 'mnesource_org');
load(fullfile(datdir, 'mnesource_tmp.mat'), 'mnesource_tmp');
disp('DONE')

%% Find point cloud
roi = [-47, 10, 111];
radius = 10;

distances_org = sqrt(sum((mnesource_org.pos - roi).^2, 2));
idx_org = distances_org <= radius;
distances_tmp = sqrt(sum((mnesource_tmp.pos - roi).^2, 2));
idx_tmp = distances_tmp <= radius;

nbpts1 = mnesource_org.pos(idx_org, :);
nbpts2 = mnesource_tmp.pos(idx_tmp, :);

cfg = [];
cfg.method          = 'surface';
cfg.funparameter    = 'pow';
cfg.funcolormap     = 'OrRd';
cfg.latency         = 0.162;     % The time-point to plot (s)
cfg.colorbar        = 'no';
cfg.funcolorlim     = [lw, up];
cfg.facecolor       = 'brain';
ft_sourceplot(cfg, mnesource_org); hold on;
scatter3(nbpts1(:,1), nbpts1(:,2), nbpts1(:,3), 5, 'r', 'filled'); hold off
ft_sourceplot(cfg, mnesource_tmp); hold on;
scatter3(nbpts2(:,1), nbpts2(:,2), nbpts2(:,3), 5, 'r', 'filled'); hold off
camlight 

dat1 = mean(mnesource_org.avg.pow(idx_org,:));
dat2 = mean(mnesource_tmp.avg.pow(idx_tmp,:));
dat = [dat1; dat2];

%% Plot
lw = 1.5;              % LineWidth
ms = 5;                % MarkerSize

tim = mnesource_org.time;

f1 = figure(1); 
set(gcf,'Position',[0 0 600 300]); hold on
set(gca,'linewidth', 1.5)
plot(tim, dat1, 'b', 'linewidth', 2)
plot(tim, dat2, 'r:', 'linewidth', 2)
yy = get(gca, 'ylim'); ylim(yy);
xlabel('Time (s)'); ylabel('Source power')
ax = gca();
ax.LineWidth = lw;
axis tight

exportgraphics(f1, fullfile(figdir, 'source_ts.jpg'), 'Resolution', 600);

%% Plot MNE surfaces
lo = min([mnesource_org.avg.pow(:); mnesource_tmp.avg.pow(:)]);
up = 0.10*max([mnesource_org.avg.pow(:); mnesource_tmp.avg.pow(:)]);

cfg = [];
cfg.method          = 'surface';
cfg.funparameter    = 'pow';
cfg.funcolormap     = 'OrRd';
cfg.latency         = 0.162;     % The time-point to plot (s)
cfg.colorbar        = 'no';
cfg.funcolorlim     = [lo, up];
cfg.facecolor       = 'brain';

f2 = figure(2);
cfg.figure = f2;
ft_sourceplot(cfg, mnesource_org); 
set(gcf,'Position',[0 0 500 500]); hold on
scatter3(roi(1), roi(2), roi(3), 800, 'b', 'filled')
view([-135, 45]);
axis tight
exportgraphics(f2, fullfile(figdir, 'source_org.jpg'), 'Resolution', 600);

f3 = figure(3);
cfg.figure = f3;
ft_sourceplot(cfg, mnesource_tmp); 
set(gcf,'Position',[0 0 500 500]); hold on
scatter3(roi(1), roi(2), roi(3), 800, 'b', 'filled')
view([-135, 45]);
axis tight
exportgraphics(f3, fullfile(figdir, 'source_tmp.jpg'), 'Resolution', 600);

%% Alpha
[alpha, boots] = reliability_analysis(dat, 'interval', 1000); % 0.9968

sig = .8;
ci = prctile(boots, [2.5, 97.5]);
fprintf('Alpha = %.3f (CI: %.3f-%.3f)\n', alpha, ci(1), ci(2))
fprintf(['Probability of alpha being above threshold of %.2f:\n' ...
         '      P = %.3f\n'], sig, mean(boots> 0.8));


%% Plot
lw = 1.5;              % LineWidth
ms = 5;                % MarkerSize

f4 = figure(4); hold on
set(gcf, 'Position', [1200, 100, 300, 300])

histogram(boots, 20);
xline(alpha, 'k--', 'LineWidth',2);
% xline(sig, 'r--', 'LineWidth',2);
ax = gca();
ax.LineWidth = lw;
% set(gca, 'YTick', []);
xlim([0.99, 1]); 
ylim([0, 150])
xlabel('Alpha')
title('Bootstrap distribution')

exportgraphics(f4, fullfile(figdir, 'hist_int1.jpg'), 'Resolution', 600);

close all

%% Frequency analysis
% make data
erpdat1 = [];
erpdat1.label = {'roi'};
erpdat1.time = mnesource_org.time;
erpdat1.avg = dat1;
erpdat1.dimord = 'chan_time';
erpdat1 = ft_checkdata(erpdat1);

% Freq analysis
cfg = [];
cfg.output    = 'fourier';
cfg.method    = 'mtmconvol';
cfg.foi       = 2:10;
cfg.tapsmofrq = cfg.foi/2;
cfg.t_ftimwin = 1./cfg.foi*2;
cfg.toi       = erpdat1.time;
tst = ft_freqanalysis(cfg, erpdat1);

tst.pow = squeeze(abs(tst.fourierspctrm));
tst.theta = squeeze(angle(tst.fourierspctrm));
% imagesc(tst.pow)

cfg.method    = 'hilbert';
tst2 = ft_freqanalysis(cfg, erpdat1);
tst2.pow = squeeze(abs(tst2.fourierspctrm));
tst2.theta = squeeze(angle(tst2.fourierspctrm));

%% Plot
freqbin = 9;

f5 = figure(5); hold on
set(gcf,'Position',[0 0 600 300]); hold on
set(gca,'linewidth', 1.5)
plot(tim, tst.theta(freqbin,:), 'b', 'linewidth', 2)
plot(tim, tst2.theta(freqbin,:), 'r:', 'linewidth', 2)
yy = get(gca, 'ylim'); ylim(yy);
xlabel('Time (s)'); ylabel('Phase (rad)')
ax = gca();
ax.LineWidth = lw;
axis tight
title(sprintf('Phase at %.2f Hz', tst.freq(freqbin))); hold off

exportgraphics(f5, fullfile(figdir, 'phase_ts.jpg'), 'Resolution', 600);


%% Alpha
dat_phase = [tst.theta(freqbin,:); tst2.theta(freqbin,:)];

[alpha_phase, boots_phase] = reliability_analysis(dat_phase, 'angle_rad', 1000);

sig = .8;
ci_phase = prctile(boots_phase, [2.5, 97.5]);
fprintf('Alpha = %.3f (CI: %.3f-%.3f)\n', alpha_phase, ci_phase(1), ci_phase(2))
fprintf(['Probability of alpha being above threshold of %.2f:\n' ...
         '      P = %.3f\n'], sig, mean(boots_phase> 0.8));

%% Plot
lw = 1.5;              % LineWidth
ms = 5;                % MarkerSize

f6 = figure(6); hold on
set(gcf, 'Position', [1200, 100, 300, 300])

histogram(boots_phase, 20);
xline(alpha_phase, 'k--', 'LineWidth',2);
% xline(sig, 'r--', 'LineWidth',2);
ax = gca();
ax.LineWidth = lw;
% set(gca, 'YTick', []);
xlim([0.6, 0.9]); 
ylim([0, 150])
xlabel('Alpha')
title('Bootstrap distribution')

exportgraphics(f6, fullfile(figdir, 'hist_phase1.jpg'), 'Resolution', 600);

close all

%END