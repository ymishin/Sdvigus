function bc = construct_bc(obj)
% bc equations
%
% $Id$

% boundary nodes
node_bnd = obj.grids.stokes.node_bnd;

eq = [];
val = [];

% loop over sides of the domain
% left - right - bottom - top
for i = 1:4
    
    % check if x-velocity is prescribed
    if (~obj.stokes_bc.free(1,i))
        % velocity equations
        eq = [eq, double(node_bnd{i} * 2 - 1)];
        % prescribed values
        v = zeros(size(node_bnd{i}));
        v(:) = obj.stokes_bc.val(1,i);
        val = [val, v];
    end
    
    % check if y-velocity is prescribed
    if (~obj.stokes_bc.free(2,i))
        % velocity equations
        eq = [eq, double(node_bnd{i} * 2)];
        % prescribed values
        v = zeros(size(node_bnd{i}));
        v(:) = obj.stokes_bc.val(2,i);
        val = [val, v];
    end
    
end

% store
bc.eq  = eq';
bc.val = val';

end