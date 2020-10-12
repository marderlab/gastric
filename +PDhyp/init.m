
function data = init(TemperatureSteps)

arguments 
	TemperatureSteps double = [11 15 19 21]
end

% get all data




exp_names = {'999_007','999_011','999_015','999_025','999_009','999_013','999_017','999_035','999_120'};

% 999_023
% 999_029


for i = 1:length(exp_names)
	data{i} = crabsort.consolidate(exp_names{i},'neurons',{'LG','PD'});
end


% purge all data where the temperature is changing
for i = 1:length(data)
	this_data = data{i};

	delta_temp = cellfun(@max,{this_data.temperature}) - cellfun(@min,{this_data.temperature});
	this_data(delta_temp>2) = [];
	data{i} = this_data(:);
end


% clean up data
for i = 1:length(data)
	for j = 1:length(data{i})
		data{i}(j).PD = sort(data{i}(j).PD);
		data{i}(j).LG = sort(data{i}(j).LG);
	end
end

% write down nominal temperatures -- one ofTemperatureSteps
for i = 1:length(data)
	for j = 1:length(data{i})
		 [~,idx]=min(abs(mean(data{i}(j).temperature) - TemperatureSteps));
		 data{i}(j).nominal_temperature = TemperatureSteps(idx);
	end
end