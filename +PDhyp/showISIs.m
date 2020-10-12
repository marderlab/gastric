function showISIs(data, TemperatureSteps)

arguments
	data (:,1) struct
	TemperatureSteps (:,1) = [11 15 19 21]';
end

figure('outerposition',[300 300 1200 901],'PaperUnits','points','PaperSize',[1200 901]); hold on

for i = 1:12
	subplot(4,3,i); hold on
end

figlib.pretty();

C = colormaps.redula(4);


for i = 1:length(TemperatureSteps)

	% show PD spikes
	subplot(4,3,(i-1)*3+1); hold on
	if i == 1
		title('PD')
	end
	set(gca,'YScale','log','XLim',[0 300],'YLim',[1e-2 1e2])

	this_data = data;
	this_data([this_data.PD_hyperpolarized]==1) = [];
	gastric.plotSpiketimesISIs(this_data, 'PD', TemperatureSteps(i),C(i,:));

	% show PD on

	subplot(4,3,(i-1)*3+2); hold on
	if i == 1
		title('LG (PD on)')
	end
	set(gca,'YScale','log','XLim',[0 300],'YLim',[1e-2 1e2],'YTickLabel','')

	this_data = data;
	this_data([this_data.PD_hyperpolarized]==1) = [];
	gastric.plotSpiketimesISIs(this_data, 'LG', TemperatureSteps(i),C(i,:));


	% show PD off
	subplot(4,3,(i-1)*3+3); hold on
	if i == 1
		title('LG (PD off)')
	end
	set(gca,'YScale','log','XLim',[0 300],'YLim',[1e-2 1e2],'YTickLabel','')

	this_data = data;
	this_data([this_data.PD_hyperpolarized]==0) = [];
	gastric.plotSpiketimesISIs(this_data, 'LG', TemperatureSteps(i),C(i,:));

end



