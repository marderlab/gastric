

% run this to make data.mat
% data = crabsort.consolidate('neurons',{'PD','LP','VD','IC','LG','DG','GM','AGR'},'data_fun',{@crabsort.getTemperature,@crabsort.getDataStatistics,@gastric.findStimulationTimes});


if ~exist('data','var')
	load('data.mat','data')
end

close all


% plot the spikes, arranged by end of stimulation 

figure('outerposition',[300 300 800 1000],'PaperUnits','points','PaperSize',[800 1000]); hold on

% figure out where the last stimulation was

stimulation_ends = zeros(length(data),1);
for i = 1:length(data)

	if any(data(i).stim_times)

		stimulation_ends(i) = find(data(i).stim_times,1,'last')*1e-3 + data(i).time_offset;
	end

end

files_with_stim_ends = find(diff(stimulation_ends)<0);
files_with_stim_ends(files_with_stim_ends>80) = [];

N = length(files_with_stim_ends);

clear ax
for i = 1:N
	ax(i) = subplot(N,1,i); hold on

	a = stimulation_ends(files_with_stim_ends(i));
	a  = 0;

	if i < N
		stop_here = files_with_stim_ends(i+1);
	else
		stop_here = files_with_stim_ends(i)+4;
	end

	for j = files_with_stim_ends(i)+1:stop_here
		if data(j).abs_max(1)>9
			continue
		end


		PD = data(j).PD + data(j).time_offset - stimulation_ends(files_with_stim_ends(i));
		DG = data(j).DG + data(j).time_offset - stimulation_ends(files_with_stim_ends(i));
		GM = data(j).GM + data(j).time_offset - stimulation_ends(files_with_stim_ends(i));
		LG = data(j).LG + data(j).time_offset - stimulation_ends(files_with_stim_ends(i));
		AGR = data(j).AGR + data(j).time_offset - stimulation_ends(files_with_stim_ends(i));

		neurolib.raster(PD,LG,DG,GM,AGR,'deltat',1,'fill_fraction',.5);
	end


	z = a + 1e3;
	ax(i).XLim = [a z];

	if i < N
		ax(i).XTick = [];
		ax(i).XColor = 'w';
	end
	ax(i).YTick = [];

	ylabel(ax(i),[strlib.oval(mean(data(j).temperature)) 'C'])

end

xlabel(ax(end),'Time since stimulation end (s)')

figlib.pretty('lw',1.5,'plw',1)


neurons = {'PD','LP','VD','IC','LG','DG','GM'};
% plot all ISIs for all temperatures 

figure('outerposition',[300 300 600 900],'PaperUnits','points','PaperSize',[600 900]); hold on


for i = 1:length(neurons)
	ax(i) = subplot(length(neurons),1,i); hold on
	set(ax(i),'YScale','log','YLim',[1e-2 100],'XLim',[0 8e3],'XTick',[])
	ylabel(ax(i),neurons{i})
end
set(ax(i),'XTick',[0:1e3:8e3])



c = parula(100);
min_temp = min(vertcat(data.temperature));
max_temp = max(vertcat(data.temperature));

skipped_time = 0;

for i = 1:length(data)

	if data(i).abs_max(:,1) > 8
		skipped_time = skipped_time + data(i).T;

		for j = 1:length(neurons)
			lh = plotlib.vertline(ax(j),data(i).time_offset -skipped_time+ data(i).T);
			lh.Color = 'r';
		end

		continue
	end

	this_temp = mean(data(i).temperature);
	C = c(floor(1+(this_temp - min_temp)/(max_temp - min_temp)*99),:);

	for j = 1:length(neurons)
		this_isis = diff(sort(data(i).(neurons{j})));

		if isempty(this_isis)
			continue
		end

		isi_time = data(i).(neurons{j});
		isi_time(end) = [];
		isi_time = isi_time + data(i).time_offset - skipped_time;



		plot(ax(j),isi_time,this_isis,'.','Color',C)

	end
end

figlib.pretty('lw',1.5,'plw',1)


% compute periods and durations
data = crabsort.computePeriods(data,'PD',.2);
data = crabsort.computePeriods(data,'LP',.2);
data = crabsort.computePeriods(data,'IC',.2);
data = crabsort.computePeriods(data,'VD',.2);
data = crabsort.computePeriods(data,'LG',1);
data = crabsort.computePeriods(data,'GM',1);
data = crabsort.computePeriods(data,'DG',1);



% plot periods
ax = plotMetrics(data, 'burst_periods',neurons);
ax(1).YLim = [0 1.2];
ax(2).YLim = [0 1.2];
ax(3).YLim = [0 5];
ax(4).YLim = [0 5];



% plot durations
ax = plotMetrics(data, 'burst_durations',neurons);
ax(1).YLim = [0 .3];
ax(2).YLim = [0 .5];
ax(3).YLim = [0 1];
ax(4).YLim = [0 1];


return

% now look at integer coupling between gastric and pyloric rhythms

figure('outerposition',[300 300 1200 600],'PaperUnits','points','PaperSize',[1200 600]); hold on

subplot(1,2,1); hold on

c = parula(100);
min_temp = min(vertcat(data.temperature));
max_temp = max(vertcat(data.temperature));


% plot gridlines
for i = 1:100
	xx = linspace(0,10,1e3);
	yy = xx*i;
	plot(xx,yy,'Color',[.8 .8 .8])
end

all_rem = [];
all_temp = [];

for i = 1:length(data)

	if isnan(data(i).LG_burst_periods)
		continue
	end

	LG_burst_starts = data(i).LG_burst_starts;
	LG_burst_periods = data(i).LG_burst_periods;


	use_these = corelib.closest(data(i).PD_burst_starts,LG_burst_starts);
	PD_burst_periods = data(i).PD_burst_periods(use_these);

	this_temp = mean(data(i).temperature);
	C = c(floor(1+(this_temp - min_temp)/(max_temp - min_temp)*99),:);

	plot(PD_burst_periods,LG_burst_periods,'.','Color',C,'MarkerSize',10)

	this_rem = abs((LG_burst_periods./PD_burst_periods - floor( LG_burst_periods./PD_burst_periods)) - .5)*2;

	this_rem = mean(this_rem);

	all_rem = [all_rem; this_rem];
	all_temp = [all_temp; this_rem*0 + this_temp];

end

set(gca,'XLim',[0.1 1],'YLim',[0 30])
xlabel('Pyloric period (s)')
ylabel('Gastric period (s)')

% subplot(1,2,2); hold on
% plot(all_temp,all_rem,'k.')

figlib.pretty('lw',1,'plw',1)