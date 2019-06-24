%%
% This script makes figure 1, which shows that gastric rhythms can be evoked/exist at temperatures above 13C


close all
addpath('../')

data_root = '/Volumes/HYDROGEN/srinivas_data/gastric-data';


%% Analysis of gastric and pyloric rhythms at different temperatures
% In this document we look at pyloric and gastric rhtyhms at differnet temperatures.
% This data is from Dan Powell and the experiments that go into this are:

data = gastric.getEvokedData();




C = crabsort(false);
C.path_name = [data_root filesep '901_046'];

show_these = {'0006','0027','0054','0069','0072','0079'};



figure('outerposition',[300 300 1200 901],'PaperUnits','points','PaperSize',[1200 901]); hold on

c = parula(100);
min_temp = 5;
max_temp = 35;

for i = 6:-1:1
	ax(i) = subplot(4,3,i); hold on

	C.file_name = ['901_046_' show_these{i} '.abf'];

	C.loadFile;

	lgn_channel = find(strcmp(C.common.data_channel_names,'lgn'));
	dgn_channel = find(strcmp(C.common.data_channel_names,'dgn'));

	lgn = C.raw_data(:,lgn_channel); 
	dgn = C.raw_data(:,dgn_channel);

	z = find(C.time>60,1,'first');

	lgn = lgn/max(1.1*abs(lgn(1:z)));
	dgn = dgn/max(1.1*abs(dgn(1:z)));


	this_temp = round(mean(C.raw_data(:,strcmp(C.common.data_channel_names,'temperature'))));
	idx = ceil(((this_temp - min_temp)/(max_temp - min_temp))*100);


	

	plot(C.time(1:z), lgn(1:z) ,'Color',c(idx,:))
	plot(C.time(1:z), dgn(1:z)-2 ,'Color',c(idx,:))

	neurolib.raster(C.spikes.lgn.LG,'deltat',C.dt,'center',false,'Color',c(idx,:),'yoffset',1.1,'fill_fraction',.1)
	neurolib.raster(C.spikes.dgn.DG,'deltat',C.dt,'center',false,'Color',c(idx,:),'yoffset',-3,'fill_fraction',.1)

	set(gca,'XLim',[0 60])

	axis off

	title(ax(i),[mat2str(this_temp) 'C'],'FontWeight','normal')




end

th = text(ax(1),-1,0,'lgn');
th.Position = [-10 0];


th = text(ax(1),-10,-2,'dgn');




% now show ISIs of LG to show all the data

ax(end+1) = subplot(4,1,3); hold on
set(gca,'YScale','log','YLim',[1e-3 1e3])
offset = 0;
for i = 1:length(data)

	spiketimes = sort(data(i).LG);

	round_temp = round(data(i).temperature);
	round_temp = round_temp(round(spiketimes*1e3));

	
	ds = [NaN; diff(spiketimes)];
	ds(ds<5e-3) = NaN;

	for this_temp = min_temp:max_temp

		plot_this = (round_temp == this_temp);

		idx = ceil(((this_temp - min_temp)/(max_temp - min_temp))*100);
		if idx == 0
			idx = 1;
		end

		plot(offset + spiketimes(plot_this),ds(plot_this),'.','Color',c(idx,:))

	end

	offset = offset + spiketimes(end);

	offset = offset + 50;
	h = plotlib.vertline(offset);
	h.Color = 'k';

end


set(gca,'XColor','w')
ylabel('LG ISI (s)')

ch = colorbar;
caxis([min_temp max_temp])
title(ch,'Temperature (C)')
ch.Position = [.88 .33 .01 .15];

ax(end).Position = [.13 .33 .7 .15];

figlib.pretty('PlotLineWidth',1)





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
	plot(ax(i),C.time,lgn-2.5,'r');

	
	neurolib.raster(ax(i),C.spikes.lgn.LG,'deltat',C.dt,'center',false,'Color','r','yoffset',-3.7,'fill_fraction',.1)


	% plot the ISIs
	spiketimes = sort(C.spikes.lgn.LG)*C.dt;
	ds = [NaN; diff(spiketimes)];
	ds(ds<5e-3) = NaN;
	plot(ax_isi,offset + spiketimes,ds,'r.')
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
ph(2) = plot(NaN,NaN,'o','Color','r','MarkerFaceColor','r');
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
ax_compare.XColor = 'r';


ylabel(ax_isi,'LG ISI (s)')
ax_isi.XLim(1) = 0;

figlib.pretty('PlotLineWidth',1)

set(ax_compare,'XScale','linear','YScale','linear','XLim',[-2 25],'YLim',[-2 25])
ax_isi.Position = [.13 .11 .5 .21];

axlib.separate(ax_compare)
axlib.separate(ax_isi)

ax_isi.XLim = [-20 1e3];