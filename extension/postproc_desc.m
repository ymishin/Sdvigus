% ******************** POSTPROCESSING DESCRIPTION ********************

% numbers of data files to postprocess
first = 1;
last  = 10;
step  = 1;

dpi = 200;

% ***** PLOT JUST GRID *****

grid.plot = false;
grid.title = '[''Grid, '', num2str(time)]';
grid.dpi = dpi;

% ***** PLOT FIELD(S) FROM GRID *****

velocity_x.plot = true;
velocity_x.grid = false;
velocity_x.title = '[''x-velocity, '', num2str(time)]';
velocity_x.dpi = dpi;

velocity_y.plot = true;
velocity_y.grid = false;
velocity_y.title = '[''y-velocity, '', num2str(time)]';
velocity_y.dpi = dpi;

pressure.plot = true;
pressure.grid = false;
pressure.title = '[''pressure, '', num2str(time)]';
pressure.dpi = dpi;

% ***** PLOT FIELD(S) FROM PARTICLES *****

% resolution of Voronoi tessellation for particles->grid interpolation
voronoi_res = [3 3];

material.plot = true;
material.grid = false;
material.title = '[''material field, '', num2str(time)]';
material.dpi = dpi;

viscosity.plot = false;
viscosity.grid = false;
viscosity.title = '[''viscosity, '', num2str(time)]';
viscosity.dpi = dpi;

density.plot = false;
density.grid = false;
density.title = '[''density, '', num2str(time)]';
density.dpi = dpi;

strain_rate.plot = true;
strain_rate.grid = false;
strain_rate.title = '[''strain rate, '', num2str(time)]';
strain_rate.dpi = dpi;

strain_plast.plot = false;
strain_plast.grid = false;
strain_plast.title = '[''plastic strain, '', num2str(time)]';
strain_plast.dpi = dpi;