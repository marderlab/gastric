data_root = '/Volumes/HYDROGEN/srinivas_data/gastric-data';


%% Analysis of gastric and pyloric rhythms at different temperatures
% In this document we look at pyloric and gastric rhtyhms at differnet temperatures.
% This data is from Dan Powell and the experiments that go into this are:

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


% compute burst metrics of all LG neurons
data = crabsort.computePeriods(data,'neurons',{'PD'},'ibis',.18,'min_spikes_per_burst',2);
data = crabsort.computePeriods(data,'neurons',{'LG'},'ibis',1,'min_spikes_per_burst',5);



% show raw traces of spontaenous vs. evoked 
figure('outerposition',[300 300 1200 900],'PaperUnits','points','PaperSize',[1200 900]); hold on

spont_files = {'941_006','901_086','901_080','901_062'};
evoked_files = {'0029','0032','0012','0020'};



for i = 1:length(spont_files)


	C = crabsort(false);
	C.path_name = [data_root filesep spont_files{i}];

		
	if exist([C.path_name spont_files{i} '_0000.abf'],'file')
		C.file_name = [spont_files{i} '_0000.abf'];
		C.loadFile;
	else
		C.file_name = [spont_files{i} '_0000.crab'];
		C.loadFile;
	end


	subplot(2,2,i); hold on

	raw_data = C.raw_data(:,strcmp(C.common.data_channel_names,'lgn'));
	raw_data = raw_data/max(abs(raw_data));
	plot(C.time,raw_data + 2,'k');


	raw_data = C.raw_data(:,strcmp(C.common.data_channel_names,'dgn'));
	raw_data = raw_data/max(abs(raw_data));
	plot(C.time,raw_data ,'k');


	% now show evoked rhythms at the same temperatures

	if exist([C.path_name spont_files{i} '_' evoked_files{i} '.abf'],'file')
		C.file_name = [spont_files{i} '_' evoked_files{i} '.abf'];
		C.loadFile;
	else
		C.file_name = [spont_files{i} '_' evoked_files{i} '.crab'];
		C.loadFile;
	end

	raw_data = C.raw_data(:,strcmp(C.common.data_channel_names,'lgn'));
	raw_data = raw_data/max(abs(raw_data));
	plot(C.time,raw_data - 2,'r');


	raw_data = C.raw_data(:,strcmp(C.common.data_channel_names,'dgn'));
	raw_data = raw_data/max(abs(raw_data));
	plot(C.time(1:10:end),raw_data(1:10:end) - 4,'r');

	set(gca,'XLim',[0 60],'YTick',[])


end

figlib.pretty('PlotLineWidth',1)



% plot spontanous vs. evoked burst periods in LG

spont.LG_T = [];
spont.PD_T = [];
spont.PD_duty_cycle = [];

evoked.LG_T = [];
evoked.PD_T = [];
evoked.PD_duty_cycle = [];

idx = 1;

for i = 1:length(data)
	if ~any(strcmp(spont_files,char(data(i).experiment_idx)))
		continue
	end

	
	% spont
	z = 1e-3*find(data(i).mask==0,1,'first');

	LG_T = data(i).LG_burst_periods;
	PD_T = data(i).PD_burst_periods;
	LG_T(data(i).LG_burst_starts > z) = [];
	PD_T(data(i).PD_burst_starts > z) = [];

	LG_T(LG_T>100) = [];
	PD_T(PD_T>5) = [];

	spont.LG_T = [spont.LG_T; nanmean(LG_T)];
	spont.PD_T = [spont.PD_T; nanmean(PD_T)];


	spont.raw_PD_T{idx} = PD_T;


	% evoked

	temp_ok = find(abs(data(i).temperature - 11) < .1);
	temp_ok(temp_ok>min(find(round(data(i).temperature) > 13))) = [];
	z = max(temp_ok);

	% find the last stim at this temp
	stim_times = find(data(i).mask==0);
	a = stim_times(find(stim_times < z,1,'last'));

	a = a*1e-3;
	z = z*1e-3;

	LG_T = data(i).LG_burst_periods;
	PD_T = data(i).PD_burst_periods;

	rm_this = data(i).LG_burst_starts > z | data(i).LG_burst_starts < a;
	LG_T(rm_this) = [];
	rm_this = data(i).PD_burst_starts > z | data(i).PD_burst_starts < a;
	PD_T(rm_this) = [];

	LG_T(LG_T>100) = [];
	PD_T(PD_T>5) = [];

	evoked.LG_T = [evoked.LG_T; nanmean(LG_T)];
	evoked.PD_T = [evoked.PD_T; nanmean(PD_T)];

	evoked.raw_PD_T{idx} = PD_T;

	idx = idx + 1;

end


figure('outerposition',[300 300 1200 600],'PaperUnits','points','PaperSize',[1200 600]); hold on
subplot(1,2,1); hold on
plot(evoked.LG_T,spont.LG_T,'ro')
plot(evoked.PD_T,spont.PD_T,'ko')
plotlib.drawDiag;
set(gca,'XScale','log','YScale','log','XLim',[.5 100],'YLim',[.5 100])
axis square
xlabel('Evoked period (s)')
ylabel('Spontaenous period (s)')


figlib.pretty()
