
function data = getEvokedData()


data_root = '/Volumes/HYDROGEN/srinivas_data/gastric-data';



include_these = sort({'901_005','901_086','901_046','901_049','901_052','901_062','901_080','901_095','901_098','932_151','941_003','941_006'});

disp(include_these')

if exist('dan_stacked_data.mat','file') == 2

	load('dan_stacked_data','data')
else
	for i = 1:length(include_these)
		data(i)  = crabsort.consolidate('neurons',{'PD','LG'},'DataFun',{@crabsort.getTemperature},'DataDir',[data_root filesep include_these{i}],'stack',true);
	end

	save('dan_stacked_data','data','-nocompression','-v7.3')

end




% make sure spiketimes are sorted
for i = 1:length(data)
	data(i).PD = sort(data(i).PD);
	data(i).LG = sort(data(i).LG);
end
