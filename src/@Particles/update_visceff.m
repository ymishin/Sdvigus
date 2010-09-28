function elem_visc = update_visceff(obj, pressure)
% Calculate new effective viscosities on particles and return averages 
% inside elements. 'pressure' will be used for yield stress estimation.
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
num_pnode_el = size(pressure, 1);

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
visc0 = obj.mtrl_lib.visc0;
cohesion1 = obj.mtrl_lib.cohesion(1,:)';
cohesion2 = obj.mtrl_lib.cohesion(2,:)';
cohesion3 = cohesion2 - cohesion1;
cohesion3(isnan(cohesion3)) = 0.0;
phi1 = obj.mtrl_lib.phi(1,:)';
phi2 = obj.mtrl_lib.phi(2,:)';
phi3 = phi2 - phi1;
weakhard1 = obj.mtrl_lib.weakhard(1,:)';
weakhard2 = obj.mtrl_lib.weakhard(2,:)';
weakhard3 = 1.0 ./ (weakhard2 - weakhard1);
pln = obj.mtrl_lib.n;
pln1 = (1.0 ./ pln - 1.0);

% preallocate
elem_visc = zeros(num_elem, 1);  

% loop over elements
data = obj.data;
parfor iel = 1:num_elem
    
    % particles' data in current element
    edata = data{iel};
    
    % empty element ?
    if (isempty(edata))
        elem_visc(iel) = visc0;
        continue;
    end
    
    % nodes of the element
    nodes = elem2node(:,iel);
    % local particles coordinates
    ex = node_coord(1,nodes(1:4));
    ey = node_coord(2,nodes(1:4));
    coord = [((edata(:,1) - ex(1)) / (ex(2) - ex(1)) * 2 - 1), ...
             ((edata(:,2) - ey(2)) / (ey(3) - ey(2)) * 2 - 1)]';
    % derivatives of velocity shape functions
    dNv = ShapeFuncs.compute_der(coord, num_vnode_el);
    % pressure shape functions
    Np = ShapeFuncs.compute(coord, num_pnode_el);
    
    % ********** COMPUTE STRAIN RATE **********
    
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
    
    % ********** COMPUTE NEW EFFECTIVE VISCOSITIES **********
    
    % set background viscosities by default
    type = edata(:,itype);
    new_visc = visc(type);
    
    % compute effective viscosities due to power-law
    if (powerlaw_flag)
        new_visc = new_visc .* (edata(:,israte) .^ pln1(type));
    end
    
    % compute effective viscosities due to yielding
    if (yielding_flag)
        % strain weakening / hardening (effective cohesion and friction angle)
        coef = (edata(:,isplast) - weakhard1(type)) .* weakhard3(type);
        coef(isnan(coef)) = 0.0;
        coef(coef < 0.0) = 0.0;
        coef(coef > 1.0) = 1.0;
        cohesion = cohesion1(type) + cohesion3(type) .* coef;
        phi = phi1(type) + phi3(type) .* coef;
        % yield stress (Drucker-Prager criterion)
        stress_yield = cosd(phi) .* cohesion + ...
                       sind(phi) .* (Np * pressure(:,iel));
        %stress_yield = max(cosd(phi) .* cohesion, stress_yield);
        % new effective viscoties
        new_visc = min(new_visc, 0.5 * stress_yield ./ edata(:,israte));
    end
    
    % cutoff viscosities and store updated data
    new_visc = max(visc0, new_visc);
    edata(:,ivisc) = new_visc;
    data{iel} = edata;
    
    % ********** COMPUTE AVERAGE VISCOSITY **********
    
    % arithmetic mean
    elem_visc(iel) = mean(new_visc);
    % harmonic mean
    %elem_visc(iel) = 1.0 / mean(1.0 ./ new_visc);
    
end
obj.data = data;
clear data;

t = toc(t);
verbose.disp(['Viscosities update ... ', num2str(t)], 2);

end