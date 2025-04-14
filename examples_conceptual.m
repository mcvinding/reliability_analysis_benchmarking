% Make conceptual figures
wrkdir = 'C:\Users\ncb623\reliability_analysis benchmarking';
outdir = fullfile(wrkdir, '/output');
addpath("C:\Users\ncb623\reliability_analysis")

%% Basic seetings
lw = 1.5;              % LineWidth
ms = 5;                % MarkerSize

cmap_cat = [215/255, 25/255, 28/255;
            253/255,174/255, 97/255;
            255/255,255/255,191/255;
            171/255,217/255,233/255;
             44/255,123/255,182/255];

cmap_con = [240/255,249/255,232/255;
            186/255,228/255,188/255;
            123/255,204/255,196/255;
             67/255,162/255,202/255;
              8/255,104/255,172/255];

%% Interval data example
% Define the sine data
t = linspace(0, 2*pi, 1000);
f = 1; % Frequency of both sine waves
phase_shifts = [pi/12, pi/4, pi/2]; 

close all
f1 = figure(1);
set(f1, 'Position', [600, 400, 1200, 600])
for ii = 1:length(phase_shifts)
    % Phase difference
    y1 = sin(2*pi*f*t);
    y2 = sin(2*pi*f*t + phase_shifts(ii));
    a = reliability_analysis([y1;y2], 'interval');

    subplot(3,3,ii); hold on
    plot(t, y1, 'b', 'LineWidth',lw);
    plot(t, y2, 'r', 'LineWidth',lw);
    xlim([0, 3])
    set(gca,'YTickLabel',[], 'XTickLabel',[]);
    ax = gca();
    ax.LineWidth = lw;
    title(sprintf('Alpha = %.2f', a), 'FontSize', 14)

    % Amplitude difference
    y1 = sin(2*pi*f*t);
    y2 = y1/(ii*1.15);
    a = reliability_analysis([y1;y2], 'interval');

    subplot(3,3,ii+3); hold on
    plot(t, y1, 'b', 'LineWidth',lw);
    plot(t, y2, 'r', 'LineWidth',lw);
    xlim([0, 3])
    set(gca,'YTickLabel',[], 'XTickLabel',[]);
    ax = gca();
    ax.LineWidth = lw;
    title(sprintf('Alpha = %.2f', a), 'FontSize', 14)

    % Noise difference
    y1 = sin(2*pi*f*t);
    y2 = y1+randn(size(y1))*ii/3;
    a = reliability_analysis([y1;y2], 'interval');

    subplot(3,3,ii+6); hold on
    plot(t, y2, 'r', 'LineWidth',lw);
    plot(t, y1, 'b', 'LineWidth',lw);
    xlim([0, 3])
    set(gca,'YTickLabel',[], 'XTickLabel',[]);
    ax = gca();
    ax.LineWidth = lw;
    title(sprintf('Alpha = %.2f', a), 'FontSize', 14)

end

exportgraphics(f1, fullfile(outdir, 'example_int.jpg'), 'Resolution', 600); 


%% Ordinal and nominal
rng(3)
            
% Define the grid size
rows = 4;
cols = 20;

percentages = [1, 40, 80]; % 10% of cells will be replaced

f3 = figure(3);
f4 = figure(4);
set(f3, 'Position', [600, 400, 1200, 200])
set(f4, 'Position', [600, 400, 1200, 200])

for ii = 1:length(percentages)
    % Initialize the grid with identical values in each row
    grid = repmat(1:5, rows, ceil(cols/5));
    grid = grid(:, 1:cols);

    num_cells_to_replace = round(rows * cols * percentages(ii) / 100);
    for i = 1:num_cells_to_replace
        row = randi(rows);
        col = randi(cols);
        grid(row, col) = randi([1, 5]); % Replace with a value between 1 and 5
    end

    a_ordinal = reliability_analysis(grid, 'ordinal');
    a_nominal = reliability_analysis(grid, 'nominal');

    % Plot the grid using imagesc
    figure(3);
    subplot(1,3,ii); hold on
    imagesc(grid);
    colormap(cmap_con)

    title(sprintf('Alpha = %.2f', a_ordinal), 'FontSize', 14)
    %Add grid lines
    ax = gca;
    ax.XGrid = 'on';
    ax.YGrid = 'on';
    ax.GridColor = [0, 0, 0]; % Black grid lines
    ax.GridAlpha = 0.5; % Transparency of grid lines
    ax.XTick = 0.5:1:cols+0.5;
    ax.YTick = 0.5:1:rows+0.5;
    ax.XTickLabel = [];
    ax.YTickLabel = [];
    ax.Layer = 'top';
    ax.LineWidth = lw;

    axis tight
    % Display the values in each square
    for i = 1:rows
        for j = 1:cols
            text(j, i, num2str(grid(i, j)), 'Color', 'k', 'FontSize', 10, ...
                'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
        end
    end

    % Plot the grid using imagesc
    figure(4);
    subplot(1,3,ii); hold on
    imagesc(grid);
    colormap(cmap_cat)

    title(sprintf('Alpha = %.2f', a_nominal), 'FontSize', 14)
    %Add grid lines
    ax = gca;
    ax.XGrid = 'on';
    ax.YGrid = 'on';
    ax.GridColor = [0, 0, 0]; % Black grid lines
    ax.GridAlpha = 0.5; % Transparency of grid lines
    ax.XTick = 0.5:1:cols+0.5;
    ax.YTick = 0.5:1:rows+0.5;
    ax.XTickLabel = [];
    ax.YTickLabel = [];
    ax.Layer = 'top';
    ax.LineWidth = lw;

    axis tight
    % Display the values in each square
    for i = 1:rows
        for j = 1:cols
            text(j, i, num2str(grid(i, j)), 'Color', 'k', 'FontSize', 10, ...
                'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
        end
    end
end

exportgraphics(f3, fullfile(outdir, 'example_ord.jpg'), 'Resolution', 600); 
exportgraphics(f4, fullfile(outdir, 'example_nom.jpg'), 'Resolution', 600); 

% END