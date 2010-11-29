function generate_simple(obj)
% Generate equidistant FE grid.
%
% $Id$

global verbose;
t = tic;

% domain dimensions
xmin = obj.dsize(1); xmax = obj.dsize(2);
ymin = obj.dsize(3); ymax = obj.dsize(4);

% number of elements
num_elem_x = obj.res(1);
num_elem_y = obj.res(2);
num_elem = num_elem_x * num_elem_y;

% order of elements
elem_order = obj.elem_order;

% number of nodes
num_node_x = num_elem_x * elem_order + 1;
num_node_y = num_elem_y * elem_order + 1;

% nodes' bottom-up numbering
node_no = zeros(num_node_y, num_node_x, 'uint32');
node_no(:) = 1:(num_node_x * num_node_y);

% nodes' global coordinates (bottom-up numbering)
[coord_x, coord_y] = meshgrid(linspace(xmin, xmax, num_node_x), ...
                              linspace(ymin, ymax, num_node_y));
node_coord = [coord_x(:), coord_y(:)]';

% abstract element
switch elem_order
    case 1
        elemhl = [(coord_x(1,2) - coord_x(1,1)), ... % dx
                  (coord_y(2,1) - coord_y(1,1))];    % dy
    case 2
        elemhl = [(coord_x(1,3) - coord_x(1,1)), ... % dx
                  (coord_y(3,1) - coord_y(1,1))];    % dy
end
clear coord_x coord_y;

% preallocate
nnode = (elem_order + 1) ^ 2; % number of nodes per element
elem2node = zeros(nnode, num_elem, 'uint32');
iel = 0;

% what type of element to search for ?
switch elem_order
    
    case 1
        
        % loop over nodes
        for inx = 1:(num_node_x-1)
            for iny = 1:(num_node_y-1)
                
                % link element with corresponding nodes
                iel = iel + 1;
                elem2node(1,iel) = node_no(iny,inx);
                elem2node(2,iel) = node_no(iny,inx+1);
                elem2node(3,iel) = node_no(iny+1,inx+1);
                elem2node(4,iel) = node_no(iny+1,inx);
                
            end
        end
        
    case 2
        
        % loop over nodes
        for inx = 1:2:(num_node_x-2)
            for iny = 1:2:(num_node_y-2)
                
                % link element with corresponding nodes
                iel = iel + 1;
                elem2node(1,iel) = node_no(iny,inx);
                elem2node(2,iel) = node_no(iny,inx+2);
                elem2node(3,iel) = node_no(iny+2,inx+2);
                elem2node(4,iel) = node_no(iny+2,inx);
                elem2node(5,iel) = node_no(iny,inx+1);
                elem2node(6,iel) = node_no(iny+1,inx+2);
                elem2node(7,iel) = node_no(iny+2,inx+1);
                elem2node(8,iel) = node_no(iny+1,inx);
                elem2node(9,iel) = node_no(iny+1,inx+1);
                
            end
        end
end

% shrink
elem2node = elem2node(:,1:iel);

% find boundary nodes
node_bnd = {node_no(:,1)', ...    % left
            node_no(:,end)', ...  % right
            node_no(1,:), ...     % bottom
            node_no(end,:)};      % top

% store
obj.node_coord = node_coord;
obj.elem2node = elem2node;
obj.node_bnd = node_bnd;
obj.elemhl = elemhl;
obj.elem_level = [];
obj.elem2elemhl = [];

t = toc(t);
verbose.disp(['Equidistant grid generation ... ', num2str(t)], 2);

end