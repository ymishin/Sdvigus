function run(obj)
% Reads model description and creates all necessary files.
%
% $Id$

% run model description script
run(obj.desc);

% *************** INITIAL DATA FILE ***************
if (create_init)
    
    % domain dimensions
    dsize = [xmin, xmax, ymin, ymax];
            
    % highest grid resolution
    reshl = [num_elem_x, num_elem_y];
    
    % construct grid mask
    if (jmax > 1)
        % element type
        switch elem_type
            case {1, 2}, elem_order = 1; % Q1P0, Q1Q1
            case 3,      elem_order = 2; % Q2P-1
        end
        % number of nodes at highest level
        num_nodes_x = num_elem_x * elem_order + 1;
        num_nodes_y = num_elem_y * elem_order + 1;
        % grid mask
        mask = false(num_nodes_y, num_nodes_x);
        s = 2 ^ (jmax - jstart);
        mask(1:s:end,1:s:end) = true;
    else
        % grid mask
        mask = 0;
    end
    
    % particle density
    num_part_x = num_part_elem_x * num_elem_x;
    num_part_y = num_part_elem_y * num_elem_y;
    num_part = num_part_x * num_part_y;
    
    % create particles uniformly
    dx = (xmax - xmin) / num_part_x; dx2 = 0.5 * dx;
    dy = (ymax - ymin) / num_part_y; dy2 = 0.5 * dy;
    [coord_x, coord_y] = meshgrid(linspace(xmin+dx2, xmax-dx2, num_part_x), ...
                                  linspace(ymin+dy2, ymax-dy2, num_part_y));
    
    % introduce some noise and accumulate
    rand('twister', 7777777);
    coord_x = coord_x + part_noise * dx * (rand(num_part_y, num_part_x) - 0.5);
    coord_y = coord_y + part_noise * dy * (rand(num_part_y, num_part_x) - 0.5);
    part_coord = [reshape(coord_x, numel(coord_x), 1), ...
        reshape(coord_y, numel(coord_y), 1)];
    clear coord_x coord_y;
    
    % assign types to particles according to material zones
    part_type = zeros(num_part, 1);
    for izone = 1:size(mtrl_zones, 2)
        % find particles inside current zone
        inside = true(num_part, 1); % by default all are inside
        funcs = mtrl_zones{izone}(2:end);
        for ifunc = 1:length(funcs)
            % check constraints
            inside = inside & funcs{ifunc}(part_coord(:,1), part_coord(:,2));
        end
        % assign type to particles which are inside
        part_type(inside) = mtrl_zones{izone}{1};
    end
    clear inside;
    
    % eliminate unassigned particles
    free = ~part_type;
    part_type(free) = [];
    part_coord(free,:) = [];
    clear free;
    
    % save initial setup file
    if (exist('init_fname', 'var'))
        fname = init_fname;
    else
        fname = [obj.model_name, '_00000', '.h5'];
    end
    w = 'writemode'; a = 'append';
    hdf5write(fname, '/time/dt', 0);
    hdf5write(fname, '/time/current_time', 0, w, a);
    hdf5write(fname, '/domain/size0', dsize, w, a);
    hdf5write(fname, '/domain/size', dsize, w, a);
    hdf5write(fname, '/grids/reshl', reshl, w, a);
    hdf5write(fname, '/grids/mask', uint8(mask), w, a);
    hdf5write(fname, '/grids/elem_type', elem_type, w, a);
    hdf5write(fname, '/grids/velocity', 0, w, a);
    hdf5write(fname, '/grids/pressure', 0, w, a);
    hdf5write(fname, '/particles/coord', part_coord, w, a);
    hdf5write(fname, '/particles/type', uint8(part_type), w, a);
    if (yielding_rheol || powerlaw_rheol)
        part_visc = mtrl_visc(part_type)';
        hdf5write(fname, '/particles/visc', part_visc, w, a);
        z = zeros(size(part_type));
        hdf5write(fname, '/particles/strain_rate', z, w, a);
        if (yielding_rheol)
            hdf5write(fname, '/particles/strain_plast', z, w, a);
        end
    end
    
    % number of the model file to start from
    csvwrite('start_from', 0);
    
end

% *************** MATERIAL LIBRARY ***************
if (create_mtrl)
    
    % for powerlaw rheology
    if (~exist('mtrl_n','var') || isempty(mtrl_n))
        mtrl_n = ones(size(mtrl_visc));
    end
    
    % for yielding rheology
    if (~exist('mtrl_cohesion','var') || isempty(mtrl_cohesion))
        mtrl_cohesion = Inf(2,length(mtrl_visc));
    end
    if (~exist('mtrl_phi','var') || isempty(mtrl_phi))
        mtrl_phi = zeros(2,length(mtrl_visc));
    end
    if (~exist('mtrl_weakhard','var') || isempty(mtrl_weakhard))
        mtrl_weakhard = zeros(2,length(mtrl_visc));
    end

    % save materal library file
    if (exist('mtrl_fname', 'var'))
        fname = init_fname;
    else
        fname = [obj.model_name, '_mtrl', '.h5'];
    end
    w = 'writemode'; a = 'append';
    hdf5write(fname, '/dens', mtrl_dens);
    hdf5write(fname, '/visc', mtrl_visc, w, a);
    hdf5write(fname, '/dens0', dens0, w, a);
    hdf5write(fname, '/visc0', visc0, w, a);
    hdf5write(fname, '/powerlaw/n', mtrl_n, w, a);    
    hdf5write(fname, '/yielding/cohesion', mtrl_cohesion, w, a);
    hdf5write(fname, '/yielding/phi', mtrl_phi, w, a);
    hdf5write(fname, '/yielding/weakhard', mtrl_weakhard, w, a);
    
end

% *************** CONTROL FILE ***************
if (create_ctrl)
    
    % boundary conditions
    % left
    bv_left = [0 0]; bv_left_free = [1 1];
    if (~isempty(bvx_left))
        bv_left(1) = bvx_left; bv_left_free(1) = 0;
    end
    if (~isempty(bvy_left))
        bv_left(2) = bvy_left; bv_left_free(2) = 0;
    end
    % right
    bv_right = [0 0]; bv_right_free = [1 1];
    if (~isempty(bvx_right))
        bv_right(1) = bvx_right; bv_right_free(1) = 0;
    end
    if (~isempty(bvy_right))
        bv_right(2) = bvy_right; bv_right_free(2) = 0;
    end
    % bottom
    bv_bottom = [0 0]; bv_bottom_free = [1 1];
    if (~isempty(bvx_bottom))
        bv_bottom(1) = bvx_bottom; bv_bottom_free(1) = 0;
    end
    if (~isempty(bvy_bottom))
        bv_bottom(2) = bvy_bottom; bv_bottom_free(2) = 0;
    end
    % top
    bv_top = [0 0]; bv_top_free = [1 1];
    if (~isempty(bvx_top))
        bv_top(1) = bvx_top; bv_top_free(1) = 0;
    end
    if (~isempty(bvy_top))
        bv_top(2) = bvy_top; bv_top_free(2) = 0;
    end
    
    % boundary exits
    if (~exist('left_exit','var') || isempty(left_exit))
        left_exit = false;
    end
    if (~exist('right_exit','var') || isempty(right_exit))
        right_exit = false;
    end
    
    % time step
    if (isempty(dt_default)), dt_default = -1; end
    if (isempty(courant)), courant = -1; end
    
    % Voronoi
    if (isempty(fixed_types)), fixed_types = -1; end
    if (isempty(min_area)), min_area = -1; end
    if (isempty(max_area)), max_area = -1; end
    
    % adaptive grid refinement
    if (jmax == 1), adapt_grid = false; end
    
    % criteria for adaptive grid refinement
    if (isempty(criter_viscosity)), criter_viscosity = 0; end
    if (isempty(criter_velocity_x)), criter_velocity_x = 0; end
    if (isempty(criter_velocity_y)), criter_velocity_y = 0; end
    
    % save control file
    if (exist('ctrl_fname', 'var'))
        fname = ctrl_fname;
    else
        fname = [obj.model_name, '_ctrl', '.h5'];
    end
    w = 'writemode'; a = 'append';
    hdf5write(fname, '/Fext', Fext);
    hdf5write(fname, '/domain/change_size', uint8(change_domain_size), w, a);
    hdf5write(fname, '/bc/bv_left', bv_left, w, a);
    hdf5write(fname, '/bc/bv_left_free', bv_left_free, w, a);
    hdf5write(fname, '/bc/bv_right', bv_right, w, a);
    hdf5write(fname, '/bc/bv_right_free', bv_right_free, w, a);
    hdf5write(fname, '/bc/bv_bottom', bv_bottom, w, a);
    hdf5write(fname, '/bc/bv_bottom_free', bv_bottom_free, w, a);
    hdf5write(fname, '/bc/bv_top', bv_top, w, a);
    hdf5write(fname, '/bc/bv_top_free', bv_top_free, w, a);
    hdf5write(fname, '/bc/left_exit', uint8(left_exit), w, a);
    hdf5write(fname, '/bc/right_exit', uint8(right_exit), w, a);
    hdf5write(fname, '/voronoi/enabled', uint8(voronoi_enabled), w, a);
    hdf5write(fname, '/voronoi/res', [voronoi_res_x, voronoi_res_y], w, a);
    hdf5write(fname, '/voronoi/fixed_types', fixed_types, w, a);
    hdf5write(fname, '/voronoi/min_area', min_area, w, a);
    hdf5write(fname, '/voronoi/max_area', max_area, w, a);
    hdf5write(fname, '/grids/adapt_grid', uint8(adapt_grid), w, a);
    hdf5write(fname, '/grids/jmax', jmax, w, a);
    hdf5write(fname, '/grids/criter_viscosity', criter_viscosity, w, a);
    hdf5write(fname, '/grids/criter_velocity_x', criter_velocity_x, w, a);
    hdf5write(fname, '/grids/criter_velocity_y', criter_velocity_y, w, a);
    hdf5write(fname, '/solvers/PH/k', PH_k, w, a);
    hdf5write(fname, '/solvers/PH/maxdiv', PH_maxdiv, w, a);
    hdf5write(fname, '/solvers/PH/maxiter', PH_maxiter, w, a);
    hdf5write(fname, '/solvers/nonlinear/norm', nonlinear_norm, w, a);
    hdf5write(fname, '/solvers/nonlinear/tol', nonlinear_tol, w, a);
    hdf5write(fname, '/solvers/nonlinear/maxiter', nonlinear_maxiter, w, a);
    hdf5write(fname, '/rheologies/yielding', uint8(yielding_rheol), w, a);
    hdf5write(fname, '/rheologies/powerlaw', uint8(powerlaw_rheol), w, a);
    hdf5write(fname, '/time/total_time', total_time, w, a);
    hdf5write(fname, '/time/dt_default', dt_default, w, a);
    hdf5write(fname, '/time/courant', courant, w, a);
    hdf5write(fname, '/output/enabled', uint8(output_enabled), w, a);
    hdf5write(fname, '/output/prec', uint8(prec_output), w, a);
    
end

end
