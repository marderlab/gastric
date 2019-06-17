%%
% This script makes figure 1, which shows that gastric rhythms can be evoked/exist at temperatures above 13C


data_root = '/Volumes/HYDROGEN/srinivas_data/gastric-data';


%% Analysis of gastric and pyloric rhythms at different temperatures
% In this document we look at pyloric and gastric rhtyhms at differnet temperatures.
% This data is from Dan Powell and the experiments that go into this are:

include_these = {'901_086','901_046','901_049','901_052','901_062','901_080','901_095','901_098'};

disp(include_these')

if exist('dan_stacked_data.mat','file') == 2

	load('dan_stacked_data','data')
else
	for i = 1:length(include_these)
		data(i)  = crabsort.consolidate('neurons',{'PD','LG'},'DataFun',{@crabsort.getTemperature},'DataDir',[data_root filesep include_these{i}],'stack',true);
	end

	save('dan_stacked_data','data','-nocompression','-v7.3')

end



figure('outerposition',[300 300 603 901],'PaperUnits','points','PaperSize',[603 901]); hold on


C = parula(100);

c = crabsort(false);
c.path_name = [data_root filesep '901_046'];

show_these = {'0006','0027','0054','0069','0079'};


for i = 1:length(show_these)
	c.file_name = ['901_046_' show_these{i} '.abf'];

	c.loadFile;

	channel = find(strcmp(c.common.data_channel_names,'lgn'));
	temp = (strcmp(c.common.data_channel_names,'temperature'));
	temp = mean(c.raw_data(:,temp));
	temp_text = [mat2str(round(temp)) 'C'];
	temp = round(((temp-5)/(25-5))*100);



	lgn = c.raw_data(:,channel);
	lgn = lgn/std(lgn);

	subplot(length(show_these),1,i); hold on
	time = (1:length(lgn))*c.dt;
	plot(time,lgn,'Color',C(temp,:))
	set(gca,'XLim',[0 30])

	neurolib.raster(c.spikes.lgn.LG*c.dt,'deltat',1,'yoffset',min(lgn)-1,'Color','r','center',false)
	neurolib.raster(c.spikes.pdn.PD*c.dt,'deltat',1,'yoffset',min(lgn)-2,'Color','k','center',false)

	if i < length(show_these)
		set(gca,'XColor','w')
	else
		xlabel('Time (s)')
	end

	set(gca,'YTick',[])

	y = ylabel(temp_text);
	y.Rotation = 0;
	y.HorizontalAlignment = 'right';

	if i == 1
		title('Elicited rhythms')
	end
end

figlib.pretty('PlotLineWidth',1)
