function plotRasterTriggeredBy(data, varargin)


options.neuron = '';
options.trigger = '';
options.before = 3;
options.after = 3;
options.min_temp = 5;
options.max_temp = 23;
options.N_rescale = NaN;
options.use_raster = false;
options.MarkerSize = 1;

options = corelib.parseNameValueArguments(options, varargin{:});


structlib.packUnpack(options)


if ~isnan(N_rescale)
	assert(N_rescale>0,'N_rescale must be a +ve integer')
	assert(isscalar(N_rescale),'N_rescale must be a +ve integer')
	assert(N_rescale == round(N_rescale),'N_rescale must be a +ve integer')
end

trigger_points = data.(trigger);
spikes = NaN(200,length(trigger_points));
temperature = NaN*trigger_points;

neuron_burst_starts = data.([neuron '_burst_starts']);
neuron_burst_periods = data.([neuron '_burst_periods']);

for j = 1:length(trigger_points)
	these_spikes = data.(neuron)(data.(neuron) > (trigger_points(j) - before) & data.(neuron) < (trigger_points(j) + after));

	if isempty(these_spikes)
		continue
	end

	if length(these_spikes) > 2e3
		these_spikes = these_spikes(1:2e3);
	end

	these_spikes = these_spikes - trigger_points(j);
	
	temperature(j) = data.temperature(round(trigger_points(j)*1e3));

	% should we rescale time? 
	if ~isnan(N_rescale)
		idx = find(neuron_burst_starts<trigger_points(j),1,'last');
		mean_neuron_period = nanmean(neuron_burst_periods(idx-N_rescale:idx));
		these_spikes = these_spikes/mean_neuron_period;

	end
	spikes(1:length(these_spikes),j) = these_spikes;

end

[temperature,idx] = sort(temperature);
spikes = spikes(:,idx);


C = temperature;
C =  C - min_temp;
C = C/(max_temp - min_temp);
C = round(C*99 + 1);

% prevent over or underflows
C(C>100) = 100;
C(C<1) = 1;

c = colormaps.redula(101);
c(end,:) = [0 0 0];

% if no temp data avaialble, set to black
C(isnan(C)) = length(c);

for j = 1:length(trigger_points)
	if options.use_raster
		neurolib.raster(spikes(:,j),'Color',c(C(j),:),'deltat',1,'yoffset',j,'center',false)
	else
		plot(spikes(:,j),spikes(:,j)*0 + j,'.', 'Color',c(C(j),:),'MarkerSize',MarkerSize)
	end
end

plot([0 0],[0 length(trigger_points)],'k--')
set(gca,'XLim',[-before after],'YLim',[0 length(trigger_points)]);
