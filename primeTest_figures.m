% PLOT PRIME TEST
wrkdir = 'C:\Users\ncb623\reliability_analysis benchmarking';
outdir = fullfile(wrkdir, '/output');
figdir = fullfile(wrkdir, '/figures');
tooldir = 'C:\Users\ncb623\reliability_analysis';
addpath(tooldir) 

%% Load data
fprintf('Loading output... ')
load(fullfile(outdir,'primetest'), 'alpha','alphaP250','alphaP100','alphaP010','alphaP001')
disp('DONE')

%% Summaries
ciA0 = prctile(alpha, [2.5, 97.5]);
ciP250 = prctile(alphaP250, [2.5, 97.5]);
ciP100 = prctile(alphaP100, [2.5, 97.5]);
ciP010 = prctile(alphaP010, [2.5, 97.5]);
ciP001 = prctile(alphaP001, [2.5, 97.5]);

%% Summary tables
TA0   = array2table([0:.1:2; mean(alpha); ciA0]);
TP250 = array2table([0:.1:2; mean(alpha); ciA0]);
TP100 = array2table([0:.1:2; mean(alpha); ciA0]);
TP010 = array2table([0:.1:2; mean(alpha); ciA0]);
TP001 = array2table([0:.1:2; mean(alpha); ciA0]);

%% Settings
nrun        = 100;
StopTime    = 10;                % seconds 
fs          = 1000;              % Sampling frequency (samples per second) 
dt          = 1/fs;              % seconds per sample 
t           = (dt:dt:StopTime);  % seconds 
Freq        = 5;                 % Sine wave frequency (Hz) 
err         = 0:0.1:2;           % Noise scaling

%% Plot test result
lw = 1;                 % LineWidth
ms = 4;                % MarkerSize

f1 = figure; hold on
errorbar(err-0.01, median(alpha), ciA0(1,:)-median(alpha), ciA0(2,:)-median(alpha), ...
    'ro--', 'MarkerSize', ms, 'lineWidth', lw);
errorbar(err-0.005, median(alphaP001), ciP001(1,:)-median(alphaP001), ciP001(2,:)-median(alphaP001), ...
    'o--', 'MarkerSize', ms, 'lineWidth', lw, 'color',"#0072BD");
errorbar(err+0.005, median(alphaP010), ciP010(1,:)-median(alphaP010), ciP010(2,:)-median(alphaP010), ...
    'o--', 'MarkerSize', ms, 'lineWidth', lw, 'color',"#D95319");
errorbar(err+0.01, median(alphaP100), ciP100(1,:)-median(alphaP100), ciP100(2,:)-median(alphaP100), ...
    'o--', 'MarkerSize', ms, 'lineWidth', lw, 'color',"#7E2F8E");
errorbar(err+0.01, median(alphaP250), ciP250(1,:)-median(alphaP250), ciP250(2,:)-median(alphaP250), ...
    'o--', 'MarkerSize', ms, 'lineWidth', lw, 'color',"#4DBEEE");


set(gcf, 'Position', [600, 400, 700, 500])
legend('Alpha', ...
       ['Alpha', char(39), ' (0.1%)'], ... 
       ['Alpha', char(39), ' (1%)'], ...
       ['Alpha', char(39), ' (10%)'], ...
       ['Alpha', char(39), ' (25%)'])
xlim([-0.05 2.05]);
ax = gca();
ax.LineWidth = 1.5;
xlabel('Noise factor'); ylabel('Alpha')

exportgraphics(f1, fullfile(outdir, 'primeComparison.jpg'), 'Resolution', 600); 
%close 

%% Compare

kripAlpha([mean(alphaP001); mean(alpha)], 'interval')
kripAlpha([mean(alphaP010); mean(alpha)], 'interval')
kripAlpha([mean(alphaP100); mean(alpha)], 'interval')
kripAlpha([mean(alphaP250); mean(alpha)], 'interval')

kripAlpha([alphaP001(:)'; alpha(:)'], 'interval')
kripAlpha([alphaP010(:)'; alpha(:)'], 'interval')
kripAlpha([alphaP100(:)'; alpha(:)'], 'interval')
kripAlpha([alphaP250(:)'; alpha(:)'], 'interval')

for ii = 2:length(err)
    [pval100(ii), H100(ii)] = signrank(alphaP100(:,ii), alpha(:,ii), 'tail', 'both','method','exact');
    [pval010(ii), H010(ii)] = signrank(alphaP010(:,ii), alpha(:,ii), 'tail', 'both','method','exact');
    [pval001(ii), H001(ii)] = signrank(alphaP001(:,ii), alpha(:,ii), 'tail', 'both','method','exact');
    [pval001(ii), H250(ii)] = signrank(alphaP250(:,ii), alpha(:,ii), 'tail', 'both','method','exact');

    [H100b(ii), pval100b(ii)] = ttest(alphaP100(:,ii), alpha(:,ii), 'tail', 'both');
    [H010b(ii), pval010b(ii)] = ttest(alphaP010(:,ii), alpha(:,ii), 'tail', 'both');
    [H001b(ii), pval001b(ii)] = ttest(alphaP001(:,ii), alpha(:,ii), 'tail', 'both');
    [H250b(ii), pval250b(ii)] = ttest(alphaP250(:,ii), alpha(:,ii), 'tail', 'both');

    aval100(ii) = kripAlpha([alphaP100(:,ii)'; alpha(:,ii)'], 'ratio');
    aval010(ii) = kripAlpha([alphaP010(:,ii)'; alpha(:,ii)'], 'ratio');
    aval001(ii) = kripAlpha([alphaP001(:,ii)'; alpha(:,ii)'], 'ratio');
    aval250(ii) = kripAlpha([alphaP250(:,ii)'; alpha(:,ii)'], 'ratio');
end

%% %-deviation from real alpha
pctP100 = (alphaP100-alpha)./alpha*100;
mean(pctP100)
ciPctP100 = prctile(pctP100, [2.5, 97.5]);
pctP010 = (alphaP010-alpha)./alpha*100;
mean(pctP010)
ciPctP101 = prctile(pctP010, [2.5, 97.5]);
pctP001 = (alphaP001-alpha)./alpha*100;
mean(pctP001)
ciPctP001 = prctile(pctP001, [2.5, 97.5]);
pctP250 = (alphaP250-alpha)./alpha*100;
mean(pctP250)
ciPctP250 = prctile(pctP250, [2.5, 97.5]);

%% Plot %
lw = 1.5;                 % LineWidth
ms = 4;         % MarkerSize
f2 = figure(); hold on
set(gcf, 'Position', [1300, 600, 700, 500])

subplot(2,1,2); hold on
errorbar(err-0.01, median(pctP001), ciPctP001(1,:)-median(pctP001), ciPctP001(2,:)-median(pctP001), ...
    'o--', 'MarkerSize',ms, 'lineWidth',1, 'color',"#0072BD");
errorbar(err+0.005, median(pctP010), ciPctP101(1,:)-median(pctP010), ciPctP101(2,:)-median(pctP010), ...
    'o--', 'MarkerSize',ms, 'lineWidth',1, 'color',"#D95319");
errorbar(err, median(pctP100), ciPctP100(1,:)-median(pctP100), ciPctP100(2,:)-median(pctP100), ...
    'o--', 'MarkerSize',ms, 'lineWidth',1, 'color',"#7E2F8E");
errorbar(err-0.005, median(pctP250), ciPctP250(1,:)-median(pctP250), ciPctP250(2,:)-median(pctP250), ...
    'o--', 'MarkerSize',ms, 'lineWidth',1, 'color',"#4DBEEE");
hold off
% set(gcf, 'Position', [1300, 600, 700, 200])
legend(['Alpha', char(39), ' (0.1%)'], ... 
       ['Alpha', char(39), ' (1%)'], ...
       ['Alpha', char(39), ' (10%)'], ...
       ['Alpha', char(39), ' (25%)'], ...
       'Location', 'southwest')
xlim([0.05 2.05]); ylim([-50, 5])
ax = gca();
ax.LineWidth = lw;
xlabel('Noise factor'); 
ylabel('%-Error')

% exportgraphics(f2, fullfile(outdir, 'primeComparisonPct.jpg'), 'Resolution', 600); 

%% Difference from real alpha
difP100 = alphaP100-alpha;
mean(difP100)
ciDifP100 = prctile(difP100, [2.5, 97.5]);
difP010 = alphaP010-alpha;
mean(difP010)
ciDifP010 = prctile(difP010, [2.5, 97.5]);
difP001 = alphaP001-alpha;
mean(difP001)
ciDifP001 = prctile(difP001, [2.5, 97.5]);
difP250 = alphaP250-alpha;
mean(difP250)
ciDifP250 = prctile(difP250, [2.5, 97.5]);

%% Plot
% lw = 1.5;                 % LineWidth
% ms = 12;                % MarkerSize
% f3 = figure; hold on
subplot(2,1,1); hold on

errorbar(err-0.005, median(difP001), ciDifP001(1,:)-median(difP001), ciDifP001(2,:)-median(difP001), ...
    'o--', 'MarkerSize',ms, 'lineWidth',1, 'color',"#0072BD");
errorbar(err+0.005, median(difP010), ciDifP010(1,:)-median(difP010), ciDifP010(2,:)-median(difP010), ...
    'o--', 'MarkerSize',ms, 'lineWidth',1, 'color',"#D95319");
errorbar(err, median(difP100), ciDifP100(1,:)-median(difP100), ciDifP100(2,:)-median(difP100), ...
    'o--', 'MarkerSize',ms, 'lineWidth',1, 'color',"#7E2F8E");
errorbar(err, median(difP250), ciDifP250(1,:)-median(difP250), ciDifP250(2,:)-median(difP250), ...
    'o--', 'MarkerSize',ms, 'lineWidth',1, 'color',"#4DBEEE");
hold off
% set(gcf, 'Position', [1300, 600, 700, 200])
% legend(['Alpha', char(39), ' (0.1%)'], ... 
%        ['Alpha', char(39), ' (1%)'], ...
%        ['Alpha', char(39), ' (10%)'], ...
%        'Location', 'southeast')
xlim([-0.05 2.05]); ylim([-0.2, 0.05])
ax = gca();
ax.LineWidth = lw;
% xlabel('Noise factor'); 
ylabel('Difference')

% exportgraphics(f3, fullfile(outdir, 'primeComparisondif.jpg'), 'Resolution', 600); 
exportgraphics(f2, fullfile(outdir, 'primeComparisonDifPct.jpg'), 'Resolution', 600); 
