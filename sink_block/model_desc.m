% ******************** MODEL DESCRIPTION ********************

% create initial data file ?
create_init = true;

% create material library file ?
create_mtrl = true;

% create control file ?
create_ctrl = true;

% domain dimensions
xmin = 0.0;
xmax = 1.0;
ymin = 0.0;
ymax = 2.0;

% change size of the domain according to normal componenets of velocity BC
change_domain_size = true;

% number of elements in x- and y-directions
% in case of multilevel grid (jmax > 1) this resolution corresponds to 
% finest grid level and have to be Mx * 2^(jmax-1) and My * 2^(jmax-1) in 
% x- and y-directions respectively (Mx and My are arbitrary and determine 
% resolution at coarsest grid level)
num_elem_x = 7 * 2^(5-1);
num_elem_y = 5 * 2^(5-1);

% total number of grid levels in case of multilevel grid
% if jmax equals 1 - simple equidistant grid will be used
jmax = 1;

% level of the initial grid, can be from jmax (finest) to 1 (coarsest)
% resolution of the initial grid will be:
% Mx * 2^(jstart-1) by My * 2^(jstart-1)
jstart = 3;

% enable adaptive grid refinement
% makes sense only if grid is multilevel (jmax > 1)
adapt_grid = true;

% element type
% 1 - Q1P0  (bilinear velocity, constant discontinuous pressure)
% 2 - Q1Q1  (bilinear velocity, bilinear continuous pressure, stabilized)
% 3 - Q2P-1 (biquadratic velocity, linear discontinuous pressure)
elem_type = 2;

% velocity boundary conditions
bvx_left   = 0.0; bvy_left   =  [];
bvx_right  = 0.0; bvy_right  =  [];
bvx_bottom =  []; bvy_bottom = 0.0;
bvx_top    =  []; bvy_top    = 0.0;

% external force field
Fext(1) =   0.0;  % x-direction
Fext(2) = -10.0;  % y-direction

% TIME PARAMETERS
% total time of simulation
total_time = 4.0;
% time step
% 'dt_default' allows to set constant time step manually
% 'courant' is Courant number and can be from 0.0 (meaningless) to 1.0
% at least one of them has to be determined, if both are determined - actual 
% time step will be minimum between dt_default and one calculated based on 
% Courant number
dt_default = [];
courant    = 0.8;

% Voronoi tessellation to maintain distribution of particles
voronoi_enabled = true;
% resolution of Voronoi cells
voronoi_res_x = 20;
voronoi_res_y = 20;
% max and min normalized area of Voronoi cells (the total area is 1.0)
% can be [] (undetermined), but if determined - Voronoi cells with 
% max_area / min_area will splitted / destroyed (i.e. corresponding 
% particles will be cloned / eliminated)
max_area = 1/3;
min_area = 1/27;
% Voronoi cells corresponding to particles of 
% fixed types will not be splitted / destroyed
fixed_types = [2];

% initial particle density per element at finest level in x- and y-directions
% (total particle density per element equals product of these two)
num_part_elem_x = 3;
num_part_elem_y = 3;

% random noise for particle distribution
% can be from 0.0 (no noise) to 1.0 (highest noise)
part_noise = 0.3;

% zones of initial material distribution
% 1. each zone is specified by the following format:
%    {mtrl_no, constraint1, constraint2, ...}
% 2. 'mtrl_no' is index from the material library and so determines the 
%    material of the zone; zone will be filled with particles of this type
% 3. 'constraints' are vectorized anonymous functions determining 
%    area of the zone and having the following format: @(x, y)( ... )
%    for some point (x, y) function has to return 1 if this point is 
%    inside the zone and 0 otherwise
% 4. if there are no constraints the zone will be equal to the whole domain
% 5. in case of zones overlap the following zone in the list has the priority
mtrl_zones = { ...
    { 1 }, ...
    { 2, @(x,y)(x > 0.3), @(x,y)(x < 0.7), ...
         @(x,y)(y > 1.3), @(x,y)(y < 1.7) } };

% material library, index can be from 1 to 100 (upto 100 materials)
% mtrl_dens - density
% mtrl_visc - viscosity
% material 1
mtrl_dens(1) =  1.0;
mtrl_visc(1) =  1.0;
% material 2
mtrl_dens(2) =  3.0;
mtrl_visc(2) = 1000.0;
% viscosity and density for empty space (air)
dens0 = 0.00;
visc0 = 0.01;

% perform output ?
output_enabled = true;
% when to perform output - before advection (true), or after (false)
prec_output = false;