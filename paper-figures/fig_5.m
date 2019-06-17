%%
% This figure shows that integer coupling persists across temperatures


clear all
close all
addpath('../')

data_root = '/Volumes/HYDROGEN/srinivas_data/gastric-data';


%% Analysis of gastric and pyloric rhythms at different temperatures
% In this document we look at pyloric and gastric rhtyhms at differnet temperatures.
% This data is from Dan Powell and the experiments that go into this are:

include_these = sort({'901_005','901_086','901_046','901_049','901_052','901_062','901_080','901_095','901_098','932_151','941_003','941_006'});

disp(include_these')

if exist('../dan_stacked_data.mat','file') == 2

	load('../dan_stacked_data','data')
else
	for i = 1:length(include_these)
		data(i)  = crabsort.consolidate('neurons',{'PD','LG'},'DataFun',{@crabsort.getTemperature},'DataDir',[data_root filesep include_these{i}],'stack',true);
	end

	save('../dan_stacked_data','data','-nocompression','-v7.3')

end



% make sure spiketimes are sorted
for i = 1:length(data)
	data(i).PD = sort(data(i).PD);
	data(i).LG = sort(data(i).LG);
end


% compute burst metrics of all LG neurons
data = crabsort.computePeriods(data,'neurons',{'PD'},'ibis',.18,'min_spikes_per_burst',2);
data = crabsort.computePeriods(data,'neurons',{'LG'},'ibis',1,'min_spikes_per_burst',5);





%% Integer coupling b/w PD and LG periods
% The periods of PD and LG neurons have previously been shown the be integer-coupled, that is, the LG periods is an integer mulitple of the PD period. Here we see the same thing: the following figure plots the LG period vs. the mean PD periods during taht LG burst. Note that the gray lines are not fits to the data -- they are merely lines with integer slopes. Note that the data naturally falls on top of these lines. 


all_x = [];
all_temp = [];
all_y = [];
all_prep = [];

for i = 1:length(data)
	[this_x,this_temp] = gastric.integerCoupling(data(i));
	this_x(this_x>5) = NaN;
	all_x = [all_x; this_x];
	all_temp = [all_temp; this_temp];
	all_y = [all_y; data(i).LG_burst_periods];
	all_prep = [all_prep; this_x*0 + i];
end

figure('outerposition',[300 300 1200 601],'PaperUnits','points','PaperSize',[1200 601]); hold on
subplot(1,2,1); hold on

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
ch.Position = [.37 .18 .1 .02];
title(ch,'Temperature (C)')





%%
% How does integer coupling vary with temperature?

N_pyloric_gastric = round(all_y./all_x);
integerness = 1- abs(all_y./all_x - N_pyloric_gastric)*2;



temp_space = 7:2:23;
PD_space = .2:.2:2;

% plot N/plyoric and group by temperature
subplot(2,2,2); hold on
gastric.groupAndPlotErrorBars(temp_space, all_temp, all_prep, N_pyloric_gastric);

set(gca,'YLim',[1 400],'YScale','log','XTickLabel',{})
ylabel('N gastric/pyloric')


% plot integerness and group by temperature
subplot(2,2,4); hold on
gastric.groupAndPlotErrorBars(temp_space, all_temp, all_prep, integerness);

set(gca,'YLim',[0 1])
ylabel('Integerness')
xlabel('Temperature (C)')



figlib.pretty('PlotLineWidth',1,'FontSize',16)




