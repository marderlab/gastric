

%% 
% In this document we look at integer coupling b/w the pyloric and gastric burst periods

close all

% first, gather all the data 
if ~exist('data','var')
	if exist('integer_coupling_data.mat','file') == 2

		load('integer_coupling_data.mat','data')
	else

		data_root = '/Volumes/HYDROGEN/srinivas_data/gastric-data';
		include_these = {'901_086','901_046','901_049','901_052','901_062','901_080','901_095','901_098'};


		data = crabsort.consolidate('neurons',{'PD','LG'},'data_fun',{@crabsort.getTemperature,@crabsort.getDataStatistics},'data_dir',[data_root filesep include_these{1}]);

		for i = 2:length(include_these)

			this_data = crabsort.consolidate('neurons',{'PD','LG'},'data_fun',{@crabsort.getTemperature,@crabsort.getDataStatistics},'data_dir',[data_root filesep include_these{i}]);


			data = [data, this_data];

		end

		save('integer_coupling_data.mat','data')
	end
end


% make sure spiketimes are sorted
for i = 1:length(data)
	data(i).PD = sort(data(i).PD);
	data(i).LG = sort(data(i).LG);
end


 data = crabsort.computePeriods(data,'neurons',{'PD'},'ibis',.15,'min_spikes_per_burst',2);
data = crabsort.computePeriods(data,'neurons',{'LG'},'ibis',1,'min_spikes_per_burst',5);


unique_exp_ids = unique([data.experiment_idx]);


% compute the last stim time in the timeframe of each data slice
for i = 1:length(data)
	if min(data(i).mask) == 0
		data(i).last_stim = find(data(i).mask==0,1,'last')*1e-3;
	else
		data(i).last_stim = NaN;
	end
end

% compute for each element in data the time since the last stimulation 
all_last_stim = [data.last_stim];
all_exp_ids  = [data.experiment_idx];
for i = 1:length(data)
	data(i).time_to_last_stim = NaN;
	if min(data(i).mask) == 1
		% compute time to last stim
		temp = all_last_stim;
		temp(all_exp_ids ~= data(i).experiment_idx) = NaN;
		temp = temp(1:i);
		file_with_last_stim = find(~isnan(temp),1,'last');

		if isempty(file_with_last_stim)
			continue
		end

		data(i).time_to_last_stim = round(data(i).time_offset - data(file_with_last_stim).time_offset - data(file_with_last_stim).last_stim);

	end

end



% show the raw data, triggered by when the stimulus goes off

all_temp = 7:2:23;
figure('outerposition',[300 300 1200 901],'PaperUnits','points','PaperSize',[1200 901]); hold on
clear ax
N = length(unique_exp_ids);

for i = 1:N
	ax(i) = figlib.autoPlot(N,i); hold on
	xlabel(ax(i),'Time since stimulation (s)')
	ylabel(ax(i),'Temperature (C)')
	ax(i).YTick = (1:2:length(all_temp)) + .5;
	ax(i).YTickLabel = {'7','11','15','19','21'};
	ax(i).XLim = [0 120];
end


first_file_after_stim = find(~isnan(all_last_stim))+1;



all_rasters = false(length(all_temp),length(first_file_after_stim));

for i = 1:length(first_file_after_stim)

	
	idx = first_file_after_stim(i);

	if isnan(data(idx).time_to_last_stim)
		continue
	end


	this_exp = find(unique_exp_ids == data(idx).experiment_idx);

	spiketimes = data(idx).LG + data(idx).time_to_last_stim;

	temp_idx = corelib.closest(all_temp,mean(data(idx).temperature));


	if ~all_rasters(temp_idx,this_exp)

		neurolib.raster(ax(this_exp),spiketimes,'deltat',1,'yoffset',temp_idx)
		all_rasters(temp_idx,this_exp) = true;
	end


	title(ax(this_exp),strlib.oval(data(idx).experiment_idx))

end


suptitle('LG bursts after stimulation')

figlib.pretty('plw',1,'lw',1)






% plot gastric period after stimulation as a function of time since stim


c = parula(110);
min_temp = min(vertcat(data.temperature));
max_temp = max(vertcat(data.temperature));



all_temp = 7:2:23;
figure('outerposition',[300 300 1200 901],'PaperUnits','points','PaperSize',[1200 901]); hold on
clear ax
N = length(unique_exp_ids);

for i = 1:N
	ax(i) = figlib.autoPlot(N,i); hold on
	xlabel(ax(i),'Time since stimulation (s)')
	ylabel(ax(i),'LG burst period (s)')
	ax(i).XLim = [0 400];
	ax(i).YLim = [0 20];
end


first_file_after_stim = find(~isnan(all_last_stim))+1;

all_rasters = false(length(all_temp),length(first_file_after_stim));

for i = 1:length(first_file_after_stim)


	for j = first_file_after_stim(i):length(data)

		if ~isnan(data(j).last_stim)
			break
		end


		if isnan(data(j).time_to_last_stim)
			continue
		end

		this_exp = find(unique_exp_ids == data(j).experiment_idx);


		% get the periods
		y = data(j).LG_burst_periods;
		x = data(j).LG_burst_starts +  data(j).time_to_last_stim;

		this_temp = mean(data(j).temperature);
		C = c(floor(1+(this_temp - min_temp)/(max_temp - min_temp)*99),:);

		plot(ax(this_exp),x,y,'.','Color',C,'MarkerSize',10)

		title(ax(this_exp),strlib.oval(data(j).experiment_idx))

	end	

end


suptitle('LG bursts after stimulation')

figlib.pretty('plw',1,'lw',1)





% plot pyloric and gastric periods as a function of temperature
figure('outerposition',[300 300 1400 901],'PaperUnits','points','PaperSize',[1400 901]); hold on
clear ax
N = length(unique_exp_ids);
for i = 1:N
	ax(i) = figlib.autoPlot(N,i); hold on
	ax(i).YScale = 'log';
	xlabel(ax(i),'Temperature (C)')
	ylabel(ax(i),'Period (s)')
end

for i = 1:length(data)

	if isnan(data(i).LG_burst_periods)
		continue
	end

	if isempty(data(i).LG_burst_periods)
		continue
	end

	if min(data(i).mask) == 0
		continue
	end

	this_exp = find(unique_exp_ids == data(i).experiment_idx);

	% LG
	temperature = data(i).temperature(round(data(i).LG_burst_starts*1e3));
	LG_burst_periods = data(i).LG_burst_periods;
	plot(ax(this_exp),temperature,LG_burst_periods,'b.')

	temperature = data(i).temperature(round(data(i).PD_burst_starts*1e3));
	PD_burst_periods = data(i).PD_burst_periods;
	plot(ax(this_exp),temperature,PD_burst_periods,'r.')

	title(ax(this_exp),strlib.oval(data(i).experiment_idx))
	
end

figlib.pretty('plw',1,'lw',1)




figure('outerposition',[300 300 700 700],'PaperUnits','points','PaperSize',[700 700]); hold on
ax_int = gca;

% plot gridlines
for i = 1:100
	xx = linspace(0,10,1e3);
	yy = xx*i;
	plot(gca,xx,yy,'Color',[.8 .8 .8])
end

set(gca,'XLim',[0.1 1],'YLim',[0 30])
xlabel('Pyloric period (s)')
ylabel('Gastric period (s)')

figlib.pretty('lw',1,'plw',1)




figure('outerposition',[300 300 901 901],'PaperUnits','points','PaperSize',[901 901]); hold on
clear ax


for i = 1:4
	ax(i) = subplot(2,2,i); hold on
	xlabel('Temperature (C)')
end

ylabel(ax(1),'PD_{start} \rightarrow LG_{start} (s)')
ylabel(ax(2),'PD_{start} \rightarrow LG_{end} (s)')
ylabel(ax(3),'PD_{end} \rightarrow LG_{start} (s)')
ylabel(ax(4),'PD_{end} \rightarrow LG_{end} (s)')


figlib.pretty('lw',1,'plw',1)

% and a figure for norm by PD period
figure('outerposition',[300 300 901 901],'PaperUnits','points','PaperSize',[901 901]); hold on
clear ax_PD
for i = 1:4
	ax_PD(i) = subplot(2,2,i); hold on
	xlabel('Temperature (C)')
end

suptitle('Normalized by PD period')
ylabel(ax_PD(1),'PD_{start} \rightarrow LG_{start} (norm)')
ylabel(ax_PD(2),'PD_{start} \rightarrow LG_{end} (norm)')
ylabel(ax_PD(3),'PD_{end} \rightarrow LG_{start} (norm)')
ylabel(ax_PD(4),'PD_{end} \rightarrow LG_{end} (norm)')

% assemble all data together
all_temperature = [];
all_exp_ids = [];
all_intergerness = [];
all_N = [];


for i = 1:length(data)

	if isnan(data(i).LG_burst_periods)
		continue
	end

	if isempty(data(i).LG_burst_periods)
		continue
	end

	if min(data(i).mask) == 0
		continue
	end


	LG_burst_starts = data(i).LG_burst_starts;
	LG_burst_ends = data(i).LG_burst_ends;
	LG_burst_periods = data(i).LG_burst_periods;

	mean_PD_burst_periods = NaN*LG_burst_starts;
	n_pyloric_cyles = NaN*LG_burst_starts;
	delay_PD_start_LG_start = NaN*LG_burst_starts;
	delay_PD_start_LG_end = NaN*LG_burst_starts;
	delay_PD_end_LG_start = NaN*LG_burst_starts;
	delay_PD_end_LG_end = NaN*LG_burst_starts;


	for j = 1:length(LG_burst_starts)-1
		closest_PD_a = corelib.closest(data(i).PD_burst_starts,LG_burst_starts(j));
		closest_PD_z = corelib.closest(data(i).PD_burst_starts,LG_burst_ends(j+1));


		n_pyloric_cyles(j) = closest_PD_z - closest_PD_a;

		mean_PD_burst_periods(j) = (data(i).PD_burst_starts(closest_PD_z) -  data(i).PD_burst_starts(closest_PD_a))/n_pyloric_cyles(j);

		% compute delays (delay_PD_start_LG_start)
		allowed_PD_starts = data(i).PD_burst_starts(data(i).PD_burst_starts < LG_burst_starts(j));
		idx = corelib.closest(allowed_PD_starts,LG_burst_starts(j));
		if ~isempty(idx)
			delay_PD_start_LG_start(j) = LG_burst_starts(j) - allowed_PD_starts(idx);
		end


		allowed_PD_starts = data(i).PD_burst_starts(data(i).PD_burst_starts < LG_burst_ends(j));
		idx = corelib.closest(allowed_PD_starts,LG_burst_ends(j));
		if ~isempty(idx)
			delay_PD_start_LG_end(j) = LG_burst_ends(j) - allowed_PD_starts(idx);
		end

		allowed_PD_ends = data(i).PD_burst_ends(data(i).PD_burst_ends < LG_burst_starts(j));
		idx = corelib.closest(allowed_PD_ends,LG_burst_starts(j));
		if ~isempty(idx)
			delay_PD_end_LG_start(j) = LG_burst_starts(j) - allowed_PD_ends(idx);
		end

		allowed_PD_ends = data(i).PD_burst_ends(data(i).PD_burst_ends < LG_burst_ends(j));
		idx = corelib.closest(allowed_PD_ends,LG_burst_ends(j));
		if ~isempty(idx)
			delay_PD_end_LG_end(j) = LG_burst_ends(j) - allowed_PD_ends(idx);
		end




	end

	% normalize by LG
	delay_PD_start_LG_start_norm_LG = delay_PD_start_LG_start./LG_burst_periods;
	delay_PD_start_LG_end_norm_LG = delay_PD_start_LG_end./LG_burst_periods;
	delay_PD_end_LG_start_norm_LG = delay_PD_end_LG_start./LG_burst_periods;
	delay_PD_end_LG_end_norm_LG = delay_PD_end_LG_end./LG_burst_periods;


	% normalize by PD burst period
	delay_PD_start_LG_start_norm_PD = delay_PD_start_LG_start./mean_PD_burst_periods;
	delay_PD_start_LG_end_norm_PD = delay_PD_start_LG_end./mean_PD_burst_periods;
	delay_PD_end_LG_start_norm_PD = delay_PD_end_LG_start./mean_PD_burst_periods;
	delay_PD_end_LG_end_norm_PD = delay_PD_end_LG_end./mean_PD_burst_periods;

	this_temp = mean(data(i).temperature);

	% append to all data
	this_N = round(LG_burst_periods./mean_PD_burst_periods);
	this_integerness = abs(LG_burst_periods./mean_PD_burst_periods - this_N)*2;
	all_N = [all_N; this_N];
	all_temperature = [all_temperature; this_temp + 0*this_N];
	all_intergerness = [all_intergerness; this_integerness];
	all_exp_ids = [all_exp_ids; data(i).experiment_idx + 0*this_N];

	C = c(floor(1+(this_temp - min_temp)/(max_temp - min_temp)*99),:);

	plot(ax_int,mean_PD_burst_periods,LG_burst_periods,'.','Color',C,'MarkerSize',10)


	plot(ax(1),this_temp,delay_PD_start_LG_start,'.','Color',C,'MarkerSize',10)
	plot(ax(2),this_temp,delay_PD_start_LG_end,'.','Color',C,'MarkerSize',10)
	plot(ax(3),this_temp,delay_PD_end_LG_start,'.','Color',C,'MarkerSize',10)
	plot(ax(4),this_temp,delay_PD_end_LG_end,'.','Color',C,'MarkerSize',10)


	% norm by PD period
	plot(ax_PD(1),this_temp,delay_PD_start_LG_start_norm_PD,'.','Color',C,'MarkerSize',10)
	plot(ax_PD(2),this_temp,delay_PD_start_LG_end_norm_PD,'.','Color',C,'MarkerSize',10)
	plot(ax_PD(3),this_temp,delay_PD_end_LG_start_norm_PD,'.','Color',C,'MarkerSize',10)
	plot(ax_PD(4),this_temp,delay_PD_end_LG_end_norm_PD,'.','Color',C,'MarkerSize',10)


end

for i = 1:4
	ax(i).YLim = [0 1];
	ax_PD(i).YLim = [0 1];
end



figlib.pretty('lw',1,'plw',1)







figure('outerposition',[300 300 1001 901],'PaperUnits','points','PaperSize',[1001 901]); hold on


subplot(2,2,1); hold on
plot(all_temperature,all_N,'.','Color',[.8 .8 .8],'MarkerSize',24)
xlabel('Temperature (C)')
ylabel('N (pyloric/gastric)')

% also group by exp id
for j = 1:length(unique_exp_ids)
	M = NaN*temp_space;
	E = NaN*temp_space;
	for i = 1:length(temp_space)
		idx = (all_temperature > temp_space(i)-.5 & all_temperature < temp_space(i)+.5 & all_exp_ids == unique_exp_ids(j));
		M(i) = nanmean(all_N(idx));
		E(i) = corelib.sem(all_N(idx));
	end
	errorbar(temp_space,M,E,'LineWidth',2)

end

% plot averages by temperatiure
temp_space = 7:2:23;
M = NaN*temp_space;
E = NaN*temp_space;
for i = 1:length(temp_space)
	idx = (all_temperature > temp_space(i)-.5 & all_temperature < temp_space(i)+.5);
	M(i) = nanmean(all_N(idx));
	E(i) = corelib.sem(all_N(idx));
end
errorbar(temp_space,M,E,'k','LineWidth',3)


set(gca,'YLim',[0 60],'XLim',[5 25])


subplot(2,2,2); hold on
plot(all_temperature,1-all_intergerness,'.','Color',[.8 .8 .8],'MarkerSize',24)
xlabel('Temperature (C)')
ylabel('Integerness')


% also group by exp id
for j = 1:length(unique_exp_ids)
	M = NaN*temp_space;
	E = NaN*temp_space;
	for i = 1:length(temp_space)
		idx = (all_temperature > temp_space(i)-.5 & all_temperature < temp_space(i)+.5 & all_exp_ids == unique_exp_ids(j));
		M(i) = nanmean(1-all_intergerness(idx));
		E(i) = corelib.sem(1-all_intergerness(idx));
	end
	errorbar(temp_space,M,E,'LineWidth',2)

end


% plot averages by temperatiure
temp_space = 7:2:23;
M = NaN*temp_space;
E = NaN*temp_space;
for i = 1:length(temp_space)
	idx = (all_temperature > temp_space(i)-.5 & all_temperature < temp_space(i)+.5);
	M(i) = nanmean(1-all_intergerness(idx));
	E(i) = corelib.sem(1-all_intergerness(idx));
end

errorbar(temp_space,M,E,'k','LineWidth',3)
set(gca,'YLim',[0 1],'XLim',[5 25])

ax = subplot(2,2,3); hold on
p = plotlib.cplot(all_N,1-all_intergerness,all_temperature);
p.Marker = 'o';
p.SizeData = 48;
p.MarkerFaceAlpha = .8;
xlabel('N (pyloric/gastric)')
ylabel('Integerness')
set(ax,'XScale','log')



figlib.pretty('lw',1,'plw',1)
ax.XLim = [5 100];