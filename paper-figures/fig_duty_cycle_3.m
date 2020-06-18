
clearvars
close all
addpath('../')


data = gastric.getEvokedData();


min_temp = 5;
max_temp = 25;



% compute burst metrics of all LG neurons
data = crabsort.computePeriods(data,'neurons',{'PD'},'ibis',.18,'min_spikes_per_burst',2);
data = crabsort.computePeriods(data,'neurons',{'LG'},'ibis',1,'min_spikes_per_burst',5);
data = crabsort.computePeriods(data,'neurons',{'DG'},'ibis',1,'min_spikes_per_burst',5);


% compute duty cycles everywhre
neurons = {'PD','LG','DG'};
for i = 1:length(data)
	for j = 1:length(neurons)
		data(i).([neurons{j} '_duty_cycles']) = data(i).([neurons{j} '_burst_durations'])./data(i).([neurons{j} '_burst_periods']);
	end
end


example = 1;
temp = data(example).temperature;
temp(data(example).mask == 0) = NaN;
temp = temp(round(data(example).PD_burst_starts*1e3));

y = data(example).PD_duty_cycles;

temp_space = 11:2:23;
C = colormaps.redula(length(temp_space));
my = NaN*temp_space;
sy = NaN*temp_space;

for i = 1:length(temp_space)
	my(i) = nanmean(y(round(temp) == temp_space(i)));
	sy(i) = nanstd(y(round(temp) == temp_space(i)));
end

figure('outerposition',[300 300 1200 1199],'PaperUnits','points','PaperSize',[1200 1199]); hold on
subplot(2,2,1); hold on


for i = 1:length(temp_space)
	thisx = temp(round(temp) == temp_space(i));
	thisy = y(round(temp) == temp_space(i));;

	scatter(thisx,thisy,24,C(i,:),'MarkerFaceAlpha',.01,'MarkerEdgeAlpha',.01,'MarkerFaceColor',C(i,:));

end

errorbar(temp_space,my,sy,'k')

set(gca,'YLim',[0 1],'XLim',[10 24])

ylabel('PD Duty cycle')
xlabel(gastric.tempLabel)


% show LG
subplot(2,2,2); hold on

temp = data(example).temperature;
temp(data(example).mask == 0) = NaN;
temp = temp(round(data(example).LG_burst_starts*1e3));

y = data(example).LG_duty_cycles;

temp_space = 11:2:23;
my = NaN*temp_space;
sy = NaN*temp_space;

for i = 1:length(temp_space)
	my(i) = nanmean(y(round(temp) == temp_space(i)));
	sy(i) = nanstd(y(round(temp) == temp_space(i)));
end

for i = 1:length(temp_space)
	thisx = temp(round(temp) == temp_space(i));
	thisy = y(round(temp) == temp_space(i));

	scatter(thisx,thisy,24,C(i,:),'MarkerFaceAlpha',.5,'MarkerEdgeAlpha',.5,'MarkerFaceColor',C(i,:));

end

errorbar(temp_space,my,sy,'k')

set(gca,'YLim',[0 1],'XLim',[10 24])

ylabel('LG Duty cycle')
xlabel(gastric.tempLabel)


% now show all preps - PD

subplot(2,2,3); hold on
all_PD_temp = [];
all_PD_prep = [];
all_PD_dc = [];

for i = 1:length(data)

	temp = data(i).temperature;
	temp(data(i).mask == 0) = NaN;
	temp = temp(round(data(i).PD_burst_starts*1e3));

	all_PD_temp = [all_PD_temp; temp];
	all_PD_prep = [all_PD_prep; 0*temp + i];
	all_PD_dc = [all_PD_dc; data(i).PD_duty_cycles];

end

ph_PD = gastric.groupAndPlotErrorBars(temp_space, all_PD_temp, all_PD_prep, all_PD_dc,'UseSEM',false);

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

set(gca,'YLim',[0 1],'XLim',[10 24])

ylabel('PD Duty cycle')
xlabel(gastric.tempLabel)


% now show all preps - LG

subplot(2,2,4); hold on
all_LG_temp = [];
all_LG_prep = [];
all_LG_dc = [];

for i = 1:length(data)

	temp = data(i).temperature;
	temp(data(i).mask == 0) = NaN;
	temp = temp(round(data(i).LG_burst_starts*1e3));

	all_LG_temp = [all_LG_temp; temp];
	all_LG_prep = [all_LG_prep; 0*temp + i];
	all_LG_dc = [all_LG_dc; data(i).LG_duty_cycles];

end

ph_LG = gastric.groupAndPlotErrorBars(temp_space, all_LG_temp, all_LG_prep, all_LG_dc,'UseSEM',false);

C = ones(length(ph_LG),3);
C(:,2) = .8+ .05*randn(length(ph_LG),1);
C(:,3) = .8+ .05*randn(length(ph_LG),1);
C(C>1) = 1;
C(C<0) = 0;


for i = 1:length(ph_LG)-1
	set(ph_LG(i),'Color',C(i,:))
end
set(ph_LG(end),'Color','r')

set(gca,'YLim',[0 1],'XLim',[10 24])

ylabel('LG Duty cycle')
xlabel(gastric.tempLabel)


figlib.pretty()

try
	figlib.saveall('Location',  '/Users/srinivas/Dropbox/Temp-Paper/Temperature-Paper/individual-figures','SaveName',mfilename)
catch

end

