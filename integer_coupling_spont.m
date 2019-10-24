%
% in this script, we build on the interger-coupling analysis,
% but in Sara's data, where there are sponteanous gastric rhythms


% first, gather all the data 
if ~exist('data_s','var')
	if exist('integer_coupling_data_spont.mat','file') == 2

		load('integer_coupling_data_spont.mat','data_s')
	else

		data_root = '/Volumes/HYDROGEN/srinivas_data/temperature-data-for-embedding';
		include_these = {'857_144','857_142','857_138_1','857_134_1','857_130','857_052','857_016','857_012','857_010','857_001_2'};

		data_s = struct;

		for i = 1:length(include_these)

			this_data = crabsort.consolidate('neurons',{'PD','LG'},'data_fun',{,@crabsort.getDataStatistics},'data_dir',[data_root filesep include_these{i}]);

			data_s = structlib.merge(data_s,this_data);

		end

		save('integer_coupling_data_spont.mat','data_s')
	end
end



% make sure spiketimes are sorted
for i = 1:length(data_s)
	data_s(i).PD = sort(data_s(i).PD);
	data_s(i).LG = sort(data_s(i).LG);
end

data_s = crabsort.computePeriods(data_s,'neurons',{'PD'},'ibis',.15,'min_spikes_per_burst',2);
data_s = crabsort.computePeriods(data_s,'neurons',{'LG'},'ibis',1,'min_spikes_per_burst',5);

unique_exp_ids = unique([data_s.experiment_idx]);

c = parula(110);
min_temp = nanmin(vertcat(data_s.temperature));
max_temp = nanmax(vertcat(data_s.temperature));





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


for i = 1:length(data_s)

	if isnan(data_s(i).LG_burst_periods)
		continue
	end

	if isempty(data_s(i).LG_burst_periods)
		continue
	end

	if min(data_s(i).mask) == 0
		continue
	end


	LG_burst_starts = data_s(i).LG_burst_starts;
	LG_burst_ends = data_s(i).LG_burst_ends;
	LG_burst_periods = data_s(i).LG_burst_periods;

	mean_PD_burst_periods = NaN*LG_burst_starts;
	n_pyloric_cyles = NaN*LG_burst_starts;
	delay_PD_start_LG_start = NaN*LG_burst_starts;
	delay_PD_start_LG_end = NaN*LG_burst_starts;
	delay_PD_end_LG_start = NaN*LG_burst_starts;
	delay_PD_end_LG_end = NaN*LG_burst_starts;


	for j = 1:length(LG_burst_starts)-1
		closest_PD_a = corelib.closest(data_s(i).PD_burst_starts,LG_burst_starts(j));
		closest_PD_z = corelib.closest(data_s(i).PD_burst_starts,LG_burst_starts(j+1));


		n_pyloric_cyles(j) = closest_PD_z - closest_PD_a;

		mean_PD_burst_periods(j) = (data_s(i).PD_burst_starts(closest_PD_z) -  data_s(i).PD_burst_starts(closest_PD_a))/n_pyloric_cyles(j);

		% compute delays (delay_PD_start_LG_start)
		allowed_PD_starts = data_s(i).PD_burst_starts(data_s(i).PD_burst_starts < LG_burst_starts(j));


		idx = corelib.closest(allowed_PD_starts,LG_burst_starts(j));
		if ~isempty(idx)
			delay_PD_start_LG_start(j) = LG_burst_starts(j) - allowed_PD_starts(idx);
		end


		allowed_PD_starts = data_s(i).PD_burst_starts(data_s(i).PD_burst_starts < LG_burst_ends(j));
		idx = corelib.closest(allowed_PD_starts,LG_burst_ends(j));
		if ~isempty(idx)
			delay_PD_start_LG_end(j) = LG_burst_ends(j) - allowed_PD_starts(idx);
		end

		allowed_PD_ends = data_s(i).PD_burst_ends(data_s(i).PD_burst_ends < LG_burst_starts(j));
		idx = corelib.closest(allowed_PD_ends,LG_burst_starts(j));
		if ~isempty(idx)
			delay_PD_end_LG_start(j) = LG_burst_starts(j) - allowed_PD_ends(idx);
		end

		allowed_PD_ends = data_s(i).PD_burst_ends(data_s(i).PD_burst_ends < LG_burst_ends(j));
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

	this_temp = mean(data_s(i).temperature);

	% append to all data
	this_N = round(LG_burst_periods./mean_PD_burst_periods);
	this_integerness = abs(LG_burst_periods./mean_PD_burst_periods - this_N)*2;
	all_N = [all_N; this_N];
	all_temperature = [all_temperature; this_temp + 0*this_N];
	all_intergerness = [all_intergerness; this_integerness];
	all_exp_ids = [all_exp_ids; data_s(i).experiment_idx + 0*this_N];

	if ~isnan(this_temp)
		C = c(floor(1+(this_temp - min_temp)/(max_temp - min_temp)*99),:);
	else
		C = [ 0 0 0];
	end

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




figlib.saveall('Location',pwd,'SaveName',mfilename)