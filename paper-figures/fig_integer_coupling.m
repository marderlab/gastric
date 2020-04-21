%%
% This figure shows that integer coupling persists across temperatures

clearvars
close all
addpath('../')


%% Analysis of gastric and pyloric rhythms at different temperatures
% In this document we look at pyloric and gastric rhtyhms at differnet temperatures.
% This data is from Dan Powell and the experiments that go into this are:

data = gastric.getEvokedData();



% compute burst metrics of all LG neurons
data = crabsort.computePeriods(data,'neurons',{'PD'},'ibis',.18,'min_spikes_per_burst',2);
data = crabsort.computePeriods(data,'neurons',{'LG'},'ibis',1,'min_spikes_per_burst',5);
data = crabsort.computePeriods(data,'neurons',{'DG'},'ibis',1,'min_spikes_per_burst',5);





%% Integer coupling b/w PD and LG periods
% The periods of PD and LG neurons have previously been shown the be integer-coupled, that is, the LG periods is an integer mulitple of the PD period. Here we see the same thing: the following figure plots the LG period vs. the mean PD periods during taht LG burst. Note that the gray lines are not fits to the data -- they are merely lines with integer slopes. Note that the data naturally falls on top of these lines. 




figure('outerposition',[300 300 1200 1300],'PaperUnits','points','PaperSize',[1200 1300]); hold on




close all
addpath('../')

data_root = '/Volumes/DATA/gastric-data';


%% Analysis of gastric and pyloric rhythms at different temperatures
% In this document we look at pyloric and gastric rhtyhms at differnet temperatures.
% This data is from Dan Powell and the experiments that go into this are:

example_data = '901_046';


C = crabsort(false);
C.path_name = [data_root filesep char(example_data)];

show_these = {'0006','0079'};
show_these_rasters = {'0006', '0015','0026','0041','0053','0062','0084','0072','0079'};


figure('outerposition',[300 300 1200 1300],'PaperUnits','points','PaperSize',[1200 1300]); hold on

c = colormaps.redula(100);
min_temp = 5;
max_temp = 25;

show_these_channels = {'pdn','lgn'};


clear ax
ax.raw_data(1) = subplot(4,1,1); hold on
ax.raw_data(2) = subplot(4,1,2); hold on


for i = 1:length(show_these)

	C.file_name = [char(example_data) '_' show_these{i} '.abf'];
	C.loadFile;

	for j = length(show_these_channels):-1:1
		channel_idx(j) = find(strcmp(C.common.data_channel_names,show_these_channels{j}));
	end

	this_temp = round(mean(C.raw_data(:,strcmp(C.common.data_channel_names,'temperature'))))
	idx = ceil(((this_temp - min_temp)/(max_temp - min_temp))*100);

	raw_data = C.raw_data(:,channel_idx);
	time = C.time;

	% start traces when LG starts bursting
	start_here = time(C.spikes.lgn.LG(find(diff(C.spikes.lgn.LG)>1e4,1,'first') + 1));
	time = time - start_here;

	% normalize
	z = find(time>60,1,'first');

	for j = 1:size(raw_data,2)
		raw_data(:,j) = raw_data(:,j)/max(2*abs(raw_data(1:z,j)));
	end
	

	% show raw_data
	for j = 1:size(raw_data,2)
		plot(ax.raw_data(i),time,raw_data(:,j)+j,'Color',c(idx,:));
		th_nerve(j) = text(ax.raw_data(i),-1,0,['\it ' show_these_channels{j}]);
		th_nerve(j).Position = [-2 j];


		



	end

	% find spikes
	spiketimes = veclib.computeOnsOffs(abs(raw_data(:,j))>.2);


	burst_starts = find(diff(spiketimes)>3e4)+1;

	if i == 1
		ax.raw_data(i).XLim(1) = time(spiketimes(burst_starts(3)));
	end

	for k = 1:length(burst_starts)
		plotlib.vertline(ax.raw_data(i),time(spiketimes(burst_starts(k))),'k:');
	end

	set(ax.raw_data(i),'YColor','w')


	ax.raw_data(i).XColor = 'w';
	ax.raw_data(i).XTick = [];


end

ax.raw_data(1).XLim(1) = ax.raw_data(1).XLim(1) - 1;
ax.raw_data(1).XLim(2) = ax.raw_data(1).XLim(1) + 21;
ax.raw_data(2).XLim = [-1 10];

plot(ax.raw_data(1),[18.9 36.21],[.5 .5]+.9,'k','LineWidth',3)
text(34,1.55,'T_{PD} = .911s','FontSize',14,'Parent',ax.raw_data(1));

plot(ax.raw_data(1),[18.16 36.5],[.5 .5]+1.8,'k','LineWidth',3)
text(34,2.55,'T_{LG} = 9.17s','FontSize',14,'Parent',ax.raw_data(1));

ax.raw_data(1).Position(3) = .7;
ax.raw_data(2).Position(3) = .7;
th = text(39,1.5,'T_{LG}/T_{PD}=10.06','FontSize',14,'Parent',ax.raw_data(1));

plot(ax.raw_data(2),[.1915 6.769],[.5 .5]+.9,'k','LineWidth',3)
text(5,1.55,'T_{PD} = .313s','FontSize',14,'Parent',ax.raw_data(2));

plot(ax.raw_data(2),[0 6.881],[.5 .5]+1.8,'k','LineWidth',3)
text(5,2.55,'T_{LG} = 3.44s','FontSize',14,'Parent',ax.raw_data(2));

ax.raw_data(1).Position(3) = .7;
ax.raw_data(2).Position(3) = .7;
th = text(10.4,1.5,'T_{LG}/T_{PD}=10.98','FontSize',14,'Parent',ax.raw_data(2));

ax.raw_data(1).Position(2) = .82;
ax.raw_data(2).Position(2) = .65;



ax.LG.hero = subplot(3,2,3); hold on
ax.LG.remainders = subplot(3,3,7); hold on
ax.LG.ratio = subplot(3,3,9); hold on
ax.LG.integerness = subplot(3,3,8); hold on

ax.DG = ax.LG;
ax.DG.hero = subplot(3,2,4); hold on




c = [222,9,209; 40, 87, 41]/255;

[ch, ph] = gastric.plotIntegerCoupling(data, 'LG', ax.LG, c(1,:));
delete(ch)


[ch, ph] = gastric.plotIntegerCoupling(data, 'DG', ax.DG, c(2,:));
delete(ph)

ax.LG.remainders.YLim = [0 1];
ax.LG.remainders.XLim = [0 1];
plotlib.drawDiag(ax.LG.remainders);

% add a new guide line showing perfect integer coupling
plot(ax.LG.remainders,[0 0 1 1],[0 .5 .5 1],'b:')


clear lh L
lh(1) = scatter(ax.LG.remainders,NaN,NaN,32,c(1,:));
lh(2) = scatter(ax.LG.remainders,NaN,NaN,32,c(2,:));
lh(1).MarkerFaceColor = c(1,:);
lh(2).MarkerFaceColor = c(2,:);

L = legend(lh,'LG','DG');
L.Location = 'northwest';


figlib.pretty('PlotLineWidth',1,'FontSize',16)


th = text(12,.26,'Perfect integer coupling','Parent',ax.LG.integerness,'FontSize',13);

ax.LG.ratio.YLim = [0 30];
ax.LG.ratio.XLim = [5 25];


xlabel(ax.LG.remainders,'Significand of T_{gastric}/T_{pyloric}')

for P = {'LG','DG'}

	this = P{1};

	ax.(this).hero.XTick = [.2 .5 1 2];
	ax.(this).hero.YTick = [3 5 10 15 30];

	ax.(this).hero.YScale = 'linear';
	ax.(this).hero.XScale = 'linear';

	ax.(this).hero.YLim = [3 30];
	ax.(this).hero.XLim = [.2 2];
end


ch.Position = [.9 .4 .01 .2];
ch.TickDirection = 'out';

ax.LG.remainders.Position = [.1 .1 .2 .2];
ax.LG.integerness.Position = [.425 .1 .2 .2];
ax.LG.ratio.Position = [.7 .1 .2 .2];

ax.LG.hero.Position = [.1 .41 .33 .21];
ax.DG.hero.Position = [.5 .41 .33 .21];

ch.YDir = 'reverse';


axlib.label(ax.raw_data(1),'a','FontSize',30,'YOffset',-.02)
axlib.label(ax.LG.hero,'b','FontSize',30,'XOffset',-.01,'YOffset',-.01)
axlib.label(ax.DG.hero,'c','FontSize',30,'XOffset',-.01,'YOffset',-.01)

axlib.move(ax.DG.remainders,'left',.025)

axlib.move(ax.DG.ratio,'right',.025)

axlib.label(ax.DG.remainders,'d','FontSize',30,'XOffset',-.025,'YOffset',-.01)
axlib.label(ax.DG.integerness,'e','FontSize',30,'XOffset',-.025,'YOffset',-.01)
axlib.label(ax.DG.ratio,'f','FontSize',30,'XOffset',-.025,'YOffset',-.01)

figlib.saveall('Location',pwd,'SaveName',mfilename)