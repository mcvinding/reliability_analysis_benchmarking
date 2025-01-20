% SUMMARIES OF PRIME TEST
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
mTabA0   = array2table([0:.1:2; mean(alpha); ciA0]);
mTabP250 = array2table([0:.1:2; mean(ciP250); ciP250]);
mTabP100 = array2table([0:.1:2; mean(ciP100); ciP100]);
mTabP010 = array2table([0:.1:2; mean(ciP010); ciP010]);
mTabP001 = array2table([0:.1:2; mean(ciP001); ciP001]);

%% Alpha
for ii = 2:size(alpha,2)
    alphaA0P250(ii) = reliability_analysis([alpha(:,ii), alphaP250(:,ii)]', 'interval');
    alphaA0P100(ii) = reliability_analysis([alpha(:,ii), alphaP100(:,ii)]', 'interval');
    alphaA0P010(ii) = reliability_analysis([alpha(:,ii), alphaP010(:,ii)]', 'interval');
    alphaA0P001(ii) = reliability_analysis([alpha(:,ii), alphaP001(:,ii)]', 'interval');
end

aTabP250 = array2table([0:.1:2; alphaA0P250]);
aTabP100 = array2table([0:.1:2; alphaA0P100]);
aTabP010 = array2table([0:.1:2; alphaA0P010]);
aTabP001 = array2table([0:.1:2; alphaA0P001]);


for ii = 2:size(alpha,2)
    [P1(ii), H1(ii)] = signrank(alpha(:,ii)-alphaP250(:,ii)); %, 'tail', 'both');
    [P2(ii), H2(ii)] = signrank(alpha(:,ii)-alphaP100(:,ii)); %, 'tail', 'both');
    [P3(ii), H3(ii)] = signrank(alpha(:,ii)-alphaP010(:,ii)); %, 'tail', 'both');
    [P4(ii), H4(ii)] = signrank(alpha(:,ii)-alphaP001(:,ii)); %, 'tail', 'both');
end

pTabP250 = array2table([0:.1:2; P1; H1]);
pTabP100 = array2table([0:.1:2; P2; H2]);
pTabP010 = array2table([0:.1:2; P3; H3]);
pTabP001 = array2table([0:.1:2; P4; H4]);

% for ii = 1:size(alpha,2)
%     dtestA0P250(ii) = 1-max(mean((alpha(:,ii)-alphaP250(:,ii)) > 0), mean((alpha(:,ii)-alphaP250(:,ii)) < 0));
%     dtestA0P100(ii) = 1-max(mean((alpha(:,ii)-alphaP100(:,ii)) > 0), mean((alpha(:,ii)-alphaP100(:,ii)) < 0));
%     dtestA0P010(ii) = 1-max(mean((alpha(:,ii)-alphaP010(:,ii)) > 0), mean((alpha(:,ii)-alphaP010(:,ii)) < 0));
%     dtestA0P001(ii) = 1-max(mean((alpha(:,ii)-alphaP001(:,ii)) > 0), mean((alpha(:,ii)-alphaP001(:,ii)) < 0));
% end


%% Save
writetable(mTabA0, fullfile(outdir, 'mTabA0.csv'))
writetable(mTabP250, fullfile(outdir, 'mTabP250.csv'))
writetable(mTabP100, fullfile(outdir, 'mTabP100.csv'))
writetable(mTabP010, fullfile(outdir, 'mTabP010.csv'))
writetable(mTabP001, fullfile(outdir, 'mTabP001.csv'))

writetable(aTabP250, fullfile(outdir, 'aTabP250.csv'))
writetable(aTabP100, fullfile(outdir, 'aTabP100.csv'))
writetable(aTabP010, fullfile(outdir, 'aTabP010.csv'))
writetable(aTabP001, fullfile(outdir, 'aTabP001.csv'))

writetable(pTabP250, fullfile(outdir, 'pTabP250.csv'))
writetable(pTabP100, fullfile(outdir, 'pTabP100.csv'))
writetable(pTabP010, fullfile(outdir, 'pTabP010.csv'))
writetable(pTabP001, fullfile(outdir, 'pTabP001.csv'))
disp('DONE')

%END
