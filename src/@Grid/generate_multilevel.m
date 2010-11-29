function generate_multilevel(obj)
% Generate multilevel FE grid.
%
% $Id$

global verbose;
t = tic;

% domain dimensions
xmin = obj.dsize(1); xmax = obj.dsize(2);
ymin = obj.dsize(3); ymax = obj.dsize(4);

% number of elements at finest level
num_elem_x = obj.res(1);
num_elem_y = obj.res(2);
num_elem = num_elem_x * num_elem_y;

% mask, jmax, elem_order
mask = obj.mask;
jmax = obj.jmax;
elem_order = obj.elem_order;

% number of nodes at finest level
num_node_x = num_elem_x * elem_order + 1;
num_node_y = num_elem_y * elem_order + 1;

% nodes' bottom-up numbering
node_no = zeros(num_node_y, num_node_x, 'uint32');
node_no(mask) = 1:nnz(mask);

% nodes' global coordinates (bottom-up numbering)
[coord_x, coord_y] = meshgrid(linspace(xmin, xmax, num_node_x), ...
                              linspace(ymin, ymax, num_node_y));
node_coord = [coord_x(mask), coord_y(mask)]';

% abstract element at finest level
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
elem_level = zeros(num_elem, 1, 'uint8');
mask_el = false(num_node_y, num_node_x);
elem2elemhl = struct('no_elem', cell(jmax,1), 'no_elemhl', cell(jmax,1));
iel = 0;

% what type of element to search for ?
switch elem_order
    
    case 1
        
        % loop over grid levels, find and store all elements
        for j = jmax:-1:1
            
            % step
            s = 2 ^ (jmax - j);
            
            % preallocate
            n = 2 ^ (2 * (jmax - j));
            no_elem = zeros(num_elem / n, 1);
            no_elemhl = zeros(n, num_elem / n);
            iel_j = 0;
            
            % elements numbering offset at finest level
            offset = repmat((0:s-1), s, 1)' + ...
                repmat(num_elem_y * (0:s-1), s, 1);
            
            % check all elements at current level
            for inx = 1:s:(num_node_x-s)
                for iny = 1:s:(num_node_y-s)
                    
                    % is element refined at finer level ?
                    if (j<jmax && mask_el(iny,inx))
                        continue
                    end
                    
                    % check if element exists
                    if (j>1 && ~(mask(iny,inx) && mask(iny,inx+s) && ...
                                 mask(iny+s,inx+s) && mask(iny+s,inx)))
                        continue;
                    end
                    
                    % element exists and is not refined ->
                    % link it with corresponding nodes
                    iel = iel + 1;
                    elem2node(1,iel) = node_no(iny,inx);
                    elem2node(2,iel) = node_no(iny,inx+s);
                    elem2node(3,iel) = node_no(iny+s,inx+s);
                    elem2node(4,iel) = node_no(iny+s,inx);
                    
                    % element's level
                    elem_level(iel) = j;
                    
                    % inclusive elements at coarser levels are refined
                    mask_el(iny,inx) = true;
                    
                    % included elements from finest level
                    iel_j = iel_j + 1;
                    no_elem(iel_j) = iel;
                    no_elemhl(:,iel_j) = offset(:) + ...
                        num_elem_y * (inx - 1) + iny;
                    
                end
            end
            
            % store
            elem2elemhl(j).no_elem = uint32(no_elem(1:iel_j));
            elem2elemhl(j).no_elemhl = uint32(no_elemhl(:,1:iel_j));
            clear no_elem no_elemhl;
            
        end
        
    case 2
        
        % loop over grid levels, find and store all elements
        for j = jmax:-1:1
            
            % step
            s = 2 ^ (jmax - j) * 2;
            s2 = s / 2;
            
            % preallocate
            n = 2 ^ (2 * (jmax - j));
            no_elem = zeros(num_elem / n, 1);
            no_elemhl = zeros(n, num_elem / n);
            iel_j = 0;
            
            % elements numbering offset at finest level
            offset = repmat((0:s2-1), s2, 1)' + ...
                repmat(num_elem_y * (0:s2-1), s2, 1);
            
            % check all elements at current level
            for inx = 1:s:(num_node_x-s)
                for iny = 1:s:(num_node_y-s)
                    
                    % is element refined at finer level ?
                    if (j<jmax && mask_el(iny,inx))
                        continue
                    end
                    
                    % check if element exists
                    if (j>1 && ~(mask(iny,inx) && mask(iny,inx+s) && ...
                                 mask(iny+s,inx+s) && mask(iny+s,inx) && ...
                                 mask(iny,inx+s2) && mask(iny+s2,inx+s) && ...
                                 mask(iny+s,inx+s2) && mask(iny+s2,inx) && ...
                                 mask(iny+s2,inx+s2)))
                        continue;
                    end
                    
                    % element exists and is not refined ->
                    % link it with corresponding nodes
                    iel = iel + 1;
                    elem2node(1,iel) = node_no(iny,inx);
                    elem2node(2,iel) = node_no(iny,inx+s);
                    elem2node(3,iel) = node_no(iny+s,inx+s);
                    elem2node(4,iel) = node_no(iny+s,inx);
                    elem2node(5,iel) = node_no(iny,inx+s2);
                    elem2node(6,iel) = node_no(iny+s2,inx+s);
                    elem2node(7,iel) = node_no(iny+s,inx+s2);
                    elem2node(8,iel) = node_no(iny+s2,inx);
                    elem2node(9,iel) = node_no(iny+s2,inx+s2);
                    
                    % element's level
                    elem_level(iel) = j;
                    
                    % inclusive elements at coarser levels are refined
                    mask_el(iny,inx) = true;
                    
                    % included elements from finest level
                    iel_j = iel_j + 1;
                    no_elem(iel_j) = iel;
                    no_elemhl(:,iel_j) = offset(:) + ...
                        num_elem_y * (inx - 1) / 2 + (iny + 1) / 2;
                    
                end
            end
            
            % store
            elem2elemhl(j).no_elem = uint32(no_elem(1:iel_j));
            elem2elemhl(j).no_elemhl = uint32(no_elemhl(:,1:iel_j));
            clear no_elem no_elemhl;
            
        end
        
end

% shrink
elem2node = elem2node(:,1:iel);
elem_level = elem_level(1:iel);

% find boundary nodes
node_bnd = {node_no(mask(:,1),1)', ...     % left
            node_no(mask(:,end),end)', ... % right
            node_no(1,mask(1,:)), ...      % bottom
            node_no(end,mask(end,:))};     % top

% store
obj.node_coord = node_coord;
obj.elem2node = elem2node;
obj.node_bnd = node_bnd;
obj.elemhl = elemhl;
obj.elem_level = elem_level;
obj.elem2elemhl = elem2elemhl;

t = toc(t);
verbose.disp(['Multilevel grid generation ... ', num2str(t)], 2);

end