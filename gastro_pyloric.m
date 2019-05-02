
pdflib.header


data_root = '/Volumes/HYDROGEN/srinivas_data/gastric-data';


%% Analysis of gastric and pyloric rhythms at different temperatures
% In this document we look at pyloric and gastric rhtyhms at differnet temperatures.
% This data is from Dan Powell and the experiments that go into this are:

include_these = {'901_086','901_046','901_049','901_052','901_062','901_080','901_095','901_098'};

disp(include_these')

if exist('dan_stacked_data.mat','file') == 2

	load('dan_stacked_data','data')
else
	for i = 1:length(include_these)
		data(i)  = crabsort.consolidate('neurons',{'PD','LG'},'DataFun',{@crabsort.getTemperature},'DataDir',[data_root filesep include_these{i}],'stack',true);
	end

	save('dan_stacked_data','data','-nocompression','-v7.3')

end


%%
% This figure shows the temperature in all the experiments. 

figure('outerposition',[300 300 901 1200],'PaperUnits','points','PaperSize',[901 1200]); hold on

for i = 1:length(data)
	subplot(8,1,i); hold on
	time = (1:length(data(i).temperature))*1e-3;
	time = time(1:100:end);
	plot(time,data(i).temperature(1:100:end),'k')
	set(gca,'XLim',[0 9e3])
	if i < length(data)
		set(gca,'XTick',[])
	end
	set(gca,'YLim',[5 23])

	neurolib.raster(data(i).LG,'deltat',1,'yoffset',5)
end

xlabel('Time (s)')

pdflib.snap()

figlib.pretty('fs',20)


% make sure spiketimes are sorted
for i = 1:length(data)
	data(i).PD = sort(data(i).PD);
	data(i).LG = sort(data(i).LG);
end


% compute burst metrics of all LG neurons
data = crabsort.computePeriods(data,'neurons',{'PD'},'ibis',.18,'min_spikes_per_burst',2);
data = crabsort.computePeriods(data,'neurons',{'LG'},'ibis',1,'min_spikes_per_burst',5);

%% Variability in PD burst periods
% In this section, I look at cycle-to-cycle variability in the PD burst periods. Specifically, I compare PD burst periods in one cycle to the burst periods in the next cycle. 

figure('outerposition',[300 300 903 901],'PaperUnits','points','PaperSize',[903 901]); hold on

for i = 1:length(data)
	subplot(3,3,i); hold on


	x = data(i).PD_burst_periods(1:end-1);
	xx = round(data(i).PD_burst_starts(1:end-1)*1e3);

	y = data(i).PD_burst_periods(2:end);



	C = data(i).temperature(xx);
	[~,ch]=plotlib.cplot(x,y,C);
	caxis([7 23])
	set(gca,'XLim',[0 2],'YLim',[0 2],'XScale','linear','YScale','linear')

	if i < length(data)
		delete(ch)
	end
	title(data(i).experiment_idx)

	if i == 7
		xlabel('PD burst period (s)')
		ylabel('Next cycle period (s)')
	end
end



title(ch,'Temperature (C)')
ch.Position(1) = .75;

figlib.pretty

%% Integer coupling
% In this section I look at the integer coupling b/w PD and LG burst periods. 





%% Burst period vs. temperature
% In the following figure, I plot burst periods of LG and PD neurons as a function of temperature for each prep. 

figure('outerposition',[300 300 1200 600],'PaperUnits','points','PaperSize',[1200 600]); hold on
for i = 1:length(data)
	subplot(2,4,i); hold on


	x = round(data(i).PD_burst_starts*1e3);
	plot(data(i).temperature(x),data(i).PD_burst_periods,'k.')

	x = round(data(i).LG_burst_starts*1e3);
	plot(data(i).temperature(x),data(i).LG_burst_periods,'r.')

	set(gca,'YScale','log','XLim',[6 24])

	title(data(i).experiment_idx)
	xlabel('Temperature (C)')
end

figlib.pretty('fs',14)

%% Duty cycles vs temperature

figure('outerposition',[300 300 1301 801],'PaperUnits','points','PaperSize',[1301 801]); hold on
for i = 1:length(data)
	subplot(2,4,i); hold on


	x = round(data(i).PD_burst_starts*1e3);
	plot(data(i).temperature(x),data(i).PD_burst_durations./data(i).PD_burst_periods,'k.')

	x = round(data(i).LG_burst_starts*1e3);
	plot(data(i).temperature(x),data(i).LG_burst_durations./data(i).LG_burst_periods,'r.')

	set(gca,'YScale','linear','YLim',[0 1],'YTick',0:.2:1,'XLim',[6 24])

	title(data(i).experiment_idx)
	xlabel('Temperature (C)')
end

figlib.pretty('fs',14)


%%
% In the following figure I plot PD ISIs triggered by when LG starts. 


ax = gastric.PlotISITriggeredBy(data, 'PD', 'LG_burst_starts');

ylabel(ax(7),'PD ISI (s)')
xlabel(ax(7),'Time since LG start (s)')

figlib.pretty


%%
% Now a similar figure, but triggered when LG ends. 

ax = gastric.PlotISITriggeredBy(data, 'PD', 'LG_burst_ends');

ylabel(ax(7),'PD ISI (s)')
xlabel(ax(7),'Time since LG end (s)')

figlib.pretty









figure('outerposition',[300 300 1200 600],'PaperUnits','points','PaperSize',[1200 600]); hold on

subplot(1,2,1); hold on

all_y = NaN(2042,100);

idx = 1;

for exp_idx = setdiff(1:length(data),3)

	trigger_points = data(exp_idx).LG_burst_starts;

	temperature = data(exp_idx).temperature(round(trigger_points*1e3));

	y = data(exp_idx).PD_burst_periods;
	x = data(exp_idx).PD_burst_starts;

	xs = linspace(-5,10,100);

	for i = 1:length(trigger_points)
		
		xx = x - trigger_points(i);

		if min(xx) > -5 || max(xx) < 5
			continue
		end

		all_y(idx,:) = interp1(xx,y,xs);	

		all_y(idx,:) = all_y(idx,:)./mean(all_y(idx,1:50) );

		idx = idx + 1;
	end

end


% do for differnet temperatures
for i = 1:length(all_temp)
	do_this = abs(temperature - all_temp(i)) <  .5;
	plot(xs,100*nanmean(all_y(do_this,:))-100,'Color',c(i,:),'LineWidth',3)
end
ylabel('% Change in PD burst period (s)')
xlabel('Time since LG start (s)')
set(gca,'YLim',[-10 20])

subplot(1,2,2); hold on

all_y = NaN(2042,100);

idx = 1;

for exp_idx = setdiff(1:length(data),3)

	trigger_points = data(exp_idx).LG_burst_ends;

	temperature = data(exp_idx).temperature(round(trigger_points*1e3));

	y = data(exp_idx).PD_burst_periods;
	x = data(exp_idx).PD_burst_starts;

	xs = linspace(-5,10,100);

	for i = 1:length(trigger_points)
		
		xx = x - trigger_points(i);

		if min(xx) > -5 || max(xx) < 5
			continue
		end

		all_y(idx,:) = interp1(xx,y,xs);	

		all_y(idx,:) = all_y(idx,:)./mean(all_y(idx,1:50) );

		idx = idx + 1;
	end

end


% do for differnet temperatures
for i = 1:length(all_temp)
	do_this = abs(temperature - all_temp(i)) <  .5;
	plot(xs,100*nanmean(all_y(do_this,:))-100,'Color',c(i,:),'LineWidth',3)
end
set(gca,'YLim',[-10 20])
xlabel('Time since LG end')

figlib.pretty

%% Metadata
% To reproduce this document:

pdflib.footer