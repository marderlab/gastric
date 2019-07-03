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

c = colormaps.redula(100);
min_temp = 5;
max_temp = 23;

for i = 6:-1:1
	ax(i) = subplot(5,3,i); hold on

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

	title(ax(i),[mat2str(this_temp) char(176) 'C'],'FontWeight','normal')




end

th = text(ax(1),-1,0,'lgn');
th.Position = [-10 0];


th = text(ax(1),-10,-2,'dgn');




% show burst periods of LG

data = crabsort.computePeriods(data,'neurons',{'LG'},'ibis',1,'min_spikes_per_burst',7);

% make an axes to show rasters
ax(end+1) = subplot(5,3,7:12); hold on


ax(end+1) = subplot(5,3,13:15); hold on
set(ax(end),'YLim',[1 100],'YScale','log')


xoffset = 0;


for i = 1:length(data)

	temperature = round(data(i).temperature);

	all_stim_times = find(data(i).mask == 0);
	stim_times = find(data(i).mask == 0);
	last_stim  = stim_times(end);
	stim_times = stim_times([diff(stim_times); NaN] > 120e3);
	stim_times = [stim_times; last_stim];



	yoffset = 0;

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

		if i == 2

			these_spikes = (data(i).LG(data(i).LG > stim_times(j)*1e-3 & data(i).LG < z*1e-3));
			
			neurolib.raster(ax(end-1),these_spikes,'Color',c(idx,:),'deltat',1,'yoffset',yoffset)

			yoffset = yoffset - 1;
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

		plot(ax(end),xoffset + time, Y,'Color',c(idx,:));


	end

	xoffset = xoffset + 250;

	plotlib.vertline(xoffset,'Color','k');

end





set(ax(end-1),'XLim',[0 200])
ax(end-1).YLim = [-8 1];
axis(ax(end-1),'off')
ax(end-1).Position = [.13 .4 .775 .2];


figlib.pretty('PlotLineWidth',1,'LineWidth',1)


ax(end).Position = [.13 .11 .7 .25];
ax(end).XColor = 'w';
ax(end).YMinorGrid = 'on';
ax(end).YMinorTick = 'on';



ylabel(ax(end),'LG burst period (s)')


ch = colorbar(ax(end));
colormap(ch,colormaps.redula);
title(ch,['Temperature'  char(176) '(C)'])
ch.Position = [.88 .1 .01 .25];
caxis([min_temp max_temp])










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