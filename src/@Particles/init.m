function init(obj, df, mf, cf, domain, grids, stokes_sys)
% Read input files and perform initialization.
%
% $Id$

% references to main entities
obj.domain = domain;
obj.grids = grids;
obj.stokes_sys = stokes_sys;

% enabled rheologies
obj.yielding_flag = logical(hdf5read(cf, '/rheologies/yielding'));
obj.powerlaw_flag = logical(hdf5read(cf, '/rheologies/powerlaw'));

% material library
obj.mtrl_lib.visc = hdf5read(mf, '/visc');
obj.mtrl_lib.dens = hdf5read(mf, '/dens');
obj.mtrl_lib.visc0 = hdf5read(mf, '/visc0');
obj.mtrl_lib.dens0 = hdf5read(mf, '/dens0');
% for powerlaw rheology
obj.mtrl_lib.n = hdf5read(mf, '/powerlaw/n');
% for yielding rheology
obj.mtrl_lib.cohesion = hdf5read(mf, '/yielding/cohesion');
obj.mtrl_lib.phi = hdf5read(mf, '/yielding/phi');
obj.mtrl_lib.weakhard = hdf5read(mf, '/yielding/weakhard');

% process data file
obj.data = hdf5read(df, '/particles/coord');
obj.iprop.COORD = [1 2];
obj.data = [obj.data, double(hdf5read(df, '/particles/type'))];
obj.iprop.TYPE = 3;
% densities according to types
obj.data = [obj.data, obj.mtrl_lib.dens(obj.data(:,obj.iprop.TYPE))];
obj.iprop.DENS = 4;
if (obj.yielding_flag || obj.powerlaw_flag)
    % efficient viscosities
    obj.data = [obj.data, hdf5read(df, '/particles/visc')];
    obj.iprop.VISC = 5;
    % 2nd strain rate invariant
    obj.data = [obj.data, hdf5read(df, '/particles/strain_rate')];
    obj.iprop.STRAIN_RATE = 6;
    if (obj.yielding_flag)
        % accumulated plastic strain
        obj.data = [obj.data, hdf5read(df, '/particles/strain_plast')];
        obj.iprop.STRAIN_PLAST = 7;
    else
        obj.iprop.STRAIN_PLAST = [];
    end
else
    % viscosities according to types
    obj.data = [obj.data, obj.mtrl_lib.visc(obj.data(:,obj.iprop.TYPE))];
    obj.iprop.VISC = 5;
    obj.iprop.STRAIN_RATE = [];
    obj.iprop.STRAIN_PLAST = [];
end

% initial state is array
obj.data_state = 1;

% number of particles
obj.num_part = size(obj.data, 1);

end