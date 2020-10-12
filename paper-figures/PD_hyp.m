% get data for the PD hyperpolairziation experiments
% these are in the "999" notebook, because Dan did these 
% experiments in a notebook that didn't have a number

close all

TemperatureSteps = [11 15 19 21];

if ~exist('data','var')	
	data = PDhyp.init(TemperatureSteps);
end

% show ISIs
C = colormaps.redula(4);

for this_data = List(data)
	PDhyp.showISIs(this_data, TemperatureSteps);

end


return


% compute periods for each prep for the reference temperatures 
PD_periods_mean = NaN(length(exp_names),length(all_temp));
PD_periods_std = PD_periods_mean;
LG_periods_mean_PD_off = PD_periods_mean;
LG_periods_mean_PD_on = PD_periods_mean;

for i = 1:length(data)
	data{i} = crabsort.computePeriods(data{i},'neurons',{'LG'},'ibis',1,'min_spikes_per_burst',5);
	data{i} = crabsort.computePeriods(data{i},'neurons',{'PD'},'ibis',.25,'min_spikes_per_burst',2);
end


for i = 1:length(data)
	this_data = data{i};


	% compute PD periods
	for j = 1:length(this_data)

		if length(this_data(j).PD) < 100
			continue
		end

		if this_data(j).PD_hyperpolarized
			continue
		end

		idx = ceil(this_data(j).PD_burst_starts);
		temp = this_data(j).temperature(idx);
		
		temp = round(mean(temp));
		tempidx  = find(all_temp==temp);
		if isempty(tempidx)
			continue
		end
		PD_periods_mean(i,tempidx) = nanmean(this_data(j).PD_burst_periods);
		PD_periods_std(i,tempidx) = nanstd(this_data(j).PD_burst_periods);

	end

	% compute LG periods when PD on
		for j = 1:length(this_data)

		if length(this_data(j).LG) < 100
			continue
		end

		if this_data(j).PD_hyperpolarized
			continue
		end

		idx = ceil(this_data(j).LG_burst_starts);
		temp = this_data(j).temperature(idx);
		
		temp = round(mean(temp));
		tempidx  = find(all_temp==temp);
		if isempty(tempidx)
			continue
		end
		LG_periods_mean_PD_on(i,tempidx) = nanmean(this_data(j).LG_burst_periods);
		LG_periods_std_PD_on(i,tempidx) = nanstd(this_data(j).LG_burst_periods);

	end

	% compute LG periods when PD off
		for j = 1:length(this_data)

		if length(this_data(j).LG) < 100
			continue
		end

		if this_data(j).PD_hyperpolarized == 0
			continue
		end

		idx = ceil(this_data(j).LG_burst_starts);
		temp = this_data(j).temperature(idx);
		
		temp = round(mean(temp));
		tempidx  = find(all_temp==temp);
		if isempty(tempidx)
			continue
		end
		LG_periods_mean_PD_off(i,tempidx) = nanmean(this_data(j).LG_burst_periods);
		LG_periods_std_PD_off(i,tempidx) = nanstd(this_data(j).LG_burst_periods);

	end
	

end


% show periods vs. time on a prep-by-prep basis

figure('outerposition',[300 300 1200 600],'PaperUnits','points','PaperSize',[1200 600]); hold on

subplot(1,3,1); hold on,set(gca,'YScale','log','YLim',[.4 20])
temp = repmat(all_temp,length(exp_names),1);
all_prep = repmat(1:length(exp_names),length(all_temp),1)';
ph = gastric.groupAndPlotErrorBars(all_temp, temp(:), all_prep(:), PD_periods_mean);

for i = 1:length(ph)-1
	ph(i).Color = [.5 .5 .5];
end

xlabel('Temperature (C)')
ylabel('T_{PD} (s)')

title(['PD q_{10}=' mat2str(mean(gastric.q10(PD_periods_mean(:),temp(:))),2)])


subplot(1,3,2); hold on; set(gca,'YScale','log','YLim',[.4 20])
temp = repmat(all_temp,length(exp_names),1);
all_prep = repmat(1:length(exp_names),length(all_temp),1)';
ph = gastric.groupAndPlotErrorBars(all_temp, temp(:), all_prep(:), LG_periods_mean_PD_on);

for i = 1:length(ph)-1
	ph(i).Color = [.5 .5 .5];
end


xlabel('Temperature (C)')
ylabel('T_{LG} (s)')

title(['LG q_{10}=' mat2str(mean(gastric.q10(LG_periods_mean_PD_on(:),temp(:))),2)])


subplot(1,3,3); hold on; set(gca,'YScale','log','YLim',[.4 20])
temp = repmat(all_temp,length(exp_names),1);
all_prep = repmat(1:length(exp_names),length(all_temp),1)';
ph = gastric.groupAndPlotErrorBars(all_temp, temp(:), all_prep(:), LG_periods_mean_PD_off);

for i = 1:length(ph)-1
	ph(i).Color = [.5 .5 .5];
end


xlabel('Temperature (C)')
ylabel('T_{LG} (s)')

title(['LG q_{10}=' mat2str(mean(gastric.q10(LG_periods_mean_PD_off(:),temp(:))),2)])


figlib.pretty()