%%
% This script makes figure 1, which shows that gastric rhythms can be evoked/exist at temperatures above 13C


close all
addpath('../')

data_root = getpref('gastric','data_loc');


%% Analysis of gastric and pyloric rhythms at different temperatures
% In this document we look at pyloric and gastric rhtyhms at differnet temperatures.
% This data is from Dan Powell and the experiments that go into this are:

data = gastric.getEvokedData();

example_data = '901_046';


C = crabsort(false);
C.path_name = fullfile(data_root,example_data);

show_these = {'0006','0079'};
show_these_rasters = {'0006', '0015','0026','0041','0053','0062','0084','0072','0079'};


figure('outerposition',[300 300 1200 1300],'PaperUnits','points','PaperSize',[1200 1300]); hold on

c = colormaps.redula(100);
min_temp = 5;
max_temp = 25;

show_these_channels = {'pdn','mvn','dgn','lgn'};


clear ax
ax.raw_data(1) = subplot(4,1,1); hold on
ax.raw_data(2) = subplot(4,1,2); hold on

yscales = [];

for i = 1:length(show_these)

	C.file_name = [char(example_data) '_' show_these{i} '.abf'];
	C.loadFile;

	for j = length(show_these_channels):-1:1
		channel_idx(j) = find(strcmp(C.common.data_channel_names,show_these_channels{j}));
	end

	this_temp = round(mean(C.raw_data(:,strcmp(C.common.data_channel_names,'temperature'))));
	idx = ceil(((this_temp - min_temp)/(max_temp - min_temp))*100);

	raw_data = C.raw_data(:,channel_idx);
	time = C.time;

	% start traces when LG starts bursting
	start_here = time(C.spikes.lgn.LG(find(diff(C.spikes.lgn.LG)>1e4,1,'first') + 1));
	time = time - start_here;

	% normalize
	z = find(time>60,1,'first');

	for j = 1:size(raw_data,2)
		if i == 1
			yscales(j) = max(2*abs(raw_data(1:z,j)));
		end
		raw_data(:,j) = raw_data(:,j)/yscales(j);
	end
	

	% show raw_data
	for j = 1:size(raw_data,2)
		plot(ax.raw_data(i),time,raw_data(:,j)+j,'Color',c(idx,:));
		th = text(ax.raw_data(i),-1,0,['\it ' show_these_channels{j}]);
		th.Position = [-3 j];
	end

	set(ax.raw_data(i),'XLim',[0 60],'YColor','w')


	ax.raw_data(i).XColor = 'w';
	ax.raw_data(i).XTick = [];


end



% show rasters at all temperatures
% make an axes to show rasters
ax.rasters = subplot(4,1,3); hold on


this_data = data([data.experiment_idx] == example_data);
yoffset = 0;
for i = 1:length(show_these_rasters)
	a = find(this_data.filename == [example_data '_' show_these_rasters{i}],1,'first')*1e-3;
	z = find(this_data.filename == [example_data '_' show_these_rasters{i}],1,'last')*1e-3;

	LG = this_data.LG;
	LG(LG<a) = [];
	LG(LG>z) = [];

	S = find(diff(LG) > 1,1,'first');
	LG(1:S) = [];
	LG = LG - LG(1);

	stim_temp = mean(this_data.temperature(a*1e3:z*1e3));

	idx = ceil(((stim_temp - min_temp)/(max_temp - min_temp))*100);

	neurolib.raster(ax.rasters,LG,'Color',c(idx,:),'deltat',1,'yoffset',yoffset,'center',false,'fill_fraction',.8)
				yoffset = yoffset - 1;


end

text(ax.rasters,-2.7,-4,['\it lgn']);



set(ax.rasters,'XLim',[0 60],'YLim',[yoffset-1, 1])
ax.rasters.YTick = [];
ax.rasters.YLim = [-9 1];
ax.rasters.YColor = 'w';
xlabel(ax.rasters,'Time (s)')



ch = colorbar(ax.rasters);
colormap(ch,colormaps.redula);
title(ch,gastric.tempLabel)
ch.Position = [.9 .34 .01 .16];
caxis([min_temp max_temp])
ch.YDir = 'reverse';

ax.raw_data(1).Position = [.09 .75 .775 .2];
ax.raw_data(2).Position = [.09 .525 .775 .2];
ax.rasters.Position = [.09 .335 .775 .16];


figlib.pretty('PlotLineWidth',1,'LineWidth',1)

figlib.label('FontSize',30)

try
	figlib.saveall('Location',  '/Users/srinivas/Dropbox/Temp-Paper/Temperature-Paper/individual-figures','SaveName',mfilename)
catch

end



return



















% show burst periods of LG

data = crabsort.computePeriods(data,'neurons',{'LG'},'ibis',1,'min_spikes_per_burst',7);




ax.LG_burst_periods = subplot(4,1,4); hold on
set(ax.LG_burst_periods,'YScale','log','YLim',[3 30])

xoffset = 0;

show_neuron_rasters = {'LG'};
yoffset = 0;

for i = 1:length(data)

	temperature = round(data(i).temperature);

	all_stim_times = find(data(i).mask == 0);
	stim_times = find(data(i).mask == 0);
	last_stim  = stim_times(end);
	stim_times = stim_times([diff(stim_times); NaN] > 120e3);
	stim_times = [stim_times; last_stim];





	for j = 1:length(stim_times)

		% figure out the temperature immediately after stim end
		stim_temp = round(mean(data(i).temperature(stim_times(j):stim_times(j)+5e3)));

		% when does the next stimulation occur? 
		next_stim = all_stim_times(find(all_stim_times>stim_times(j),1,'first'));

		% find out how long this temperature is maintained
		z = find(temperature(stim_times(j):next_stim) ~= stim_temp,1,'first') + stim_times(j);

		if isempty(z) && ~isempty(next_stim)
			% temperature maintained all the way to next stim
			z = next_stim - 1;
		elseif isempty(z) && isempty(next_stim)
			z = length(data(i).temperature);
		end

		if (z-stim_times(j))*1e-3 < 120
			% temperature held for less than 2 minutes
			continue
		end

		idx = ceil(((stim_temp - min_temp)/(max_temp - min_temp))*100);


		% get all burst periods in this duration

		burst_starts = data(i).LG_burst_starts;
		only_these = burst_starts > stim_times(j)*1e-3 & burst_starts < z*1e-3;

		if ~any(only_these)
			continue
		end

		time = burst_starts(only_these);
		time = time - time(1);
		time(time > 200) = NaN;

		Y = data(i).LG_burst_periods(only_these);
		Y(Y>30) = NaN;

		plot(ax.LG_burst_periods,xoffset + time, Y,'.','Color',c(idx,:),'MarkerSize',22);


	end

	xoffset = xoffset + 250;

	if i < length(data)
		plotlib.vertline(xoffset,'Color','k');
	end

end




% add a wee scale bar
plot(ax.LG_burst_periods,[100 200], [3 3],'k','LineWidth',3);


ax.LG_burst_periods.XColor = 'w';
ax.LG_burst_periods.YMinorGrid = 'on';
ax.LG_burst_periods.YMinorTick = 'on';
ylabel(ax.LG_burst_periods,'LG burst period (s)')


ax.LG_burst_periods.Position = [.13 .07 .7 .2];


set(ax.LG_burst_periods,'YScale','log','YLim',[3 30])
ax.LG_burst_periods.YTick = [3 6 10 20 30];

text(ax.LG_burst_periods,100,2.7,'100 s','FontSize',14)
