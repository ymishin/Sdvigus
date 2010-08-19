function init(obj)
% Model initialization.
%
% $Id$

% number of the data file to start from
obj.nstep = csvread('start_from');

% file names
df = [obj.model_name, '_', num2str(obj.nstep, '%05d'), '.h5'];
mf = [obj.model_name, '_mtrl', '.h5'];
cf = [obj.model_name, '_ctrl', '.h5'];

% time parameters
obj.current_time = hdf5read(df, '/time/current_time');
obj.dt = hdf5read(df, '/time/dt');
obj.total_time = hdf5read(cf, '/time/total_time');
obj.dt_default = hdf5read(cf, '/time/dt_default');
obj.courant = hdf5read(cf, '/time/courant');
% check if determined
if (obj.dt_default == -1), obj.dt_default = []; end
if (obj.courant == -1), obj.courant = []; end

% output parameters
obj.prec_output = logical(hdf5read(cf, '/output/prec'));
obj.output_enabled = logical(hdf5read(cf, '/output/enabled'));

% create main objects
obj.domain = Domain();
obj.particles = Particles();
obj.grids = GridMngr();
obj.stokes_sys = StokesSys();

% and initialize them
obj.domain.init(df, cf);
obj.particles.init(df, mf, cf, obj.domain, obj.grids, obj.stokes_sys);
obj.grids.init(df, cf, obj.domain, obj.particles, obj.stokes_sys);
obj.stokes_sys.init(df, cf, obj.domain, obj.grids, obj.particles);

end