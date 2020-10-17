% get data for the PD hyperpolairziation experiments
% these are in the "999" notebook, because Dan did these 
% experiments in a notebook that didn't have a number

close all

TemperatureSteps = [11 15 19 21];

if ~exist('data','var')	
	data = PDhyp.init(TemperatureSteps);
end


for i = 1:length(data)
	data{i} = crabsort.computePeriods(data{i},'neurons',{'LG'},'ibis',1,'min_spikes_per_burst',5);
	data{i} = crabsort.computePeriods(data{i},'neurons',{'PD'},'ibis',.25,'min_spikes_per_burst',2);
end

% verify integer coupling
figure('outerposition',[300 300 600 600],'PaperUnits','points','PaperSize',[1200 600]); hold on

% plot gridlines
for i = 4:30
	xx = linspace(0,10,1e3);
	yy = xx*i;
	plot(xx,yy,'Color',[.8 .8 .8])
end

for i = 1:length(data)
	for j = 1:length(data{i})
		[x,temp]=gastric.integerCoupling(data{i}(j),'LG','PD');
		plot(x,data{i}(j).LG_burst_periods,'k.')
	end
end
set(gca,'XLim',[0 2],'YLim',[0 20])
xlabel('Mean PD period (s)')
ylabel('LG burst period (s)')

axis square


figlib.pretty()




figure('outerposition',[300 300 1444 901],'PaperUnits','points','PaperSize',[1444 901]); hold on
clear ax
ax(1) = subplot(1,3,1); hold on
axis off
set(gca,'YLim',[-16 3])
plot([0 10],[-16 -16],'k','LineWidth',3)


ax(2) = subplot(1,3,2); hold on
axis off
set(gca,'YLim',[-16 3])

C = crabsort(false);


try data_root = getpref('gastric','data_loc');
catch
	error('You need to tell this script where you data is located using setpref ')
end
C.path_name = fullfile(fileparts(data_root), 'powell','999_017' );

file_names = {'0002','0005','0008','0011','0003','0006','0009','0012'};


yoffset = 0;

colors = [colormaps.redula(4); colormaps.redula(4)];

for i = 1:length(file_names)

	C.file_name = ['999_017_' file_names{i} '.mat'];

	C.loadFile;

	lgn_channel = find(strcmp(C.common.data_channel_names,'lgn'));
	pdn_channel = find(strcmp(C.common.data_channel_names,'pdn'));

	lgn = C.raw_data(:,lgn_channel); 
	pdn = C.raw_data(:,pdn_channel);

	a = C.spikes.lgn.LG(1);
	z = a + 60e4;

	
	lgn = lgn/abs(max(lgn(a:z)));
	
	
	if i == 5
		yoffset = 0;
	end

	if i > 4
		pdn = pdn/pdn_scale;
		subplot(1,3,2); 
	else
		pdn_scale = abs(max(pdn(a:z)));
		pdn = pdn/pdn_scale;
		subplot(1,3,1); 
	end


	lgn = lgn(a:z);
	pdn = pdn(a:z);

	


	lgn = (veclib.interleave(veclib.subSample(lgn,100,@min),veclib.subSample(lgn,100,@max)));
	pdn = (veclib.interleave(veclib.subSample(pdn,100,@min),veclib.subSample(pdn,100,@max)));

	time = (1:length(lgn))*C.dt*100;

	plot(time,lgn+yoffset,'Color',colors(i,:))
	plot(time,pdn+yoffset+2,'Color',colors(i,:))


	yoffset = yoffset-5;

end




% compute periods for each prep for the reference temperatures 
PD.periods = [];
PD.temperature = [];
PD.prep_idx = [];

LG.periods = [];
LG.temperature = [];
LG.prep_idx = [];

LG_PD0.periods = [];
LG_PD0.temperature = [];
LG_PD0.prep_idx = [];

prep_idx = 0;

for i = [7 2 8]
	this_data = data{i};

	prep_idx = prep_idx + 1;

	% compute PD periods
	for j = 1:length(this_data)

		if length(this_data(j).PD) < 100
			continue
		end
		if this_data(j).PD_hyperpolarized
			continue
		end

		idx = ceil(this_data(j).PD_burst_starts);
		temp = this_data(j).temperature(idx);
		
		PD.periods = [PD.periods; this_data(j).PD_burst_periods];
		PD.temperature = [PD.temperature; temp];
		PD.prep_idx = [PD.prep_idx; repmat(prep_idx,length(temp),1)];
	end


	% compute LG periods when PD is on
	for j = 1:length(this_data)

		if length(this_data(j).LG) < 100
			continue
		end
		if this_data(j).PD_hyperpolarized
			continue
		end

		idx = ceil(this_data(j).LG_burst_starts);
		temp = this_data(j).temperature(idx);
		
		LG.periods = [LG.periods; this_data(j).LG_burst_periods];
		LG.temperature = [LG.temperature; temp];
		LG.prep_idx = [LG.prep_idx; repmat(prep_idx,length(temp),1)];
	end



	% compute LG periods when PD is off
	for j = 1:length(this_data)

		if length(this_data(j).LG) < 100
			continue
		end
		if this_data(j).PD_hyperpolarized == 0
			continue
		end

		idx = ceil(this_data(j).LG_burst_starts);
		temp = this_data(j).temperature(idx);
		
		LG_PD0.periods = [LG_PD0.periods; this_data(j).LG_burst_periods];
		LG_PD0.temperature = [LG_PD0.temperature; temp];
		LG_PD0.prep_idx = [LG_PD0.prep_idx; repmat(prep_idx,length(temp),1)];
	end

end



% compare Q10s 
ax(4) = subplot(2,3,6); hold on
clear Q
R = randn(4)/10;
for i = 1:prep_idx
	Q = gastric.q10(PD.periods(PD.prep_idx==i),PD.temperature(PD.prep_idx==i));
	errorbar(1+R(i),mean(Q),std(Q)/sqrt(length(Q)),'Color','k');
	plot(ax(4),1+R(i),mean(Q),'o','Color','k','MarkerFaceColor','k');

	Q = gastric.q10(LG.periods(LG.prep_idx==i),LG.temperature(LG.prep_idx==i));
	errorbar(2+R(i),mean(Q),std(Q)/sqrt(length(Q)),'Color','k');
	plot(ax(4),2+R(i),mean(Q),'o','Color','k','MarkerFaceColor','k');

	Q = gastric.q10(LG_PD0.periods(LG_PD0.prep_idx==i),LG_PD0.temperature(LG_PD0.prep_idx==i));
	errorbar(3+R(i),mean(Q),std(Q)/sqrt(length(Q)),'Color','k');
	plot(ax(4),3+R(i),mean(Q),'o','Color','k','MarkerFaceColor','k');

end
set(gca,'YLim',[0 4])



% show periods for the example prep
PD = structlib.purge(PD,PD.prep_idx~=1);
LG = structlib.purge(LG,LG.prep_idx~=1);
LG_PD0 = structlib.purge(LG_PD0,LG_PD0.prep_idx~=1);

colors = gastric.colors;

ax(3) = subplot(2,3,3); hold on
ph = gastric.groupAndPlotErrorBars(TemperatureSteps, PD.temperature, PD.prep_idx, PD.periods*10);
delete(ph(end))
ph(1).Color = colors.PD;

ph = gastric.groupAndPlotErrorBars(TemperatureSteps, LG.temperature, LG.prep_idx, LG.periods);
delete(ph(end))
ph(1).Color = colors.LG;

ph = gastric.groupAndPlotErrorBars(TemperatureSteps, LG_PD0.temperature, LG_PD0.prep_idx, LG_PD0.periods);
delete(ph(end))
ph(1).Color = colors.('LG (PD hyp.)');

xlabel('Temperature (C)')
ylabel('Burst period (s)')
ax(3).YScale = 'log';

% fake plots for a legend
clear ph
ph(1) = plot(NaN,NaN,'.','MarkerSize',30,'Color',colors.PD);
ph(2) = plot(NaN,NaN,'.','MarkerSize',30,'Color',colors.LG);
ph(3) = plot(NaN,NaN,'.','MarkerSize',30,'Color',colors.('LG (PD hyp.)'));
legend(ph,{'PD (10x)','LG','LG (PD hyp.)'})



th = text(ax(1),-15,0,'\itlgn','FontSize',20);
th = text(ax(1),-15,2,'\itpdn','FontSize',20);

th = text(ax(1),1,-16.5,'10 s','FontSize',20);

th = text(ax(1),-25,1,'11°C','FontSize',20);
th = text(ax(1),-25,-4,'15°C','FontSize',20);
th = text(ax(1),-25,-9,'19°C','FontSize',20);
th = text(ax(1),-25,-14,'21°C','FontSize',20);



figlib.pretty()


ax(4).XTick = [1:3];
ax(4).XTickLabel = {'PD','LG','LG (PD hyp.)'};
ax(4).XLim = [0 4];
ax(4).XTickLabelRotation = 45;
ax(4).Position(2) = .13;
ylabel(ax(4),'Q_{10} (burst period)')

figlib.label('XOffset',-.01,'FontSize',28)

ax(3).YTick = [3 10 30];
ax(3).YLim = [3 30];


return





% compare bi-modality of ISIs with and without PD hyperpolairzation 
Bimodality.P_noPD = [];
Bimodality.P_PD = [];


for thisdata = List(data)

	for i = 1:length(TemperatureSteps)
		idx = find([thisdata.nominal_temperature] == TemperatureSteps(i) & [thisdata.PD_hyperpolarized],1,'first');
		if isempty(idx)
			continue
		end
		if length(thisdata(idx).LG)<10
			continue
		end
		LG = thisdata(idx).LG;
		LG(LG>60)=[];
		[~,p]=statlib.HartigansDipSignifTest(log(diff(LG)));
		Bimodality.P_noPD = [Bimodality.P_noPD; p];


		idx = find([thisdata.nominal_temperature] == TemperatureSteps(i) & [thisdata.PD_hyperpolarized]==0,1,'first');

		LG = thisdata(idx).LG;
		LG(LG>60)=[];
		if isempty(idx) || length(LG)<10
			Bimodality.P_PD = [Bimodality.P_PD; NaN];
		else
			[~,p]=statlib.HartigansDipSignifTest(log(diff(LG)));
			Bimodality.P_PD = [Bimodality.P_PD; p];
			
		end
	end
end

return