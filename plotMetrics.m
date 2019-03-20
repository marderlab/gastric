function ax = plotMetrics(data, thing_to_plot, neurons)


figure('outerposition',[300 300 600 900],'PaperUnits','points','PaperSize',[600 900]); hold on



for i = 1:length(neurons)
	ax(i) = subplot(length(neurons),1,i); hold on
	set(ax(i),'YScale','linear','YLim',[1e-2 20],'XLim',[0 8e3],'XTick',[])
	ylabel(ax(i),neurons{i})
end
set(ax(i),'XTick',[0:1e3:8e3])
title(ax(1),thing_to_plot,'interpreter','none')

xlabel(ax(end),'Time (s)')

c = parula(100);
min_temp = min(vertcat(data.temperature));
max_temp = max(vertcat(data.temperature));

skipped_time = 0;

for i = 1:length(data)

	if data(i).abs_max(:,1) > 8
		skipped_time = skipped_time + data(i).T;
		for j = 1:length(neurons)
			lh = plotlib.vertline(ax(j),data(i).time_offset -skipped_time+ data(i).T);
			lh.Color = 'r';
		end

		continue
	end

	this_temp = mean(data(i).temperature);
	C = c(floor(1+(this_temp - min_temp)/(max_temp - min_temp)*99),:);

	for j = 1:length(neurons)

		if ~isfield(data(i),[neurons{j} '_burst_starts'])
			continue
		end
		X = data(i).([neurons{j} '_burst_starts']);
		X = X + data(i).time_offset - skipped_time;
		Y = data(i).([neurons{j} '_' thing_to_plot]);

		if isempty(X)
			continue
		end

		plot(ax(j),X,Y,'.','Color',C)

	end
end


figlib.pretty('plw',1,'lw',1.5,'fs',14)