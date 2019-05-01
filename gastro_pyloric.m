data_root = '/Volumes/HYDROGEN/srinivas_data/gastric-data';
include_these = {'901_086','901_046','901_049','901_052','901_062','901_080','901_095','901_098'};


include_these = {'901_049','901_046'};

for i = 1:length(include_these)
	data(i)  = crabsort.consolidate('neurons',{'PD','LG'},'DataFun',{@crabsort.getTemperature},'DataDir',[data_root filesep include_these{i}],'stack',true);
end

