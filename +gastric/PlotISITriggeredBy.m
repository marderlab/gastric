
function ax = PlotISITriggeredBy(data, YNeuron, Trigger)

figure('outerposition',[300 300 901 899],'PaperUnits','points','PaperSize',[901 899]); hold on

clear ax

for exp_idx = 1:length(data)
	ax(exp_idx) = subplot(3,3,exp_idx); hold on

	trigger_points = data(exp_idx).(Trigger);
	temperature = data(exp_idx).temperature(round(trigger_points*1e3));
	isis = diff(data(exp_idx).(YNeuron));
	x = data(exp_idx).(YNeuron)(1:end-1);


	before = 5;
	after = 5;

	all_temp = [7 11 15 19];

	c = parula(5);


	for j = 1:length(all_temp)


		for i = 1:length(trigger_points)

			if abs(temperature(i) - all_temp(j)) > .5
				continue
			end


			xx = x - trigger_points(i);
			show_this = xx > -before & xx < after;

			plot(xx(show_this),isis(show_this),'.','Color',c(j,:))

		end
	end

	set(gca,'YScale','linear','XLim',[-before after],'YLim',[.1 2])
	title(data(exp_idx).experiment_idx)

end
