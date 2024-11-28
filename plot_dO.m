function plot_dO(dat, cfg, dE_opt)

if nargin < 2
    allvals = unique(dat(~isnan(dat)));
    cfg.method = NaN;
else
    allvals = cfg.allvals;
end

if nargin < 3
    if (length(allvals) <= 20)
        dE_opt = 'bar';
    else
        dE_opt = 'line';
    end
end


tdim = size(dat, 2);                % "Time" axis (copy from real data)
Y = repmat(1:size(dat,2), size(dat,1), 1);
XY = [dat(:), Y(:)];
dO = hist3(XY, {allvals, 1:tdim});
dE = sum(dO(:,sum(dO)>1),2);
% nu_ = sum(dO, 1);
% n__ = sum(nu_(nu_>1));

clear XY Y

%  plot
f1 = figure;
ax = subplot(1,20,5:20); imagesc(1:size(dat,2),allvals,dO); 
colormap(flipud(gray)); colorbar
ylim(ax.YLim)

subplot(1,20,1:3); 
if any(strcmp(dE_opt, {'bar', 'both'}))
    barh(allvals,dE, 'FaceColor',[0.5, 0.5, 0.5],'EdgeColor', 'k'); hold on 
end
if any(strcmp(dE_opt, {'line', 'both'}))
    plot(dE, allvals, 'k-')
end
ylim(ax.YLim)
set(gca,'YDir','reverse')
