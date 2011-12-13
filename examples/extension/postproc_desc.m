% ******************** POSTPROCESSING DESCRIPTION ********************

% numbers of data files to postprocess
nsteps = [0:20];

% common
xtick = [-1.5 0 1.5];
ytick = [0 1];
dpi = 300;
fmt = 'tiff';

% ***** PLOT JUST GRID *****

grid.plot = true;
grid.title = '[''multilevel grid, '', stime]';
grid.xtick = xtick;
grid.ytick = ytick;
grid.ticklength = 0;
grid.dpi = dpi;
grid.fmt = fmt;
grid.custom_funcs = { @cfunc };

% ***** PLOT FIELD(S) FROM GRID *****

velocity_x.plot = false;
velocity_x.grid.plot = false;
velocity_x.title = '[''x-velocity, '', stime]';
velocity_x.xtick = xtick;
velocity_x.ytick = ytick;
velocity_x.dpi = dpi;
velocity_x.fmt = fmt;
velocity_x.custom_funcs = { @cfunc };

velocity_y.plot = false;
velocity_y.grid.plot = false;
velocity_y.title = '[''y-velocity, '', stime]';
velocity_y.xtick = xtick;
velocity_y.ytick = ytick;
velocity_y.dpi = dpi;
velocity_y.fmt = fmt;
velocity_y.custom_funcs = { @cfunc };

pressure.plot = false;
pressure.grid.plot = false;
pressure.title = '[''pressure, '', stime]';
pressure.xtick = xtick;
pressure.ytick = ytick;
pressure.dpi = dpi;
pressure.fmt = fmt;
pressure.custom_funcs = { @cfunc };

% ***** PLOT FIELD(S) FROM PARTICLES *****

% resolution of Voronoi tessellation for particles->grid interpolation
voronoi_res = [3 3];

material.plot = true;
material.grid.plot = false;
material.cmap = [0.0 0.0 0.0; 0.3 0.3 0.3; 0.7 0.7 0.7];
material.caxis = [0 2];
material.title = '[''material field, '', stime]';
material.xtick = xtick;
material.ytick = ytick;
material.dpi = dpi;
material.fmt = fmt;
material.custom_funcs = { @cfunc };

viscosity.plot = false;
viscosity.grid.plot = false;
viscosity.title = '[''viscosity, '', stime]';
viscosity.xtick = xtick;
viscosity.ytick = ytick;
viscosity.dpi = dpi;
viscosity.fmt = fmt;
viscosity.custom_funcs = { @cfunc };

density.plot = false;
density.grid.plot = false;
density.title = '[''density, '', stime]';
density.xtick = xtick;
density.ytick = ytick;
density.dpi = dpi;
density.fmt = fmt;
density.custom_funcs = { @cfunc };

strain_rate.plot = true;
strain_rate.grid.plot = false;
strain_rate.log = true;
strain_rate.clim = [-2.5 0.5];
strain_rate.colorbar.plot = true;
strain_rate.colorbar.loc = 'SouthOutside';
strain_rate.title = '[''2nd strain rate invariant, '', stime]';
strain_rate.xtick = xtick;
strain_rate.ytick = ytick;
strain_rate.dpi = dpi;
strain_rate.fmt = fmt;
strain_rate.custom_funcs = { @cfunc };

strain_plast.plot = false;
strain_plast.grid.plot = false;
strain_plast.title = '[''accumulated plastic strain, '', stime]';
strain_plast.xtick = xtick;
strain_plast.ytick = ytick;
strain_plast.dpi = dpi;
strain_plast.fmt = fmt;
strain_plast.custom_funcs = { @cfunc };

% ***** CUSTOM FUNCTION(S) TO PERFORM ADDITIONAL ANALYSIS *****

custom_funcs = { @cfunc2 };