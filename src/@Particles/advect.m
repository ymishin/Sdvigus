function advect(obj, dt)
% Advection of particles.
% TODO: implement higher order schemes
%
% $Id$

global verbose;
t = tic;

% assign particles to elements of Stokes grid
obj.reshape_data('cell_stokes');

% velocities
vx = obj.stokes_sys.velocity(:,1);
vy = obj.stokes_sys.velocity(:,2);

% grid structure
node_coord = obj.grids.stokes.node_coord;
elem2node = obj.grids.stokes.elem2node;

% number of elements and velocity nodes per element
num_elem = size(elem2node, 2);
num_vnode_el = size(elem2node, 1);

% loop over elements
data = obj.data;
parfor iel = 1:num_elem
    
    % particles' data in current element
    idata = data{iel};
    
    % empty element ?
    if (isempty(idata))
        continue;
    end
    
    % nodes of the element
    nodes = elem2node(:,iel);
    
    % global coordinates of elements corners
    ex = node_coord(1,nodes(1:4));
    ey = node_coord(2,nodes(1:4));
    
    % compute shape functions at
    % local particles coordinates (reference element is [-1 +1 -1 +1])
    Nv = ShapeFuncs.compute([ ...
        ((idata(:,1) - ex(1)) / (ex(2) - ex(1)) * 2 - 1), ...
        ((idata(:,2) - ey(2)) / (ey(3) - ey(2)) * 2 - 1)]', ...
        num_vnode_el);
    
    % interpolate velocities from nodes to particles
    % and perform particles advection
    idata(:,1:2) = idata(:,1:2) + dt * Nv * [vx(nodes) vy(nodes)];
    
    % store data
    data{iel} = idata;
    
end
obj.data = data;
clear data;

t = toc(t);
if (verbose > 0)
    fprintf('Advection of particles ... %f\n', t);
end

end