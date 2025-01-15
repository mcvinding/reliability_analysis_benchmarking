%% Example of nominal data: an MRI atlas

% Paths and files
addpath /usr/local/freesurfer/7.2.0-1/matlab
cd /home/mikkel/mri_warpimg/fs_subjects_dir/0177/mri/

wrkdir = '/home/mikkel/reliability_analysis_proj/reliability_analysis_benchmarking';
figdir = fullfile(wrkdir, '/figures');
outdir = fullfile(wrkdir, '/output');

%%  Read MRI and prepare data
mri1 = MRIread('/home/mikkel/mri_warpimg/fs_subjects_dir/0177/mri/aparc.a2009s+aseg.mgz');
mri2 = MRIread('/home/mikkel/mri_warpimg/fs_subjects_dir/0177warp/mri/aparc.a2009s+aseg.mgz');

mri1flat = mri1.vol(:)';
mri2flat = mri2.vol(:)';

dat = [mri1flat; mri2flat];

%% Calculate Alpha
addpath('~/reliability_analysis_proj/reliability_analysis/')

alph = reliability_analysis(dat, 'nominal');   % 0.7253
[alpha, cfg] = kripAlpha(dat,  'nominal');
tic
[boots] = bootstrap_alpha(dat, cfg, 1000);
toc

%% Summary
% load(fullfile(outdir, 'example_ord_results.mat'), ...
%     'boots','alpha')

sig = .8;

ci = prctile(boots, [2.5, 97.5]);
fprintf('Alpha = %.3f (CI: %.3f-%.3f)\n', alpha, ci(1), ci(2))
fprintf(['Probability of alpha being above threshold of %.2f:\n' ...
         '      P = %.3f\n'], sig, mean(boots> 0.8));

%% Plot
lw = 1.5;              % LineWidth
ms = 5;                % MarkerSize

f1 = figure(1); hold on
set(gcf, 'Position', [1200, 100, 300, 300])

histogram(boots, 20);
xline(alpha, 'k--', 'LineWidth',2);
% xline(sig, 'r--', 'LineWidth',2);
ax = gca();
ax.LineWidth = lw;
% set(gca, 'YTick', []);
xlim([0.72, 0.73]); 
ylim([0, 150])
xlabel('Alpha')
title('Bootstrap distribution')

exportgraphics(f1, fullfile(figdir, 'hist_ord1.jpg'), 'Resolution', 600);

%% Restrict to brain mask

mri1_mask = MRIread('/home/mikkel/mri_warpimg/fs_subjects_dir/0177/mri/brainmask.mgz');
mask = mri1_mask.vol > 0;
mri1.masked = mri1.vol;
mri1.masked(~mask) = NaN;

mri1flatMask = mri1.vol(mask)';
mri2flatMask = mri2.vol(mask)';

dat2 = [mri1flatMask; mri2flatMask];

tic
[alpha2, cfg2] = kripAlpha(dat2,  'nominal');  % 0.5615
toc; tic
[boots2] = bootstrap_alpha(dat2, cfg2, 1000);
toc

ci2 = prctile(boots2, [2.5, 97.5]);
fprintf('Alpha = %.3f (CI: %.3f-%.3f)\n', alpha2, ci2(1), ci2(2))
fprintf(['Probability of alpha being above threshold of %.2f:\n' ...
         '      P = %.3f\n'], sig, mean(boots2> 0.8));
figure; histogram(boots2, 30, 'Normalization', 'pdf');
xline(alpha2, 'k', 'LineWidth',2);

% [vert, lab, col] = read_annotation(fname);

%% Save data
save(fullfile(outdir, 'example_ord_results.mat'), ...
    'boots','boots2', 'alpha', 'alpha2')

%END