%%
% The point of fig 3 is to compare burst periods of PD and LG as temperature is varied. 

clearvars
close all
addpath('../')

colors = gastric.colors;


%% Analysis of gastric and pyloric rhythms at different temperatures
% In this document we look at pyloric and gastric rhtyhms at differnet temperatures.
% This data is from Dan Powell and the experiments that go into this are:

data = gastric.getEvokedData();


% compute burst metrics of all LG neurons
data = crabsort.computePeriods(data,'neurons',{'PD'},'ibis',.18,'min_spikes_per_burst',2);
data = crabsort.computePeriods(data,'neurons',{'LG'},'ibis',1,'min_spikes_per_burst',5);
data = crabsort.computePeriods(data,'neurons',{'DG'},'ibis',1,'min_spikes_per_burst',5);




all_x_PD = [];
all_y_PD = [];
all_prep_PD = [];

all_x_LG = [];
all_y_LG = [];
all_prep_LG = [];


clear ax
figure('outerposition',[300 300 1400 555],'PaperUnits','points','PaperSize',[1400 555]); hold on
for i = 1:length(data)

	if i == 2
		ax.preps(i) = subplot(1,3,1); hold on
	end

	y = data(i).PD_burst_periods;
	% remove some outliers
	y(y>5)= NaN;
	x = round(data(i).PD_burst_starts*1e3);
	T = data(i).temperature(x);

	all_x_PD = [all_x_PD; T];
	all_y_PD = [all_y_PD; y];
	all_prep_PD = [all_prep_PD; i + 0*x];

	if i == 2
		plot(T,y,'.','Color',colors.PD)
	end

	f = 1./y;
	f0 = nanmean(f(abs(T - 11) < .1));
	q10 = ((f./f0).^(10./(T-11)));
	q10(q10>10) = NaN;
	data(i).Q_PD_mean = nanmean(q10);
	data(i).Q_PD_std = nanstd(q10)/sqrt(sum(~isnan(q10)));





	% LG

	y = data(i).LG_burst_periods;
	% remove some outliers
	y(y>50)= NaN;

	x = round(data(i).LG_burst_starts*1e3);
	T = data(i).temperature(x);

	if i == 2
		plot(T,y,'.','Color',colors.LG)
	end


	all_x_LG = [all_x_LG; T];
	all_y_LG = [all_y_LG; y];
	all_prep_LG = [all_prep_LG; i + 0*x];

	f = 1./y;
	f0 = nanmean(f(abs(T - 11) < .1));
	q10 = ((f./f0).^(10./(T-11)));
	q10(q10>10) = NaN;
	data(i).Q_LG_mean = nanmean(q10);
	data(i).Q_LG_std =nanstd(q10)/sqrt(sum(~isnan(q10)));

	set(gca,'YScale','log','XLim',[6 24],'YTick',[.1 1 10 100],'YLim',[.1 100])


	xlabel(gastric.tempLabel);
	ylabel('Burst period (s)');


end



ax.all_periods = subplot(1,3,2); hold on
temp_space = 7:2:23;
ph_PD = gastric.groupAndPlotErrorBars(temp_space, all_x_PD, all_prep_PD, all_y_PD);



for i = 1:length(ph_PD)-1
	set(ph_PD(i),'Color',brighten(colors.PD,.9))
end


ph_LG = gastric.groupAndPlotErrorBars(temp_space, all_x_LG, all_prep_LG, all_y_LG);



for i = 1:length(ph_LG)-1
	set(ph_LG(i),'Color',brighten(colors.LG,.9))
end
set(ph_LG(end),'Color',colors.LG)

set(gca,'YScale','log')

xlabel(['Temperature (' char(176) 'C)'])
ylabel('Burst period (s)')



clear l
l(1) = plot(NaN,NaN,'o','MarkerFaceColor',colors.PD,'MarkerEdgeColor',colors.PD);
l(2) = plot(NaN,NaN,'o','MarkerFaceColor',colors.LG,'MarkerEdgeColor',colors.LG);
legend(l,{'PD','LG'});







ax.q10s = subplot(1,3,3); hold on
% LGE = [data.Q_LG_std];
% PDE = [data.Q_PD_std];

% noise = randn(length(LGE),1)/10;
% e = errorbar(noise + 1,[data.Q_LG_mean],LGE);
% e.LineStyle = 'none';
% e.Color = 'r';
% e.Marker = 'o';
% e.MarkerFaceColor = 'r';

% e = errorbar(noise + 2,[data.Q_PD_mean],PDE);
% e.LineStyle = 'none';
% e.Color = 'k';
% e.Marker = 'o';
% e.MarkerFaceColor = 'k';

% set(ax.q10s,'XTickLabel',{'LG','PD'},'YLim',[0 3],'XTick',[1 2],'XLim',[.5 2.5])
% ylabel('Q_{10}')

% ax.q10s.Position(3) = .1;


e = errorbar(ax.q10s,[data.Q_PD_mean],[data.Q_LG_mean],[data.Q_PD_std],[data.Q_PD_std],[data.Q_LG_std],[data.Q_LG_std]);
e.LineStyle = 'none';
e.Marker = 'o';
e.MarkerFaceColor = 'k';
e.MarkerEdgeColor = 'k';
e.Color = 'k';
ax.q10s.XLim = [0 3];
ax.q10s.YLim = [0 3];


plotlib.drawDiag(ax.q10s,'Color',[.6 .6 .6],'LineStyle','--');
xlabel('Q_{10} of PD burst period')
ylabel('Q_{10} of LG burst period')
figlib.pretty()


ax.q10s.XColor = colors.PD;
ax.q10s.YColor = colors.LG;

figlib.saveall('Location',pwd,'SaveName',mfilename)


return



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









ax.firing_rate = subplot(2,2,4); hold on
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


xlabel(['Temperature (' char(176) 'C)'])
ylabel('Within-burst frequency (Hz)')




figlib.pretty('FontSize',18)



% for i = 1:length(ax.preps)
% 	ax.preps(i).Position(4) = .18;
% 	if rem(i,5) ~= 1
% 		ax.preps(i).OuterPosition(3) = .13;
% 	end
% end

% for i = 1:5
% 	ax.preps(i).Position(2) = .71;
% end

% for i = 6:length(ax.preps)
% 	ax.preps(i).Position(2) = .5;
% end

% ax.all_periods.Position(1) = .11;
% ax.firing_rate.Position(1) = .71;


% xh.Position = [60 .015];
% yh.Position = [-2 200];

ax.all_periods.YMinorTick = 'on';
ax.all_periods.XMinorTick = 'off';
ax.all_periods.XTick = 7:4:23;
ax.all_periods.YTick = [.1 1 10 100];
axis(ax.preps(2),'square')


figlib.saveall('Location',pwd,'SaveName',mfilename)