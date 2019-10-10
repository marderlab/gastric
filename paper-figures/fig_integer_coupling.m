%%
% This figure shows that integer coupling persists across temperatures

clearvars
close all
addpath('../')


%% Analysis of gastric and pyloric rhythms at different temperatures
% In this document we look at pyloric and gastric rhtyhms at differnet temperatures.
% This data is from Dan Powell and the experiments that go into this are:

data = gastric.getEvokedData();



% compute burst metrics of all LG neurons
data = crabsort.computePeriods(data,'neurons',{'PD'},'ibis',.18,'min_spikes_per_burst',2);
data = crabsort.computePeriods(data,'neurons',{'LG'},'ibis',1,'min_spikes_per_burst',5);
data = crabsort.computePeriods(data,'neurons',{'DG'},'ibis',1,'min_spikes_per_burst',5);





%% Integer coupling b/w PD and LG periods
% The periods of PD and LG neurons have previously been shown the be integer-coupled, that is, the LG periods is an integer mulitple of the PD period. Here we see the same thing: the following figure plots the LG period vs. the mean PD periods during taht LG burst. Note that the gray lines are not fits to the data -- they are merely lines with integer slopes. Note that the data naturally falls on top of these lines. 




figure('outerposition',[300 300 1200 901],'PaperUnits','points','PaperSize',[1200 901]); hold on

clear ax
ax.LG.hero = subplot(2,2,1); hold on
ax.LG.remainders = subplot(2,3,4); hold on
ax.LG.ratio = subplot(2,3,6); hold on
ax.LG.integerness = subplot(2,3,5); hold on

ax.DG = ax.LG;
ax.DG.hero = subplot(2,2,2); hold on


c = lines;

ch = gastric.plotIntegerCoupling(data, 'LG', ax.LG, c(1,:));
delete(ch)


ch = gastric.plotIntegerCoupling(data, 'DG', ax.DG, c(2,:));


ax.LG.remainders.YLim = [0 1];
ax.LG.remainders.XLim = [0 1];
plotlib.drawDiag(ax.LG.remainders);

% add a new guide line showing perfect integer coupling
plot(ax.LG.remainders,[0 0 1 1],[0 .5 .5 1],'b:')

ax.LG.remainders.Position(4) = .3;
ax.LG.ratio.Position(4) = .3;
ax.LG.integerness.Position(4) = .3;

ax.LG.hero.Position = [.1 .55 .4 .4];
ax.DG.hero.Position = [.5 .55 .4 .4];

clear lh L
lh(1) = scatter(ax.LG.remainders,NaN,NaN,32,c(1,:));
lh(2) = scatter(ax.LG.remainders,NaN,NaN,32,c(2,:));
lh(1).MarkerFaceColor = c(1,:);
lh(2).MarkerFaceColor = c(2,:);

L = legend(lh,'LG','DG');
L.Location = 'northwest';


figlib.pretty('PlotLineWidth',1,'FontSize',16)


th = text(12,.26,'Perfect integer coupling','Parent',ax.LG.integerness,'FontSize',13);

ax.LG.ratio.YLim = [0 30];



xlabel(ax.LG.remainders,'Significand of T_{gastric}/T_{pyloric}')