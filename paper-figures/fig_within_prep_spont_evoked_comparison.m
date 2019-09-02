

close all
clearvars

data_root = '/Volumes/DATA/gastric-data';


data = gastric.getEvokedData();


% compute burst metrics of all LG neurons
data = crabsort.computePeriods(data,'neurons',{'PD'},'ibis',.18,'min_spikes_per_burst',2);
data = crabsort.computePeriods(data,'neurons',{'LG'},'ibis',1,'min_spikes_per_burst',5);



% show raw traces of spontaenous vs. evoked 
figure('outerposition',[300 300 1200 1333],'PaperUnits','points','PaperSize',[1200 1333]); hold on

spont_files = {'941_006','901_086','901_080','901_062'};
evoked_files = {'0029','0032','0012','0020'};

clear ax
for i = 1:length(spont_files)
	ax.raw_data_spont(i) = subplot(5,2,(i-1)*2 + 1); hold on;
	ax.raw_data_evoked(i) = subplot(5,2,(i-1)*2 + 2); hold on;
end

ax.isi = subplot(5,2,9); hold on
ax.isi.Position = [.1 .1 .5 .1];
ax.isi.YScale = 'log';
ax.isi.YLim = [1e-3 1e3];

offset = 0;

clear spont_T evoked_T

show_these_channels = {'lvn','pdn','mvn','dgn','lgn'};

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


	for j = length(show_these_channels):-1:1
		channel_idx(j) = find(strcmp(C.common.data_channel_names,show_these_channels{j}));
	end


	raw_data = C.raw_data(:,channel_idx);
	time = C.time;

	% normalize
	z = find(time>60,1,'first');

	for j = 1:size(raw_data,2)
		raw_data(:,j) = raw_data(:,j)/max(2*abs(raw_data(1:z,j)));
	end

	% start traces when LG starts bursting
	start_here = time(C.spikes.lgn.LG(find(diff(C.spikes.lgn.LG)>1e4,1,'first') + 1));
	time = time - start_here;
	

	% show raw_data
	for j = 1:size(raw_data,2)
		plot(ax.raw_data_spont(i),time,raw_data(:,j)+j,'Color','k');
		th = text(ax.raw_data_spont(i),-1,0,['\it ' show_these_channels{j}]);
		th.Position = [-3 j];
	end


	% plot the ISIs
	spiketimes = sort(C.spikes.lgn.LG)*C.dt;
	ds = [NaN; diff(spiketimes)];
	ds(ds<5e-3) = NaN;
	plot(ax.isi,offset + spiketimes,ds,'k.')
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

	for j = length(show_these_channels):-1:1
		channel_idx(j) = find(strcmp(C.common.data_channel_names,show_these_channels{j}));
	end


	raw_data = C.raw_data(:,channel_idx);
	time = C.time;

	% normalize
	z = find(time>60,1,'first');

	for j = 1:size(raw_data,2)
		raw_data(:,j) = raw_data(:,j)/max(2*abs(raw_data(1:z,j)));
	end

	% start traces when LG starts bursting
	start_here = time(C.spikes.lgn.LG(find(diff(C.spikes.lgn.LG)>1e4,1,'first') + 1));
	time = time - start_here;
	

	% show raw_data
	for j = 1:size(raw_data,2)
		plot(ax.raw_data_evoked(i),time,raw_data(:,j)+j,'Color','b');
	end



	% plot the ISIs
	spiketimes = sort(C.spikes.lgn.LG)*C.dt;
	ds = [NaN; diff(spiketimes)];
	ds(ds<5e-3) = NaN;
	plot(ax.isi,offset + spiketimes,ds,'b.')
	offset = offset + spiketimes(end) + 2;

	% compute periods
	evoked_T(i) = crabsort.computePeriods(struct('LG',spiketimes),'neurons',{'LG'},'ibis',1);


	h = plotlib.vertline(ax.isi,offset);
	h.Color = 'k';


	set(ax.raw_data_evoked(i),'XLim',[0 30],'YTick',[],'YLim',[0 6],'YColor','w')
	set(ax.raw_data_spont(i),'XLim',[0 30],'YTick',[],'YLim',[0 6],'YColor','w')

	if i < 4
		ax.raw_data_spont(i).XTick = [];
		ax.raw_data_spont(i).XColor = 'w';
		ax.raw_data_evoked(i).XTick = [];
		ax.raw_data_evoked(i).XColor = 'w';
	end

end

title(ax.raw_data_evoked(1),'Evoked')
title(ax.raw_data_spont(1),'Spontaneous')


for i = 1:4
	ax.raw_data_spont(i).Position(1) = .1;
	ax.raw_data_spont(i).Position(3) = .39;
	ax.raw_data_evoked(i).Position(1) = .51;
	ax.raw_data_evoked(i).Position(3) = .39;

	ax.raw_data_spont(i).Position(4) = .17;
	ax.raw_data_evoked(i).Position(4) = .17;
end






% plot spontanous vs. evoked burst periods in LG

for i = 1:length(spont_T)
	spont_T(i).M = nanmean(spont_T(i).LG_burst_periods);
	spont_T(i).S = nanstd(spont_T(i).LG_burst_periods);
	evoked_T(i).M = nanmean(evoked_T(i).LG_burst_periods);
	evoked_T(i).S = nanstd(evoked_T(i).LG_burst_periods);
end




ax.compare = subplot(5,4,20); hold on


errorbar(ax.compare, [spont_T.M],[evoked_T.M],[evoked_T.S]/2,[evoked_T.S]/2,[spont_T.S]/2,[spont_T.S]/2,'ko')

plotlib.drawDiag;

axis square
xlabel('Evoked period (s)')
ylabel('Spontaneous period (s)')

ax.compare.XColor = 'b';


ylabel(ax.isi,'LG ISI (s)')
ax.isi.XLim(1) = 0;

figlib.pretty('PlotLineWidth',1)

set(ax.compare,'XScale','linear','YScale','linear','XLim',[-2 25],'YLim',[-2 25])


axlib.separate(ax.compare);
axlib.separate(ax.isi);

ax.isi.XLim = [-20 1e3];
ax.compare.Position = [.7 .1 .15 .125];

ax.isi.XColor = 'w';
ax.isi.XTick = [];