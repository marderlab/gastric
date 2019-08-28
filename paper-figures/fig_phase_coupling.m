
clearvars
close all
addpath('../')



data = gastric.getEvokedData();


min_temp = 5;
max_temp = 25;


% make sure spiketimes are sorted
for i = 1:length(data)
	data(i).PD = sort(data(i).PD);
	data(i).LG = sort(data(i).LG);
end


% compute burst metrics of all LG neurons
data = crabsort.computePeriods(data,'neurons',{'PD'},'ibis',.18,'min_spikes_per_burst',2);
data = crabsort.computePeriods(data,'neurons',{'LG'},'ibis',1,'min_spikes_per_burst',5);
data = crabsort.computePeriods(data,'neurons',{'DG'},'ibis',1,'min_spikes_per_burst',5);


%


% supplementary figure -- all rasters

clear ax

figure('outerposition',[300 300 1002 1300],'PaperUnits','points','PaperSize',[1002 1300]); hold on

LG_plots = 1:20; 
LG_plots(3:4:end) = [];
LG_plots(3:3:end) = [];

DG_plots = 1:20; 
DG_plots(1:4:end) = [];
DG_plots(1:3:end) = [];

for i = 1:length(data)

	ax.LG_triggered(i) = subplot(5,4,LG_plots(i)); hold on



	gastric.plotRasterTriggeredBy(data(i),'neuron','PD', 'trigger','LG_burst_starts','N_rescale',3,'min_temp',min_temp,'max_temp',max_temp);
	set(gca,'YTick',[])
	set(gca,'YColor','w')

	ax.DG_triggered(i) = subplot(5,4,DG_plots(i)); hold on
	gastric.plotRasterTriggeredBy(data(i),'neuron','PD', 'trigger','DG_burst_starts','N_rescale',3,'min_temp',min_temp,'max_temp',max_temp);
	set(gca,'YTick',[])
	set(gca,'YColor','w')


	


end

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

return



















% summary stats





figure('outerposition',[300 300 1202 901],'PaperUnits','points','PaperSize',[1202 901]); hold on
clear ax
temp_space = min_temp:2:max_temp;

nbins = 30;
N = 1e2;

c = colormaps.redula(length(temp_space));

% show histograms of when LG bursts start in PD phase
all_phase = [];
all_temp = [];
all_prep = [];

for i = 1:length(data)
	[this_phase,this_temp] = gastric.measurePhase(data(i),'LG_burst_starts','PD');
	all_phase = [all_phase; this_phase];
	all_temp = [all_temp; round(this_temp)];
	all_prep = [all_prep; this_phase*0 + i];
end

ax(1) = subplot(2,3,1); hold on
set(gca,'YLim',[0 .2],'XLim',[0 1])




for i = 1:length(temp_space)
	use_these = all_phase(all_temp == temp_space(i));
	if length(use_these) < 2*nbins
		continue
	end

	hy = zeros(N,nbins);

	for j = 1:N
		sample = datasample(use_these,length(use_these));
		hy(j,:) = (histcounts(sample,linspace(0,1,nbins+1)));
		hy(j,:) = hy(j,:)/sum(hy(j,:));

	end

	Upper = max(hy);
	Lower = min(hy);

	[hy, hx] = histcounts(use_these,linspace(0,1,nbins+1));
	
	hy = hy/sum(hy);


	hx = hx(1:end-1) + mean(diff(hx))/2;

	Upper = (Upper - hy)/sqrt(N);
	Lower = (hy - Lower)/sqrt(N);



	ph = plotlib.shadedErrorBar(hx,hy,[Upper; Lower]);
	delete(ph.mainLine)

	ph.patch.FaceColor = c(i,:);
	ph.patch.FaceAlpha = .5;

	ph.edge(1).Color = c(i,:);
	ph.edge(2).Color = c(i,:);

end

ylabel('Probability of LG burst start')
xlabel('PD phase')
plotlib.horzline(1/nbins,'LineWidth',2,'Color','k','LineStyle','--');


% DG 
% show histograms of when LG bursts start in PD phase
all_phase = [];
all_temp = [];
all_prep = [];

for i = 1:length(data)
	[this_phase,this_temp] = gastric.measurePhase(data(i),'DG_burst_starts','PD');
	all_phase = [all_phase; this_phase];
	all_temp = [all_temp; round(this_temp)];
	all_prep = [all_prep; this_phase*0 + i];
end

ax(1) = subplot(2,3,2); hold on
set(gca,'YLim',[0 .2],'XLim',[0 1])

for i = 1:length(temp_space)
	use_these = all_phase(all_temp == temp_space(i));
	if length(use_these) < 2*nbins
		continue
	end

	hy = zeros(N,nbins);

	for j = 1:N
		sample = datasample(use_these,length(use_these));
		hy(j,:) = (histcounts(sample,linspace(0,1,nbins+1)));
		hy(j,:) = hy(j,:)/sum(hy(j,:));

	end

	Upper = max(hy);
	Lower = min(hy);

	[hy, hx] = histcounts(use_these,linspace(0,1,nbins+1));
	
	hy = hy/sum(hy);


	hx = hx(1:end-1) + mean(diff(hx))/2;

	Upper = (Upper - hy)/sqrt(N);
	Lower = (hy - Lower)/sqrt(N);



	ph = plotlib.shadedErrorBar(hx,hy,[Upper; Lower]);
	delete(ph.mainLine)

	ph.patch.FaceColor = c(i,:);
	ph.patch.FaceAlpha = .5;

	ph.edge(1).Color = c(i,:);
	ph.edge(2).Color = c(i,:);

end

ylabel('Probability of DG burst start')
xlabel('PD phase')
plotlib.horzline(1/nbins,'LineWidth',2,'Color','k','LineStyle','--');

figlib.pretty('PlotLineWidth',1)




return






ax(1) = subplot(2,2,1); hold on
set(gca,'YColor','w')
gastric.plotRasterTriggeredBy(data(2),'neuron','PD', 'trigger','LG_burst_starts','before',2,'after',2,'min_temp',min_temp,'max_temp',max_temp)
xlabel('Time since LG burst start (s)')

ax(2) = subplot(2,2,2); hold on
set(gca,'YColor','w')
gastric.plotRasterTriggeredBy(data(2),'neuron','PD', 'trigger','LG_burst_starts','N_rescale',3,'min_temp',min_temp,'max_temp',max_temp)
xlabel('PD Phase since LG burst start')

ch = colorbar;
caxis([min_temp max_temp]);
title(ch,'Temperature (C)')
colormap(colormaps.redula)

ax(1).Position(3:4) = [.33 .33]
ax(2).Position(3:4) = [.33 .33];





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
ph = gastric.groupAndPlotErrorBars(temp_space, all_temp, all_prep, all_phase);

R = randn(length(ph),1);
C = ones(length(ph),3);
C(:,1) = .8+ .05*R;
C(:,2) = .8+ .05*R;
C(:,3) = .8+ .05*R;

C(C>1) = 1;
C(C<0) = 0;

for i = 1:length(ph)-1
	set(ph(i),'Color',C(i,:))
end

set(gca,'YLim',[0 1],'YScale','linear')
ylabel('LG start in PD phase')
xlabel('Temperature (C)')











c = colormaps.redula(100);



for i = 1:length(data)
	[data(i).all_phases, data(i).all_temp] = gastric.measurePhase(data(i),'LG','PD');
end
all_phases = vertcat(data.all_phases);
all_temp = vertcat(data.all_temp);

hx = linspace(0,1,20);

% average across preps and plot by temperature
subplot(2,2,4); hold on

for i = 1:length(temp_space)
	plot_this = round(all_temp) == temp_space(i);
	hy = histcounts(all_phases(plot_this),hx);
	hy = hy/sum(hy);
	hy = hy/mean(diff(hx));


	idx = ceil(((temp_space(i) - min_temp)/(max_temp - min_temp))*100);
	if idx < 1
		idx = 1;
	end
	if idx > length(c)
		idx = length(c);
	end


	plot(hx(2:end),hy,'Color',c(idx,:))

end
xlabel('PD phase')
ylabel('LG spike probability')
set(gca,'XLim',[0 1])

figlib.pretty
pdflib.snap()







% supplementary figure -- all rasters rescaled by PD period

figure('outerposition',[300 300 1002 901],'PaperUnits','points','PaperSize',[1002 901]); hold on

for i = 1:length(data)
	subplot(3,4,i); hold on
	gastric.plotRasterTriggeredBy(data(i),'neuron','PD', 'trigger','LG_burst_starts','N_rescale',3,'min_temp',min_temp,'max_temp',max_temp)
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
