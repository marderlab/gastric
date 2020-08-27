
close all
clearvars -except data
addpath('../')


if ~exist('data','var')
	data = gastric.getEvokedData();
end

data = crabsort.computePeriods(data,'neurons',{'LG'},'ibis',1,'min_spikes_per_burst',7);


c = colormaps.redula(100);
min_temp = 5;
max_temp = 25;

figure('outerposition',[300 300 1200 1001],'PaperUnits','points','PaperSize',[1200 1001]); hold on

ax.burst_periods = subplot(2,2,1); hold on
xlabel('Time since stimulation end (s)')
ylabel('Burst period (s)')
title('One preparation')
set(gca,'YLim',[0 30]);

ax.avg_burst_periods = subplot(2,2,2); hold on
xlabel('Time since stimulation end (s)')
ylabel('Mean burst period (s)')
title('All preparations')
set(gca,'YLim',[0 30]);

results = gastric.BurstPeriodsVsTime(data(2));


for i = 1:9 % skip some

	stim_temp = results(i).temperature;
	idx = ceil(((stim_temp - min_temp)/(max_temp - min_temp))*100);

	plot(ax.burst_periods,results(i).time,results(i).burst_periods,'.-','Color',c(idx,:));
end


clear results
% now compute all the results for all the data
% reshape into a matrix
time = 0:1:600;
all_burst_periods = NaN(100,601);
all_temp = NaN(100,1);
idx = 1;

for i = 1:length(data)
	results = gastric.BurstPeriodsVsTime(data(i));
	for j = 1:length(results)
		if isempty(results(j).temperature)
			continue
		end
		all_burst_periods(idx,:) = interp1(results(j).time,results(j).burst_periods,time);
		all_temp(idx) = results(j).temperature;
		idx = idx + 1;
	end
end

unique_temps = 7:2:23;

for i = 1:length(unique_temps)

	stim_temp = unique_temps(i);
	idx = ceil(((stim_temp - min_temp)/(max_temp - min_temp))*100);

	M = nanmean(all_burst_periods(all_temp==unique_temps(i),:));
	S = nanstd(all_burst_periods(all_temp==unique_temps(i),:));
	plot(ax.avg_burst_periods, time,M,'Color',c(idx,:));

	if length(M) == length(time)

		% fit lines
		rm_this = isnan(M);
		fits(i).ff = fit(time(~rm_this)',M(~rm_this)','poly1');

		fits(i).r2 = corr(M(~rm_this)',fits(i).ff(time(~rm_this)));
	end
end


% show the raw fits
subplot(2,2,3); hold on
for i = 1:length(fits)
	stim_temp = unique_temps(i);
	idx = ceil(((stim_temp - min_temp)/(max_temp - min_temp))*100);

	plot(time,fits(i).ff(time),'Color',c(idx,:));
end
xlabel('Time since stimulation end (s)')
ylabel('Burst period (s)')
set(gca,'YLim',[0 30]);

% fit stats
subplot(2,2,4); hold on

for i = 1:length(fits)
	stim_temp = unique_temps(i);
	idx = ceil(((stim_temp - min_temp)/(max_temp - min_temp))*100);


	plot(fits(i).r2, fits(i).ff.p1,'o','Color',c(idx,:),'MarkerSize',14,'MarkerFaceColor',c(idx,:));
end
xlabel('r^2 of linear fit')
ylabel('Slope of linear fit (dimensionless)')
set(gca,'XLim',[0 1],'YLim',[-1e-2 1e-2])
plotlib.horzline(0,'k:');

figlib.pretty()

figlib.label('FontSize',30,'XOffset',-.02)