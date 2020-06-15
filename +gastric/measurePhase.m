function [phase, temperature] = measurePhase(data, thing, clock_neuron)


assert(isfield(data,thing),'Argument not found in structure')

phase = NaN*data.(thing);
temperature = NaN*phase;
things = data.(thing);

starts = data.([clock_neuron '_burst_starts']);
burst_periods = data.([clock_neuron '_burst_periods']);

for i = 2:length(phase)-1

	idx = find(starts < things(i),1,'last');
	if isempty(idx)
		continue
	end



	phase(i) = (things(i) - starts(idx))/burst_periods(idx);
	temperature(i)  = data.temperature(round(starts(idx)*1e3));

end