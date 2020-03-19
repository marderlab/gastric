

function show(x,~)

x.closed_loop = true;
x.dt = .1;

x.t_end = 30e3;
x.integrate;

x.t_end = 120e3;
V = x.integrate;



[~,LG_burst_starts] = xtools.V2metrics(V(:,3),'sampling_rate',10,'ibi_thresh',5e3);

PD = xtools.findNSpikeTimes(V(:,1),xtools.findNSpikes(V(:,1)));

PD = PD*1e-4;
LG_burst_starts = LG_burst_starts/1e4;

figure('outerposition',[300 300 1200 600],'PaperUnits','points','PaperSize',[1200 600]); hold on

for i = 1:length(LG_burst_starts)

	spiketimes = PD;
	spiketimes = spiketimes - LG_burst_starts(i);

	spiketimes(spiketimes<-5) =[];
	spiketimes(spiketimes>5) =[];


	neurolib.raster(spiketimes,'yoffset',i,'deltat',1,'center',false)

end

figlib.pretty()

set(gca,'YColor','w')
title('PD rasters triggered by LG start')
xlabel('Time since LG start (s)')
plotlib.vertline(0,'k--');