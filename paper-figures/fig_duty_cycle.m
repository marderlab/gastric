
clearvars
close all
addpath('../')


data = gastric.getEvokedData();


min_temp = 5;
max_temp = 25;



% compute burst metrics of all LG neurons
data = crabsort.computePeriods(data,'neurons',{'PD'},'ibis',.18,'min_spikes_per_burst',2);
data = crabsort.computePeriods(data,'neurons',{'LG'},'ibis',1,'min_spikes_per_burst',5);
data = crabsort.computePeriods(data,'neurons',{'DG'},'ibis',1,'min_spikes_per_burst',5);


% compute duty cycles everywhre
neurons = {'PD','LG','DG'};
for i = 1:length(data)
	for j = 1:length(neurons)
		data(i).([neurons{j} '_duty_cycles']) = data(i).([neurons{j} '_burst_durations'])./data(i).([neurons{j} '_burst_periods']);
	end
end


% show one example


for prep_idx = 2:10


	figure('outerposition',[3 3 601 901],'PaperUnits','points','PaperSize',[601 901]); hold on


	T = data(prep_idx).temperature;
	time = (1:length(T))*1e-3;

	subplot(4,1,1); hold on
	SS = 1e3;
	scatter(time(1:SS:end),T(1:SS:end),1,T(1:SS:end))

	ylabel(gastric.tempLabel)

	set(gca,'XTickLabel',{},'XLim',[0 max(time)])

	for j = 1:length(neurons)
		x = data(prep_idx).([neurons{j} '_burst_starts']);

		y = data(prep_idx).([neurons{j} '_duty_cycles']);
		y(y>1) = NaN;
		y(y<0) = NaN;
		subplot(4,1,j+1); hold on
		C = data(prep_idx).temperature(round(x*1e3));
		sh = scatter(x, y,20,C);
		sh.Marker = '.';
		ylabel([neurons{j} ' duty cycle'])

		if j < length(neurons)
			set(gca,'XTickLabel',{})
		else
			sh.SizeData = 40;
		end

		% plot mask
		M = veclib.subSample(data(prep_idx).mask,1e3,@min);
		M(M>0)=2;
		plot(M,'Color',[0.9 0.9 0.9],'LineWidth',3)

		set(gca,'YLim',[0 1],'XLim',[0 max(time)])
	end



	colormap(colormaps.redula)

	figlib.pretty('LineWidth',1)

end