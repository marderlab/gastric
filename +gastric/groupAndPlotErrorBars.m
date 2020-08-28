% given a bunch of data, group by something,
% and plot errors bars, for each prep,
% and then group them all together and plot errorbars

function [plot_handles, M] = groupAndPlotErrorBars(group_bins, group_idx, prep_idx, Y, varargin)

options.UseSEM = true;
options.circular = false;

options = corelib.parseNameValueArguments(options,varargin{:});

% work with circ stats when needed
if options.circular
	meanfunc = @circ_mean;
	Y = Y*2*pi;

	if options.UseSEM
		errfunc = @(x) circ_std(x)./sqrt(length(x));
	else
		errfunc = @circ_std;
	end

else
	if options.UseSEM
		errfunc = @corelib.sem;
	else
		errfunc = @nanstd;
	end

	meanfunc = @nanmean;
end

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


		M(j) = meanfunc(this_Y(idx));
		if M(j) < 0
			M(j) = M(j) + 2*pi;
		end


		E(j) = errfunc(this_Y(idx));
		
	end



	% convert back to [0 1] phase
	if options.circular
		M = M/(2*pi);
		E = E /(2*pi);
	end

	plot_handles(i) = errorbar(group_bins(~isnan(M)),M(~isnan(M)),E(~isnan(M)));

end




% now combine them all
% Here, we should compute error bars across biological replicates. 
M = NaN*group_bins;
E = NaN*group_bins;

for j = 1:length(group_bins)
	idx = abs(group_idx - group_bins(j)) < bin_width;

	prep_means = NaN*unique_preps;


	for i = 1:n_preps
		prep_means(i) = meanfunc(Y(unique_preps(i) == prep_idx & idx));
	end
	

	M(j) = meanfunc(prep_means);
	E(j) = errfunc(prep_means);
	

	if sum(~isnan(prep_means)) < 3
		E(j) = NaN;
	end
end

% convert back to [0 1] phase
if options.circular
	M = M/(2*pi);
	E = E /(2*pi);

	M(M<0) = M(M<0) + 1;
end


plot_handles(end+1) = errorbar(group_bins(~isnan(M)),M(~isnan(M)),E(~isnan(M)),'LineWidth',3,'Color','k');

