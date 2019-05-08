% computes integer coupling b/w LG and PD neurons 
% 
function [mean_PD_burst_periods, temperature] = integerCoupling(data)





LG_burst_starts = data.LG_burst_starts;
LG_burst_ends = data.LG_burst_ends;
LG_burst_periods = data.LG_burst_periods;

mean_PD_burst_periods = NaN*LG_burst_starts;
n_pyloric_cyles = NaN*LG_burst_starts;
delay_PD_start_LG_start = NaN*LG_burst_starts;
delay_PD_start_LG_end = NaN*LG_burst_starts;
delay_PD_end_LG_start = NaN*LG_burst_starts;
delay_PD_end_LG_end = NaN*LG_burst_starts;


for j = 1:length(LG_burst_starts)-1
	closest_PD_a = corelib.closest(data.PD_burst_starts,LG_burst_starts(j));
	closest_PD_z = corelib.closest(data.PD_burst_starts,LG_burst_starts(j+1));


	n_pyloric_cyles(j) = closest_PD_z - closest_PD_a;

	mean_PD_burst_periods(j) = (data.PD_burst_starts(closest_PD_z) -  data.PD_burst_starts(closest_PD_a))/n_pyloric_cyles(j);

	% compute delays (delay_PD_start_LG_start)
	allowed_PD_starts = data.PD_burst_starts(data.PD_burst_starts < LG_burst_starts(j));
	idx = corelib.closest(allowed_PD_starts,LG_burst_starts(j));
	if ~isempty(idx)
		delay_PD_start_LG_start(j) = LG_burst_starts(j) - allowed_PD_starts(idx);
	end


	allowed_PD_starts = data.PD_burst_starts(data.PD_burst_starts < LG_burst_ends(j));
	idx = corelib.closest(allowed_PD_starts,LG_burst_ends(j));
	if ~isempty(idx)
		delay_PD_start_LG_end(j) = LG_burst_ends(j) - allowed_PD_starts(idx);
	end

	allowed_PD_ends = data.PD_burst_ends(data.PD_burst_ends < LG_burst_starts(j));
	idx = corelib.closest(allowed_PD_ends,LG_burst_starts(j));
	if ~isempty(idx)
		delay_PD_end_LG_start(j) = LG_burst_starts(j) - allowed_PD_ends(idx);
	end

	allowed_PD_ends = data.PD_burst_ends(data.PD_burst_ends < LG_burst_ends(j));
	idx = corelib.closest(allowed_PD_ends,LG_burst_ends(j));
	if ~isempty(idx)
		delay_PD_end_LG_end(j) = LG_burst_ends(j) - allowed_PD_ends(idx);
	end




end

% compute the temperatures when we measure this stuff
temperature = data.temperature(round(LG_burst_starts*1e3));


% normalize by PD burst period
delay_PD_start_LG_start_norm_PD = delay_PD_start_LG_start./mean_PD_burst_periods;
delay_PD_start_LG_end_norm_PD = delay_PD_start_LG_end./mean_PD_burst_periods;
delay_PD_end_LG_start_norm_PD = delay_PD_end_LG_start./mean_PD_burst_periods;
delay_PD_end_LG_end_norm_PD = delay_PD_end_LG_end./mean_PD_burst_periods;

