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


figure('outerposition',[0 0 1200 901],'PaperUnits','points','PaperSize',[1200 901]); hold on

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

	a = C.spikes.lgn.LG(1);
	z = a + 60e4;

	lgn = lgn/abs(max(lgn(a:z)));
	dgn = dgn/abs(max(dgn(a:z)));


	idx = ceil(((all_temp(i) - min_temp)/(max_temp - min_temp))*100);


	

	plot(C.time(a:z), lgn(a:z) ,'Color',c(idx,:))
	plot(C.time(a:z), dgn(a:z)-2 ,'Color',c(idx,:))

	% neurolib.raster(C.spikes.lgn.LG,'deltat',C.dt,'center',false,'Color',c(idx,:),'yoffset',1.1,'fill_fraction',.1)
	% neurolib.raster(C.spikes.dgn.DG,'deltat',C.dt,'center',false,'Color',c(idx,:),'yoffset',-3,'fill_fraction',.1)

	set(gca,'XLim',[C.time(a) C.time(z)])

	axis off

	title(ax(i),[mat2str(all_temp(i))   char(176) 'C'],'FontWeight','normal')




end

plot(ax(6),[50 60],[-3 -3],'k','LineWidth',3);
thtime = text(ax(6),50,-3.5,'10 s');

th = text(ax(1),-1,0,'\itlgn');
th.Position = [-10 0];


th = text(ax(1),-10,-2,'\itdgn');




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



% interpolate temperatures because Sara didn't record temperatures
% for all files 

for i = 1:length(data)
	last_temp = NaN;
	for j = 1:length(data{i})
		if ~isnan(data{i}(j).temperature)
			last_temp = data{i}(j).temperature;
		else
			data{i}(j).temperature = last_temp;
		end

	end
end



% show dominant period of LG bursting for all data
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
			plot(i + randn*.1, dominant_periods(j),'o','MarkerFaceColor',c(idx,:),'MarkerEdgeColor',c(idx,:),'MarkerSize',10)

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

title(ch,gastric.tempLabel)

ax(end).YGrid = 'on';


figlib.pretty('PlotLineWidth',1,'LineWidth',1)

ax(end).YMinorTick = 'on';

colormap(colormaps.redula(23))












%% supplemental figure showing rasters

figure('outerposition',[300 300 901 1001],'PaperUnits','points','PaperSize',[901 1001]); hold on

ax = gca;

set(ax,'XLim',[0 30],'YColor','w')

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

	offset = offset + 3;

	plotlib.horzline(offset-.5,'LineWidth',1,'Color','k');



end

xlabel('Time (s)')

ax.YLim(1) = -.5;
ch = colorbar;
colormap(c);
caxis([min_temp max_temp])
title(ch,gastric.tempLabel)
ch.Position = [.88 .33 .01 .15];

ax.Position = [.1 .1 .7 .85];

figlib.pretty('PlotLineWidth',1)



figlib.saveall('Location',pwd,'SaveName',mfilename)