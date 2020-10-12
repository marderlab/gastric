% plots spiketimes vs. ISIs for some neuron

function plotSpiketimesISIs(data, neuron, temperature, Color)


arguments
	data struct 
	neuron char = 'PD'
	temperature (1,1) double = 11
	Color = 'k'
end


% if the mean temperature is within 1.5C of the target temperature, 
% we can use this
temp_ok = abs(cellfun(@mean,{data.temperature}) - temperature) < 1.5;

% need to ignore subsequent returns to 11C temperature
if temperature == 11
	temp_ok(find(~temp_ok,1,'first'):end)=0;
end

for j = length(data):-1:1

	if ~any(data(j).mask)
		continue
	end

	if temp_ok(j)

		if isempty(data(j).(neuron))
			continue
		end


		spiketimes = data(j).(neuron);
		isis = [NaN; diff(spiketimes)];
		plot(spiketimes,isis,'.','Color',Color)
		ylabel(data(j).filename,'interpreter','none')
		break
	end

end
