function plot_field(obj, postproc)
% Plot data fields stored on Stokes grid.
%
% $Id$

% possible fields to plot
fields = {'velocity_x', 'velocity_y', 'pressure'};

for i = 1:length(fields)
    
    % create any plots of current field ?
    field = fields{i};
    if (~postproc.isprop(field) || ~any(horzcat(postproc.(field).plot)))
        continue;
    end
    
    % all parameters
    descs = postproc.(field);
    
    % grid structure
    node_coord = obj.grids.stokes.node_coord;
    elem2node = obj.grids.stokes.elem2node;
    num_elem = size(elem2node, 2);
    
    % data to plot
    switch field
        case 'velocity_x'
            fdata = reshape(obj.velocity(elem2node(1:4,:), 1), 4, num_elem);
        case 'velocity_y'
            fdata = reshape(obj.velocity(elem2node(1:4,:), 2), 4, num_elem);
        case 'pressure'
            switch obj.elem_type
                case 1, fdata = obj.pressure';               % Q1P0
                case 2, fdata = obj.pressure(elem2node);     % Q1Q1
                case 3, fdata = obj.pressure(1:3:end)';      % Q2P-1
                    %gx = obj.pressure(2:3:end)'; % x-gradient
                    %gy = obj.pressure(3:3:end)'; % y-gradient
            end
    end
    
    % % plot all nodes in case of Q2P-1
    % fdata = [reshape(obj.velocity(elem2node([1 5 9 8],:), 1), 4, num_elem) ...
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
    
    % create plots of current field
    for j = 1:length(descs)
        
        % create plot ?
        desc = descs(j);
        if (isempty(desc.plot) || ~desc.plot)
            continue;
        end
        
        % plot the data
        h = figure('visible', 'off');
        coord_x = reshape(node_coord(1, elem2node(1:4,:)), 4, num_elem);
        coord_y = reshape(node_coord(2, elem2node(1:4,:)), 4, num_elem);
        patch(coord_x, coord_y, fdata, 'EdgeColor', 'none');
        
        % plot FE grid ?
        if (isfield(desc,'grid') && ~isempty(desc.grid))
            dgrid = desc.grid;
            if (isfield(dgrid,'plot') && ~isempty(dgrid.plot) && dgrid.plot)
                obj.grids.plot_grid_cf(dgrid);
            end
        end
        
        % tune and save
        postproc.save_plot(field, desc);
        close(h);
        
    end
    
end

end