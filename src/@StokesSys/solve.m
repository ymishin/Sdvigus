function solve(obj)
% Build and solve Stokes system of equations.
%
% $Id$

% solve Stokes system ?
if (~obj.stokes_enabled)
    % set velocities and pressures to all zeros
    num_elem = size(obj.grids.stokes.elem2node, 2);
    num_node = size(obj.grids.stokes.node_coord, 2);
    obj.velocity = zeros(num_node, 2);
    switch obj.elem_type
        case 1, obj.pressure = zeros(num_elem, 1);   % Q1P0
        case 2, obj.pressure = zeros(num_node, 1);   % Q1Q1
        case 3, obj.pressure = zeros(3*num_elem, 1); % Q2P-1
    end
    return;
end

% build bc vectors
obj.build_bc();

% average properties from particles
[visc, dens] = obj.particles.average_visc_dens();

% build all system matrices
obj.build_system_matrices(visc, dens);

% build and apply constraint matrices
if (obj.grids.stokes.jmax > 1)
    obj.build_constraint_matrices();
end

% solve the system
if (obj.linear_flag)
    obj.solve_linear();
else
    obj.solve_nonlinear();
end

% clear
obj.A = []; obj.Q = []; obj.invM = []; obj.C = [];
obj.elemA = []; obj.RHS = []; obj.bc = [];
obj.CV = 1; obj.CP = 1;

end