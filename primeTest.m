% Benchmarking of the alphaprime function with 10% 1% and 0.1% binning 
% compared to absolute alpha.
%
% Test agreement between two time-series: Sine-waves with random noise.

wrkdir = 'C:\Users\ncb623\reliability_analysis benchmarking';
outdir = fullfile(wrkdir, '/output');
tooldir = 'C:\Users\ncb623\reliability_analysis';
addpath(tooldir)

%% Generate time-series settings
nrun        = 100;
StopTime    = 10;                % seconds 
fs          = 1000;              % Sampling frequency (samples per second) 
dt          = 1/fs;              % seconds per sample 
t           = (dt:dt:StopTime);  % seconds 
Freq        = 5;                 % Sine wave frequency (Hz) 
err         = 0:0.1:2;           % Noise scaling

%% Init.
alpha = nan(nrun,length(err));
alphaP250 = nan(nrun,length(err));
alphaP100 = nan(nrun,length(err));
alphaP010 = nan(nrun,length(err));
alphaP001 = nan(nrun,length(err));

%% Test 
for ii = 1:nrun
    fprintf('Run %i of %i... ', ii, nrun) 
    for jj = 1:length(err)       

        % Generate two time-series
        x = sin(2*pi*Freq*t)+randn(1,length(t))*err(jj);
        y = sin(2*pi*Freq*t)+randn(1,length(t))*err(jj);
        dat = [x; y];   % N observers vs M samples

        % Absolute method
        alpha(ii,jj) = kripAlpha(dat, 'interval'); disp('done')

        % Approximation method
        alphaP250(ii,jj) = alphaprime(dat, 0.25); disp('done')
        alphaP100(ii,jj) = alphaprime(dat, 0.1); disp('done')
        alphaP010(ii,jj) = alphaprime(dat, 0.01); disp('done')
        alphaP001(ii,jj) = alphaprime(dat, 0.001); disp('done')
        
    end
    disp('done')
end

%% Save output
fprintf('Saving output... ')
save(fullfile(outdir,'primetest'), 'alpha','alphaP250','alphaP100','alphaP010','alphaP001')
disp('DONE')

%END