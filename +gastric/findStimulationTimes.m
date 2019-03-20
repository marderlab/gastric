function stim_times = findStimulationTimes(obj, options)

stim_times = obj.raw_data(:,1)*0;

temp_channel =  find(strcmp(obj.common.data_channel_names,'temperature'));

for i = 1:obj.n_channels
	if i == temp_channel
		continue
	end
	stim_times(abs((obj.raw_data(:,i))) > 9) = 1;
end


S = round(options.dt/obj.dt);
stim_times = stim_times(1:S:end);