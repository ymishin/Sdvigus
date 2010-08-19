function compute_strain_rate(obj)
% Compute 2nd invariant of strain rate at particles' positions.
%
% $Id$

global verbose;
t = tic;

% assign particles to elements of Stokes grid
obj.reshape_data('cell_stokes');

% grid structure
node_coord = obj.grids.stokes.node_coord;
elem2node = obj.grids.stokes.elem2node;

% usefull numbers
num_elem = size(elem2node, 2);
num_vnode_el = size(elem2node, 1);

% velocities
vx = obj.stokes_sys.velocity(:,1);
vy = obj.stokes_sys.velocity(:,2);

% Jacobian for abstract element at finest level
dx = obj.grids.stokes.elemhl(1);
dy = obj.grids.stokes.elemhl(2);
invJ = [ 2/dx 0; 0 2/dy ];

% scaling factor for invJ
if (obj.grids.stokes.jmax > 1)
    % multilevel grid
    % invJ should be scaled by 1/sf
    sf = 2.^(obj.grids.stokes.jmax - double(obj.grids.stokes.elem_level));
else
    % equidistant grid
    sf = ones(num_elem, 1);
end

% index to store 2nd invariant of strain rate
israte = obj.iprop.STRAIN_RATE;

% loop over elements
data = obj.data;
parfor iel = 1:num_elem
    
    % particles' data in current element
    edata = data{iel};
    
    % empty element ?
    if (isempty(edata))
        continue;
    end
    
    % nodes of the element
    nodes = elem2node(:,iel);
    
    % derivatives of velocity shape functions at local particles coordinates
    ex = node_coord(1,nodes(1:4));
    ey = node_coord(2,nodes(1:4));
    dNv = ShapeFuncs.compute_der([ ...
        ((edata(:,1) - ex(1)) / (ex(2) - ex(1)) * 2 - 1), ...
        ((edata(:,2) - ey(2)) / (ey(3) - ey(2)) * 2 - 1)]', ...
        num_vnode_el);
    
    % inv(J) for current element
    invJ_elem = (1/sf(iel)) * invJ;
    
    % velocities
    ev = zeros(2 * num_vnode_el, 1);
    ev(1:2:end-1) = vx(nodes);
    ev(2:2:end) = vy(nodes);
    
    % compute 2nd invariant of strain rate for each particle
    B = zeros(3, 2 * num_vnode_el);
    for i = 1:size(edata,1)
        % derivatives wrt global coordinates
        dNvi = invJ_elem * dNv(2*i-1:2*i,:);
        % strain rate at particle's position
        B(1,1:2:end-1) = dNvi(1,:);
        B(2,2:2:end)   = dNvi(2,:);
        B(3,1:2:end-1) = dNvi(2,:);
        B(3,2:2:end)   = dNvi(1,:);
        strain = B * ev;
        % 2nd invariant of strain rate
        edata(i,israte) = sqrt(0.5 * (strain(1)^2 + ...
            strain(2)^2) + (0.5 * strain(3))^2);
    end
    
    % store data
    data{iel} = edata;
    
end
obj.data = data;
clear data;

t = toc(t);
if (verbose > 1)
    fprintf('Compute 2nd invariant of strain rate ... %f\n', t);
end

end