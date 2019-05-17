
function [ax, fig] = PlotISITriggeredBy(data, YNeuron, Trigger)

fig = figure('outerposition',[300 300 901 899],'PaperUnits','points','PaperSize',[901 899]); hold on

clear ax

for exp_idx = 1:length(data)
	ax(exp_idx) = figlib.autoPlot(length(data),exp_idx); hold on

	trigger_points = data(exp_idx).(Trigger);
	temperature = data(exp_idx).temperature(round(trigger_points*1e3));
	isis = diff(data(exp_idx).(YNeuron));
	x = data(exp_idx).(YNeuron)(1:end-1);


	before = 5;
	after = 5;

	all_temp = [7:4:31];

	c = parula(length(all_temp)+1);

	% first plot the NaN temperatures
	all_x = [];
	all_y = [];

	for i = 1:length(trigger_points)
		if ~isnan(temperature)
			continue
		end

		xx = x - trigger_points(i);
		show_this = xx > -before & xx < after;

		all_x = [all_x; xx(show_this)];
		all_y = [all_y; isis(show_this)];


	end
	plot(all_x,all_y,'.','Color',[.5 .5 .5])


	for j = 1:length(all_temp)

		all_x = [];
		all_y = [];


		for i = 1:length(trigger_points)

			if abs(temperature(i) - all_temp(j)) > .5
				continue
			end

			if isnan(temperature(i))
				continue
			end


			xx = x - trigger_points(i);
			show_this = xx > -before & xx < after;

			all_x = [all_x; xx(show_this)];
			all_y = [all_y; isis(show_this)];

			

		end
		plot(all_x,all_y,'.','Color',c(j,:))
	end

	set(gca,'YScale','linear','XLim',[-before after],'YLim',[.1 2])
	title(char(data(exp_idx).experiment_idx),'interpreter','none')

end
