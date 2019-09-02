% given a bunch of data, group by something,
% and plot errors bars, for each prep,
% and then group them all together and plot errorbars

function plot_handles = groupAndPlotErrorBars(group_bins, group_idx, prep_idx, Y)



n_preps = length(unique(prep_idx(~isnan(prep_idx))));

bin_width = min(abs(diff(group_bins)))/2;

% split by prep
for i = 1:n_preps
	this_group = group_idx(prep_idx == i);
	this_Y = Y(prep_idx == i);

	M = NaN*group_bins;
	E = NaN*group_bins;

	for j = 1:length(group_bins)
		idx = abs(this_group - group_bins(j)) < bin_width;
		M(j) = nanmean(this_Y(idx));
		E(j) = corelib.sem(this_Y(idx));
	end

	plot_handles(i) = errorbar(group_bins(~isnan(M)),M(~isnan(M)),E(~isnan(M)));

end


% now combine them all
M = NaN*group_bins;
E = NaN*group_bins;

for j = 1:length(group_bins)
	idx = abs(group_idx - group_bins(j)) < bin_width;
	M(j) = nanmean(Y(idx));
	E(j) = corelib.sem(Y(idx));
end

plot_handles(end+1) = errorbar(group_bins(~isnan(M)),M(~isnan(M)),E(~isnan(M)),'LineWidth',3,'Color','k');
