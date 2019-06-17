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



%% supplementarty figure - show every prep 

all_x_PD = [];
all_y_PD = [];
all_prep_PD = [];

all_x_LG = [];
all_y_LG = [];
all_prep_LG = [];

figure('outerposition',[300 300 1001 901],'PaperUnits','points','PaperSize',[1001 901]); hold on
for i = 1:length(data)
	subplot(3,4,i); hold on

	y = data(i).PD_burst_periods;
	% remove some outliers
	y(y>5)= NaN;
	x = round(data(i).PD_burst_starts*1e3);
	T = data(i).temperature(x);

	all_x_PD = [all_x_PD; T];
	all_y_PD = [all_y_PD; y];
	all_prep_PD = [all_prep_PD; i + 0*x];


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


	all_x_LG = [all_x_LG; T];
	all_y_LG = [all_y_LG; y];
	all_prep_LG = [all_prep_LG; i + 0*x];

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




figure('outerposition',[300 300 1800 600],'PaperUnits','points','PaperSize',[1800 600]); hold on



subplot(1,3,1); hold on
temp_space = 7:2:23;
ph_PD = gastric.groupAndPlotErrorBars(temp_space, all_x_PD, all_prep_PD, all_y_PD);

R = randn(length(ph_PD),1);
C = ones(length(ph_PD),3);
C(:,1) = .8+ .05*R;
C(:,2) = .8+ .05*R;
C(:,3) = .8+ .05*R;

C(C>1) = 1;
C(C<0) = 0;

for i = 1:length(ph_PD)-1
	set(ph_PD(i),'Color',C(i,:))
end


ph_LG = gastric.groupAndPlotErrorBars(temp_space, all_x_LG, all_prep_LG, all_y_LG);


C = ones(length(ph_LG),3);
C(:,2) = .8+ .05*randn(length(ph_LG),1);
C(:,3) = .8+ .05*randn(length(ph_LG),1);
C(C>1) = 1;
C(C<0) = 0;

for i = 1:length(ph_LG)-1
	set(ph_LG(i),'Color',C(i,:))
end
set(ph_LG(end),'Color','r')

set(gca,'YScale','log')

xlabel('Temperature (C)')
ylabel('Burst period (s)')
axis square


clear l
l(1) = plot(NaN,NaN,'o','MarkerFaceColor','k','MarkerEdgeColor','k');
l(2) = plot(NaN,NaN,'o','MarkerFaceColor','r','MarkerEdgeColor','r');
legend(l,{'PD','LG'});



subplot(1,3,2); hold on
LGE = [data.Q_LG_std]/2;
PDE = [data.Q_PD_std]/2;
errorbar([data.Q_LG_mean],[data.Q_PD_mean],PDE,PDE,LGE,LGE,'o');
plotlib.drawDiag;
axis square

xlabel('Q_{10} (LG)')
ylabel('Q_{10} (PD)')



% plot firing rate within burst as a function of temperature

all_LG_isis = [];
all_LG_temp = [];
all_LG_prep = [];

all_PD_isis = [];
all_PD_temp = [];
all_PD_prep = [];

for i = 1:length(data)
	LG = [diff(data(i).LG); NaN];
	LG(LG>2) = NaN;
	all_LG_isis = [all_LG_isis; LG];
	all_LG_temp = [all_LG_temp; data(i).temperature(round(1e3*data(i).LG))];
	all_LG_prep = [all_LG_prep; LG*0 + i];

	PD = [diff(data(i).PD); NaN];
	PD(PD>.2) = NaN;
	all_PD_isis = [all_PD_isis; PD];
	all_PD_temp = [all_PD_temp; data(i).temperature(round(1e3*data(i).PD))];
	all_PD_prep = [all_PD_prep; PD*0 + i];
end

all_LG_isis(all_LG_isis<.01) = NaN;
all_PD_isis(all_PD_isis<.01) = NaN;

subplot(1,3,3); hold on
ph_LG = gastric.groupAndPlotErrorBars(temp_space, all_LG_temp, all_LG_prep, 1./all_LG_isis);

C = ones(length(ph_LG),3);
C(:,2) = .8+ .05*randn(length(ph_LG),1);
C(:,3) = .8+ .05*randn(length(ph_LG),1);
C(C>1) = 1;
C(C<0) = 0;

for i = 1:length(ph_LG)-1
	set(ph_LG(i),'Color',C(i,:))
end
set(ph_LG(end),'Color','r')

ph_PD = gastric.groupAndPlotErrorBars(temp_space, all_PD_temp, all_PD_prep, 1./all_PD_isis);

R = randn(length(ph_LG),1);
C = ones(length(ph_LG),3);
C(:,1) = .8+ .05*R;
C(:,2) = .8+ .05*R;
C(:,3) = .8+ .05*R;

C(C>1) = 1;
C(C<0) = 0;

for i = 1:length(ph_PD)-1
	set(ph_PD(i),'Color',C(i,:))
end

axis square

xlabel('Temperature (C)')
ylabel('Intra-burst frequency (Hz)')

figlib.pretty('FontSize',16)





