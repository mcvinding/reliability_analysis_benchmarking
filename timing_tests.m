% TIMING TEST
% Compare the time to  calculate Alpha with the various implemented
% methods. FIrst for interval data and then for ordinal data.

wrkdir = 'C:\Users\ncb623\reliability_analysis benchmarking';
outdir = fullfile(wrkdir, '/output');
tooldir = 'C:\Users\ncb623\reliability_analysis';
addpath(tooldir)

ps = parallel.Settings;
ps.Pool.AutoCreate=false;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Interval data 
% time-series settings
nrun        = 100;
StopTimes   = [100, 200, 400, 600, 1000, 1500, round(logspace(3.3,5,14), -2)]; % 2.^(1:15); %, 15, 20, 25, 30, 40, 50];
fs          = 1;            % Sampling frequency (samples per second) 
dt          = 1/fs;         % seconds per sample 
Freq        = 5;
N_obs       = 2;

%% Init.
alphaOrg = nan(nrun, length(StopTimes));
alphaN2f = nan(nrun, length(StopTimes));
alphaPrm = nan(nrun, length(StopTimes));
alphaMat = nan(nrun, length(StopTimes));
dTOrg = nan(nrun, length(StopTimes));
dTN2f = nan(nrun, length(StopTimes));
dTPrm = nan(nrun, length(StopTimes));
dTMat = nan(nrun, length(StopTimes));

%% Run sims
for ii = 1:nrun
    fprintf('### Run %i of %i ###\n', ii, nrun)
    for aa = 1:length(StopTimes)
        t = (dt:dt:StopTimes(aa));
        fprintf('N = %i ...\n ', length(t))

        % Generate two time-series
        dat = zeros(N_obs, length(t)); % N observers vs M samples
        for nn = 1:N_obs
            dat(nn,:) = sin(2*pi*Freq*t)*10+randn(1,length(t))*5;
        end
        
        % New fast implementation
        tic
        alphaN2f(ii,aa) = kripAlphaN2fast(dat); disp('done')
        dTN2f(ii,aa) = toc;
        fprintf('done in %3.3f s\n', dTN2f(ii,aa))

        % Approximation method
        tic
        alphaPrm(ii,aa) = alphaprime(dat); 
        dTPrm(ii,aa) = toc;
        fprintf('done in %3.3f s\n', dTPrm(ii,aa))

        % Main implementation
        if ~(length(t) > 75000)
            tic
            alphaOrg(ii,aa) = kripAlpha(dat, 'interval');
            dTOrg(ii,aa) = toc;
            fprintf('done in %3.3f s\n', dTOrg(ii,aa))
        end

        % Old MATLAB file
        if ~(length(t) > 601)  % Above this and my PC will crash
            tic
            alphaMat(ii,aa) = kriAlpha(dat, 'interval'); disp('done')
            dTMat(ii,aa) = toc;   
            fprintf('done in %3.3f s\n', dTMat(ii,aa))
        end

    end
end
disp('DONE')

% Save output
fprintf('Saving output... ')
save(fullfile(outdir,'timetest3'), 'alphaOrg','alphaN2f','alphaPrm','alphaMat', ...
                                  'dTOrg','dTN2f','dTPrm','dTMat')
disp('DONE')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Ordinal data
% settings
N_obs       = 2;
errPct      = 0.5;  %  Percent disagreement
ordVals     = [1,2,3,4,5,6,7,8,9,10];

% Init.
alphaOrg_ord = nan(nrun, length(StopTimes));
alphaMat_ord = nan(nrun, length(StopTimes));
dTOrg_ord = nan(nrun, length(StopTimes));
dTMat_ord = nan(nrun, length(StopTimes));

% Run sims
for ii = 1:nrun
    fprintf('### Run %i of %i ###\n', ii, nrun)
    for aa = 1:length(StopTimes)
        t = (dt:dt:StopTimes(aa));
        fprintf('N = %i ...\n ', length(t))

        % Generate two data-series
        dat = zeros(N_obs, length(t)); % N observers vs M samples
        dat(1,:) = repmat(ordVals, 1, StopTimes(aa)/length(ordVals));
        for nn = 2:N_obs
            tmp = dat(1,:);
            tmp(1:(length(tmp)*errPct)) = tmp(randperm(length(tmp)/2));
            dat(nn,:) = tmp;
        end

        % Main implementation
        tic
        alphaOrg_ord(ii,aa) = kripAlpha(dat, 'interval');
        dTOrg_ord(ii,aa) = toc;
        fprintf('done in %3.3f s\n', dTOrg_ord(ii,aa))

        % Old MATLAB file
        tic
        alphaMat_ord(ii,aa) = kriAlpha(dat, 'interval'); disp('done')
        dTMat_ord(ii,aa) = toc;   
        fprintf('done in %3.3f s\n', dTMat_ord(ii,aa))
    end
end
disp('DONE')

% Save output
fprintf('Saving output... ')
save(fullfile(outdir,'timetestOrd2'), 'alphaOrg_ord', 'alphaMat_ord', ...
                                     'dTOrg_ord','dTMat_ord')
disp('DONE')

%END