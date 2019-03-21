

%% 
% In this document we look at integer coupling b/w the pyloric and gastric burst periods


% first, gather all the data 
if ~exist('data','var')
	if exist('integer_coupling_data.mat','file') == 2

		load('integer_coupling_data.mat','data')
	else

		data_root = '/Volumes/HYDROGEN/srinivas_data/gastric-data';
		include_these = {'901_046','901_049','901_052','901_062','901_080'};

		for i = 1:length(include_these)

			this_data = crabsort.consolidate('neurons',{'PD','LG'},'data_fun',{@crabsort.getTemperature,@crabsort.getDataStatistics,@crabsort.findArtifacts},'data_dir',[data_root filesep include_these{i}]);


			sdfsd

		end

		save('integer_coupling_data.mat','data')
	end
end


% make sure spiketimes are sorted
for i = 1:length(data)
	data(i).PD = sort(data(i).PD);
	data(i).LG = sort(data(i).LG);
end


data = crabsort.computePeriods(data,'PD',.2);
data = crabsort.computePeriods(data,'LG',1);


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


c = parula(100);
min_temp = min(vertcat(data.temperature));
max_temp = max(vertcat(data.temperature));



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


% make a figure for normalized by LG period
figure('outerposition',[300 300 901 901],'PaperUnits','points','PaperSize',[901 901]); hold on
clear ax_LG


for i = 1:4
	ax_LG(i) = subplot(2,2,i); hold on
	xlabel('Temperature (C)')
end

suptitle('Normalized by LG period')

ylabel(ax_LG(1),'PD_{start} \rightarrow LG_{start} (norm)')
ylabel(ax_LG(2),'PD_{start} \rightarrow LG_{end} (norm)')
ylabel(ax_LG(3),'PD_{end} \rightarrow LG_{start} (norm)')
ylabel(ax_LG(4),'PD_{end} \rightarrow LG_{end} (norm)')


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





for i = 1:length(data)

	if isnan(data(i).LG_burst_periods)
		continue
	end

	if isempty(data(i).LG_burst_periods)
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


	for j = 1:length(LG_burst_starts)
		closest_PD_a = corelib.closest(data(i).PD_burst_starts,LG_burst_starts(j));
		closest_PD_z = corelib.closest(data(i).PD_burst_starts,LG_burst_ends(j));


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
	C = c(floor(1+(this_temp - min_temp)/(max_temp - min_temp)*99),:);

	plot(ax_int,mean_PD_burst_periods,LG_burst_periods,'.','Color',C,'MarkerSize',10)


	plot(ax(1),this_temp,delay_PD_start_LG_start,'.','Color',C,'MarkerSize',10)
	plot(ax(2),this_temp,delay_PD_start_LG_end,'.','Color',C,'MarkerSize',10)
	plot(ax(3),this_temp,delay_PD_end_LG_start,'.','Color',C,'MarkerSize',10)
	plot(ax(4),this_temp,delay_PD_end_LG_end,'.','Color',C,'MarkerSize',10)


	% norm by LG period
	plot(ax_LG(1),this_temp,delay_PD_start_LG_start_norm_LG,'.','Color',C,'MarkerSize',10)
	plot(ax_LG(2),this_temp,delay_PD_start_LG_end_norm_LG,'.','Color',C,'MarkerSize',10)
	plot(ax_LG(3),this_temp,delay_PD_end_LG_start_norm_LG,'.','Color',C,'MarkerSize',10)
	plot(ax_LG(4),this_temp,delay_PD_end_LG_end_norm_LG,'.','Color',C,'MarkerSize',10)

	% norm by PD period
	plot(ax_PD(1),this_temp,delay_PD_start_LG_start_norm_PD,'.','Color',C,'MarkerSize',10)
	plot(ax_PD(2),this_temp,delay_PD_start_LG_end_norm_PD,'.','Color',C,'MarkerSize',10)
	plot(ax_PD(3),this_temp,delay_PD_end_LG_start_norm_PD,'.','Color',C,'MarkerSize',10)
	plot(ax_PD(4),this_temp,delay_PD_end_LG_end_norm_PD,'.','Color',C,'MarkerSize',10)


end

for i = 1:4
	ax(i).YLim = [0 1];
	ax_LG(i).YLim = [0 1];
	ax_PD(i).YLim = [0 1];
end



figlib.pretty('lw',1,'plw',1)





