
addpath('../')

close all
clearvars

data_root = '/Volumes/DATA/pyloric-data';


data = gastric.getEvokedData();


% compute burst metrics of all LG neurons
data = crabsort.computePeriods(data,'neurons',{'PD'},'ibis',.18,'min_spikes_per_burst',2);
data = crabsort.computePeriods(data,'neurons',{'LG'},'ibis',1,'min_spikes_per_burst',5);



% show raw traces of spontaenous vs. evoked 
figure('outerposition',[300 300 1200 802],'PaperUnits','points','PaperSize',[1200 802]); hold on

spont_files = {'941_006','901_086','901_080','901_062'};
evoked_files = {'0029','0032','0012','0020'};

clear ax
for i = 1
	ax.raw_data_spont(i) = subplot(2,2,(i-1)*2 + 1); hold on;
	ax.raw_data_evoked(i) = subplot(2,2,(i-1)*2 + 2); hold on;
	set(ax.raw_data_evoked(i),'XLim',[0 30],'YTick',[],'YLim',[0 4.5],'YColor','w')
	set(ax.raw_data_spont(i),'XLim',[0 30],'YTick',[],'YLim',[0 4.5],'YColor','w')
	ax.raw_data_spont(i).XTick = [];
	ax.raw_data_spont(i).XColor = 'w';
	ax.raw_data_evoked(i).XTick = [];
	ax.raw_data_evoked(i).XColor = 'w';

	ax.raw_data_spont(i).Position(1) = .1;
	ax.raw_data_spont(i).Position(3) = .39;
	ax.raw_data_evoked(i).Position(1) = .51;
	ax.raw_data_evoked(i).Position(3) = .39;

	ax.raw_data_spont(i).Position(4) = .35;
	ax.raw_data_evoked(i).Position(4) = .35;

end

ax.isi = subplot(2,2,3); hold on
ax.isi.Position = [.1 .1 .5 .4];
ax.isi.YScale = 'log';
ax.isi.YLim = [1e-3 1e3];

offset = 0;

clear spont_T evoked_T

show_these_channels = {'pdn','mvn','dgn','lgn'};

for i = 1:length(spont_files)


	C = crabsort(false);
	C.path_name = fullfile(data_root, 'powell',spont_files{i});

		
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
	if i == 1
		for j = 1:size(raw_data,2)
			plot(ax.raw_data_spont(i),time,raw_data(:,j)+j,'Color','k');
			th = text(ax.raw_data_spont(i),-1,0,['\it ' show_these_channels{j}]);
			th.Position = [-3 j];
		end
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
	if i == 1
		for j = 1:size(raw_data,2)
			plot(ax.raw_data_evoked(i),time,raw_data(:,j)+j,'Color','b');
		end
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


end



title(ax.raw_data_evoked(1),'Evoked')
title(ax.raw_data_spont(1),'Spontaneous')







% plot spontanous vs. evoked burst periods in LG

for i = 1:length(spont_T)
	spont_T(i).M = nanmean(spont_T(i).LG_burst_periods);
	spont_T(i).S = nanstd(spont_T(i).LG_burst_periods);
	evoked_T(i).M = nanmean(evoked_T(i).LG_burst_periods);
	evoked_T(i).S = nanstd(evoked_T(i).LG_burst_periods);
end




ax.compare = subplot(2,3,6); hold on


errorbar(ax.compare, [spont_T.M],[evoked_T.M],[evoked_T.S]/2,[evoked_T.S]/2,[spont_T.S]/2,[spont_T.S]/2,'ko')

plotlib.drawDiag;

axis square
ylabel('Evoked period (s)')
xlabel(['Spontaneous' newline 'period (s)'])



ylabel(ax.isi,'LG ISI (s)')
ax.isi.XLim(1) = 0;

figlib.pretty('PlotLineWidth',1)

ax.compare.YColor = 'b';

set(ax.compare,'XScale','linear','YScale','linear','XLim',[-2 25],'YLim',[-2 25])


axlib.separate(ax.compare,'Offset',.01);
axlib.separate(ax.isi);

ax.isi.XLim = [-20 1e3];
ax.compare.Position = [.7 .1 .15 .125];

ax.isi.XColor = 'w';
ax.isi.XTick = [];

ax.isi.Position = [.1 .1 .5 .35];
ax.compare.Position = [.6 .15 .35 .35];

plot(ax.raw_data_spont(1),[20 30],[0 0],'LineWidth',3,'Color','k');


th = text(ax.isi,400,2500,'Preparation');
th.FontSize = 18;


th = text(ax.isi,100,290,'1','FontSize',18);
th = text(ax.isi,350,290,'2','FontSize',18);
th = text(ax.isi,600,290,'3','FontSize',18);
th = text(ax.isi,850,290,'4','FontSize',18);

th = text(ax.raw_data_spont,24,-.25,'10 s','FontSize',18);

try
	figlib.saveall('Location',  '/Users/srinivas/Dropbox/Temp-Paper/Temperature-Paper/individual-figures','SaveName',mfilename)
catch

end

plot(ax.isi,[100 120],[5e-3,5e-3],'LineWidth',3,'Color','k')
th = text(ax.isi,100,4e-3,'20s','FontSize',18);
th.Position = [90 2e-3];

axlib.label(ax.raw_data_spont,'a','FontSize',24,'XOffset',-.03,'YOffset',-.01);
axlib.label(ax.isi,'b','FontSize',24,'XOffset',-.03,'YOffset',-.01);
h = axlib.label(ax.compare,'c','FontSize',24,'XOffset',0,'YOffset',-.01);