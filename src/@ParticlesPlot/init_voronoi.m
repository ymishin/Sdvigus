function init_voronoi(obj, postproc)
% Voronoi initialization.
%
% $Id$

% init Voronoi object
obj.voronoi_enabled = true;
obj.voronoi = VoronoiPlot();
obj.voronoi.res = obj.grids.reshl;
obj.voronoi.dsize = obj.domain.size;
if (postproc.isprop('voronoi_res'))
    obj.voronoi.vres = postproc.voronoi_res;
else
    obj.voronoi.vres = [2 2];  % default
end

end