
function [ph1, ph2, ch] = plotISITriggeredBy(data, YNeuron, Trigger, clim)




trigger_points = data.(Trigger);
temperature = data.temperature(round(trigger_points*1e3));
isis = diff(data.(YNeuron));
x = data.(YNeuron)(1:end-1);


smallest_isi = .1;

before = 5;
after = 5;



% first plot the NaN temperatures
all_x = [];
all_y = [];

for i = 1:length(trigger_points)
	if ~isnan(temperature)
		continue
	end

	xx = x - trigger_points(i);
	show_this = xx > -before & xx < after;

	this_x = xx(show_this);
	this_y = isis(show_this);

	rm_this = this_y < smallest_isi;

	all_x = [all_x; this_x(~rm_this)];
	all_y = [all_y; this_y(~rm_this)];


end
ph1 = plot(all_x,all_y,'.','Color',[.5 .5 .5]);







all_x = [];
all_y = [];
all_temp = [];

for i = 1:length(trigger_points)

	if isnan(temperature(i))
		continue
	end

	xx = x - trigger_points(i);
	show_this = xx > -before & xx < after;

	this_x = xx(show_this);
	this_y = isis(show_this);

	rm_this = this_y < smallest_isi;


	all_x = [all_x; this_x(~rm_this)];
	all_y = [all_y; this_y(~rm_this)];
	all_temp = [all_temp; this_y(~rm_this)*0 + temperature(i)];
	
end

[ph2, ch] = plotlib.cplot(all_x,all_y,all_temp,'clim',clim);


if isnumeric(data.experiment_idx)
	title(mat2str(data.experiment_idx),'interpreter','none')
else
	title(char(data.experiment_idx),'interpreter','none')
end

