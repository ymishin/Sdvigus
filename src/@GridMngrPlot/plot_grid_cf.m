function plot_grid_cf(obj)
% Plot the grid.
%
% $Id$

% grid structure
node_coord = obj.stokes.node_coord;
elem2node = obj.stokes.elem2node;
num_elem = size(elem2node, 2);

% make the plot
hold on;
coord_x = reshape(node_coord(1, elem2node(1:4,:)), 4, num_elem);
coord_y = reshape(node_coord(2, elem2node(1:4,:)), 4, num_elem);
patch(coord_x, coord_y, 0, 'EdgeColor', 'k', 'FaceColor', 'none');
hold off;

end