function node_data = interp2node_2(obj, mask, iprop)
% Particles -> nodes iterpolation in case of 2nd order elements FE grid.
%
% $Id$

% particles' data
data = obj.data;

% domain dimensions
xmin = obj.domain.size(1); xmax = obj.domain.size(2);
ymin = obj.domain.size(3); ymax = obj.domain.size(4);

% number of nodes
[num_node_y, num_node_x] = size(mask);

% number of elements at finest level
num_elem_y = obj.grids.reshl(2);

% nodes' global coordinates (bottom-up numbering)
[coord_x, coord_y] = meshgrid(linspace(xmin, xmax, num_node_x), ...
                              linspace(ymin, ymax, num_node_y));

% preallocate
node_data = zeros(num_node_y, num_node_x);

% ***** interpolate to nodes at corners *****
mask1 = mask(1:2:end,1:2:end);
node_data(1:2:end,1:2:end) = obj.interp2node_1(mask1, iprop);

% ***** interpolate to nodes at vertical edges *****
mask1 = mask(2:2:end-1,1:2:end);
coord_x1 = coord_x(2:2:end-1,1:2:end);
coord_y1 = coord_y(2:2:end-1,1:2:end);
[num_node_y, num_node_x] = size(mask1);
node_data1 = zeros(num_node_y, num_node_x);
% loop over nodes
for iny = 1:num_node_y
    for inx = 1:num_node_x
        
        % check if the node is in the mask
        if (~mask1(iny,inx))
            continue;
        end
        
        % find elements adjacent to the node
        r = []; l = [];
        if (inx < num_node_x)
            % right
            r = (inx - 1) * num_elem_y + iny;
        end
        if (inx > 1)
            % left
            l = (inx - 2) * num_elem_y + iny;
        end
        
        % particles data from adjacent elements
        part_data_nearest = vertcat(data{[r l]});
        
        % are there any particles ?
        if (isempty(part_data_nearest))
            continue;
        end
        
        % find particle nearest to the node and store its data
        [ignore, ip] = min((part_data_nearest(:,1) - coord_x1(iny,inx)).^2 + ...
                           (part_data_nearest(:,2) - coord_y1(iny,inx)).^2);
        node_data1(iny,inx) = part_data_nearest(ip,iprop);
        
    end
end
% store
node_data(2:2:end-1,1:2:end) = node_data1;

% ***** interpolate to nodes at horizontal edges *****
mask1 = mask(1:2:end,2:2:end-1);
coord_x1 = coord_x(1:2:end,2:2:end-1);
coord_y1 = coord_y(1:2:end,2:2:end-1);
[num_node_y, num_node_x] = size(mask1);
node_data1 = zeros(num_node_y, num_node_x);
% loop over nodes
for iny = 1:num_node_y
    for inx = 1:num_node_x
        
        % check if the node is in the mask
        if (~mask1(iny,inx))
            continue;
        end
        
        % find elements adjacent to the node
        t = []; b = [];
        if (iny < num_node_y)
            % top
            t = (inx - 1) * num_elem_y + iny;
        end
        if (iny > 1)
            % bottom
            b = (inx - 1) * num_elem_y + iny - 1;
        end
        
        % particles data from adjacent elements
        part_data_nearest = vertcat(data{[t b]});
        
        % are there any particles ?
        if (isempty(part_data_nearest))
            continue;
        end
        
        % find particle nearest to the node and store its data
        [ignore, ip] = min((part_data_nearest(:,1) - coord_x1(iny,inx)).^2 + ...
                           (part_data_nearest(:,2) - coord_y1(iny,inx)).^2);
        node_data1(iny,inx) = part_data_nearest(ip,iprop);
        
    end
end
% store
node_data(1:2:end,2:2:end-1) = node_data1;

% ***** interpolate to nodes at centers *****
mask1 = mask(2:2:end-1,2:2:end-1);
coord_x1 = coord_x(2:2:end-1,2:2:end-1);
coord_y1 = coord_y(2:2:end-1,2:2:end-1);
[num_node_y, num_node_x] = size(mask1);
node_data1 = zeros(num_node_y, num_node_x);
% loop over nodes
for iny = 1:num_node_y
    for inx = 1:num_node_x
        
        % check if the node is in the mask
        if (~mask1(iny,inx))
            continue;
        end
        
        % particles data
        part_data_nearest = data{(inx - 1) * num_elem_y + iny};
        
        % are there any particles ?
        if (isempty(part_data_nearest))
            continue;
        end
        
        % find particle nearest to the node and store its data
        [ignore, ip] = min((part_data_nearest(:,1) - coord_x1(iny,inx)).^2 + ...
                           (part_data_nearest(:,2) - coord_y1(iny,inx)).^2);
        node_data1(iny,inx) = part_data_nearest(ip,iprop);
        
    end
end
% store
node_data(2:2:end-1,2:2:end-1) = node_data1;

end