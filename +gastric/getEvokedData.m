
function data = getEvokedData()


data_root = '/Volumes/HYDROGEN/srinivas_data/gastric-data';


include_these = sort({'901_005','901_086','901_046','901_049','901_052','901_062','901_080','901_095','901_098','932_151'});

disp(include_these')

cache_loc = [fileparts(fileparts(which('gastric.getEvokedData'))) filesep 'data' filesep 'dan_stacked_data.mat'];

if exist(cache_loc,'file') == 2

	load(cache_loc,'data')
else
	for i = 1:length(include_these)
		data(i)  = crabsort.consolidate('neurons',{'PD','LG','DG'},'DataFun',{@crabsort.getTemperature},'DataDir',[data_root filesep include_these{i}],'stack',true);
	end

	save(cache_loc,'data','-nocompression','-v7.3')

end




% make sure spiketimes are sorted
for i = 1:length(data)
	data(i).PD = sort(data(i).PD);
	data(i).LG = sort(data(i).LG);
end
