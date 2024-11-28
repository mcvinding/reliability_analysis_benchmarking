% PLOT TIMING TEST
% Plot average across N runs in other script.
wrkdir = 'C:\Users\ncb623\reliability_analysis benchmarking';
outdir = fullfile(wrkdir, '/output');
figdir = fullfile(wrkdir, '/figures');
tooldir = 'C:\Users\ncb623\reliability_analysis';
addpath(tooldir)

%% Load data
fprintf('Loading output... ')
load(fullfile(outdir,'timetest2'), 'alphaOrg','alphaN2f','alphaPrm','alphaMat', ...
                                  'dTOrg','dTN2f','dTPrm','dTMat')
save(fullfile(outdir,'timetestOrd'), 'alphaOrg_ord','alphaN2f_ord','alphaPrm_ord', ...
                                     'alphaMat_ord', 'dTOrg_ord','dTN2f_ord', ...
                                     'dTPrm_ord','dTMat_ord')
disp('Done!')
%% Summaries
ciOrg = prctile(dTOrg, [5, 95]) - mean(dTOrg, 'omitnan');
ciN2f = prctile(dTN2f, [5, 95]) - mean(dTN2f, 'omitnan');
ciPrm = prctile(dTPrm, [5, 95]) - mean(dTPrm, 'omitnan');
ciMat = prctile(dTMat, [5, 95]) - mean(dTMat, 'omitnan');

%% Plot
lw = 1.5;                 % LineWidth
ms = 5;                % MarkerSize

f1 = figure(1); hold on
set(gcf, 'Position', [1300, 200, 700, 600])

errorbar(StopTimes*fs, median(dTOrg, 'omitnan'), ciOrg(1,:), ciOrg(2,:), ...
    'ko--', 'MarkerSize',ms, 'lineWidth',lw);
errorbar(StopTimes*fs, median(dTN2f, 'omitnan'), ciN2f(1,:), ciN2f(2,:), ...
    'bo--', 'MarkerSize',ms, 'lineWidth',lw);
errorbar(StopTimes*fs, median(dTPrm, 'omitnan'), ciPrm(1,:), ciPrm(2,:), ...
    'ro--', 'MarkerSize',ms, 'lineWidth',lw);
errorbar(StopTimes*fs, median(dTMat, 'omitnan'), ciMat(1,:), ciMat(2,:), ...
    'mo--', 'MarkerSize',ms, 'lineWidth',lw);
yline(300, '--'); yline(60, '--'); yline(10, '--')

set(gca, 'XScale', 'log')
set(gca, 'YScale', 'log')
legend('Alpha', 'Alpha (N=2, fast)', ['Alpha', char(39)], 'Old MATLAB', 'location','northeast')
xlabel('Data points per observation'); ylabel('Time (s)')
ax = gca();
ax.LineWidth = lw;

exportgraphics(f1, fullfile(figdir, 'timeComparison.jpg'), 'Resolution', 600); 

%% Generate two time-series plot
x = sin(2*pi*Freq*t)*10+randn(1,length(t))*5;
y = sin(2*pi*Freq*t)*10+randn(1,length(t))*5;
dat = [x; y];   % N observers vs M samples

f2 = figure(2); hold on
set(gcf, 'Position', [600, 600, 700, 200])

plot(dat');
for ii = 1:length(StopTimes)
    xline(StopTimes(ii), '-')
end
set(gca, 'XScale', 'log')

exportgraphics(f2, fullfile(figdir, 'timeComparisonTS.jpg'), 'Resolution', 600); 





