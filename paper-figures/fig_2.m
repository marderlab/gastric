%%
% This script makes figure 1, which shows that gastric rhythms can be evoked/exist at temperatures above 13C


close all

data_root = '/Volumes/HYDROGEN/srinivas_data/gastric-data';


%% Analysis of gastric and pyloric rhythms at different temperatures
% In this document we look at pyloric and gastric rhtyhms at differnet temperatures.
% This data is from Dan Powell and the experiments that go into this are:

include_these = {'901_086','901_046','901_049','901_052','901_062','901_080','901_095','901_098'};

disp(include_these')
clear data

if exist('dan_stacked_data.mat','file') == 2

	load('dan_stacked_data','data')
else
	for i = 1:length(include_these)
		data(i)  = crabsort.consolidate('neurons',{'PD','LG'},'DataFun',{@crabsort.getTemperature},'DataDir',[data_root filesep include_these{i}],'stack',true);
	end

	save('dan_stacked_data','data','-nocompression','-v7.3')

end





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
