function init(obj, df, cf, domain, grids, particles)
% Read input files and perform initialization.
%
% $Id$

% references to main entities
obj.domain = domain;
obj.grids = grids;
obj.particles = particles;

% element type
obj.elem_type = hdf5read(df, '/grids/elem_type');

% velocity and pressure
obj.velocity = hdf5read(df, '/grids/velocity');
obj.pressure = hdf5read(df, '/grids/pressure');

% external force field
obj.Fext = hdf5read(cf, '/Fext');

% % element type
% elem_type = hdf5read(df, '/grids/elem_type');
% switch elem_type
%     case 1
%         % Q1P0
%         obj.num_inp = 4;        % integration points
%         obj.num_vnode_el = 4;   % velocity nodes
%         obj.num_pnode_el = 1;   % pressure nodes
%     case 2
%         % Q1Q1
%         obj.num_inp = 4;        % integration points
%         obj.num_vnode_el = 4;   % velocity nodes
%         obj.num_pnode_el = 4;   % pressure nodes
%     case 3
%         % Q2P-1
%         obj.num_inp = 9;        % integration points
%         obj.num_vnode_el = 9;   % velocity nodes
%         obj.num_pnode_el = 3;   % pressure nodes
% end

% boundary conditions
obj.stokes_bc = StokesBC();
obj.stokes_bc.init(df, cf);

end