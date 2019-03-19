
if ~exist('data','var')
	load('data.mat','data')
end

close all


% plot all ISIs for all temperatures 

figure('outerposition',[300 300 600 900],'PaperUnits','points','PaperSize',[600 900]); hold on

neurons = {'PD','LP','VD','IC','LG','DG','GM'};

for i = 1:length(neurons)
	ax(i) = subplot(7,1,i); hold on
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


% compute periods and durations
data = crabsort.computePeriods(data,'PD',.2);
data = crabsort.computePeriods(data,'LP',.2);
data = crabsort.computePeriods(data,'IC',.2);
data = crabsort.computePeriods(data,'VD',.2);
data = crabsort.computePeriods(data,'LG',1);
data = crabsort.computePeriods(data,'GM',1);
data = crabsort.computePeriods(data,'DG',1);




% plot periods
ax = plotMetrics(data, 'burst_periods');


% plot durations
ax = plotMetrics(data, 'burst_durations');
ax(1).YLim = [0 .3];
ax(2).YLim = [0 .5];
ax(3).YLim = [0 1];
ax(4).YLim = [0 1];

