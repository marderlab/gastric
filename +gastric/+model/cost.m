function C = cost(x,~)

C = 0;

x.dt = .1;
x.sim_dt = .1;

x.closed_loop = true;
x.t_end = 30e3;
x.integrate;

x.t_end = 120e3;
V = x.integrate;

% make sure LG and Int1 are still bursting 

metrics.Int1 = xtools.V2metrics(V(:,2),'sampling_rate',10,'ibi_thresh',5e3,'debug',false);
[metrics.LG, LG_burst_starts] = xtools.V2metrics(V(:,3),'sampling_rate',10,'ibi_thresh',5e3);

C = C + xtools.binCost([1e4, 1.5e4],metrics.Int1.burst_period);
C = C + xtools.binCost([1e4, 1.5e4],metrics.LG.burst_period);

% force regular bursting
C = C + xtools.binCost([0, 0.03],metrics.Int1.burst_period_std/metrics.Int1.burst_period);
C = C + xtools.binCost([0, 0.03],metrics.LG.burst_period_std/metrics.Int1.burst_period);

% force both to oscillate at the same period
C = C + xtools.binCost([0 0.01],abs(metrics.LG.burst_period - metrics.Int1.burst_period)/(metrics.LG.burst_period + metrics.Int1.burst_period));


% find PD burst starts
[metrics.PD,PD_burst_starts, PD_burst_ends] = xtools.V2metrics(V(:,1),'sampling_rate',10);

LG_start_phase = NaN*LG_burst_starts;
for i = 1:length(LG_burst_starts)


	last_PD_start = PD_burst_starts(find(PD_burst_starts<LG_burst_starts(i),1,'last'));

	LG_start_phase(i) = ((LG_burst_starts(i) - last_PD_start)/10)/metrics.PD.burst_period;


end

% make sure LG starts at around .5 in PD phase
for i = 1:length(LG_start_phase)
	C = C + xtools.binCost([0.45 .55],LG_start_phase(i));
end
