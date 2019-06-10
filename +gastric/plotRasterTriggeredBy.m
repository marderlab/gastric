function plotRasterTriggeredBy(data,neuron, trigger, before_after)

if nargin < 4
	before = 3;
	after = 3;
else
	before = before_after(1);
	after = before_after(2);
end



trigger_points = data.(trigger);
spikes = NaN(200,length(trigger_points));
temperature = NaN*trigger_points;

for j = 1:length(trigger_points)
	these_spikes = data.(neuron)(data.(neuron) > (trigger_points(j) - before) & data.(neuron) < (trigger_points(j) + after));

	if isempty(these_spikes)
		continue
	end

	if length(these_spikes) > 2e3
		these_spikes = these_spikes(1:2e3);
	end

	these_spikes = these_spikes - trigger_points(j);
	spikes(1:length(these_spikes),j) = these_spikes;
	temperature(j) = data.temperature(round(trigger_points(j)*1e3));
end

[temperature,idx] = sort(temperature);
spikes = spikes(:,idx);

C = temperature;
C =  C - min(C);
C = C/max(C);
C = round(C*99 + 1);


c = parula(120);
c(end,:) = [0 0 0];

% if no temp data avaialble, set to black
C(isnan(C)) = length(c);

for j = 1:length(trigger_points)
	neurolib.raster(spikes(:,j),'Color',c(C(j),:),'deltat',1,'yoffset',j,'center',false)
end

plot([0 0],[0 length(trigger_points)],'k--')
set(gca,'XLim',[-before after],'YLim',[0 length(trigger_points)]);
