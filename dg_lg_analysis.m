pdflib.header


% get data directory from defaults.m
pref = corelib.readPref;
data_root = pref.prep_path;


%% Analysis of gastric and pyloric rhythms at different temperatures
% In this document we look at pyloric and gastric rhythms at different temperatures.
% This data is from Dan Powell and the experiments that go into this are:

include_these = {'901_046','901_052','901_062'};

disp(include_these')

if exist('dan_stacked_data.mat','file') == 2

	load('dan_stacked_data','data')
else
	for i = 1:length(include_these)
		data(i)  = crabsort.consolidate('neurons',{'PD','LG','DG'},'DataFun',{@crabsort.getTemperature},'DataDir',[data_root filesep include_these{i}],'stack',true);
	end

	save('dan_stacked_data','data','-nocompression','-v7.3')

end


%%
% The following figure shows the temperature in all the experiments, together with a raster indicating when the LG neuron spikes. You can see from this figure that gastric rhythms were elicited at many different temperatures, once the temperature had been stabilized to the desired value. 

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
data = crabsort.computePeriods(data,'neurons',{'DG'},'ibis',1,'min_spikes_per_burst',5);





%% Variability in PD burst periods
% In this section, I look at cycle-to-cycle variability in the PD burst periods. Specifically, I compare PD burst periods in one cycle to the burst periods in the next cycle. I observed that PD neurons tended to sometimes skip a spike (the last one was quite variable). These cycle-to-cycle variations in PD period manifest as deviations from the diagonal in the following plots. 

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


%% Variability of PD period: dependence on the gastric rhythm
% One question in this data is if the gastric rhythm influences the pyloric rhythm in any way. If it does, one would expect the pyloric period to be a little more variable when the gastric rhythm is on compared to when the gastric rhythm is off. That's what the next figure shows: it compares the variability (CV) of the pyloric burst periods when the gastric rhythm is on and when it is off.

%%
% By "gastric rhythm on", we mean that PD bursts occur within 10 seconds following a LG spike, and by "gastric rhythm off", we mean PD bursts more than 100s since the last LG spike. Note that almost every dot lies below the diagonal, suggesting that G bursting makes PD bursting more variable. 

figure('outerposition',[300 300 1200 600],'PaperUnits','points','PaperSize',[1200 600]); hold on

c = parula(5);

for i = 1:length(data)
	[cv_mean_on, cv_mean_off, cv_std_on, cv_std_off] = gastric.comparePDVariability(data(i), 7:4:19, 10, 2.5);
	for j = 1:4
		scatter(cv_mean_on(j),cv_mean_off(j),64,c(j,:),'MarkerFaceColor',c(j,:),'MarkerEdgeColor',c(j,:),'MarkerFaceAlpha',.5)
	end
end

plotlib.drawDiag;
axis square

set(gca,'XLim',[0 .15],'YLim',[0 .15])
xlabel('Gastric rhythm on')
ylabel('Gastric rhythm off')
title('Variability in PD periods')

figlib.pretty()

%% Integer coupling
% In this section I look at the integer coupling b/w PD and LG burst periods. 





%% Burst period vs. temperature
% In the following figure, I plot burst periods of LG and PD neurons as a function of temperature for each prep. Black dots are PD bursts, red dots are LG bursts. Note that they both decrease at approximately the same rate. 

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
% In the following figure, I plot the duty cycles of PD and LG as a function of temperature. Note that the PD neuron maintains a constant duty cycle over the temperatures tested. 

figure('outerposition',[300 300 1301 801],'PaperUnits','points','PaperSize',[1301 801]); hold on
for i = 1:length(data)
	subplot(2,4,i); hold on


	x = round(data(i).PD_burst_starts*1e3);
	plot(data(i).temperature(x),data(i).PD_burst_durations./data(i).PD_burst_periods,'k.')

	x = round(data(i).LG_burst_starts*1e3);
	plot(data(i).temperature(x),data(i).LG_burst_durations./data(i).LG_burst_periods,'r.')

	set(gca,'YScale','linear','YLim',[0 1],'YTick',0:.2:1,'XLim',[6 24])

	title(data(i).experiment_idx)

	if i > 4
		xlabel('Temperature (C)')
	end
	if i == 1 || i == 5
		ylabel('Duty cycle')
	end

end

figlib.pretty('fs',14)

%% Spikes per burst vs. temperature
% In the following figure, I plot the # of spikes/burst as a function of temperature for both the PD neurons (black) and the LG neurons (red). Note that the # of spikes/burst decreases for the PD neuron with temperature, as that is what it does to maintain its duty cycle. 

figure('outerposition',[300 300 1301 801],'PaperUnits','points','PaperSize',[1301 801]); hold on
for i = 1:length(data)
	subplot(2,4,i); hold on


	x = round(data(i).PD_burst_starts*1e3);
	plot(data(i).temperature(x),data(i).PD_n_spikes_per_burst,'k.')

	x = round(data(i).LG_burst_starts*1e3);
	plot(data(i).temperature(x),data(i).LG_n_spikes_per_burst,'r.')

	set(gca,'YScale','log','YLim',[0 1e3],'XLim',[6 24])

	title(data(i).experiment_idx)

	if i > 4
		xlabel('Temperature (C)')
	end
	if i == 1 || i == 5
		ylabel('# spikes/burst')
	end

end

figlib.pretty('fs',14)




%% LG-PD coupling
% I now look at the fine structure of the LG-PD coupling. The hypothesis here is that the gastric rhythm, in some manner, affects the pyloric rhythm. One way to look a this is to plot the PD inter-spike-intervals triggered by start of LG bursts. That's what the next figure shows. Notice the striking fan-like structure in all preps (different colours are different temperatures). This suggests that the PD neuron is in phase with the LG start (or the LG neuron is starting at a particular phase of PD). 

%%
% Note also that the PD ISIs seem to increase and decrease with the LG start (this is especially clear in 901_062). This suggests that the LG neuron is affecting the PD neuron, though we cannot rule out PD affecting LG. 


ax = gastric.PlotISITriggeredBy(data, 'PD', 'LG_burst_starts');

ylabel(ax(length(data(i))),'PD ISI (s)')
xlabel(ax(length(data(i))),'Time since LG start (s)')

figlib.pretty


%%
% Now a similar figure, but triggered when LG ends. The effect is less clear here. One reason why is that the LG burst periods are less clearly defined, and the LG neuron tends to peter out slowly. 

ax = gastric.PlotISITriggeredBy(data, 'PD', 'LG_burst_ends');

ylabel(ax(length(data(i))),'PD ISI (s)')
xlabel(ax(length(data(i))),'Time since LG end (s)')

figlib.pretty






%% Integer coupling b/w PD and LG periods
% The periods of PD and LG neurons have previously been shown the be integer-coupled, that is, the LG periods is an integer multiple of the PD period. Here we see the same thing: the following figure plots the LG period vs. the mean PD periods during that LG burst. Note that the gray lines are not fits to the data -- they are merely lines with integer slopes. Note that the data naturally falls on top of these lines. 


all_x = [];
all_temp = [];
all_y = [];

for i = 1:length(data)
	[this_x,this_temp] = gastric.integerCoupling(data(i));
	all_x = [all_x; this_x];
	all_temp = [all_temp; this_temp];
	all_y = [all_y; data(i).LG_burst_periods];
end

figure('outerposition',[300 300 901 901],'PaperUnits','points','PaperSize',[1200 901]); hold on


% plot gridlines
for i = 4:30
	xx = linspace(0,10,1e3);
	yy = xx*i;
	plot(gca,xx,yy,'Color',[.8 .8 .8])
end


[~,ch] = plotlib.cplot(all_x,all_y,all_temp);
set(gca,'XLim',[0.2 2],'YLim',[0 30])
xlabel('Mean PD period (s)')
ylabel('LG periods (s)')

ch.Location = 'southoutside';
ch.Position = [.52 .15 .4 .02];
title(ch,'Temperature (C)')

figlib.pretty()

%% LG start phase vs temperature
% The following figures compare LG start phase as a fraction of PD burst period with the temperature of the preparation. 

figure('outerposition',[300 300 1301 801],'PaperUnits','points','PaperSize',[1301 801]); hold on
for i = 1:length(data)
	subplot(3,3,i); hold on

	% find PD bursts immediately preceding LG bursts
	relevant_PDbs = zeros(size(data(i).LG_burst_starts));
	relevant_PDbp = zeros(size(data(i).LG_burst_starts));
	for j = 1:length(data(i).LG_burst_starts)
		for k = 1:length(data(i).PD_burst_starts)
			if data(i).PD_burst_starts(k) > data(i).LG_burst_starts(j)
				relevant_PDbs(j) = data(i).PD_burst_starts(k-1);
				relevant_PDbp(j) = data(i).PD_burst_periods(k-1);
				break;
			end
		end
	end

	% calculate LG burst delay following PD burst
	LG_burst_delay = data(i).LG_burst_starts - relevant_PDbs;
	yax = LG_burst_delay./relevant_PDbp;

	% bin temperatures for plotting errorbars
	x = round(data(i).LG_burst_starts*1e3);
	temp_space = [7 9 11 13 15 17 19 21 23];
	c = parula(length(temp_space));
	M = NaN*temp_space;
	E = NaN*temp_space;
	for j = 1:length(temp_space)
		idx = (data(i).temperature(x) > temp_space(j)-.5 & data(i).temperature(x) < temp_space(j)+.5);
		M(j) = nanmean(yax(idx));
		E(j) = corelib.sem(yax(idx));
	end

	scatter(data(i).temperature(x),yax,'filled','MarkerFaceAlpha',0.1);
	errorbar(temp_space,M,E,'LineWidth',2,'LineStyle','none')

	set(gca,'YScale','linear','YLim',[0 1],'XLim',[6 24])

	title(data(i).experiment_idx)

	if i == 7
		xlabel('Temperature (C)')
		ylabel('LG Start Phase')
	end

end

figlib.pretty('fs',14)

figure('outerposition',[300 300 1301 801],'PaperUnits','points','PaperSize',[1301 801]); hold on
for i = 1:length(data)
	% find PD bursts immediately preceding LG bursts
	relevant_PDbs = zeros(size(data(i).LG_burst_starts));
	relevant_PDbp = zeros(size(data(i).LG_burst_starts));
	for j = 1:length(data(i).LG_burst_starts)
		for k = 1:length(data(i).PD_burst_starts)
			if data(i).PD_burst_starts(k) > data(i).LG_burst_starts(j)
				relevant_PDbs(j) = data(i).PD_burst_starts(k-1);
				relevant_PDbp(j) = data(i).PD_burst_periods(k-1);
				break;
			end
		end
	end


	% calculate LG burst delay following PD burst
	LG_burst_delay = data(i).LG_burst_starts - relevant_PDbs;
	yax = LG_burst_delay./relevant_PDbp;

	% bin temperatures for plotting errorbars
	x = round(data(i).LG_burst_starts*1e3);
	temp_space = [7 9 11 13 15 17 19 21 23];
	c = parula(length(temp_space));
	M = NaN*temp_space;
	E = NaN*temp_space;
	for j = 1:length(temp_space)
		idx = (data(i).temperature(x) > temp_space(j)-.5 & data(i).temperature(x) < temp_space(j)+.5);
		M(j) = nanmean(yax(idx));
		E(j) = corelib.sem(yax(idx));
	end

	errorbar(temp_space,M,E,'LineWidth',2,'LineStyle','none','MarkerFaceColor',c(i,:),'MarkerEdgeColor',c(i,:))

	set(gca,'YScale','linear','YLim',[0 1],'XLim',[6 24])

	title('LG Start Phase vs Temperature (C)')

	if i == 7
		xlabel('Temperature (C)')
		ylabel('LG Start Phase')
	end

end

figlib.pretty('fs',14)

%% DG start phase vs temperature
% The following figures compare DG start phase as a fraction of PD burst period with the temperature of the preparation. 

figure('outerposition',[300 300 1301 801],'PaperUnits','points','PaperSize',[1301 801]); hold on
for i = 1:length(data)
	subplot(3,3,i); hold on

	% find PD bursts immediately preceding DG bursts
	relevant_PDbs = zeros(size(data(i).DG_burst_starts));
	relevant_PDbp = zeros(size(data(i).DG_burst_starts));
	for j = 1:length(data(i).DG_burst_starts)
		for k = 1:length(data(i).PD_burst_starts)
			if data(i).PD_burst_starts(k) > data(i).DG_burst_starts(j)
				relevant_PDbs(j) = data(i).PD_burst_starts(k-1);
				relevant_PDbp(j) = data(i).PD_burst_periods(k-1);
				break;
			end
		end
	end

	% calculate DG burst delay following PD burst
	DG_burst_delay = data(i).DG_burst_starts - relevant_PDbs;
	yax = DG_burst_delay./relevant_PDbp;

	% bin temperatures for plotting errorbars
	x = round(data(i).DG_burst_starts*1e3);
	temp_space = [7 9 11 13 15 17 19 21 23];
	c = parula(length(temp_space));
	M = NaN*temp_space;
	E = NaN*temp_space;
	for j = 1:length(temp_space)
		idx = (data(i).temperature(x) > temp_space(j)-.5 & data(i).temperature(x) < temp_space(j)+.5);
		M(j) = nanmean(yax(idx));
		E(j) = corelib.sem(yax(idx));
	end

	scatter(data(i).temperature(x),yax,'filled','MarkerFaceAlpha',0.1);
	errorbar(temp_space,M,E,'LineWidth',2,'LineStyle','none')

	set(gca,'YScale','linear','YLim',[0 1],'XLim',[6 24])

	title(data(i).experiment_idx)

	if i == 7
		xlabel('Temperature (C)')
		ylabel('DG Start Phase')
	end

end

figlib.pretty('fs',14)

figure('outerposition',[300 300 1301 801],'PaperUnits','points','PaperSize',[1301 801]); hold on
for i = 1:length(data)
	% find PD bursts immediately preceding DG bursts
	relevant_PDbs = zeros(size(data(i).DG_burst_starts));
	relevant_PDbp = zeros(size(data(i).DG_burst_starts));
	for j = 1:length(data(i).DG_burst_starts)
		for k = 1:length(data(i).PD_burst_starts)
			if data(i).PD_burst_starts(k) > data(i).DG_burst_starts(j)
				relevant_PDbs(j) = data(i).PD_burst_starts(k-1);
				relevant_PDbp(j) = data(i).PD_burst_periods(k-1);
				break;
			end
		end
	end


	% calculate DG burst delay following PD burst
	DG_burst_delay = data(i).DG_burst_starts - relevant_PDbs;
	yax = DG_burst_delay./relevant_PDbp;

	% bin temperatures for plotting errorbars
	x = round(data(i).DG_burst_starts*1e3);
	temp_space = [7 9 11 13 15 17 19 21 23];
	c = parula(length(temp_space));
	M = NaN*temp_space;
	E = NaN*temp_space;
	for j = 1:length(temp_space)
		idx = (data(i).temperature(x) > temp_space(j)-.5 & data(i).temperature(x) < temp_space(j)+.5);
		M(j) = nanmean(yax(idx));
		E(j) = corelib.sem(yax(idx));
	end

	errorbar(temp_space,M,E,'LineWidth',2,'LineStyle','none','MarkerFaceColor',c(i,:),'MarkerEdgeColor',c(i,:))

	set(gca,'YScale','linear','YLim',[0 1],'XLim',[6 24])

	title('DG Start Phase vs Temperature (C)')

	if i == 7
		xlabel('Temperature (C)')
		ylabel('DG Start Phase')
	end

end

figlib.pretty('fs',14)

%% DG-PD coupling
% The following figures explore the fine structure of DG-PD coupling. The hypothesis here is that the gastric rhythm, in some manner, affects the pyloric rhythm. One way to look a this is to plot the PD inter-spike-intervals triggered by start of DG bursts. That's what the next figure shows. Notice the striking fan-like structure in all preps (different colours are different temperatures). This suggests that the PD neuron is in phase with the DG start (or the DG neuron is starting at a particular phase of PD). 

%%
% Note also that the PD ISIs seem to increase and decrease with the DG start (this is especially clear in 901_062). This suggests that the DG neuron is affecting the PD neuron, though we cannot rule out PD affecting DG. 


ax = gastric.PlotISITriggeredBy(data, 'PD', 'DG_burst_starts');

ylabel(ax(length(data(i))),'PD ISI (s)')
xlabel(ax(length(data(i))),'Time since DG start (s)')

figlib.pretty


%%
% Now a similar figure, but triggered when DG ends. The effect is less clear here. One reason why is that the DG burst periods are less clearly defined, and the DG neuron tends to peter out slowly. 

ax = gastric.PlotISITriggeredBy(data, 'PD', 'DG_burst_ends');

ylabel(ax(length(data(i))),'PD ISI (s)')
xlabel(ax(length(data(i))),'Time since DG end (s)')

figlib.pretty



%% Metadata
% To reproduce this document:

pdflib.footer
