%%
% This script makes figure 1, which shows that gastric rhythms can be evoked/exist at temperatures above 13C


close all
addpath('../')

data_root = '/Volumes/HYDROGEN/srinivas_data/gastric-data';


%% Analysis of gastric and pyloric rhythms at different temperatures
% In this document we look at pyloric and gastric rhtyhms at differnet temperatures.
% This data is from Dan Powell and the experiments that go into this are:

data = gastric.getEvokedData();

example_data = '901_049';


C = crabsort(false);
C.path_name = [data_root filesep char(example_data)];

show_these = {'0004','0039'};



figure('outerposition',[300 300 1200 1300],'PaperUnits','points','PaperSize',[1200 1300]); hold on

c = colormaps.redula(100);
min_temp = 5;
max_temp = 23;

show_these_channels = {'lvn','pdn','mvn','dgn','lgn','ogn'};


clear ax
ax.raw_data(1) = subplot(4,1,1); hold on
ax.raw_data(2) = subplot(4,1,2); hold on


for i = 1:length(show_these)

	C.file_name = [char(example_data) '_' show_these{i} '.crab'];
	C.loadFile;

	for j = length(show_these_channels):-1:1
		channel_idx(j) = find(strcmp(C.common.data_channel_names,show_these_channels{j}));
	end

	this_temp = round(mean(C.raw_data(:,strcmp(C.common.data_channel_names,'temperature'))));
	idx = ceil(((this_temp - min_temp)/(max_temp - min_temp))*100);

	raw_data = C.raw_data(:,channel_idx);
	time = C.time;

	% normalize
	z = find(time>60,1,'first');

	for j = 1:size(raw_data,2)
		raw_data(:,j) = raw_data(:,j)/max(2*abs(raw_data(1:z,j)));
	end
	

	% show raw_data
	for j = 1:size(raw_data,2)
		plot(ax.raw_data(i),time,raw_data(:,j)+j,'Color',c(idx,:));
		th = text(ax.raw_data(i),-1,0,show_these_channels{j});
		th.Position = [-3 j];
	end

	set(ax.raw_data(i),'XLim',[0 60],'YColor','w')


	ax.raw_data(i).XColor = 'w';
	ax.raw_data(i).XTick = [];


end



% show burst periods of LG

data = crabsort.computePeriods(data,'neurons',{'LG'},'ibis',1,'min_spikes_per_burst',7);

% make an axes to show rasters
ax.rasters = subplot(4,1,3); hold on


ax.LG_burst_periods = subplot(4,1,4); hold on
set(ax.LG_burst_periods,'YLim',[1 100],'YScale','log')


xoffset = 0;

show_neuron_rasters = {'LG','DG'};
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

		if data(i).experiment_idx == example_data


			for k = 1:length(show_neuron_rasters)
				these_spikes = data(i).(show_neuron_rasters{k});
				these_spikes(these_spikes < stim_times(j)*1e-3) = [];
				these_spikes(these_spikes > z*1e-3) = [];

				if k == 1
					this_file_name = data(i).filename(these_spikes(100)*1e3);
					rx = find(data(i).filename == this_file_name,1,'first')*1e-3;
				end
				rx
				these_spikes = these_spikes - rx;

				neurolib.raster(ax.rasters,these_spikes,'Color',c(idx,:),'deltat',1,'yoffset',yoffset,'center',false,'fill_fraction',.75)
				yoffset = yoffset - 1;
			end
			yoffset = yoffset - .5;



		end


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

		plot(ax.LG_burst_periods,xoffset + time, Y,'Color',c(idx,:));


	end

	xoffset = xoffset + 250;

	plotlib.vertline(xoffset,'Color','k');

end


set(ax.rasters,'XLim',[0 60],'YLim',[yoffset-1, 1])



ax.rasters.YTick = [];
ax.rasters.YLim = [-12 1];
ax.rasters.YColor = 'w';


xlabel(ax.rasters,'Time (s)')


ax.LG_burst_periods.XColor = 'w';
ax.LG_burst_periods.YMinorGrid = 'on';
ax.LG_burst_periods.YMinorTick = 'on';
ylabel(ax.LG_burst_periods,'LG burst period (s)')



ch = colorbar(ax.LG_burst_periods);
colormap(ch,colormaps.redula);
title(ch,['Temperature'  char(176) '(C)'])
ch.Position = [.88 .07 .01 .18];
caxis([min_temp max_temp])

ax.LG_burst_periods.Position = [.13 .07 .7 .2];

ax.raw_data(1).Position = [.13 .75 .775 .2];
ax.raw_data(2).Position = [.13 .525 .775 .2];

figlib.pretty('PlotLineWidth',1,'LineWidth',1)
return
















%% Suplemental figures
% In these supplemental figures we compare spontaneous to elicited rhythms in the same preps


% compute burst metrics of all LG neurons
data = crabsort.computePeriods(data,'neurons',{'PD'},'ibis',.18,'min_spikes_per_burst',2);
data = crabsort.computePeriods(data,'neurons',{'LG'},'ibis',1,'min_spikes_per_burst',5);



% show raw traces of spontaenous vs. evoked 
figure('outerposition',[300 300 1200 900],'PaperUnits','points','PaperSize',[1200 900]); hold on

spont_files = {'941_006','901_086','901_080','901_062'};
evoked_files = {'0029','0032','0012','0020'};


for i = 1:length(spont_files)
	ax(i) = subplot(3,2,i); hold on;
end

ax_isi = subplot(3,2,5); hold on;
set(ax_isi,'YScale','log','YLim',[1e-3 1e3])

offset = 0;

clear spont_T evoked_T

for i = 1:length(spont_files)


	C = crabsort(false);
	C.path_name = [data_root filesep spont_files{i}];

		
	if exist([C.path_name spont_files{i} '_0000.abf'],'file')
		C.file_name = [spont_files{i} '_0000.abf'];
		C.loadFile;
	else
		C.file_name = [spont_files{i} '_0000.crab'];
		C.loadFile;
	end


	

	lgn = C.raw_data(:,strcmp(C.common.data_channel_names,'lgn'));
	z = find(C.time>60,1,'first');
	lgn = lgn/max(abs(lgn(1:z)));
	plot(ax(i),C.time,lgn,'k');

	
	neurolib.raster(ax(i),C.spikes.lgn.LG,'deltat',C.dt,'center',false,'Color','k','yoffset',-1.2,'fill_fraction',.1)


	% plot the ISIs
	spiketimes = sort(C.spikes.lgn.LG)*C.dt;
	ds = [NaN; diff(spiketimes)];
	ds(ds<5e-3) = NaN;
	plot(ax_isi,offset + spiketimes,ds,'k.')
	offset = offset + spiketimes(end);


	% compute periods
	spont_T(i) = crabsort.computePeriods(struct('LG',spiketimes),'neurons',{'LG'},'ibis',1);


	% now show evoked rhythms at the same temperatures

	if exist([C.path_name spont_files{i} '_' evoked_files{i} '.abf'],'file')
		C.file_name = [spont_files{i} '_' evoked_files{i} '.abf'];
		C.loadFile;
	else
		C.file_name = [spont_files{i} '_' evoked_files{i} '.crab'];
		C.loadFile;
	end

	lgn = C.raw_data(:,strcmp(C.common.data_channel_names,'lgn'));
	z = find(C.time>60,1,'first');
	lgn = lgn/max(abs(lgn(1:z)));
	plot(ax(i),C.time,lgn-2.5,'b');

	
	neurolib.raster(ax(i),C.spikes.lgn.LG,'deltat',C.dt,'center',false,'Color','b','yoffset',-3.7,'fill_fraction',.1)


	% plot the ISIs
	spiketimes = sort(C.spikes.lgn.LG)*C.dt;
	ds = [NaN; diff(spiketimes)];
	ds(ds<5e-3) = NaN;
	plot(ax_isi,offset + spiketimes,ds,'b.')
	offset = offset + spiketimes(end) + 2;

	% compute periods
	evoked_T(i) = crabsort.computePeriods(struct('LG',spiketimes),'neurons',{'LG'},'ibis',1);


	h = plotlib.vertline(offset);
	h.Color = 'k';


	set(ax(i),'XLim',[0 60],'YTick',[],'YLim',[-4 1],'YColor','w')

	if i < 3
		set(ax(i),'XColor','w','YColor','w')
	else
		xlabel('Time (s)')
	end

	if rem(i,2) == 1
		text(ax(i),-10,0,'lgn');
		text(ax(i),-10,-2.5,'lgn');

	end






end

clear ph 
ph(1) = plot(NaN,NaN,'o','Color','k','MarkerFaceColor','k');
ph(2) = plot(NaN,NaN,'o','Color','b','MarkerFaceColor','b');
lh = legend(ph,{'Spontaneous','Evoked'});
lh.Position = [.15 .65 .11 .05];






% plot spontanous vs. evoked burst periods in LG

for i = 1:length(spont_T)
	spont_T(i).M = nanmean(spont_T(i).LG_burst_periods);
	spont_T(i).S = nanstd(spont_T(i).LG_burst_periods);
	evoked_T(i).M = nanmean(evoked_T(i).LG_burst_periods);
	evoked_T(i).S = nanstd(evoked_T(i).LG_burst_periods);
end


ax_compare = subplot(3,2,6); hold on


errorbar(ax_compare, [spont_T.M],[evoked_T.M],[evoked_T.S]/2,[evoked_T.S]/2,[spont_T.S]/2,[spont_T.S]/2,'ko')

plotlib.drawDiag;

axis square
xlabel('Evoked period (s)')
ylabel('Spontaneous period (s)')

ax_compare.Position = [.65 .11 .33 .21];
ax_compare.XColor = 'b';


ylabel(ax_isi,'LG ISI (s)')
ax_isi.XLim(1) = 0;

figlib.pretty('PlotLineWidth',1)

set(ax_compare,'XScale','linear','YScale','linear','XLim',[-2 25],'YLim',[-2 25])
ax_isi.Position = [.13 .11 .5 .21];

axlib.separate(ax_compare);
axlib.separate(ax_isi);

ax_isi.XLim = [-20 1e3];