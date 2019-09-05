
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


% show one example

idx = 1;

figure('outerposition',[3 3 902 901],'PaperUnits','points','PaperSize',[902 901]); hold on
clear ax

mask_color = [1 1 1]*.9;

t_end = [10e3, 6e3, 6e3];

for prep_idx = [2 5 10]


	for j = 1:length(neurons)
		x = data(prep_idx).([neurons{j} '_burst_starts']);

		y = data(prep_idx).([neurons{j} '_duty_cycles']);
		y(y>1) = NaN;
		y(y<0) = NaN;
		ax(idx,j) = subplot(3,3,(j-1)*3 + idx); hold on
		C = data(prep_idx).temperature(round(x*1e3));
		sh = scatter(x, y,20,C);
		sh.Marker = '.';

		if idx == 1
			ylabel([neurons{j} ' duty cycle'])
		else
			set(gca,'YTickLabel',{})
		end

		if j < length(neurons)
			set(gca,'XTickLabel',{})
		else
			xlabel('Time (s)')
		end

		if j > 1
			sh.SizeData = 40;
		end

		% plot mask
		M = veclib.subSample(data(prep_idx).mask,1e3,@min);
		M(M>0)=2;
		plot(M,'Color',mask_color,'LineWidth',3)

		set(gca,'YLim',[0 1],'XLim',[0 t_end(idx)])
	end

	colormap(colormaps.redula)


	idx = idx + 1;

end

figlib.pretty('LineWidth',1,'FontSize',14)




for i = 1:3
	ax(1,i).Position(1) = .1;
	for j = 1:3
		ax(i,j).Position(3) = .25;
	end
end

axlib.move(ax(2,:),'left',.02)