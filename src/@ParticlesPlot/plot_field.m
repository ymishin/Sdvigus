function plot_field(obj, f, postproc)
% Plot data field stored on particles.
% Data field to plot is first interpolated to an equidistant 
% grid using Voronoi tessellation and then plotted from this grid.
%
% $Id$

desc = postproc.(f);
model = postproc.model_name;
time = postproc.current_time;
nf = postproc.nfile;
outdir = postproc.outdir;

% data index
switch f
    case 'material',     ind = obj.iprop.TYPE;
    case 'viscosity',    ind = obj.iprop.VISC;
    case 'density',      ind = obj.iprop.DENS;
    case 'strain_rate',  ind = obj.iprop.STRAIN_RATE;
    case 'strain_plast', ind = obj.iprop.STRAIN_PLAST;
end
if (isempty(ind)), return; end;

% grid and Voronoi resolutions
num_dp_x = obj.voronoi.vres(1);
num_dp_y = obj.voronoi.vres(2);
num_elem_x = obj.grids.reshl(1);
num_elem_y = obj.grids.reshl(2);
num_elem = num_elem_x * num_elem_y;

% assign particles to elements
obj.reshape_data('cell_hl');

% perform Voronoi tessellation
if (isempty(obj.vcells))
    obj.vcells = obj.voronoi.compute(obj.data);
end

% preallocate
field = zeros(num_dp_y * num_elem_y, num_dp_x * num_elem_x);
field = mat2cell(field, repmat(num_dp_y, 1, num_elem_y), ...
                        repmat(num_dp_x, 1, num_elem_x));

% interpolate properies to an equidistant grid
data = obj.data;
vcells = obj.vcells;
parfor iel = 1:num_elem
    
    % is element empty ?
    edata = data{iel};
    if (isempty(edata))
        continue;
    end
    
    % interpolate
    num_part = size(edata, 1);
    evcells = double(vcells(iel,:));
    m = (evcells <= num_part);
    field{iel}(m) = edata(evcells(m), ind);
    field{iel} = reshape(field{iel}, num_dp_y, num_dp_x);
    
end
clear data vcells;
field = cell2mat(field);

% find empty space
empty_cells = (field == 0);

% modify for log-plot
if (strcmp(f,'strain_rate'))
    field = log10(field);
end

% make the plot
h = figure('visible','off');
X = linspace(obj.domain.size(1), obj.domain.size(2), num_elem_x * num_dp_x + 1);
Y = linspace(obj.domain.size(3), obj.domain.size(4), num_elem_y * num_dp_y + 1);
field = [field; field(end,:)];
field = [field, field(:,end)];
pcolor(X, Y, field);
clear field;
shading flat;

% make empty space to be white
num_empty = nnz(empty_cells);
if (num_empty > 0)
    if (isempty(obj.empty_coord))
        % construct coordinates of empty cells
        grid = Grid();
        grid.dsize = obj.domain.size;
        grid.elem_order = 1;
        grid.res = [num_elem_x * num_dp_x, num_elem_y * num_dp_y];
        grid.generate_simple();
        obj.empty_coord{1} = reshape(grid.node_coord( ...
            1, grid.elem2node(1:4, empty_cells)), 4, num_empty);
        obj.empty_coord{2} = reshape(grid.node_coord( ...
            2, grid.elem2node(1:4, empty_cells)), 4, num_empty);
        delete(grid);
    end
    % add white empty cells to the plot
    hold on;
    patch(obj.empty_coord{1}, obj.empty_coord{2}, 0, ...
        'EdgeColor', 'none', 'FaceColor', 'w');
    hold off;
end

% plot FE grid ?
if (isfield(desc,'grid') && desc.grid)
    obj.grids.plot_grid_cf();
end

% tune the plot
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
if (isfield(desc,'opengl') && desc.opengl)
    renderer = '-opengl';
else
    renderer = '-zbuffer';
end
if (isfield(desc,'tiff') && desc.tiff)
    format = '-dtiff'; ext = '.tiff';
else
    format = '-djpeg'; ext = '.jpeg';
end
if (isfield(desc,'dpi'))
    rdpi = ['-r', num2str(desc.dpi)];
else
    rdpi = '-r100';
end
print(renderer, format, rdpi, [outdir, '/', fname, ext]);
close(h);

end