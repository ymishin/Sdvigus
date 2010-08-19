function init_voronoi(obj, cf)
% Voronoi initialization.
%
% $Id$

% perform Voronoi tessellation ?
obj.voronoi_enabled = logical(hdf5read(cf, '/voronoi/enabled'));
if (obj.voronoi_enabled)
    % init Voronoi object
    obj.voronoi = Voronoi();
    obj.voronoi.res = obj.grids.reshl;
    obj.voronoi.vres = hdf5read(cf, '/voronoi/res');
    fixed_types = hdf5read(cf, '/voronoi/fixed_types');
    if (fixed_types ~= -1), obj.voronoi.fixed_types = fixed_types; end;
    min_area = hdf5read(cf, '/voronoi/min_area');
    if (min_area ~= -1), obj.voronoi.min_area = min_area; end;
    max_area = hdf5read(cf, '/voronoi/max_area');
    if (max_area ~= -1), obj.voronoi.max_area = max_area; end;
end

end