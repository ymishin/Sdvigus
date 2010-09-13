function plot_grid(obj, postproc)
% Plot the grid.
%
% $Id$

desc = postproc.grid;
model = postproc.model_name;
time = postproc.current_time;
nf = postproc.nfile;
outdir = postproc.outdir;

% make the plot
h = figure('visible', 'off');
obj.plot_grid_cf();

% and tune it
box on;
axis xy equal;
if (isfield(desc,'domain'))
    axis(desc.domain);
else
    axis(obj.domain.size);
end
if (isfield(desc,'title'))
    title(eval(desc.title));
end
set(gca,'Layer','top');

% save the plot
if (isfield(desc,'fname'))
    fname = eval(desc.fname);
else
    fname = [model, '_grid_', num2str(nf, '%05d')];
end
if (isfield(desc,'opengl') && desc.opengl)
    renderer = '-opengl';
else
    renderer = '-zbuffer';
end
if (isfield(desc,'fmt'))
    fmt = ['-d', desc.fmt];
else
    fmt = '-djpeg';
end
if (isfield(desc,'dpi'))
    rdpi = ['-r', num2str(desc.dpi)];
else
    rdpi = '-r100';
end
print(renderer, fmt, rdpi, [outdir, '/', fname]);
close(h);

end