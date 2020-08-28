

% base parameters
LG_mu = 2.2;
LG_sigma = .46;

PD_mu = -.43;
PD_sigma = .405;

sigma_scale = corelib.logrange(.04,2,100);
sigma_scale = linspace(0.04,2,100);
PD_LG_similarity = linspace(0,1,90);

N = 1e4;



DeviationFromUniform = zeros(length(sigma_scale),length(PD_LG_similarity));

for i = 1:length(sigma_scale)

	corelib.textbar(i,length(sigma_scale))

	for j = 1:length(PD_LG_similarity)

		this_mu = LG_mu*(1-PD_LG_similarity(j)) + PD_mu*PD_LG_similarity(j);

		LG = lognrnd(this_mu,LG_sigma*sigma_scale(i),1e5,1);
		PD = lognrnd(PD_mu,PD_sigma*sigma_scale(i),1e5,1);

		DeviationFromUniform(i,j) = mean(abs(histcounts(rem(LG./PD,1),linspace(0,1,100),'Normalization','pdf')-1));

	end



end



figure('outerposition',[300 300 1200 600],'PaperUnits','points','PaperSize',[1200 600]); hold on




h = heatmap(PD_LG_similarity,sigma_scale,DeviationFromUniform,'GridVisible','off');
colormap parula
caxis([0 .2])
for i = 2:length(h.YDisplayLabels)
	if rem(i,10) == 0
		continue
	end

	h.YDisplayLabels{i} = '';

end

for i = 2:length(h.XDisplayLabels)
	if rem(i,10) == 0
		continue
	end

	h.XDisplayLabels{i} = '';

end
xlabel('Similairty of LP and PD')
ylabel('Variability in period relative to data')

figlib.pretty




figure('outerposition',[300 300 1800 600],'PaperUnits','points','PaperSize',[1800 600]); hold on
subplot(1,3,1); hold on
histogram(y,'Normalization','pdf','EdgeColor','none'); figlib.pretty; box off

subplot(1,3,2); hold on
histogram(x,'Normalization','pdf','EdgeColor','none'); figlib.pretty; box off

subplot(1,3,3); hold on
histogram(xx,'Normalization','pdf','EdgeColor','none'); figlib.pretty; box off







x = rand(1e6,1)+2;
y = rand(1e6,1)+11;
z = rem(y./x,1);

figure('outerposition',[300 300 1200 600],'PaperUnits','points','PaperSize',[1200 600]); hold on
subplot(1,3,1); hold on
histogram(x,'Normalization','pdf','NumBins',100,'EdgeColor','none')
xlabel('Denominator')
ylabel('pdf')


subplot(1,3,2); hold on
histogram(y,'Normalization','pdf','NumBins',100,'EdgeColor','none')
xlabel('Numerator')


subplot(1,3,3); hold on
histogram(z,'Normalization','pdf','NumBins',100,'EdgeColor','none')
xlabel('Significand of quotient')

figlib.pretty('FontSize',30)