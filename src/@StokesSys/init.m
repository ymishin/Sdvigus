function init(obj, df, cf, domain, grids, particles)
% Read input files and perform initialization.
%
% $Id$

% references to main entities
obj.domain = domain;
obj.grids = grids;
obj.particles = particles;

% solve Stokes system ?
obj.stokes_enabled = logical(hdf5read(cf, '/solvers/stokes_enabled'));

% element type
obj.elem_type = hdf5read(df, '/grids/elem_type');

% velocity and pressure
obj.velocity = hdf5read(df, '/grids/velocity');
obj.pressure = hdf5read(df, '/grids/pressure');

% perform non-linear iterations ?
yielding_flag = logical(hdf5read(cf, '/rheologies/yielding'));
powerlaw_flag = logical(hdf5read(cf, '/rheologies/powerlaw'));
if (yielding_flag || powerlaw_flag)
    obj.linear_flag = false;
else
    obj.linear_flag = true;
end

% parameters for non-linear iterations
nonlinear_norm = hdf5read(cf, '/solvers/nonlinear/norm');
switch nonlinear_norm
    case 1, obj.solv_params.nonlinear_norm = 2;   % L2 norm
    case 2, obj.solv_params.nonlinear_norm = Inf; % infinite norm
end
obj.solv_params.nonlinear_tol = hdf5read(cf, '/solvers/nonlinear/tol');
obj.solv_params.nonlinear_maxiter = hdf5read(cf, '/solvers/nonlinear/maxiter');

% parameters for Uzawa solver (Q1P0, Q2P-1)
obj.solv_params.uzawa_k = hdf5read(cf, '/solvers/uzawa/k');
obj.solv_params.uzawa_maxdiv = hdf5read(cf, '/solvers/uzawa/maxdiv');
obj.solv_params.uzawa_maxiter = hdf5read(cf, '/solvers/uzawa/maxiter');

% external force field
obj.Fext = hdf5read(cf, '/Fext');

% boundary conditions
obj.stokes_bc = StokesBC();
obj.stokes_bc.init(df, cf);
% make boundary exits ?
obj.bc_exits.left = logical(hdf5read(cf, '/bc/left_exit'));
obj.bc_exits.right = logical(hdf5read(cf, '/bc/right_exit'));

end