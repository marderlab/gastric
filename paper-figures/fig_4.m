
close all
addpath('../')



data = gastric.getEvokedData();


% make sure spiketimes are sorted
for i = 1:length(data)
	data(i).PD = sort(data(i).PD);
	data(i).LG = sort(data(i).LG);
end


% compute burst metrics of all LG neurons
data = crabsort.computePeriods(data,'neurons',{'PD'},'ibis',.18,'min_spikes_per_burst',2);
data = crabsort.computePeriods(data,'neurons',{'LG'},'ibis',1,'min_spikes_per_burst',5);


%% LG-PD coupling: PD spiking triggered by LG starts
% To look at the interaction between LG and PD (a proxy for the interaction b/w the gastric and pyloric rhythms), I will plot PD spikes triggered by LG burst starts. 




figure('outerposition',[300 300 1202 901],'PaperUnits','points','PaperSize',[1202 901]); hold on

subplot(2,2,1); hold on
set(gca,'YColor','w')
gastric.plotRasterTriggeredBy(data(2),'neuron','PD', 'trigger','LG_burst_starts')
xlabel('Time since LG burst start (s)')

subplot(2,2,2); hold on
set(gca,'YColor','w')
gastric.plotRasterTriggeredBy(data(2),'neuron','PD', 'trigger','LG_burst_starts','N_rescale',3)
xlabel('PD Phase since LG burst start')






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


subplot(2,2,3); hold on
gastric.groupAndPlotErrorBars(temp_space, all_temp, all_prep, all_phase);

set(gca,'YLim',[0 1],'YScale','linear')
ylabel('LG start in PD phase')
xlabel('Temperature (C)')












[all_phases, all_temp] = gastric.measurePhase(data(2),'LG','PD');



c = parula(100);
min_temp = 5;
max_temp = 25;


temp_space = 7:2:21;




for i = 1:length(data)
	[data(i).all_phases, data(i).all_temp] = gastric.measurePhase(data(i),'LG','PD');
end
all_phases = vertcat(data.all_phases);
all_temp = vertcat(data.all_temp);

% average across preps and plot by temperature
subplot(2,2,4); hold on

for i = 1:length(temp_space)
	plot_this = round(all_temp) == temp_space(i);
	hy = histcounts(all_phases(plot_this),hx);

	idx = ceil(((temp_space(i) - min_temp)/(max_temp - min_temp))*100);

	plot(hx(2:end),hy/sum(hy),'Color',c(idx,:))

end
xlabel('PD phase')
ylabel('LG spike probability')
set(gca,'YLim',[0 .1],'XLim',[0 1])

figlib.pretty
pdflib.snap()




% supplementary figure -- all rasters



figure('outerposition',[300 300 1002 901],'PaperUnits','points','PaperSize',[1002 901]); hold on

for i = 1:length(data)
	subplot(3,4,i); hold on
	gastric.plotRasterTriggeredBy(data(i),'neuron','PD', 'trigger','LG_burst_starts','N_rescale',NaN)
	set(gca,'YTick',[])
	if i == 9
		xlabel('Time since LG burst start (s)')
	end
	if i < 9
		set(gca,'XTickLabel','')
	end
	set(gca,'YColor','w')
end

figlib.pretty('LineWidth',1)
pdflib.snap()



% supplementary figure -- all rasters rescaled by PD period

figure('outerposition',[300 300 1002 901],'PaperUnits','points','PaperSize',[1002 901]); hold on

for i = 1:length(data)
	subplot(3,4,i); hold on
	gastric.plotRasterTriggeredBy(data(i),'neuron','PD', 'trigger','LG_burst_starts','N_rescale',3)
	set(gca,'YTick',[])
	if i == 9
		xlabel('PD Phase since LG burst start')
	end
	if i < 9
		set(gca,'XTickLabel','')
	end
	set(gca,'YColor','w')
end

figlib.pretty('LineWidth',1)
pdflib.snap()
