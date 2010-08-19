function init(obj, df, cf, domain, particles, stokes_sys)
% Read input files and perform initialization.
%
% $Id$

% references to main entities
obj.domain = domain;
obj.particles = particles;
obj.stokes_sys = stokes_sys;

% highest grid resolution
obj.reshl = hdf5read(df, '/grids/reshl');

% total number of grid levels
jmax = hdf5read(cf, '/grids/jmax');

% multilevel grid ?
if (jmax > 1)
    mask = logical(hdf5read(df, '/grids/mask'));
    obj.adapt_grid = logical(hdf5read(cf, '/grids/adapt_grid'));
else
    mask = [];
    obj.adapt_grid = false;
end

% stokes element
elem_type = hdf5read(df, '/grids/elem_type');

% stokes grid object
obj.stokes = Grid();
obj.stokes.dsize = obj.domain.size;
obj.stokes.res = obj.reshl;
switch elem_type
    case {1, 2}, obj.stokes.elem_order = 1; % Q1P0, Q1Q1
    case 3,      obj.stokes.elem_order = 2; % Q2P-1
end
obj.stokes.jmax = jmax;
obj.stokes.mask = mask;

% update stokes grid
obj.stokes_update = true;

end