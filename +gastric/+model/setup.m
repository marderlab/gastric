% this function sets up an xfit object so that we can fiddle with parameters
% so that the model behaves like we want it to

function p = setup()


x = xolotl('t_end',30e3);

% specify channels to use in LG and Int1
channels = {'prinz/NaV','prinz/CaT','prinz/CaS','prinz/ACurrent','prinz/KCa','prinz/Kd','generic/HCurrent','Leak'};


% create Int1
x.add('compartment','Int1');
x.Int1.add('prinz/CalciumMech');

for i = 1:length(channels)
	x.Int1.add(channels{i});
end

% configure gbars
x.Int1.set('*gbar', [1e3,  86,  6.7,   30,   10.6,  387, 1, 1875])
x.set('*Leak.E',-50)


% copy Int1 into LG (we assume they are the same)
x.add(copy(x.Int1),'LG')


% configure HCurrent and synapses
x.Int1.HCurrent.tau = 2e3;
x.LG.HCurrent.tau = 2e3;
x.connect('Int1','LG','generic/Graded','gmax',100,'tau',425,'Vth',-38);
x.connect('LG','Int1','generic/Graded','gmax',100,'tau',425,'Vth',-38);

x.Int1.V = -50;
x.LG.V = -60;

% create the AB model
temp = xolotl.examples.BurstingNeuron('prefix','prinz');
temp.AB.HCurrent.destroy;
temp.AB.add('generic/HCurrent')
x.add(temp.AB,'AB');

% connect AB to Int1
x.connect('AB','Int1','generic/Graded','gmax',.5,'tau',100,'Vth',-35)


% now create the xfit object and configure
p = xfit;
p.x = x;

% cost function
p.SimFcn = @gastric.model.cost;


% parameters to optimize and bounds
p.FitParameters = x.find('*gmax');
p.lb = [0 0 0];
p.ub = [300 300 300];
p.seed = x.get('*gmax');


p.SaveParameters = [p.x.find('*gbar'); p.x.find('*gmax')];

p.ShowFcn = @gastric.model.show;

p.SaveWhenCostBelow = 1;

p.options.MaxTime = 5e3;


p.InitFcn = @gastric.model.init;
p.InitFcn(p.x)