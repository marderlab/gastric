
clearvars
close all
addpath('../')


data = gastric.getEvokedData();


min_temp = 5;
max_temp = 25;



% compute burst metrics of all LG neurons
data = crabsort.computePeriods(data,'neurons',{'PD'},'ibis',.18,'min_spikes_per_burst',2);
data = crabsort.computePeriods(data,'neurons',{'LG'},'ibis',1,'min_spikes_per_burst',5);
data = crabsort.computePeriods(data,'neurons',{'DG'},'ibis',1,'min_spikes_per_burst',5);


% compute duty cycles everywhre
neurons = {'PD','LG','DG'};
for i = 1:length(data)
	for j = 1:length(neurons)
		data(i).([neurons{j} '_duty_cycles']) = data(i).([neurons{j} '_burst_durations'])./data(i).([neurons{j} '_burst_periods']);
	end
end

for i = 1:length(data)

	temperature = round(data(i).temperature);

	all_stim_times = find(data(i).mask == 0);
	stim_times = find(data(i).mask == 0);
	last_stim  = stim_times(end);
	stim_times = stim_times([diff(stim_times); NaN] > 120e3);
	stim_times = [stim_times; last_stim];



	data(i).stim_ends = [];
	data(i).stim_temp = [];

	for j = 1:length(stim_times)

		% figure out the temperature immediately after stim end
		stim_temp = round(mean(data(i).temperature(stim_times(j):stim_times(j)+5e3)));

		% when does the next stimulation occur? 
		next_stim = all_stim_times(find(all_stim_times>stim_times(j),1,'first'));

		% find out how long this temperature is maintained
		z = find(temperature(stim_times(j):next_stim) ~= stim_temp,1,'first') + stim_times(j);

		if isempty(z) && ~isempty(next_stim)
			% temperature maintained all the way to next stim
			z = next_stim - 1;
		elseif isempty(z) && isempty(next_stim)
			z = length(data(i).temperature);
		end

		if (z-stim_times(j))*1e-3 < 120
			% temperature held for less than 2 minutes
			continue
		end

		data(i).stim_ends = [data(i).stim_ends; stim_times(j)];
		data(i).stim_temp = [data(i).stim_temp; stim_temp];


	end

end


figure('outerposition',[300 300 700 901],'PaperUnits','points','PaperSize',[1200 901]); hold on
clear ax
show_these = [2 4 6 8 9];

temp_space = 7:4:23;
temp_space(end) = 21;

c = colormaps.redula(100);

T = 500;
buffer = 50;

for i = 1:length(show_these)

	ii = show_these(i);

	ax(i) = subplot(length(show_these),1,i); hold on

	set(gca,'XColor','w','XTick',[])

	set(gca,'YLim',[0 3],'YTick',[.5 1.5 2.5],'YTickLabel',{'PD','LG','DG'})

	xoffset = -T - buffer;

	for j = 1:length(temp_space)
		this_temp = temp_space(j);

		% find the point in time where this temp is stimulated
		stim_end = data(ii).stim_ends(find(data(ii).stim_temp == this_temp,1,'first'));
		
		xoffset = xoffset + T + buffer;

		if isempty(stim_end)
			continue
		end

		cidx = ceil(((this_temp - min_temp)/(max_temp - min_temp))*100);

		% show PD
		these_PD_bursts = data(ii).PD_burst_starts > stim_end*1e-3 & data(ii).PD_burst_starts < (stim_end*1e-3 + T);

		these_PD_duty_cycles = data(ii).PD_duty_cycles(these_PD_bursts);
		x = data(ii).PD_burst_starts(these_PD_bursts);
		
		if ~isempty(x)
			x = x - x(1);
			x = x + xoffset;
			plot(x,these_PD_duty_cycles,'.','Color',c(cidx,:))
		end


		% show LG
		these_LG_bursts = data(ii).LG_burst_starts > stim_end*1e-3 & data(ii).LG_burst_starts < (stim_end*1e-3 + T);

		these_LG_duty_cycles = data(ii).LG_duty_cycles(these_LG_bursts);
		x = data(ii).LG_burst_starts(these_LG_bursts);
		
		if ~isempty(x)
			x = x - x(1);
			x = x + xoffset;
			plot(x,these_LG_duty_cycles + 1,'.','Color',c(cidx,:))
		end

		% show DG
		these_DG_bursts = data(ii).DG_burst_starts > stim_end*1e-3 & data(ii).DG_burst_starts < (stim_end*1e-3 + T);

		these_DG_duty_cycles = data(ii).DG_duty_cycles(these_DG_bursts);
		x = data(ii).DG_burst_starts(these_DG_bursts);
		
		if ~isempty(x)
			x = x - x(1);
			x = x + xoffset;
			plot(x,these_DG_duty_cycles + 2,'.','Color',c(cidx,:))
		end



		plotlib.vertline(xoffset,'Color','k','LineWidth',1);
		

	end

	set(gca,'XLim',[0 (buffer + T)*length(temp_space)])

	for hi = 0:3
		plotlib.horzline(hi,'Color',[.5 .5 .5],'LineWidth',1);
	end


end

figlib.pretty('FontSize',13)

for i = 1:length(ax)
	ax(i).Position(4) = .15;
end

plot(ax(end),[T-120, T],[0 0],'LineWidth',3,'Color','k')
th = text(T-150,-.2,'2 min','Parent',ax(end),'FontSize',14);