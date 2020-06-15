function plotLGRasters(data,ax, min_temp, max_temp, prep_offset)
c = colormaps.redula(100);

if ~exist('prep_offset','var')
	prep_offset = 15;
end

set(ax,'XLim',[0 120],'YColor','w','XColor','w')

offset = 5;
for i = 1:length(data)
	this_data = data{i};
	for j = 1:length(this_data)
		spiketimes = sort(this_data(j).LG);
		if length(spiketimes) < 2
			continue
		end
		if this_data(j).decentralized
			continue
		end

		if isnan(this_data(j).temperature)
			continue
		end

		if sum(spiketimes < 60) < 20
			continue
		end



		idx = ceil(((this_data(j).temperature - min_temp)/(max_temp - min_temp))*100);
		idx(idx>length(c)) = length(c);
			idx(idx<1) = 1;
		neurolib.raster(this_data(j).LG,'deltat',1,'yoffset',offset,'Color',c(idx,:),'center',true)

		offset = offset +  1;
	end

	if i < length(data)
		plotlib.horzline(offset + prep_offset/2,'LineWidth',1,'Color','k');
	end

	offset = offset + prep_offset;

	

end
