figure('outerposition',[300 300 1200 600],'PaperUnits','points','PaperSize',[1200 600]); hold on
for i = 1:length(data)
	subplot(3,3,i); hold on

	% find PD bursts immediately preceding LG bursts
	relevant_PDbs = zeros(size(data(i).LG_burst_starts));
	relevant_PDbp = zeros(size(data(i).LG_burst_starts));
	burst_index = zeros(size(data(i).LG_burst_starts));
	for j = 1:length(data(i).LG_burst_starts)
		for k = 1:length(data(i).PD_burst_starts)
			if data(i).PD_burst_starts(k) > data(i).LG_burst_starts(j)
				relevant_PDbs(j) = data(i).PD_burst_starts(k-1);
				relevant_PDbp(j) = data(i).PD_burst_periods(k-1);
				burst_index(j) = k-1;
				break;
			end
		end
	end


	x = round(data(i).PD_burst_starts*1e3);
	plot(data(i).temperature(x),data(i).PD_burst_periods,'r.')

	set(gca,'YScale','log','XLim',[6 24])

	title(data(i).experiment_idx)

	if i == 1
		ylabel('PD Burst Period (s)')
		xlabel('PDbp Since LGbs')
	end
end

figlib.pretty('fs',14)
