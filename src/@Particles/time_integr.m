function time_integr(obj, dt)
% Time integration of particles' properties.
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

% rheologies
yielding_flag = obj.yielding_flag;
powerlaw_flag = obj.powerlaw_flag;
% indices
itype = obj.iprop.TYPE;
ivisc = obj.iprop.VISC;
israte = obj.iprop.STRAIN_RATE;
isplast = obj.iprop.STRAIN_PLAST;
% material properties
visc = obj.mtrl_lib.visc;
pln = obj.mtrl_lib.n;
pln1 = (1.0 ./ pln - 1.0);

% loop over elements
data = obj.data;
parfor iel = 1:num_elem
    
    % particles' data in current element
    edata = data{iel};
    
    % empty element ?
    if (isempty(edata))
        continue;
    end

    % ********** UPDATE PARTICLES' POSITIONS (ADVECTION) **********
    
    % nodes of the element
    nodes = elem2node(:,iel);
    
    % global coordinates of elements corners
    ex = node_coord(1,nodes(1:4));
    ey = node_coord(2,nodes(1:4));
    
    % compute shape functions at local particles
    % coordinates (reference element is [-1 +1 -1 +1])
    Nv = ShapeFuncs.compute([ ...
        ((edata(:,1) - ex(1)) / (ex(2) - ex(1)) * 2 - 1), ...
        ((edata(:,2) - ey(2)) / (ey(3) - ey(2)) * 2 - 1)]', ...
        num_vnode_el);
    
%     % Runge–Kutta 2 (Midpoint method)
%     Nv = ShapeFuncs.compute([ ...
%         ((edata(:,1) - ex(1)) / (ex(2) - ex(1)) * 2 - 1), ...
%         ((edata(:,2) - ey(2)) / (ey(3) - ey(2)) * 2 - 1)]', ...
%         num_vnode_el);
%     coord = edata(:,1:2) + (dt / 2) * Nv * [vx(nodes) vy(nodes)];
%     Nv = ShapeFuncs.compute([ ...
%         ((coord(:,1) - ex(1)) / (ex(2) - ex(1)) * 2 - 1), ...
%         ((coord(:,2) - ey(2)) / (ey(3) - ey(2)) * 2 - 1)]', ...
%         num_vnode_el);
%     
%     % Runge–Kutta 4
%     Nv1 = ShapeFuncs.compute([ ...
%         ((edata(:,1) - ex(1)) / (ex(2) - ex(1)) * 2 - 1), ...
%         ((edata(:,2) - ey(2)) / (ey(3) - ey(2)) * 2 - 1)]', ...
%         num_vnode_el);
%     coord = edata(:,1:2) + (dt / 2) * Nv1 * [vx(nodes) vy(nodes)];
%     Nv2 = ShapeFuncs.compute([ ...
%         ((coord(:,1) - ex(1)) / (ex(2) - ex(1)) * 2 - 1), ...
%         ((coord(:,2) - ey(2)) / (ey(3) - ey(2)) * 2 - 1)]', ...
%         num_vnode_el);
%     coord = edata(:,1:2) + (dt / 2) * Nv2 * [vx(nodes) vy(nodes)];
%     Nv3 = ShapeFuncs.compute([ ...
%         ((coord(:,1) - ex(1)) / (ex(2) - ex(1)) * 2 - 1), ...
%         ((coord(:,2) - ey(2)) / (ey(3) - ey(2)) * 2 - 1)]', ...
%         num_vnode_el);
%     coord = edata(:,1:2) + dt * Nv3 * [vx(nodes) vy(nodes)];
%     Nv4 = ShapeFuncs.compute([ ...
%         ((coord(:,1) - ex(1)) / (ex(2) - ex(1)) * 2 - 1), ...
%         ((coord(:,2) - ey(2)) / (ey(3) - ey(2)) * 2 - 1)]', ...
%         num_vnode_el);
%     Nv = (Nv1 + 2 * Nv2 + 2 * Nv3 + Nv4) / 6;
    
    % perform advection
    edata(:,1:2) = edata(:,1:2) + dt * Nv * [vx(nodes) vy(nodes)];
    
    % ********** UPDATE ACCUMULATED PLASTIC STRAIN **********
    
    if (yielding_flag)
        % recall creep viscosities
        type = edata(:,itype);
        old_visc = visc(type);
        if (powerlaw_flag)
            old_visc = old_visc .* (edata(:,israte) .^ pln1(type));
        end
        % accumulate plastic strain
        edata(:,isplast) = edata(:,isplast) + dt * ...
            edata(:,israte) .* (1.0 - edata(:,ivisc) ./ old_visc);
    end
    
    % store updated data
    data{iel} = edata;
    
end
obj.data = data;
clear data;

t = toc(t);
verbose.disp(['Particles time integration ... ', num2str(t)], 2);

end