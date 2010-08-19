function solve(obj)
% Build and solve Stokes system of equations.
% TODO: think about re-design construct_bc()
%       and data structures passing to solve_linear()
% 
% $Id$

% interpolate properties from particles
[visc, dens] = obj.particles.interp2elem();

% build all system matrices
stokes = obj.build_system_matrices(visc, dens);

% bc equations
bc = obj.construct_bc();

% get solution
[v, p] = obj.solve_linear(stokes, bc);
obj.velocity = v(1:2:end-1);
obj.velocity(:,2) = v(2:2:end);
obj.pressure = p;
clear stokes bc v p;

end