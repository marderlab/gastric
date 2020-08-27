% the point of fig 1 is to show that spontaenous gastric rhythms can exist 
% at many temperatures, especially at high temperatures

close all
clearvars data ax

% load the example dataset

addpath('../')

C = crabsort(false);


try data_root = getpref('gastric','data_loc');
catch
	error('You need to tell this script where you data is located using setpref ')
end
C.path_name = fullfile(fileparts(fileparts(data_root)), 'haddad','830_116_2' );


file_names = {'0008','0015','0021','0025','0028','0030'};
all_temp = [11 15 19 23 27 30];


figure('outerposition',[0 0 1200 1301],'PaperUnits','points','PaperSize',[1200 1301]); hold on

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

	set(gca,'XLim',[C.time(a) C.time(z)])

	axis off

	title(ax(i),[mat2str(all_temp(i))   char(176) 'C'],'FontWeight','normal')




end

l = axlib.label(ax(1),'a','FontSize',30,'YOffset',-.01);


plot(ax(6),[50 60],[-3 -3],'k','LineWidth',3);
thtime = text(ax(6),50,-3.5,'10 s');

th = text(ax(1),-1,0,'\itlgn');
th.Position = [-10 0];


th = text(ax(1),-10,-2,'\itdgn');


% now show rasters
data_files = {'830_120_1','830_116_2'};

H = hashlib.md5hash([data_files{:}]);

if exist([H '.cache'],'file') == 2
	load([H '.cache'],'-mat')
else

	clear data
	for i = length(data_files):-1:1
		data{i} = crabsort.consolidate(data_files{i},'neurons',{'LG'},'RebuildCache',true);
	end
	save([H '.cache'],'data');
end



ax = subplot(2,1,2); hold on


gastric.plotLGRasters(data,ax,min_temp,max_temp);

xlabel('Time (s)')
ax.YDir = 'reverse';
ax.YLim(1) = -.5;
ch = colorbar;
colormap(c);
caxis([min_temp max_temp])
title(ch,gastric.tempLabel)
ch.Position = [.9 .23 .01 .15];



time_scale = plot(ax,[110 120],[0 0],'k','LineWidth',3);

figlib.pretty('PlotLineWidth',1)

ax.Position = [.13 .1 .7 .4];


aLG = annotation('textarrow',[0.3 0.5],[0.6 0.5],'String','LG');
aLG.Position = [.12 .955 .016 -0.0355];
aLG.FontSize = 16;

aDG = annotation('textarrow',[0.3 0.5],[0.6 0.5],'String','DG');
aDG.Position = [0.1524    0.7426    0.0125    0.0251];
aDG.FontSize = 16;




th = text(ax,ax.XLim(2)-6,-4,'10s');
th.FontSize = 20;

th = text(ax,0, 30,'Preparation 1','FontSize',18,'Rotation',90);
th.Position = [-3 30];

th = text(ax,-3, 79,'Preparation 2','FontSize',18,'Rotation',90);

ch.YDir = 'reverse';


axlib.label(ax,'b','FontSize',30,'YOffset',-.01)
figlib.saveall('Location',pwd,'SaveName',mfilename)








% supplementary figure showing all other preps

clear data

data_files = {'828_086_2','828_114_2','828_128','830_100','830_116_1','834_022','834_086_2'};


H = hashlib.md5hash([data_files{:}]);

if exist([H '.cache'],'file') == 2
	load([H '.cache'],'-mat')
else

	clear data
	for i = length(data_files):-1:1
		data{i} = crabsort.consolidate(data_files{i},'neurons',{'LG'},'RebuildCache',true);
	end
	save([H '.cache'],'data');
end




figure('outerposition',[300 300 888 1111],'PaperUnits','points','PaperSize',[888 1111]); hold on

ax = gca;

gastric.plotLGRasters(data,ax,min_temp,max_temp,5);


set(ax,'XLim',[0 120],'YColor','w','XColor','w')


xlabel('Time (s)')
ax.YDir = 'reverse';
ax.YLim(1) = -.5;
ch = colorbar;
colormap(c);
caxis([min_temp max_temp])
title(ch,gastric.tempLabel)
ch.Position = [.91 .23 .01 .15];
yy = get(gca,'YLim');
yy = yy(2);
time_scale = plot(ax,[110 120],[130 130],'k','LineWidth',3);
ch.YDir = 'reverse'

figlib.pretty('PlotLineWidth',1)


ax.Position = [.06 .11 .77 .8];

th = text(112,134,'10s')
th.FontSize = 20;

try
	figlib.saveall('Location',  '/Users/srinivas/Dropbox/Temp-Paper/Temperature-Paper/individual-figures','SaveName',mfilename)
catch

end




return













th = text(ax,ax.XLim(2)-6,-4,'10s');
th.FontSize = 20;

th = text(ax,0, 30,'Preparation 1','FontSize',18,'Rotation',90);
th.Position = [-3 30];

th = text(ax,-3, 79,'Preparation 2','FontSize',18,'Rotation',90);

ch.YDir = 'reverse';


axlib.label(ax,'b','FontSize',30,'YOffset',-.01)
figlib.saveall('Location',pwd,'SaveName',mfilename)









return


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









