% the point of fig 1 is to show that spontaenous gastric rhythms can exist 
% at many temperatures, especially at high temperatures

close all
clearvars data ax

% load the example dataset

addpath('../')

C = crabsort(false);


C.path_name = '/Volumes/HYDROGEN/srinivas_data/temperature-data-for-embedding/830_116_2/';


file_names = {'0008','0015','0021','0025','0028','0030'};
all_temp = [11 15 19 23 27 30];


figure('outerposition',[300 300 1200 901],'PaperUnits','points','PaperSize',[1200 901]); hold on

c = colormaps.redula(100);
min_temp = 7;
max_temp = 30;

for i = 6:-1:1
	ax(i) = subplot(4,3,i); hold on

	C.file_name = ['830_116_' file_names{i} '.crab'];

	C.loadFile;

	lgn_channel = find(strcmp(C.common.data_channel_names,'lgn'));
	dgn_channel = find(strcmp(C.common.data_channel_names,'dgn'));

	lgn = C.raw_data(:,lgn_channel); 
	dgn = C.raw_data(:,dgn_channel);

	z = find(C.time>60,1,'first');

	lgn = lgn/abs(max(lgn(1:z)));
	dgn = dgn/abs(max(dgn(1:z)));


	idx = ceil(((all_temp(i) - min_temp)/(max_temp - min_temp))*100);


	

	plot(C.time(1:z), lgn(1:z) ,'Color',c(idx,:))
	plot(C.time(1:z), dgn(1:z)-2 ,'Color',c(idx,:))

	neurolib.raster(C.spikes.lgn.LG,'deltat',C.dt,'center',false,'Color',c(idx,:),'yoffset',1.1,'fill_fraction',.1)
	neurolib.raster(C.spikes.dgn.DG,'deltat',C.dt,'center',false,'Color',c(idx,:),'yoffset',-3,'fill_fraction',.1)

	set(gca,'XLim',[0 60])

	axis off

	title(ax(i),[mat2str(all_temp(i))   char(176) 'C'],'FontWeight','normal')




end

th = text(ax(1),-1,0,'lgn');
th.Position = [-10 0];


th = text(ax(1),-10,-2,'dgn');



% now show ISIs of LG to show all the data
data_root = '/Volumes/HYDROGEN/srinivas_data/temperature-data-for-embedding/';
data_files = {'845_070','828_086_2','828_114_2','828_128','830_100','830_116_2','830_116_1','830_120_1','834_022','834_086_2'};

H = hashlib.md5hash([data_files{:}]);

if exist([H '.cache'],'file') == 2
	load([H '.cache'],'-mat')
else

	clear data
	for i = length(data_files):-1:1
		data{i} = crabsort.consolidate('DataDir',[data_root data_files{i}],'neurons',{'LG'});
	end
	save([H '.cache'],'data');
end






% show spectrograms of LG spiking for all data
ax = gca;
ax(end+1) = subplot(2,1,2); hold on
ax(end).YScale = 'log';
ax(end).YLim = [1 100];

window_size = 100;
step_size = 10;
spike_bin = 1; % seconds

offset = 0;

for i = 1:length(data)


	this_data = data{i};

	S = zeros(100,length(this_data));


	for j = 1:length(this_data)
		spiketimes = sort(this_data(j).LG);

		if length(spiketimes) < 20
			continue
		end

		spiketimes = spiketimes - spiketimes(1);

		% round to the nearest 1/10 of a second
		spiketimes = ceil(spiketimes/spike_bin);
		spiketimes(spiketimes == 0) = 1;

		T = length(this_data(j).mask)*1e-3;

		if T < 50
			continue
		end


		X = zeros(ceil(T/spike_bin),1);
		X(spiketimes) = 1;


		[S(:,j), f] = spectrogram(X,length(X),[],logspace(-1.5,-.5,100),1./spike_bin,'yaxis');


	end



	S = abs(S);
	[val,idx] = max(S);
	bf = f(idx);
	bf(val < 1 ) = NaN;


	dominant_periods = 1./bf;
	dominant_periods(dominant_periods > [this_data.T]/2) = NaN;


	all_temp = [this_data.temperature];
	all_time = cumsum([this_data.T]);

	plot_this = isnan(all_temp);
	plot(i + randn(length(dominant_periods(plot_this)),1)*.05, dominant_periods(plot_this),'o','MarkerFaceColor',[.8 .8 .8],'MarkerEdgeColor',[.8 .8 .8],'MarkerSize',9)

	for j = 1:length(all_temp)
		if isnan(all_temp(j))
			continue
		else
			idx  = ceil(((all_temp(j) - min_temp)/(max_temp - min_temp))*100);
			idx(idx>length(c)) = length(c);
			idx(idx<1) = 1;
			plot(i + randn*.05, dominant_periods(j),'o','MarkerFaceColor',c(idx,:),'MarkerEdgeColor',c(idx,:),'MarkerSize',10)
			%text(i + randn*.05, dominant_periods(j), mat2str(all_temp(j)),'Color',c(idx,:),'FontWeight','bold')
		end

	end


	if any(dominant_periods > 27 & dominant_periods < 28)
		sfsd

	end



	plotlib.vertline(i+.5,'Color','k');





end

ax(end).XColor = 'w';


xlabel('Time (s)')
ylabel('Dominant period in LG (s)')

ch = colorbar;
caxis([min_temp max_temp])
colormap(c);
ch.Location = 'northoutside';
ch.Position = [.25 .05 .5 .015];
figlib.pretty('PlotLineWidth',1,'LineWidth',1)

ax(end).XLim(1) = 0.5;
ax(end).YLim = [2 50];
ax(end).YTick = [2 5 10 20 50];

title(ch,['Temperature ' char(176) '(C)'])

ax(end).YGrid = 'on';


figlib.pretty('PlotLineWidth',1,'LineWidth',1)

ax(end).YMinorTick = 'on';



% ax(end+1) = subplot(4,1,3); hold on
% set(gca,'YScale','log','YLim',[1e-3 1e3])
% offset = 0;
% for i = 1:length(data)
% 	this_data = data{i};
% 	for j = 1:length(this_data)
% 		spiketimes = sort(this_data(j).LG);
% 		if length(spiketimes) < 2
% 			continue
% 		end
% 		if this_data(j).decentralized
% 			continue
% 		end
% 		ds = [NaN; diff(spiketimes)];
% 		ds(ds<5e-3) = NaN;

% 		if isnan(this_data(j).temperature)

% 			plot(offset+spiketimes,ds,'.','Color',[.5 .5 .5])
% 		else
% 			idx = ceil(((this_data(j).temperature - min_temp)/(max_temp - min_temp))*100);
% 			plot(offset + spiketimes,ds,'.','Color',c(idx,:))
% 		end
% 		offset = offset + spiketimes(end);
% 	end
% 	offset = offset + 50;
% 	h = plotlib.vertline(offset);
% 	h.Color = 'k';

% end
% set(gca,'XColor','w')
% ylabel('LG ISI (s)')

% ch = colorbar;
% caxis([min_temp max_temp])
% title(ch,'Temperature (C)')
% ch.Position = [.88 .33 .01 .15];

% ax(end).Position = [.13 .33 .7 .15];














%% supplemental figure showing rasters

figure('outerposition',[300 300 901 1001],'PaperUnits','points','PaperSize',[901 1001]); hold on

ax = gca;

set(ax,'XLim',[0 60],'YColor','w')

offset = 0;
for i = 1:length(data)
	this_data = data{i};
	for j = 1:length(this_data)
		spiketimes = sort(this_data(j).LG);
		if length(spiketimes) < 2
			continue
		end
		if this_data(j).decentralized
			continue
		end

		if isnan(this_data(j).temperature)
			continue
		end

		if sum(spiketimes < 60) < 20
			continue
		end



		idx = ceil(((this_data(j).temperature - min_temp)/(max_temp - min_temp))*100);
		idx(idx>length(c)) = length(c);
			idx(idx<1) = 1;
		neurolib.raster(this_data(j).LG,'deltat',1,'yoffset',offset,'Color',c(idx,:),'center',true)

		offset = offset +  1;
	end

	offset = offset + 1;

	plotlib.horzline(offset-.5,'LineWidth',2,'Color','k');



end

xlabel('Time (s)')

ax.YLim(1) = -.5;
ch = colorbar;
colormap(c);
caxis([min_temp max_temp])
title(ch,'Temperature (C)')
ch.Position = [.88 .33 .01 .15];

ax.Position = [.1 .1 .7 .85];

figlib.pretty('PlotLineWidth',1)
