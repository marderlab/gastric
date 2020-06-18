
clearvars
close all
addpath('../')



data = gastric.getEvokedData();

% we're only going to show 4 preps
%data = data([2 3 5 10]);
data = data([2 4 6 5]);

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

figure('outerposition',[3 3 1001 999],'PaperUnits','points','PaperSize',[1001 999]); hold on


for i = 1:length(data)

	ax(i) = subplot(4,4,i); hold on


	gastric.plotRasterTriggeredBy(data(i),'neuron','PD', 'trigger','LG_burst_starts','min_temp',min_temp,'max_temp',max_temp,'time_window',2)
	set(gca,'YTick',[],'XTick',[])
	set(gca,'YColor','w')
	if i == 1
		ylabel('LG')
	end

	ax(i+4) = subplot(4,4,i + 4); hold on
	gastric.plotRasterTriggeredBy(data(i),'neuron','PD', 'trigger','DG_burst_starts','min_temp',min_temp,'max_temp',max_temp,'time_window',2)
	set(gca,'YTick',[])
	set(gca,'YColor','w')


	if i == 1
		ylabel('DG')
	end


end


% now plot the normalized rasters

for i = 1:length(data)

	ax(i+8) = subplot(4,4,i+8); hold on

	gastric.plotRasterTriggeredBy(data(i),'neuron','PD', 'trigger','LG_burst_starts','N_rescale',3,'min_temp',min_temp,'max_temp',max_temp,'time_window',4);
	set(gca,'YTick',[],'XTick',[])
	set(gca,'YColor','w')

	if i == 1
		ylabel('LG')
	end


	ax(i+12) = subplot(4,4,i+12); hold on
	gastric.plotRasterTriggeredBy(data(i),'neuron','PD', 'trigger','DG_burst_starts','N_rescale',3,'min_temp',min_temp,'max_temp',max_temp,'time_window',4);
	set(gca,'YTick',[])
	set(gca,'YColor','w')

	if i == 1
		ylabel('DG')
	end



end


th(1) = text(ax(1),-2.5,500,'LG','Rotation',90,'FontSize',16);
th(2) = text(ax(5),-2.5,300,'DG','Rotation',90,'FontSize',16);
th(3) = text(ax(9),-3.5,500,'LG','Rotation',90,'FontSize',16);
th(4) = text(ax(13),-3.5,300,'DG','Rotation',90,'FontSize',16);

figlib.pretty('LineWidth',1)


axlib.move(ax,'left',.05)

axlib.move(ax(5:8),'up',.04)
axlib.move(ax(9:12),'down',.04)


ch = colorbar(ax(end));
colormap(colormaps.redula)
ch.Position = [.925 .25 .01 .5];
caxis(ax(end),[min_temp max_temp]);
ax(end).Position(3) = ax(1).Position(3);

title(ch,gastric.tempLabel);

xh(1) = xlabel(ax(6),'Time since burst start (s)');
xh(1).Position = [3 -201];

xh(2) = xlabel(ax(14),'PD phase');
xh(2).Position = [4.2 -201];


try
	figlib.saveall('Location',  '/Users/srinivas/Dropbox/Temp-Paper/Temperature-Paper/individual-figures','SaveName',mfilename)
catch

end

