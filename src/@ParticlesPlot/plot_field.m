function plot_field(obj, postproc)
% Plot data fields stored on particles.
%
% $Id$

% possible fields to plot
fields = {'material', 'viscosity', 'density', 'strain_rate', 'strain_plast'};

for i = 1:length(fields)
    
    % create any plots of current field ?
    field = fields{i};
    if (~postproc.isprop(field) || ~any(horzcat(postproc.(field).plot)))
        continue;
    end
    
    % all parameters
    descs = postproc.(field);
    
    % data index
    switch field
        case 'material',     ind = obj.iprop.TYPE;
        case 'viscosity',    ind = obj.iprop.VISC;
        case 'density',      ind = obj.iprop.DENS;
        case 'strain_rate',  ind = obj.iprop.STRAIN_RATE;
        case 'strain_plast', ind = obj.iprop.STRAIN_PLAST;
    end
    if (isempty(ind)), continue; end;
    
    % create plots of current field
    for j = 1:length(descs)
        
        % create plot ?
        desc = descs(j);
        if (isempty(desc.plot) || ~desc.plot)
            continue;
        end
        
        % plot data field
        h = figure('visible','off');
        if (isfield(desc,'mode') && strcmpi(desc.mode,'scatter'))
            obj.plot_field_scatter(ind, desc);
        else
            obj.plot_field_voronoi(ind, desc);
        end
        
        % plot FE grid ?
        if (isfield(desc,'grid') && ~isempty(desc.grid))
            dgrid = desc.grid;
            if (isfield(dgrid,'plot') && ~isempty(dgrid.plot) && dgrid.plot)
                obj.grids.plot_grid_cf(dgrid);
            end
        end
        
        % tune and save
        postproc.tune_save_plot(field, desc);
        close(h);
        
    end
    
end