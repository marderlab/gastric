% computes integer coupling b/w the bursts on 
% a slowly-timed neuron and a fast neuron
% the typical use case is if the fast neuron if
% PD and the slow neuron is LG
% 
function [mean_fast_burst_periods, temperature] = integerCoupling(data, slow_neuron, fast_neuron)


arguments
	data (1,1) struct
	slow_neuron char = 'LG'
	fast_neuron char = 'PD'
end


slow_burst_starts = data.([slow_neuron '_burst_starts']);
slow_burst_ends = data.([slow_neuron '_burst_ends']);


if all(isnan(slow_burst_starts))
	mean_fast_burst_periods = NaN*slow_burst_starts;
	temperature = NaN*slow_burst_starts;
	return
end


mean_fast_burst_periods = NaN*slow_burst_starts;
n_pyloric_cyles = NaN*slow_burst_starts;
delay_fast_start_slow_start = NaN*slow_burst_starts;
delay_fast_start_slow_end = NaN*slow_burst_starts;
delay_fast_end_slow_start = NaN*slow_burst_starts;
delay_fast_end_slow_end = NaN*slow_burst_starts;


for j = 1:length(slow_burst_starts)-1
	closest_fast_a = corelib.closest(data.([fast_neuron '_burst_starts']),slow_burst_starts(j));
	closest_fast_z = corelib.closest(data.([fast_neuron '_burst_starts']),slow_burst_starts(j+1));


	n_pyloric_cyles(j) = closest_fast_z - closest_fast_a;

	mean_fast_burst_periods(j) = (data.([fast_neuron '_burst_starts'])(closest_fast_z) -  data.([fast_neuron '_burst_starts'])(closest_fast_a))/n_pyloric_cyles(j);

	% compute delays (delay_fast_start_slow_start)
	allowed_fast_starts = data.([fast_neuron '_burst_starts'])(data.([fast_neuron '_burst_starts']) < slow_burst_starts(j));
	idx = corelib.closest(allowed_fast_starts,slow_burst_starts(j));
	if ~isempty(idx)
		delay_fast_start_slow_start(j) = slow_burst_starts(j) - allowed_fast_starts(idx);
	end


	allowed_fast_starts = data.([fast_neuron '_burst_starts'])(data.([fast_neuron '_burst_starts']) < slow_burst_ends(j));
	idx = corelib.closest(allowed_fast_starts,slow_burst_ends(j));
	if ~isempty(idx)
		delay_fast_start_slow_end(j) = slow_burst_ends(j) - allowed_fast_starts(idx);
	end

	allowed_fast_ends = data.([fast_neuron '_burst_ends'])(data.([fast_neuron '_burst_ends']) < slow_burst_starts(j));
	idx = corelib.closest(allowed_fast_ends,slow_burst_starts(j));
	if ~isempty(idx)
		delay_fast_end_slow_start(j) = slow_burst_starts(j) - allowed_fast_ends(idx);
	end

	allowed_fast_ends = data.([fast_neuron '_burst_ends'])(data.([fast_neuron '_burst_ends']) < slow_burst_ends(j));
	idx = corelib.closest(allowed_fast_ends,slow_burst_ends(j));
	if ~isempty(idx)
		delay_fast_end_slow_end(j) = slow_burst_ends(j) - allowed_fast_ends(idx);
	end




end

% compute the temperatures when we measure this stuff
temperature = data.temperature(round(slow_burst_starts*1e3));

