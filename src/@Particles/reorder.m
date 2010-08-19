function reorder(obj)
% Reorder particles in the domain and maintain their distribution.
%
% $Id$

global verbose;
t = tic;

% re-assign particles to elements
obj.reshape_data('cell_hl_forced');
if (verbose > 0), fprintf('Number of particles %d\n', obj.num_part); end;

% perform Voronoi tessellation
if (obj.voronoi_enabled)
    obj.voronoi.dsize = obj.domain.size;
    obj.data = obj.voronoi.compute(obj.data);
end

t = toc(t);
if (verbose > 1), fprintf('Reorder particles ... %f\n', t); end;

end