% ******************** POSTPROCESSING DESCRIPTION ********************

% numbers of data files to postprocess
nsteps = [0:5:150];

% common
axis = [0 1 0 1];
xtick = [0 0.5 1];
ytick = [0 0.5 1];
dpi = 300;
fmt = 'tiff';

% ***** PLOT JUST GRID *****

grid.plot = true;
grid.axis = axis;
grid.title = '[''multilevel grid, '', stime]';
grid.xtick = xtick;
grid.ytick = ytick;
grid.ticklength = 0;
grid.dpi = dpi;
grid.fmt = fmt;
grid.custom_funcs = { @cfunc };

% ***** PLOT FIELD(S) FROM GRID *****

velocity_x.plot = false;
velocity_x.axis = axis;
velocity_x.grid.plot = false;
velocity_x.title = '[''x-velocity, '', stime]';
velocity_x.xtick = xtick;
velocity_x.ytick = ytick;
velocity_x.dpi = dpi;
velocity_x.fmt = fmt;
velocity_x.custom_funcs = { @cfunc };

velocity_y.plot = true;
velocity_y.axis = axis;
velocity_y.grid.plot = false;
velocity_y.clim = [-8e-3 8e-3];
velocity_y.colorbar.plot = true;
velocity_y.colorbar.loc = 'SouthOutside';
velocity_y.title = '[''y-velocity, '', stime]';
velocity_y.xtick = xtick;
velocity_y.ytick = ytick;
velocity_y.dpi = dpi;
velocity_y.fmt = fmt;
velocity_y.custom_funcs = { @cfunc };

pressure.plot = false;
pressure.axis = axis;
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
material.axis = axis;
material.grid.plot = false;
material.cmap = [0.3 0.3 0.3; 0.7 0.7 0.7];
material.clim = [1 2];
material.title = '[''material field, '', stime]';
material.xtick = xtick;
material.ytick = ytick;
material.dpi = dpi;
material.fmt = fmt;
material.custom_funcs = { @cfunc };
% * scatter plot of individual particles *
% material.mode = 'scatter';
% material.partfilled = true;
% material.fmt = 'epsc2';
% material.rend = 'painters';

viscosity.plot = false;
viscosity.axis = axis;
viscosity.grid.plot = false;
viscosity.title = '[''viscosity, '', stime]';
viscosity.xtick = xtick;
viscosity.ytick = ytick;
viscosity.dpi = dpi;
viscosity.fmt = fmt;
viscosity.custom_funcs = { @cfunc };

density.plot = false;
density.axis = axis;
density.grid.plot = false;
density.title = '[''density, '', stime]';
density.xtick = xtick;
density.ytick = ytick;
density.dpi = dpi;
density.fmt = fmt;
density.custom_funcs = { @cfunc };

% ***** CUSTOM FUNCTION(S) TO PERFORM ADDITIONAL ANALYSIS *****

custom_funcs = { @cfunc2 };