% measures PD period variability when gastric is on or off

function [cv_mean_on, cv_mean_off, cv_std_on, cv_std_off, time_since_gastric, PD_period_cv, temperature] = comparePDVariability(data, all_temp, N_periods, max_burst_period)


time_since_gastric = NaN*data.PD_burst_starts;
PD_period_cv = NaN*data.PD_burst_starts;
temperature = NaN*data.PD_burst_starts;

data.PD_burst_periods(data.PD_burst_periods > max_burst_period) = NaN;


for i = N_periods+1:length(PD_period_cv)

	last_LG = find(data.LG < data.PD_burst_starts(i) ,1,'last');
	if isempty(last_LG)
		continue
	end


	time_since_gastric(i) = data.PD_burst_starts(i) - data.LG(last_LG);
	PD_period_cv(i) = statlib.cv(data.PD_burst_periods(i-N_periods:i));
	temperature(i) = data.temperature(round(1e3*data.PD_burst_starts(i)));



end





% build averages 
cv_mean_off = NaN*all_temp;
cv_mean_on = NaN*all_temp;
cv_std_on = NaN*all_temp;
cv_std_off = NaN*all_temp;

for i = 1:length(all_temp)
	only_this = temperature > all_temp(i) -.5 & temperature < all_temp(i) +.5 & time_since_gastric > 100 & PD_period_cv < 10;

	cv_mean_off(i) = nanmean(PD_period_cv(only_this));
	cv_std_off(i) = nanstd(PD_period_cv(only_this));

	only_this = temperature > all_temp(i) -.5 & temperature < all_temp(i) +.5 & time_since_gastric < 1 & PD_period_cv < 1;
	cv_mean_on(i) = nanmean(PD_period_cv(only_this));
	cv_std_on(i) = nanstd(PD_period_cv(only_this))/sqrt(sum(only_this));
end

