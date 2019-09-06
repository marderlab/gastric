function ch = plotIntegerCoupling(data, neuron, ax, base_color)

% add some fake data to get the colorbars to be consistent across all figures
all_x = [20; 20];
all_temp = [5; 35];
all_y = [NaN; NaN];
all_prep = [1; 1];

for i = 1:length(data)
	[this_x,this_temp] = gastric.integerCoupling(data(i),neuron,'PD');
	this_x(this_x>5) = NaN;
	all_x = [all_x; this_x];
	all_temp = [all_temp; this_temp];
	all_y = [all_y; data(i).([neuron '_burst_periods'])];
	all_prep = [all_prep; this_x*0 + i];
end


% plot gridlines
for i = 4:30
	xx = linspace(0,10,1e3);
	yy = xx*i;
	plot(ax.hero,xx,yy,'Color',[.8 .8 .8])
end


[ph,ch] = plotlib.cplot(ax.hero, all_x,all_y,all_temp,'colormap',colormaps.redula(20),'use_scatter',false,'clim',[5 23]);
set(ax.hero,'XLim',[0.2 2],'YLim',[0 30])
xlabel(ax.hero,'Mean PD period (s)')

ch.Location = 'eastoutside';
title(ch,gastric.tempLabel)
colormap(colormaps.redula)



%%
% How does integer coupling vary with temperature?

rm_this = all_x > 2 | all_y > 30 | all_x < 0 | all_y < 0;
all_x(rm_this) = NaN;
all_t(rm_this) = NaN;

N_pyloric_gastric = round(all_y./all_x);
Rem = rem(all_y./all_x,1);
integerness = gastric.integerness(Rem);




temp_space = 7:2:23;
PD_space = .2:.2:2;

% plot N/plyoric and group by temperature
axes(ax.ratio)
ph = gastric.groupAndPlotErrorBars(temp_space, all_temp, all_prep, N_pyloric_gastric);


delete(ph(1:end-1));
ph(end).Color = base_color;





% plot integerness and group by temperature
axes(ax.integerness)
ph = gastric.groupAndPlotErrorBars(temp_space, all_temp, all_prep, integerness);


delete(ph(1:end-1));
ph(end).Color = base_color;





% now plot the remainders to show that it is different from random

x = 1:length(Rem);
N = 1e3;
y = NaN(length(x),N);
for i = 1:N
	y(:,i) = sort(datasample(Rem,length(x)));
	
end

m = nanmean(y,2);


Upper = nanstd(y,[],2);
Upper(isnan(Upper)) = 0;


x = x/sum(~isnan(m));
axes(ax.remainders)
ph = plotlib.shadedErrorBar(x(:),m,[Upper Upper]);
delete(ph.mainLine)
ph.patch.FaceColor = base_color;
ph.patch.FaceAlpha = .5;
ph.edge(1).Color = base_color;
ph.edge(2).Color = base_color;



set(ax.integerness,'YLim',[0 1])
ylabel(ax.integerness,'Integerness')
xlabel(ax.integerness,gastric.tempLabel)
xlabel(ax.ratio,gastric.tempLabel)
set(ax.ratio,'YLim',[0 50],'YScale','linear')
ylabel(ax.ratio,'N gastric/pyloric')
ax.hero.YColor = base_color;
ylabel(ax.hero,[neuron ' burst period (s)'])
axis(ax.hero,'square')

ylabel(ax.remainders,'Significand of burst period ratio')
xlabel(ax.remainders,'Cumulative probability')