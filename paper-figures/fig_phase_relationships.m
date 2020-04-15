
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




clear ax

figure('outerposition',[3 3 1444 999],'PaperUnits','points','PaperSize',[1444 999]); hold on


ax(1) = subplot(2,3,1); hold on
gastric.plotRasterTriggeredBy(data(2),'neuron','PD', 'trigger','LG_burst_starts','N_rescale',3,'min_temp',min_temp,'max_temp',max_temp,'time_window',4);
set(gca,'YTick',[])
set(gca,'YColor','w')



ax(4) = subplot(2,3,4); hold on
gastric.plotRasterTriggeredBy(data(2),'neuron','PD', 'trigger','DG_burst_starts','N_rescale',3,'min_temp',min_temp,'max_temp',max_temp,'time_window',4);
set(gca,'YTick',[])
set(gca,'YColor','w')




temp_space = min_temp:2:max_temp;




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


ax(2) = subplot(2,3,2); hold on
set(ax(2),'YLim',[0 6],'XLim',[0 1])


nbins = 20;

for i = 1:length(temp_space)
	use_these = all_phase(all_temp == temp_space(i));

	if length(use_these) < 100
		continue
	end


	hy = histcounts(use_these,'BinEdges',linspace(0,1,nbins+1),'Normalization','pdf');
	hx = linspace(0,1,nbins);

	a(i) = area(hx,hy,'FaceColor',c(i,:),'FaceAlpha',.3,'EdgeColor',c(i,:),'LineWidth',2);

	% generate null data
	n = rand(length(use_these),1);
	[~,p] = kstest2(n,use_these)

end

plot([0 1],[1 1],'k--')

ylabel('LG burst start probability')




% inset
inset = axes; hold on
inset.Position = [.52 .77 .12 .15];
[ph, M] = gastric.groupAndPlotErrorBars(temp_space, all_temp, all_prep, all_phase);

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
ylabel('LG start (PD phase)')
xlabel(gastric.tempLabel)


disp('Spearman test for LG start phase across temperature:')
[~,p]=corr(temp_space(2:end-1)',M(2:end-1)','Type','Spearman')



% DG 
% show histograms of when LG bursts start in PD phase
all_phase = [];
all_temp = [];
all_prep = [];

disp('DG')

for i = 1:length(data)
	[this_phase,this_temp] = gastric.measurePhase(data(i),'DG_burst_starts','PD');
	all_phase = [all_phase; this_phase];
	all_temp = [all_temp; round(this_temp)];
	all_prep = [all_prep; this_phase*0 + i];
end

ax(5) = subplot(2,3,5); hold on
set(gca,'YLim',[0 6],'XLim',[0 1])

for i = 1:length(temp_space)
	use_these = all_phase(all_temp == temp_space(i));

	if length(use_these) < 100
		continue
	end

	hy = histcounts(use_these,'BinEdges',linspace(0,1,nbins+1),'Normalization','pdf');
	hx = linspace(0,1,nbins);

	a(i) = area(hx,hy,'FaceColor',c(i,:),'FaceAlpha',.3,'EdgeColor',c(i,:),'LineWidth',2);

	% generate null data
	n = rand(length(use_these),1);
	[~,p] = kstest2(n,use_these)
end


plot([0 1],[1 1],'k--')

ylabel('DG burst start probability')
xlabel('PD phase')




% measure PD stops everywhere
for i = 1:length(data)
	[data(i).PD_stops, data(i).PD_temp] = gastric.measurePhase(data(i),'PD_burst_ends','PD');
end
PD_stops = vertcat(data.PD_stops);
PD_temp = vertcat(data.PD_temp);



c = colormaps.redula(100);

for i = 1:length(data)
	[data(i).LG_phase, data(i).all_temp] = gastric.measurePhase(data(i),'LG','PD');
end
LG_phase = vertcat(data.LG_phase);
all_temp = vertcat(data.all_temp);

nbins = 30;

hx = linspace(0,1,nbins+1);
hc = hx(1:end-1) + mean(diff(hx))/2;

% average across preps and plot by temperature
ax(3) = subplot(2,3,3); hold on
barx = 5;
for i = 1:length(temp_space)

	plot_this = round(all_temp) == temp_space(i);

	if sum(plot_this) < 1e3
		continue
	end

	
	use_these = LG_phase(plot_this);


	idx = ceil(((temp_space(i) - min_temp)/(max_temp - min_temp))*100);
	if idx < 1
		idx = 1;
	end
	if idx > length(c)
		idx = length(c);
	end


	hy = histcounts(use_these,'BinEdges',linspace(0,1,nbins+1),'Normalization','pdf');
	hx = linspace(0,1,nbins);

	a(i) = area(hx,hy,'FaceColor',c(idx,:),'FaceAlpha',.3,'EdgeColor',c(idx,:),'LineWidth',2);


	% also indicate where PD stops bursting
	M = mean(PD_stops(round(PD_temp) == temp_space(i)));
	S = std(PD_stops(round(PD_temp) == temp_space(i)));
	h(i) = barh(barx,M,'BarWidth',.3,'FaceColor',c(idx,:),'EdgeColor',c(idx,:));

	errorbar(M,barx,S,'horizontal','Color',c(idx,:));

	barx = barx - .3;


end

yh = ylabel('LG spike probability');
set(gca,'XLim',[0 1],'YLim',[0 6],'YTick',[0:0.5:2])
plotlib.horzline(1,'LineStyle','--','Color','k','LineWidth',1);




for i = 1:length(data)
	[data(i).DG_phase, data(i).all_temp] = gastric.measurePhase(data(i),'DG','PD');
end
DG_phase = vertcat(data.DG_phase);
all_temp = vertcat(data.all_temp);

hx = linspace(0,1,nbins);

% average across preps and plot by temperature
ax(6) = subplot(2,3,6); hold on

for i = 1:length(temp_space)
	plot_this = round(all_temp) == temp_space(i);

	if sum(plot_this) < 1e3
		continue
	end

	use_these = DG_phase(plot_this);


	idx = ceil(((temp_space(i) - min_temp)/(max_temp - min_temp))*100);
	if idx < 1
		idx = 1;
	end
	if idx > length(c)
		idx = length(c);
	end


	hy = histcounts(use_these,'BinEdges',linspace(0,1,nbins+1),'Normalization','pdf');
	hx = linspace(0,1,nbins);

	a(i) = area(hx,hy,'FaceColor',c(idx,:),'FaceAlpha',.3,'EdgeColor',c(idx,:),'LineWidth',1);



end
xlabel('PD phase')
ylabel('DG spike probability')
set(gca,'XLim',[0 1],'YLim',[0 6])

plotlib.horzline(1,'LineStyle','--','Color','k','LineWidth',1);

colormap(c)

ch = colorbar();
ch.Position = [.75 .1 .01 .3];
caxis([min_temp max_temp])
title(ch,gastric.tempLabel)

figlib.pretty('PlotLineWidth',1)


yh.Position = [-.22 0.04];


ax(1).Position(1) = .05;
ax(4).Position(1) = .05;

ax(2).Position(1) = .35;
ax(5).Position(1) = .35;

title(ax(1),'PD spikes','FontWeight','normal')

ax(1).YColor = 'k';
ax(4).YColor = 'k';

ylabel(ax(1),'aligned to LG start')
ylabel(ax(4),'aligned to DG start')

xlabel(ax(4),'PD phase')


ch.Location = 'north';
ch.Position = [.52 .77 .12 .01];
title(ch,'')
ch.TickLabels = {};
yh.Position = [-.13 .8];

figlib.label('IgnoreThese',inset,'XOffset',-.02,'FontSize',29)