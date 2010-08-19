function node_data = interp2node(obj, mask, elem_order, prop)
% Iterpolate physical properties from particles to nodes (nearest neighbour
% interpolation). Interpolation is performed only for nodes marked by 'mask'
% and grid is assumed to consist of elements of 'elem_order'.
% 'prop' determines property to interpolate.
%
% $Id$

% assign particles to elements
obj.reshape_data('cell_hl');

% property to interpolate
iprop = obj.iprop.(prop);

% perform iterpolation
switch elem_order
    case 1
        node_data = obj.interp2node_1(mask, iprop);
    case 2
        node_data = obj.interp2node_2(mask, iprop);
end

end