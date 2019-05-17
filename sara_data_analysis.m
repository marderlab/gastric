

pdflib.header





%% Analysis of gastric and pyloric rhythms at different temperatures
% In this document we look at pyloric and gastric rhtyhms at differnet temperatures.
% This data is from Sara Haddad and the experiments that go into this are:

data_root = '/Volumes/HYDROGEN/srinivas_data/temperature-data-for-embedding';
include_these = {'857_144','857_142','857_138_1','857_134_1','857_130','857_052','857_016','857_012','857_010','857_001_2'};


disp(include_these')

if exist('sara_stacked_data.mat','file') == 2

	load('sara_stacked_data','data')
else
	data_s = struct;
	for i = 1:length(include_these)
		this_data  = crabsort.consolidate('neurons',{'PD','LG'},'DataDir',[data_root filesep include_these{i}],'stack',true);

		data_s = structlib.merge(data_s,this_data);
	end

	data = data_s;

	save('sara_stacked_data','data','-nocompression','-v7.3')

end

N = length(data);

% make sure spiketimes are sorted
for i = 1:N
	data(i).PD = sort(data(i).PD);
	data(i).LG = sort(data(i).LG);
end

% throw away data that is decentralized
for i = 1:N
	idx = find(data(i).decentralized,1,'first');
	if isempty(idx)
		continue
	end
	data(i).PD(data(i).PD > idx) = [];
	data(i).LG(data(i).LG > idx) = [];
end


data = crabsort.computePeriods(data,'neurons',{'PD'},'ibis',.15,'min_spikes_per_burst',2);
data = crabsort.computePeriods(data,'neurons',{'LG'},'ibis',1,'min_spikes_per_burst',5);





%% Variability of PD period: dependence on the gastric rhythm
% One question in this data is if the gastric rhythm influences the pyloric rhythm in any way. If it does, one would expect the pyloric period to be a little more variable when the gastric rhythm is on compared to when the gastric rhythm is off. That's what the next figure shows: it compares the variability (CV) of the pyloric burst periods when the gastric rhythm is on and when it is off.

%%
% By "gastric rhythm on", we mean that PD bursts occur within 10 seconds following a LG spike, and by "gastric rhythm off", we mean PD bursts more than 100s since the last LG spike. Note that almost every dot lies below the diagonal, suggesting that G bursting makes PD bursting more variable. 

figure('outerposition',[300 300 1200 600],'PaperUnits','points','PaperSize',[1200 600]); hold on

c = parula(5);

for i = 1:length(data)
	[cv_mean_on, cv_mean_off, cv_std_on, cv_std_off] = gastric.comparePDVariability(data(i), 7:4:31, 10, 2.5);
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

figlib.pretty('fs',16)
pdflib.snap()











%% Burst period vs. temperature
% In the following figure, I plot burst periods of LG and PD neurons as a function of temperature for each prep. Black dots are PD bursts, red dots are LG bursts. Note that they both decrease at approximately the same rate. 

figure('outerposition',[300 300 1200 600],'PaperUnits','points','PaperSize',[1200 600]); hold on
N = length(data);
for i = 1:N
	figlib.autoPlot(N,i); hold on


	x = round(data(i).PD_burst_starts*1e3);
	plot(data(i).temperature(x),data(i).PD_burst_periods,'k.')

	x = round(data(i).LG_burst_starts*1e3);
	plot(data(i).temperature(x),data(i).LG_burst_periods,'r.')

	set(gca,'YScale','log','XLim',[6 33])

	title(char(data(i).experiment_idx),'interpreter','none')
	xlabel('Temperature (C)')
end

figlib.pretty('fs',16)
pdflib.snap()
















%% Duty cycles vs temperature
% In the following figure, I plot the uty cycles of PD and LG as a function of temperature. note that the PD neuron maintains a constant duty cycle over the temperatures tested. 

figure('outerposition',[300 300 1301 801],'PaperUnits','points','PaperSize',[1301 801]); hold on
for i = 1:N
	figlib.autoPlot(N,i); hold on


	x = round(data(i).PD_burst_starts*1e3);
	plot(data(i).temperature(x),data(i).PD_burst_durations./data(i).PD_burst_periods,'k.')

	x = round(data(i).LG_burst_starts*1e3);
	plot(data(i).temperature(x),data(i).LG_burst_durations./data(i).LG_burst_periods,'r.')

	set(gca,'YScale','linear','YLim',[0 1],'YTick',0:.2:1,'XLim',[6 24])

	title(char(data(i).experiment_idx),'interpreter','none')

	if i > 4
		xlabel('Temperature (C)')
	end
	if i == 1 || i == 5
		ylabel('Duty cycle')
	end

end

figlib.pretty('fs',16)
pdflib.snap()












%%
% Why is the PD so noisy? Does this actually exist in the data? It turns out it does. 

C = crabsort(false);
C.path_name = [data_root filesep '857_144'];
C.file_name = '857_144_0001.crab';
C.loadFile;

figure('outerposition',[300 300 1200 600],'PaperUnits','points','PaperSize',[1200 600]); hold on

plot(C.time,C.raw_data(:,5),'k')
set(gca,'XLim',[72 80])
xlabel('Time (s)')
ylabel('pdn')


figlib.pretty('fs',16)
pdflib.snap()












%% LG-PD coupling
% I now look at the fine structure of the LG-PD coupling. The hypothesis here is that the gastric rhythm, in some manner, affects the pyloric rhythm. One way to look a this is to plot the PD inter-spike-intervals triggered by start of LG bursts. That's what the next figure shows. Notice the striking fan-like structure in all preps (different colours are different temperatures). This suggests that the PD neuron is in phase with the LG start (or the LG neuron is starting at a particular phase of PD). 

%%
% Note also that the PD ISIs seem to increase and decrease with the LG start (this is expecially clear in 901_062). This suggests that the LG neuron is affecting the PD neuron, though we cannot rule out PD affecting LG. 


[ax, fig] = gastric.PlotISITriggeredBy(data, 'PD', 'LG_burst_starts');

fig.OuterPosition = [300 300 1700 1e3];
fig.PaperSize = [1700 1e3];

ylabel(ax(1),'PD ISI (s)')
xlabel(ax(1),'Time since LG start (s)')

figlib.pretty('fs',16)
pdflib.snap()











%%
% Now a similar figure, but triggered when LG ends. The effect is less clear here. One reason why is that the LG burst periods are less clearly defined, and the LG neuron tends to peter out slowly. 

[ax, fig] = gastric.PlotISITriggeredBy(data, 'PD', 'LG_burst_ends');
fig.OuterPosition = [300 300 1700 1e3];
fig.PaperSize = [1700 1e3];

ylabel(ax(1),'PD ISI (s)')
xlabel(ax(1),'Time since LG end (s)')

figlib.pretty('fs',16)
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

figlib.pretty('fs',16)
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
for i = 4:40
	xx = linspace(0,10,1e3);
	yy = xx*i;
	plot(gca,xx,yy,'Color',[.8 .8 .8])
end

plot(all_x,all_y,'.','Color',[.8 .8 .8],'MarkerSize',20)
[~,ch] = plotlib.cplot(all_x,all_y,all_temp);
set(gca,'XLim',[0.2 2],'YLim',[0 30])
xlabel('Mean PD period (s)')
ylabel('LG periods (s)')

ch.Location = 'southoutside';
ch.Position = [.52 .15 .4 .02];
title(ch,'Temperature (C)')

figlib.pretty('fs',16)

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

figlib.pretty('fs',16)
pdflib.snap()













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

figlib.pretty('fs',16)
pdflib.snap()














%% Metadata
% To reproduce this document:

pdflib.footer