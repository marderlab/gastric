function ch = plotSpikeStatisticsTriggeredBy(ax, data,neuron, trigger)


before = 3;
after = 3;

max_allowed_period = 2;

temp_bins = [7:4:23];


trigger_points = data.(trigger);
mean_burst_periods_before = NaN*trigger_points;
mean_burst_periods_after = NaN*trigger_points;

cv_burst_periods_before = NaN*trigger_points;
cv_burst_periods_after = NaN*trigger_points;

temperature = NaN*trigger_points;

for j = 1:length(trigger_points)

	bs = [neuron '_burst_starts'];
	bp = [neuron '_burst_periods'];

	periods_before = data.(bp)(data.(bs) > (trigger_points(j) - before) & data.(bs) < (trigger_points(j)));

	periods_after = data.(bp)(data.(bs) > (trigger_points(j)) & data.(bs) < (after + trigger_points(j)));


	mean_burst_periods_after(j) = mean(periods_after);
	mean_burst_periods_before(j) = mean(periods_before);

	cv_burst_periods_after(j) = statlib.cv(periods_after);
	cv_burst_periods_before(j) = statlib.cv(periods_before);


	temperature(j) = data.temperature(round(trigger_points(j)*1e3));
end

rm_this = mean_burst_periods_after > max_allowed_period | mean_burst_periods_before > max_allowed_period;

mean_burst_periods_after(rm_this) = [];
mean_burst_periods_before(rm_this) = [];
cv_burst_periods_after(rm_this) = [];
cv_burst_periods_before(rm_this) = [];
temperature(rm_this) = [];

% average across temperature bins
mean_before = NaN*temp_bins;
mean_after = NaN*temp_bins;

cv_before = NaN*temp_bins;
cv_after = NaN*temp_bins;


for i = 1:length(temp_bins)
	ok = abs(temperature - temp_bins(i)) < 1;
	mean_before(i) = nanmean(mean_burst_periods_before(ok));
	mean_after(i) = nanmean(mean_burst_periods_after(ok));

	cv_before(i) = nanmean(cv_burst_periods_before(ok));
	cv_after(i) = nanmean(cv_burst_periods_after(ok));
end


ch(1) = plotlib.cplot(ax(1),mean_before,mean_after,temp_bins,'clim',[5 23]);

ch(2) = plotlib.cplot(ax(2), cv_before,cv_after,temp_bins,'clim',[5 23]);

