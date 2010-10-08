function plot_grid(obj, postproc)
% Plot the grid.
%
% $Id$

field = 'grid';

% create any plots ?
if (~postproc.isprop(field) || ~any(horzcat(postproc.(field).plot)))
    return;
end

% all parameters
descs = postproc.(field);

% create grid plots
for j = 1:length(descs)
    
    % create plot ?
    desc = descs(j);
    if (isempty(desc.plot) || ~desc.plot)
        continue;
    end
    
    % plot the grid
    h = figure('visible', 'off');
    obj.plot_grid_cf(desc);
    
    % tune and save
    postproc.tune_save_plot(field, desc);
    close(h);
    
end

end