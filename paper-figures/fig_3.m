%%
% The point of fig 3 is to compare burst periods of PD and LG as temperature is varied. 


clear all
close all

data_root = '/Volumes/HYDROGEN/srinivas_data/gastric-data';


%% Analysis of gastric and pyloric rhythms at different temperatures
% In this document we look at pyloric and gastric rhtyhms at differnet temperatures.
% This data is from Dan Powell and the experiments that go into this are:

include_these = sort({'901_005','901_086','901_046','901_049','901_052','901_062','901_080','901_095','901_098','932_151','941_003','941_006'});

disp(include_these')

if exist('../dan_stacked_data.mat','file') == 2

	load('../dan_stacked_data','data')
else
	for i = 1:length(include_these)
		data(i)  = crabsort.consolidate('neurons',{'PD','LG'},'DataFun',{@crabsort.getTemperature},'DataDir',[data_root filesep include_these{i}],'stack',true);
	end

	save('../dan_stacked_data','data','-nocompression','-v7.3')

end



% make sure spiketimes are sorted
for i = 1:length(data)
	data(i).PD = sort(data(i).PD);
	data(i).LG = sort(data(i).LG);
end


% compute burst metrics of all LG neurons
data = crabsort.computePeriods(data,'neurons',{'PD'},'ibis',.18,'min_spikes_per_burst',2);
data = crabsort.computePeriods(data,'neurons',{'LG'},'ibis',1,'min_spikes_per_burst',5);




%% Burst period vs. temperature
% In the following figure, I plot burst periods of LG and PD neurons as a function of temperature for each prep. Black dots are PD bursts, red dots are LG bursts. Note that they both decrease at approximately the same rate. 

figure('outerposition',[300 300 1001 901],'PaperUnits','points','PaperSize',[1001 901]); hold on
for i = 1:length(data)
	subplot(3,4,i); hold on

	y = data(i).PD_burst_periods;
	% remove some outliers
	y(y>5)= NaN;
	x = round(data(i).PD_burst_starts*1e3);
	T = data(i).temperature(x);


	plot(T,y,'k.')

	f = 1./y;
	f0 = nanmean(f(abs(T - 11) < .1));
	q10 = ((f./f0).^(10./(T-11)));
	q10(q10>10) = NaN;
	data(i).Q_PD_mean = nanmean(q10);
	data(i).Q_PD_std = nanstd(q10)/sqrt(sum(~isnan(q10)));


	y = data(i).LG_burst_periods;
	% remove some outliers
	y(y>50)= NaN;

	x = round(data(i).LG_burst_starts*1e3);
	T = data(i).temperature(x);
	plot(T,y,'r.')

	f = 1./y;
	f0 = nanmean(f(abs(T - 11) < .1));
	q10 = ((f./f0).^(10./(T-11)));
	q10(q10>10) = NaN;
	data(i).Q_LG_mean = nanmean(q10);
	data(i).Q_LG_std =nanstd(q10)/sqrt(sum(~isnan(q10)));

	set(gca,'YScale','log','XLim',[6 24])

	title(char(data(i).experiment_idx),'interpreter','none')
	if i == 9
		xlabel('Temperature (C)')
		ylabel('Burst period (s)')
	end
	if i < 9
		set(gca,'XTickLabel',{})
	end
	if rem(i,4) == 1
	else
		set(gca,'YTickLabel',{})
	end
end

figlib.pretty('FontSize',16)
pdflib.snap()



figure('outerposition',[300 300 1200 600],'PaperUnits','points','PaperSize',[1200 600]); hold on

subplot(1,2,1); hold on

LGE = [data.Q_LG_std]/2;
PDE = [data.Q_PD_std]/2;
errorbar([data.Q_LG_mean],[data.Q_PD_mean],PDE,PDE,LGE,LGE,'o');
plotlib.drawDiag;
axis square

xlabel('Q_{10} (LG)')
ylabel('Q_{10} (PD)')

figlib.pretty()