% computes q10s from paired vectors of periods and temperatures

function q = q10(periods, temperatures)

arguments
	periods (:,1) double
	temperatures (:,1) double
end

rm_this = isnan(periods) | isnan(temperatures);

periods(rm_this) = [];
temperatures(rm_this) = [];

f = 1./periods(:);
f0 = nanmean(f(abs(temperatures(:) - 11) < .1));
q = ((f./f0).^(10./(temperatures(:)-11)));

q(isnan(q)) = [];
q(isinf(q)) = [];
q(q==0) = [];