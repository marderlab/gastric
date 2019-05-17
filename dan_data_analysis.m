
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
% The following figure shows the temperature in all the experiments, together with a raster indicating when the LG neuron spikes. You can see from this figure that gastric rhythms were elicted at many different temperatures, once the temperature had been stabilized to the desired value. 

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

figlib.pretty('fs',20)
pdflib.snap()














% make sure spiketimes are sorted
for i = 1:length(data)
	data(i).PD = sort(data(i).PD);
	data(i).LG = sort(data(i).LG);
end


% compute burst metrics of all LG neurons
data = crabsort.computePeriods(data,'neurons',{'PD'},'ibis',.18,'min_spikes_per_burst',2);
data = crabsort.computePeriods(data,'neurons',{'LG'},'ibis',1,'min_spikes_per_burst',5);






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
pdflib.snap()















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
pdflib.snap()


















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
pdflib.snap()












%% Duty cycles vs. temperature
% In the following figure, I plot the uty cycles of PD and LG as a function of temperature. note that the PD neuron maintains a constant duty cycle over the temperatures tested. 

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
pdflib.snap()














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
pdflib.snap()
















%% LG-PD coupling
% I now look at the fine structure of the LG-PD coupling. The hypothesis here is that the gastric rhythm, in some manner, affects the pyloric rhythm. One way to look a this is to plot the PD inter-spike-intervals triggered by start of LG bursts. That's what the next figure shows. Notice the striking fan-like structure in all preps (different colours are different temperatures). This suggests that the PD neuron is in phase with the LG start (or the LG neuron is starting at a particular phase of PD). 

%%
% Note also that the PD ISIs seem to increase and decrease with the LG start (this is expecially clear in 901_062). This suggests that the LG neuron is affecting the PD neuron, though we cannot rule out PD affecting LG. 


ax = gastric.PlotISITriggeredBy(data, 'PD', 'LG_burst_starts');

ylabel(ax(7),'PD ISI (s)')
xlabel(ax(7),'Time since LG start (s)')

figlib.pretty
pdflib.snap()











%%
% Now a similar figure, but triggered when LG ends. The effect is less clear here. One reason why is that the LG burst periods are less clearly defined, and the LG neuron tends to peter out slowly. 

ax = gastric.PlotISITriggeredBy(data, 'PD', 'LG_burst_ends');

ylabel(ax(7),'PD ISI (s)')
xlabel(ax(7),'Time since LG end (s)')

figlib.pretty
pdflib.snap()












%% Phase coupling between LG and PD
% All of this hints at a phase coupling between LG and PD. Here I measure the phase in the PD cycle where LG starts and plot that as a function of temperature. 

figure('outerposition',[300 300 1200 601],'PaperUnits','points','PaperSize',[1200 601]); hold on

temp_space = 7:2:23;

all_phase = [];
all_temp = [];
all_prep = [];

for i = 1:length(data)
	[this_phase,this_temp] = gastric.measurePhase(data(i),'LG_burst_starts','PD');
	all_phase = [all_phase; this_phase];
	all_temp = [all_temp; this_temp];
	all_prep = [all_prep; this_phase*0 + i];
end


subplot(1,2,1); hold on
gastric.groupAndPlotErrorBars(temp_space, all_temp, all_prep, all_phase);

set(gca,'YLim',[0 1],'YScale','linear')
ylabel('LG start in PD phase')
xlabel('Temperature (C)')

figlib.pretty()
pdflib.snap()










%% Integer coupling b/w PD and LG periods
% The periods of PD and LG neurons have previously been shown the be integer-coupled, that is, the LG periods is an integer mulitple of the PD period. Here we see the same thing: the following figure plots the LG period vs. the mean PD periods during taht LG burst. Note that the gray lines are not fits to the data -- they are merely lines with integer slopes. Note that the data naturally falls on top of these lines. 


all_x = [];
all_temp = [];
all_y = [];
all_prep = [];

for i = 1:length(data)
	[this_x,this_temp] = gastric.integerCoupling(data(i));
	all_x = [all_x; this_x];
	all_temp = [all_temp; this_temp];
	all_y = [all_y; data(i).LG_burst_periods];
	all_prep = [all_prep; this_x*0 + i];
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
pdflib.snap()











%%
% Now I colour the dots in the integer coupling plot by prep ID. 
figure('outerposition',[300 300 901 901],'PaperUnits','points','PaperSize',[1200 901]); hold on


% plot gridlines
for i = 4:30
	xx = linspace(0,10,1e3);
	yy = xx*i;
	plot(gca,xx,yy,'Color',[.8 .8 .8])
end


[~,ch] = plotlib.cplot(all_x,all_y,all_prep,'colormap','lines');
delete(ch);
set(gca,'XLim',[0.2 2],'YLim',[0 30])
xlabel('Mean PD period (s)')
ylabel('LG periods (s)')

figlib.pretty()



%%
% How does integer coupling vary with temperature?

N_pyloric_gastric = round(all_y./all_x);
integerness = 1- abs(all_y./all_x - N_pyloric_gastric)*2;




figure('outerposition',[300 300 903 901],'PaperUnits','points','PaperSize',[903 901]); hold on

temp_space = 7:2:23;
PD_space = .2:.2:2;

% plot N/plyoric and group by temperature
subplot(2,2,1); hold on
gastric.groupAndPlotErrorBars(temp_space, all_temp, all_prep, N_pyloric_gastric);

set(gca,'YLim',[1 400],'YScale','log')
ylabel('N gastric/pyloric')
xlabel('Temperature (C)')


% plot integerness and group by temperature
subplot(2,2,2); hold on
gastric.groupAndPlotErrorBars(temp_space, all_temp, all_prep, integerness);

set(gca,'YLim',[0 1])
ylabel('Integerness')
xlabel('Temperature (C)')


% now group by PD periods
subplot(2,2,3); hold on
gastric.groupAndPlotErrorBars(PD_space, all_x, all_prep, N_pyloric_gastric);

set(gca,'YLim',[1 400],'YScale','log')
ylabel('N gastric/pyloric')
xlabel('PD period (s)')


subplot(2,2,4); hold on
gastric.groupAndPlotErrorBars(PD_space, all_x, all_prep, integerness);
ylabel('Integerness')
xlabel('PD period (s)')

figlib.pretty('plw',1)
pdflib.snap()














%% Metadata
% To reproduce this document:

pdflib.footer