% PLOT TIMING TEST
wrkdir = 'C:\Users\ncb623\reliability_analysis benchmarking';
outdir = fullfile(wrkdir, '/output');
figdir = fullfile(wrkdir, '/figures');
tooldir = 'C:\Users\ncb623\reliability_analysis';
addpath(tooldir) 

%% Load data
fprintf('Loading output... ')
load(fullfile(outdir,'timetest3'), 'alphaOrg','alphaN2f','alphaPrm','alphaMat', ...
                                  'dTOrg','dTN2f','dTPrm','dTMat')
load(fullfile(outdir,'timetestOrd2'), 'dTOrg_ord', 'dTMat_ord')
disp('Done!')

%% Plot over time
% to check if there is accumulating lag
figure();
subplot(1,4,1); plot(dTOrg); title('Org')
subplot(1,4,2); plot(dTN2f); title('N2')
subplot(1,4,3); plot(dTPrm); title('Prim')
subplot(1,4,4); plot(dTMat); title('Old')

%% Summaries
ciOrg = prctile(dTOrg, [5, 95]) - mean(dTOrg, 'omitnan');
ciN2f = prctile(dTN2f, [5, 95]) - mean(dTN2f, 'omitnan');
ciPrm = prctile(dTPrm, [5, 95]) - mean(dTPrm, 'omitnan');
ciMat = prctile(dTMat, [5, 95]) - mean(dTMat, 'omitnan');

ciOrgOrd = prctile(dTOrg_ord, [5, 95]) - mean(dTOrg_ord, 'omitnan');
ciMatOrd = prctile(dTMat_ord, [5, 95]) - mean(dTMat_ord, 'omitnan');

%% time-series settings
nrun        = 100;
StopTimes   = [100, 200, 400, 600, 1000, 1500, round(logspace(3.3,5,14), -2)];
fs          = 1;            % Sampling frequency (samples per second) 
dt          = 1/fs;         % seconds per sample 
Freq        = 5;

%% Plot settings
close all
lw = 1.5;              % LineWidth
ms = 5;                % MarkerSize

f1 = figure(1); hold on
set(gcf, 'Position', [1200, 100, 700, 900])

%% Plot: interval data
subplot(15,1,4:10); hold on
yline(300, '--'); yline(60, '--'); yline(10, '--');  yline(1, '--')
errorbar(StopTimes*fs, median(dTOrg, 'omitnan'), ciOrg(1,:), ciOrg(2,:), ...
    'ko--', 'MarkerSize',ms, 'lineWidth',lw);
% errorbar(StopTimes*fs, median(dTOrg_ord, 'omitnan'), ciOrgOrd(1,:), ciOrgOrd(2,:), ...
%     'ko--', 'MarkerSize',ms, 'lineWidth',lw);
errorbar(StopTimes*fs, median(dTN2f, 'omitnan'), ciN2f(1,:), ciN2f(2,:), ...
    'bo--', 'MarkerSize',ms, 'lineWidth',lw);
errorbar(StopTimes*fs, median(dTPrm, 'omitnan'), ciPrm(1,:), ciPrm(2,:), ...
    'ro--', 'MarkerSize',ms, 'lineWidth',lw);
errorbar(StopTimes*fs, median(dTMat, 'omitnan'), ciMat(1,:), ciMat(2,:), ...
    'mo--', 'MarkerSize',ms, 'lineWidth',lw);

set(gca, 'XScale', 'log'); xlim([90 110000])
set(gca, 'YScale', 'log'); ylim([0.0001, 1e3])
legend('Alpha', 'Alpha (N=2)', ['Alpha', char(39)], 'Old MATLAB',...
    'Location','southeast')
% legend('Alpha', 'Alpha (ordinal)', 'Alpha (N=2)', ['Alpha', char(39)], 'Old MATLAB', 'Old MATLAB (ordinal)',...
%     'Location','southeast')
% xlabel('Data points per observation'); 
ylabel('Time (s)')
ax = gca();
ax.LineWidth = lw;
title('Interval data', 'FontSize',14)

% exportgraphics(f1, fullfile(figdir, 'timeComparison.jpg'), 'Resolution', 600);

%% Ordinal
% f2 = figure(2); hold on
% set(gcf, 'Position', [1300, 200, 700, 300])

subplot(15,1,12:15); hold on
errorbar(StopTimes*fs, median(dTOrg_ord, 'omitnan'), ciOrgOrd(1,:), ciOrgOrd(2,:), ...
    'ko--', 'MarkerSize',ms, 'lineWidth',lw);
errorbar(StopTimes*fs, median(dTMat_ord, 'omitnan'), ciMatOrd(1,:), ciMatOrd(2,:), ...
    'mo--', 'MarkerSize',ms, 'lineWidth',lw);
yline(1, '--')
set(gca, 'XScale', 'log'); xlim([90 110000])
set(gca, 'YScale', 'log')
legend('Alpha', 'Old MATLAB', 'location','southeast')
xlabel('Data points per observation'); ylabel('Time (s)')
ax = gca();
ax.LineWidth = lw;
title('Ordinal data', 'FontSize',14)

% exportgraphics(f2, fullfile(figdir, 'timeComparison_ord.jpg'), 'Resolution', 600);

%% Generate two time-series plot
t = 1:dt:max(StopTimes);
x = sin(2*pi*Freq*t)*10+randn(1,length(t))*5;
y = sin(2*pi*Freq*t)*10+randn(1,length(t))*5;
dat = [x; y];   % N observers vs M samples

% f2 = figure(2); hold on
% set(gcf, 'Position', [600, 600, 700, 200])

subplot(15,1,1:2); hold on
plot(dat');
for ii = 1:length(StopTimes)
    xline(StopTimes(ii), '-', 'lineWidth',lw)
end
ax = gca();
ax.LineWidth = lw;

% exportgraphics(f2, fullfile(figdir, 'timeComparisonTS.jpg'), 'Resolution', 600);

%% Export all
exportgraphics(f1, fullfile(figdir, 'timeComparison_all.jpg'), 'Resolution', 600);

% END