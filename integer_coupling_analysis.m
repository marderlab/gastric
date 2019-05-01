%% 
% In this document we look at integer coupling b/w the pyloric and gastric burst periods

close all


		data_root = '/Volumes/HYDROGEN/srinivas_data/gastric-data';
		include_these = {'901_086','901_046','901_049','901_052','901_062','901_080','901_095','901_098'};

		for i = 1:length(include_these)

			data{i} = crabsort.consolidate('neurons',{'PD','LG'},'DataFun',{@crabsort.getTemperature,@crabsort.getDataStatistics},'DataDir',[data_root filesep include_these{i}],'stack',true);


		end


return


% first, gather all the data 
if ~exist('data','var')
	if exist('integer_coupling_data.mat','file') == 2

		load('integer_coupling_data.mat','data')
	else




		for i = 1:length(include_these)

			data{i} = crabsort.consolidate('neurons',{'PD','LG'},'DataFun',{@crabsort.getTemperature,@crabsort.getDataStatistics},'DataDir',[data_root filesep include_these{i}],'stack',true);


		end

		save('integer_coupling_data.mat','data')
	end
end
