
pdflib.header


data_root = '/Volumes/HYDROGEN/srinivas_data/gastric-data';


%% Analysis of gastric and pyloric rhythms at different temperatures
% In this document we look at pyloric and gastric rhtyhms at differnet temperatures.
% This data is from Dan Powell and the experiments that go into this are:

include_these = sort({'901_005','901_086','901_046','901_049','901_052','901_062','901_080','901_095','901_098','932_151','941_003','941_006'});

disp(include_these')

if exist('dan_stacked_data.mat','file') == 2

	load('dan_stacked_data','data')
else
	for i = 1:length(include_these)
		data(i)  = crabsort.consolidate('neurons',{'PD','LG'},'DataFun',{@crabsort.getTemperature},'DataDir',[data_root filesep include_these{i}],'stack',true);
	end

	save('dan_stacked_data','data','-nocompression','-v7.3')

end






% make sure spiketimes are sorted
for i = 1:length(data)
	data(i).PD = sort(data(i).PD);
	data(i).LG = sort(data(i).LG);
end


% compute burst metrics of all LG neurons
data = crabsort.computePeriods(data,'neurons',{'PD'},'ibis',.18,'min_spikes_per_burst',2);
data = crabsort.computePeriods(data,'neurons',{'LG'},'ibis',1,'min_spikes_per_burst',5);





%% PD bursts

figure('outerposition',[300 300 1200 901],'PaperUnits','points','PaperSize',[1200 901]); hold on


for i = 1:length(data)
	subplot(3,4,i); hold on
	isis = diff(data(i).PD);
	% isis(isis>2) = NaN;
	isis(isis<1e-2) = NaN;
	spiketimes = data(i).PD(1:end-1);
	plotlib.cplot(spiketimes,isis,data(i).temperature(round(spiketimes*1e3)))
		

	set(gca,'YScale','log','YLim',[1e-2 2],'YTick',[1e-2 1e-1 1])
	title(char(data(i).experiment_idx),'interpreter','none')
end

suptitle('PD neurons, Dans data')

figlib.pretty
pdflib.snap()


%% LG bursts
% How regular is LG bursting? Is it meaningful to measure LG burst metrics? To get a sense of this, I plot all ISIs from the LG neuron in all preps. 

figure('outerposition',[300 300 1200 901],'PaperUnits','points','PaperSize',[1200 901]); hold on


for i = 1:length(data)
	subplot(3,4,i); hold on
	isis = diff(data(i).LG);
	isis(isis>20) = NaN;
	isis(isis<1e-2) = NaN;
	spiketimes = data(i).LG(1:end-1);
	plotlib.cplot(spiketimes,isis,data(i).temperature(round(spiketimes*1e3)))
		

	set(gca,'YScale','log','YLim',[1e-2 100])
	title(char(data(i).experiment_idx),'interpreter','none')
end


suptitle('LG neurons, Dans data')

figlib.pretty
pdflib.snap()




figure('outerposition',[300 300 1002 901],'PaperUnits','points','PaperSize',[1002 901]); hold on

for i = 1:length(data)
	subplot(3,4,i); hold on
	gastric.plotRasterTriggeredBy(data(i),'LG', 'LG_burst_starts',[20 20])
end










%% Variability in PD burst periods
% In this section, I look at cycle-to-cycle variability in the PD burst periods. Specifically, I compare PD burst periods in one cycle to the burst periods in the next cycle. I observed that PD neurons tended to sometimes skip a spike (the last one was quite variable). These cycle-to-cycle variations in PD period manifest as deviations from the diagonal in the following plots. 

figure('outerposition',[300 300 903 901],'PaperUnits','points','PaperSize',[903 901]); hold on

for i = 1:length(data)
	subplot(3,4,i); hold on


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
	title(char(data(i).experiment_idx),'interpreter','none')

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
clear ax
ax(2) = subplot(1,2,2); hold on
ax(1) = subplot(1,2,1); hold on
set(ax(1),'XScale','log','YLim',[0 .2])


temp_space = 7:2:21;
c = parula(length(temp_space)+1);

all_x = [];
all_y = [];
all_temp = [];

for i = 1:length(data)
	[cv_mean_on, cv_mean_off, cv_std_on, cv_std_off, time_since_gastric, PD_period_cv, temperature]  = gastric.comparePDVariability(data(i), temp_space, 10, 2.5);

	all_x = [time_since_gastric; all_x];
	all_y = [PD_period_cv; all_y];
	all_temp = [temperature; all_temp];

	

	for j = 1:length(temp_space)
		scatter(ax(2),cv_mean_on(j),cv_mean_off(j),64,c(j,:),'MarkerFaceColor',c(j,:),'MarkerEdgeColor',c(j,:),'MarkerFaceAlpha',.5)
	end
end


for i = 1:length(temp_space)
	ok = abs(temp_space(i) - all_temp) < 1;
	plotlib.pieceWiseLinear(ax(1),all_x(ok),all_y(ok),'nbins',10,'Color',c(i,:));


end

xlabel(ax(1),'Time since LG spike (s)')
ylabel(ax(1),'PD burst variability')


plotlib.drawDiag(ax(2));
axis(ax(2),'square')

set(ax(2),'XLim',[0 .15],'YLim',[0 .15])
xlabel(ax(2),'Gastric rhythm on')
ylabel(ax(2),'Gastric rhythm off')
suptitle('Variability in PD periods')

ch = colorbar(ax(2));
caxis(ax(2),[min(temp_space) max(temp_space)]);
title(ch,'Temperature (C)')

figlib.pretty('FontSize',16)
pdflib.snap()




















%% Burst period vs. temperature
% In the following figure, I plot burst periods of LG and PD neurons as a function of temperature for each prep. Black dots are PD bursts, red dots are LG bursts. Note that they both decrease at approximately the same rate. 

figure('outerposition',[300 300 1001 901],'PaperUnits','points','PaperSize',[1001 901]); hold on
for i = 1:length(data)
	subplot(3,4,i); hold on


	x = round(data(i).PD_burst_starts*1e3);
	plot(data(i).temperature(x),data(i).PD_burst_periods,'k.')

	x = round(data(i).LG_burst_starts*1e3);
	plot(data(i).temperature(x),data(i).LG_burst_periods,'r.')

	set(gca,'YScale','log','XLim',[6 24])

	title(char(data(i).experiment_idx),'interpreter','none')
	if i == 7
		xlabel('Temperature (C)')
		ylabel('Burst period (s)')
	end
end

figlib.pretty('FontSize',16)
pdflib.snap()












%% Duty cycles vs. temperature
% In the following figure, I plot the uty cycles of PD and LG as a function of temperature. note that the PD neuron maintains a constant duty cycle over the temperatures tested. 

figure('outerposition',[300 300 901 801],'PaperUnits','points','PaperSize',[901 801]); hold on
for i = 1:length(data)
	subplot(3,4,i); hold on


	x = round(data(i).PD_burst_starts*1e3);
	plot(data(i).temperature(x),data(i).PD_burst_durations./data(i).PD_burst_periods,'k.')

	x = round(data(i).LG_burst_starts*1e3);
	plot(data(i).temperature(x),data(i).LG_burst_durations./data(i).LG_burst_periods,'r.')

	set(gca,'YScale','linear','YLim',[0 1],'YTick',0:.2:1,'XLim',[6 24])

	title(char(data(i).experiment_idx),'interpreter','none')

	if i == 7
		xlabel('Temperature (C)')
		ylabel('Duty cycle')
	end

end

figlib.pretty('FontSize',16)
pdflib.snap()














%% Spikes per burst vs. temperature
% In the following figure, I plot the # of spikes/burst as a function of temperature for both the PD neurons (black) and the LG neurons (red). Note that the # of spikes/burst decreases for the PD neuron with temperature, as that is what it does to maintain its duty cycle. 

figure('outerposition',[300 300 1301 801],'PaperUnits','points','PaperSize',[1301 801]); hold on
for i = 1:length(data)
	subplot(3,4,i); hold on


	x = round(data(i).PD_burst_starts*1e3);
	plot(data(i).temperature(x),data(i).PD_n_spikes_per_burst,'k.')

	x = round(data(i).LG_burst_starts*1e3);
	plot(data(i).temperature(x),data(i).LG_n_spikes_per_burst,'r.')

	set(gca,'YScale','log','YLim',[0 1e3],'XLim',[6 24])

	title(char(data(i).experiment_idx),'interpreter','none')

	if i > 4
		xlabel('Temperature (C)')
	end
	if i == 1 || i == 5
		ylabel('# spikes/burst')
	end

end

figlib.pretty('FontSize',16)
pdflib.snap()







%% LG-PD coupling: PD spiking triggered by LG starts
% To look at the interaction between LG and PD (a proxy for the interaction b/w the gastric and pyloric rhythms), I will plot PD spikes triggered by LG burst starts. 




figure('outerposition',[300 300 1002 901],'PaperUnits','points','PaperSize',[1002 901]); hold on

for i = 1:length(data)
	subplot(3,4,i); hold on
	gastric.plotRasterTriggeredBy(data(i),'PD', 'LG_burst_starts')
	set(gca,'YTick',[])
	ylabel(char(data(i).experiment_idx),'interpreter','none')
	if i == 7
		xlabel('Time since LG start (s)')
	end
end

suptitle('PD spikes')
figlib.pretty
pdflib.snap()






%%
% Now I look at PD spiking triggered by LG burst ends


figure('outerposition',[300 300 1002 901],'PaperUnits','points','PaperSize',[1002 901]); hold on

for i = 1:length(data)
	subplot(3,4,i); hold on
	gastric.plotRasterTriggeredBy(data(i),'PD', 'LG_burst_ends')
	set(gca,'YTick',[])
	ylabel(char(data(i).experiment_idx),'interpreter','none')
	if i == 7
		xlabel('Time since LG end (s)')
	end
end

suptitle('PD spikes')

figlib.pretty
pdflib.snap()










%% LG-PD coupling
% I now look at the fine structure of the LG-PD coupling. The hypothesis here is that the gastric rhythm, in some manner, affects the pyloric rhythm. One way to look a this is to plot the PD inter-spike-intervals triggered by start of LG bursts. That's what the next figure shows. Notice the striking fan-like structure in all preps (different colours are different temperatures). This suggests that the PD neuron is in phase with the LG start (or the LG neuron is starting at a particular phase of PD). 

%%
% Note also that the PD ISIs seem to increase and decrease with the LG start (this is expecially clear in 901_062). This suggests that the LG neuron is affecting the PD neuron, though we cannot rule out PD affecting LG. 



figure('outerposition',[300 300 1002 901],'PaperUnits','points','PaperSize',[1002 901]); hold on

for i = 1:length(data)
	subplot(3,4,i); hold on
	[~, ph, ch] = gastric.plotISITriggeredBy(data(i), 'PD', 'LG_burst_starts',[6 23]);
	if i == 7
		ylabel(gca,'PD IBI (s)')
		xlabel(gca,'Time since LG start (s)')
	end
	set(gca,'YLim',[0 2])

	ph.SizeData = 10;
	ph.Marker = 'o';

	if i < length(data)
		delete(ch)
	end

end


figlib.pretty('FontSize',16)
pdflib.snap()









%%
% Now a similar figure, but triggered when LG ends. The effect is less clear here. One reason why is that the LG burst periods are less clearly defined, and the LG neuron tends to peter out slowly. 

figure('outerposition',[300 300 1002 901],'PaperUnits','points','PaperSize',[1002 901]); hold on

for i = 1:length(data)
	subplot(3,4,i); hold on
	[~, ph, ch] = gastric.plotISITriggeredBy(data(i), 'PD', 'LG_burst_ends',[6 23]);
	if i == 7
		ylabel(gca,'PD ISI (s)')
		xlabel(gca,'Time since LG end (s)')
	end
	set(gca,'YLim',[0 2])

	ph.SizeData = 10;
	ph.Marker = 'o';

	if i < length(data)
		delete(ch)
	end

end


figlib.pretty('FontSize',16)
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

figlib.pretty('FontSize',16)
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

figlib.pretty('FontSize',16)
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

figlib.pretty('FontSize',16)
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

figlib.pretty('PlotLineWidth',1)
pdflib.snap()







%% Metadata
% To reproduce this document:

pdflib.footer