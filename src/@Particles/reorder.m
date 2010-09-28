function reorder(obj)
% Reorder particles in the domain and maintain their distribution.
%
% $Id$

global verbose;
t = tic;

% re-assign particles to elements
obj.reshape_data('cell_hl_forced');
verbose.disp(['Number of particles: ', num2str(obj.num_part)], 1);

% perform Voronoi tessellation
if (obj.voronoi_enabled)
    obj.voronoi.dsize = obj.domain.size;
    obj.data = obj.voronoi.compute(obj.data);
    obj.num_part = sum(cellfun('size', obj.data, 1));
    verbose.disp(['Number of particles (Voronoi): ', num2str(obj.num_part)], 1);
end

t = toc(t);
verbose.disp(['Particles reordering ... ', num2str(t)], 2);

end