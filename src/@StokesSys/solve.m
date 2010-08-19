function solve(obj)
% Build and solve Stokes system of equations.
% 
% $Id$

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