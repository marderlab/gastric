% gastric.plotIntegerCoupling
% makes an integer coupling plot for the 
% requested neuron 

function [ch, plh] = plotIntegerCoupling(data, neuron, ax, base_color)


arguments
	data (:,1) struct
	neuron char
	ax struct
	base_color 
end

MarkerSize = 10;

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

% throw out some outliers
all_y(all_y>30) = NaN;
all_y(all_y<0) = NaN;
all_x(all_x<0) = NaN;
all_x(all_x>2) = NaN;

% plot gridlines
for i = 4:30
	xx = linspace(0,10,1e3);
	yy = xx*i;
	plot(ax.hero,xx,yy,'Color',[.8 .8 .8])
end

only_these = all_prep > 0;
[ph,ch] = plotlib.cplot(ax.hero, all_x(only_these),all_y(only_these),all_temp(only_these),'colormap',@colormaps.redula,'CLim',[5 25],'BinCenters',7:2:23);


for i = 1:length(ph)
	try
		ph(i).MarkerSize = MarkerSize;
	catch
	end
end

xlabel(ax.hero,'Mean PD burst period (s)')

ch.Location = 'eastoutside';
title(ch,gastric.tempLabel)



%%
% How does integer coupling vary with temperature?

rm_this = all_x > 2 | all_y > 30 | all_x < 0 | all_y < 0;
all_x(rm_this) = NaN;
all_t(rm_this) = NaN;

N_pyloric_gastric = (all_y./all_x);
Rem = rem(all_y./all_x,1);
RandRem = rem(all_y./veclib.shuffle(all_x),1);
RandRem(isnan(RandRem)) = [];

rm_this = isnan(N_pyloric_gastric);
[rho, pval] = corr(all_temp(~rm_this),N_pyloric_gastric(~rm_this),'Type','Spearman');
disp('Spearman p-value for all temperatures vs. ratios...')
disp(pval)

disp('N cycles compared:')
disp(sum(~rm_this))

% what if we weighted each prep equally?
disp('Spearman p-value for all temperatures vs. ratios, prep by prep...')

unique_temps = 7:2:23;
all_N = NaN(length(unique_temps),10);

for i = 1:length(unique_temps)
	for j = 1:10
		all_N(i,j) = nanmean(N_pyloric_gastric(~rm_this & all_prep == j & abs(all_temp - unique_temps(i)) <1));
	end
end
unique_temps = repmat(unique_temps,10,1);

temp_space = 7:2:23;
PD_space = .2:.2:2;

% plot N/plyoric and group by temperature
axes(ax.ratio)
plh = plot(ax.ratio,all_temp,N_pyloric_gastric,'.','Color',base_color);
% ph = gastric.groupAndPlotErrorBars(temp_space, all_temp, all_prep, N_pyloric_gastric);


% delete(ph(1:end-1));
% ph(end).Color = base_color;



% we now define "integerness" as the area b/w the curve and the diagonal. 
% let's compute that on a prep-by-prep basis, on a temperature-by temperature basis
% this necessarily has to pool all data to measure this (because we need the CDF)



% how many times should we bootstrap the data?
N = 100;

unique_preps = unique(all_prep);
unique_preps(isnan(unique_preps)) = [];

mean_integerness = NaN(length(temp_space),length(unique_preps));
mean_integerness_rand =  NaN(length(temp_space),length(unique_preps));

for i = 1:length(temp_space)
	this_temp = temp_space(i);

	for j = 1:length(unique_preps)
		this_prep = unique_preps(j);

		this_rem = Rem(abs(all_temp - this_temp) < 1 & all_prep == this_prep);
		this_rem(isnan(this_rem)) = [];

		if length(this_rem) < 30
			continue
		end

		rand_rem = datasample(RandRem,length(this_rem));

		mean_integerness(i,j) = 0;
		mean_integerness_rand(i,j) = 0;

		for k = 1:N
			X = sort(datasample(this_rem,length(this_rem)));
			[~,idx] = unique(X);
			Y = linspace(0,1,length(X));
			XX = linspace(0,1,100);
			YY = interp1(X(idx),Y(idx),XX);

			mean_integerness(i,j) = mean_integerness(i,j) + nansum(abs(XX - YY)/(100));

			% now the dummy data
			X = sort(datasample(rand_rem,length(rand_rem)));
			[~,idx] = unique(X);
			Y = linspace(0,1,length(X));
			XX = linspace(0,1,100);
			YY = interp1(X(idx),Y(idx),XX);

			mean_integerness_rand(i,j) = mean_integerness_rand(i,j) + nansum(abs(XX - YY)/(100));
			

		end
		mean_integerness(i,j) = mean_integerness(i,j)/N;
		mean_integerness_rand(i,j) = mean_integerness_rand(i,j)/N;

	end

end




% error is computed across biological replicates. 
error_integerness = nanstd(mean_integerness,[],2);
error_integerness = error_integerness./sqrt(sum(~isnan(mean_integerness),2));

Y = nanmean(mean_integerness,2);
rm_this = isnan(Y);

errorbar(ax.integerness,temp_space(~rm_this),Y(~rm_this),error_integerness(~rm_this),'Color',base_color,'LineWidth',2);


% now plot errorbars for randomized data
error_integerness = nanstd(mean_integerness_rand,[],2);
error_integerness = error_integerness./sqrt(sum(~isnan(mean_integerness_rand),2));

Y = nanmean(mean_integerness_rand,2);
rm_this = isnan(Y);


errorbar(ax.integerness,temp_space(~rm_this),Y(~rm_this),error_integerness(~rm_this),'Color',[.7 .7 .7],'LineWidth',2);




p = NaN*temp_space;
for i = 1:length(p)
	use_this = abs(all_temp - temp_space(i)) < 1;
	x = Rem(use_this);
	x(isnan(x)) = [];

	this_y = all_y(use_this);
	this_x = all_x(use_this);
	rm_this = isnan(this_x) | isnan(this_y);
	this_y(rm_this) = [];
	this_x(rm_this) = [];
	this_x = datasample(this_x,100);
	this_y = datasample(this_y,100);
	this_rem = rem(this_y./this_x,1);
	
	

	[~,p(i), ksstat] = kstest2(x,this_rem);


	if p(i) < .05/9
		disp(['Significantly integer coupled at ' mat2str(temp_space(i)), 'p = ' mat2str(p(i),4)])
	else
		disp(['NOT Significantly integer coupled at ' mat2str(temp_space(i)), 'p = ' mat2str(p(i),4)])
	end

	disp('ksstat=')
	disp(ksstat)
end





% now plot the remainders to show that it is different from random

x = 1:length(Rem);

N = 1e3;
nbins = 100;

y = NaN(nbins,N);

for i = 1:N
	y(:,i) = cumsum(histcounts(datasample(Rem,length(x)),linspace(0,1,nbins+1)));
	y(:,i) = y(:,i)/y(end,i);
	
end

m = nanmean(y,2);


Upper = nanstd(y,[],2);
Upper(isnan(Upper)) = 0;


x = linspace(0,1,nbins);
axes(ax.remainders)
ph = plotlib.shadedErrorBar(x(:),m,[Upper Upper]);
delete(ph.mainLine)
ph.patch.FaceColor = base_color;
ph.patch.FaceAlpha = .5;
ph.edge(1).Color = base_color;
ph.edge(2).Color = base_color;

% now plot the null distribution which we obtain by randomizing numerators and denominators
% rand_rem = rem(datasample(all_y,1e4)./datasample(all_x,1e4),1);
% rand_rem(isnan(rand_rem)) = [];
% null_y = histcounts(rand_rem,linspace(0,1,nbins+1),'Normalization','cdf');
% plot(ax.remainders,x,null_y,'k')



% add a line to indicate theoretical maximum
plot(ax.integerness,[0 100],[.25 .25],'b:');

set(ax.integerness,'YLim',[0 .3],'XLim',[min(temp_space)-5 max(temp_space)+5])
ylabel(ax.integerness,{'Area b/w significand','c.d.f and diagonal'})
xlabel(ax.integerness,gastric.tempLabel)
xlabel(ax.ratio,gastric.tempLabel)
ylabel(ax.ratio, 'T_{gastric}/T_{pyloric}')
ax.hero.YColor = base_color;
ylabel(ax.hero,[neuron ' burst period (s)'])
axis(ax.hero,'square')

ylabel(ax.remainders,'Cumulative probability')

