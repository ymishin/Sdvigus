function plot_field(obj, f, postproc)
% Plot data field stored on Stokes grid.
%
% $Id$

desc = postproc.(f);
model = postproc.model_name;
time = postproc.current_time;
nf = postproc.nfile;
outdir = postproc.outdir;

% grid structure
node_coord = obj.grids.stokes.node_coord;
elem2node = obj.grids.stokes.elem2node;
num_elem = size(elem2node, 2);

% field to plot
switch f
    case 'velocity_x'
        field = reshape(obj.velocity(elem2node(1:4,:), 1), 4, num_elem);
    case 'velocity_y'
        field = reshape(obj.velocity(elem2node(1:4,:), 2), 4, num_elem);
    case 'pressure'
        switch obj.elem_type
            case 1, field = obj.pressure';               % Q1P0
            case 2, field = obj.pressure(elem2node);     % Q1Q1
            case 3, field = obj.pressure(1:3:end)';      % Q2P-1
                %gx = obj.pressure(2:3:end)'; % x-gradient
                %gy = obj.pressure(3:3:end)'; % y-gradient
        end
end

% % plot all nodes in case of Q2P-1
% field = [reshape(obj.velocity(elem2node([1 5 9 8],:), 1), 4, num_elem) ...
%          reshape(obj.velocity(elem2node([5 2 6 9],:), 1), 4, num_elem) ...
%          reshape(obj.velocity(elem2node([9 6 3 7],:), 1), 4, num_elem) ...
%          reshape(obj.velocity(elem2node([8 9 7 4],:), 1), 4, num_elem)];
% coord_x = [reshape(node_coord(1, elem2node([1 5 9 8],:)), 4, num_elem) ...
%            reshape(node_coord(1, elem2node([5 2 6 9],:)), 4, num_elem) ...
%            reshape(node_coord(1, elem2node([9 6 3 7],:)), 4, num_elem) ...
%            reshape(node_coord(1, elem2node([8 9 7 4],:)), 4, num_elem)];
% coord_y = [reshape(node_coord(2, elem2node([1 5 9 8],:)), 4, num_elem) ...
%            reshape(node_coord(2, elem2node([5 2 6 9],:)), 4, num_elem) ...
%            reshape(node_coord(2, elem2node([9 6 3 7],:)), 4, num_elem) ...
%            reshape(node_coord(2, elem2node([8 9 7 4],:)), 4, num_elem)];

% plot FE grid ?
edge_color = 'none';
if (isfield(desc,'grid') && desc.grid)
    edge_color = 'k';
end

% make the plot
h = figure('visible', 'off');
coord_x = reshape(node_coord(1, elem2node(1:4,:)), 4, num_elem);
coord_y = reshape(node_coord(2, elem2node(1:4,:)), 4, num_elem);
patch(coord_x, coord_y, field, 'EdgeColor', edge_color);

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
    fname = [model, '_', f, '_', num2str(nf, '%05d')];
end
if (isfield(desc,'dpi'))
    rdpi = ['-r', num2str(desc.dpi)];
else
    rdpi = '-r100';
end
print('-zbuffer', '-djpeg', rdpi, [outdir, '/', fname, '.jpg']);
close(h);

end