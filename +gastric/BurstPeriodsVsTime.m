% measures burst periods vs. time since stimulation end

function results = BurstPeriodsVsTime(data)

temperature = round(data.temperature);

all_stim_times = find(data.mask == 0);
stim_times = find(data.mask == 0);
last_stim  = stim_times(end);
stim_times = stim_times([diff(stim_times); NaN] > 120e3);
stim_times = [stim_times; last_stim];





for j = 1:length(stim_times)

	% figure out the temperature immediately after stim end
	stim_temp = round(mean(data.temperature(stim_times(j):stim_times(j)+5e3)));

	% when does the next stimulation occur? 
	next_stim = all_stim_times(find(all_stim_times>stim_times(j),1,'first'));

	% find out how long this temperature is maintained
	z = find(temperature(stim_times(j):next_stim) ~= stim_temp,1,'first') + stim_times(j);

	if isempty(z) && ~isempty(next_stim)
		% temperature maintained all the way to next stim
		z = next_stim - 1;
	elseif isempty(z) && isempty(next_stim)
		z = length(data.temperature);
	end

	if (z-stim_times(j))*1e-3 < 120
		% temperature held for less than 2 minutes
		continue
	end


	% get all burst periods in this duration

	burst_starts = data.LG_burst_starts;
	only_these = burst_starts > stim_times(j)*1e-3 & burst_starts < z*1e-3;

	if ~any(only_these)
		continue
	end

	time = burst_starts(only_these);
	time = time - time(1);
	Y = data.LG_burst_periods(only_these);
	Y(Y>30) = NaN;



	results(j).time = time;
	results(j).burst_periods = Y;
	results(j).temperature = stim_temp;


end



