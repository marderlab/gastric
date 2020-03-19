function init(x,~)


% configure AB gbars so that we get a nice duty cycle
% use parameters from the neuroDB project

varnames = evalin('base','whos');
if any(strcmp({varnames.class},'neuroDB'))
	% already exists
	n = evalin('base','n');
else
	n = neuroDB();
	n.DataDump = [fileparts(fileparts(which('neuroDB'))) filesep 'prinz' filesep];
	assignin('base','n',n);
end


show_these = find(n.results.burst_period > .95e3 ...
	            & n.results.burst_period < 1.05e3 ...
	            & n.results.burst_period_std./n.results.burst_period < .01 ...
	            & n.results.duty_cycle_mean > .25 ...
	            & n.results.duty_cycle_mean < .3 ...
	            & n.results.duty_cycle_std./n.results.duty_cycle_mean < .01 ...
	            & n.results.n_spikes_per_burst_mean > 10 ...
	            & n.results.n_spikes_per_burst_mean < 15 ...
	            & n.results.min_V_in_burst_mean > n.results.min_V_mean ...
	            & n.results.min_V_mean < -60);  

show_these = veclib.shuffle(show_these);


x.set('*AB*gbar', n.results.all_g(show_these(1),:));