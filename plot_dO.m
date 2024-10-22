

Y = repmat(1:size(dat,2), size(dat,1), 1);
XY = [dat(:), Y(:)];
dO = hist3(XY, {allvals, 1:tdim});
dE = sum(dO(:,sum(dO)>1),2);
nu_ = sum(dO, 1);
n__ = sum(nu_(nu_>1));
clear XY Y

% Optional plot
if makeplot
    figure;
    subplot(1,20,1:3); plot(dE, allvals); axis tight; hold on
    subplot(1,20,5:20); imagesc(1:size(dat,2),allvals,dO); colorbar
    set(gca,'YDir','normal')
end