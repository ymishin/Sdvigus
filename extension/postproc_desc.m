% ******************** POSTPROCESSING DESCRIPTION ********************

% numbers of data files to postprocess
nsteps = 1:10;

% common settings
dpi = 200;

% ***** PLOT JUST GRID *****

grid.plot = false;
grid.title = '[''Grid, '', stime]';
grid.dpi = dpi;

% ***** PLOT FIELD(S) FROM GRID *****

velocity_x.plot = true;
velocity_x.grid = false;
velocity_x.title = '[''x-velocity, '', stime]';
velocity_x.dpi = dpi;

velocity_y.plot = true;
velocity_y.grid = false;
velocity_y.title = '[''y-velocity, '', stime]';
velocity_y.dpi = dpi;

pressure.plot = true;
pressure.grid = false;
pressure.title = '[''pressure, '', stime]';
pressure.dpi = dpi;

% ***** PLOT FIELD(S) FROM PARTICLES *****

% resolution of Voronoi tessellation for particles->grid interpolation
voronoi_res = [3 3];

material.plot = true;
material.grid = false;
material.title = '[''material field, '', stime]';
material.dpi = dpi;

viscosity.plot = false;
viscosity.grid = false;
viscosity.title = '[''viscosity, '', stime]';
viscosity.dpi = dpi;

density.plot = false;
density.grid = false;
density.title = '[''density, '', stime]';
density.dpi = dpi;

strain_rate.plot = true;
strain_rate.grid = false;
strain_rate.title = '[''strain rate, '', stime]';
strain_rate.dpi = dpi;

strain_plast.plot = false;
strain_plast.grid = false;
strain_plast.title = '[''plastic strain, '', stime]';
strain_plast.dpi = dpi;