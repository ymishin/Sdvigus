function init(obj, df, mf, cf, domain, grids, stokes_sys)
% Read input files and perform initialization.
%
% $Id$

% references to main entities
obj.domain = domain;
obj.grids = grids;
obj.stokes_sys = stokes_sys;

% process data file
obj.data = hdf5read(df, '/particles/coord');
obj.iprop.COORD = [1 2];
obj.data = [obj.data, double(hdf5read(df, '/particles/type'))];
obj.iprop.TYPE = 3;
obj.data = [obj.data, hdf5read(df, '/particles/visc')];
obj.iprop.VISC = 4;
obj.data = [obj.data, hdf5read(df, '/particles/dens')];
obj.iprop.DENS = 5;

% number of particles
obj.num_part = size(obj.data, 1);

% initial state is array
obj.data_state = 1;

% material library
obj.mtrl_lib.visc = hdf5read(mf, '/visc');
obj.mtrl_lib.dens = hdf5read(mf, '/dens');
obj.mtrl_lib.visc0 = hdf5read(mf, '/visc0');
obj.mtrl_lib.dens0 = hdf5read(mf, '/dens0');

% perform Voronoi tessellation ?
obj.voronoi_enabled = logical(hdf5read(cf, '/voronoi/enabled'));
if (obj.voronoi_enabled)
    % init Voronoi object
    obj.voronoi = Voronoi();
    obj.voronoi.vres = hdf5read(cf, '/voronoi/res');
    fixed_types = hdf5read(cf, '/voronoi/fixed_types');
    if (fixed_types ~= -1), obj.voronoi.fixed_types = fixed_types; end;
    min_area = hdf5read(cf, '/voronoi/min_area');
    if (min_area ~= -1), obj.voronoi.min_area = min_area; end;
    max_area = hdf5read(cf, '/voronoi/max_area');    
    if (max_area ~= -1), obj.voronoi.max_area = max_area; end;
end

end