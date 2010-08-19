function node_data = interp2node_1(obj, mask, iprop)
% Particles -> nodes iterpolation in case of 1st order elements FE grid.
%
% $Id$

% particles' data
data = obj.data;

% domain dimensions
xmin = obj.domain.size(1); xmax = obj.domain.size(2);
ymin = obj.domain.size(3); ymax = obj.domain.size(4);

% number of nodes
[num_node_y, num_node_x] = size(mask);
num_node = num_node_y * num_node_x;

% number of elements at finest level
num_elem_y = obj.grids.reshl(2);

% nodes' global coordinates (bottom-up numbering)
[coord_x, coord_y] = meshgrid(linspace(xmin, xmax, num_node_x), ...
                              linspace(ymin, ymax, num_node_y));

% preallocate
node_data = zeros(num_node, 1);

% loop over nodes
parfor in = 1:num_node
    
    % check if the node is in the mask
    if (~mask(in))
        continue;
    end
    
    % find elements adjacent to the node
    inx = ceil(in / num_node_y);
    iny = in - (inx - 1) * num_node_y;
    tr = []; br = []; tl = []; bl = [];
    if (inx < num_node_x && iny < num_node_y)
        % top-right
        tr = (inx - 1) * num_elem_y + iny;
    end
    if (inx < num_node_x && iny > 1)
        % bottom-right
        br = (inx - 1) * num_elem_y + iny - 1;
    end
    if (inx > 1 && iny < num_node_y)
        % top-left
        tl = (inx - 2) * num_elem_y + iny;
    end
    if (inx > 1 && iny > 1)
        % bottom-left
        bl = (inx - 2) * num_elem_y + iny - 1;
    end
    
    % particles data from adjacent elements
    part_data_nearest = vertcat(data{[tr br tl bl]});
    
    % are there any particles ?
    if (isempty(part_data_nearest))
        continue;
    end
    
    % find particle nearest to the node and store its data
    [ignore, ip] = min((part_data_nearest(:,1) - coord_x(in)).^2 + ...
                       (part_data_nearest(:,2) - coord_y(in)).^2);
    node_data(in) = part_data_nearest(ip,iprop);
    
end

% reshape
node_data = reshape(node_data, num_node_y, num_node_x);

end