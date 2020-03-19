% given a bunch of data, group by something,
% and plot errors bars, for each prep,
% and then group them all together and plot errorbars

function [plot_handles, M] = groupAndPlotErrorBars(group_bins, group_idx, prep_idx, Y, varargin)

options.UseSEM = true;
options = corelib.parseNameValueArguments(options,varargin{:});


unique_preps = unique(prep_idx(~isnan(prep_idx)));
n_preps = length(unique_preps);

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

		if options.UseSEM
			E(j) = corelib.sem(this_Y(idx));
		else
			E(j) = nanstd(this_Y(idx));
		end

		
	end

	plot_handles(i) = errorbar(group_bins(~isnan(M)),M(~isnan(M)),E(~isnan(M)));

end


% now combine them all
% Here, we should compute error bars across biological replicates. 
M = NaN*group_bins;
E = NaN*group_bins;

for j = 1:length(group_bins)
	idx = abs(group_idx - group_bins(j)) < bin_width;

	prep_means = 0*unique_preps;

	for i = 1:n_preps
		prep_means(i) = nanmean(Y(unique_preps(i) == prep_idx & idx));
	end

	M(j) = nanmean(prep_means);
	

	


	if options.UseSEM
		E(j) = corelib.sem(prep_means);
	else
		E(j) =  nanstd(prep_means);
	end

	if sum(~isnan(prep_means)) < 3
		E(j) = NaN;
	end
end

plot_handles(end+1) = errorbar(group_bins(~isnan(M)),M(~isnan(M)),E(~isnan(M)),'LineWidth',3,'Color','k');
