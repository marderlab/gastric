
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


clear ax

figure('outerposition',[300 300 1002 1300],'PaperUnits','points','PaperSize',[1002 1300]); hold on

LG_plots = 1:20; 
LG_plots(3:4:end) = [];
LG_plots(3:3:end) = [];

DG_plots = 1:20; 
DG_plots(1:4:end) = [];
DG_plots(1:3:end) = [];



figlib.pretty('LineWidth',1)



for i = 1:2:length(ax.LG_triggered)
	ax.LG_triggered(i).Position(1) = .1;
end

for i = 2:2:length(ax.LG_triggered)
	ax.LG_triggered(i).Position(1) = .3;
end

for i = 1:2:length(ax.DG_triggered)
	ax.DG_triggered(i).Position(1) = .6;
end

for i = 2:2:length(ax.DG_triggered)
	ax.DG_triggered(i).Position(1) = .8;
end

h = xlabel(ax.LG_triggered(end),'PD Phase since LG burst start');
h.Position = [-1.9 -100];

h = xlabel(ax.DG_triggered(end),'PD Phase since DG burst start');
h.Position = [-1.9 -100];

suptitle('PD spikes')




















% summary stats













