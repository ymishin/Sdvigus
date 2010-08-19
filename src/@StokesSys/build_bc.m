function build_bc(obj)
% Build BC vectors (equations and corresponding values).
%
% $Id: construct_bc.m 25 2010-06-04 22:51:28Z ymishin $

% boundary nodes
node_bnd = obj.grids.stokes.node_bnd;

eq = [];
val = [];

% make boundary exits
if (obj.bc_exits.left),  node_bnd{1} = node_bnd{1}(3:end); end;
if (obj.bc_exits.right), node_bnd{2} = node_bnd{2}(3:end); end;

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
obj.bc.eq  = eq';
obj.bc.val = val';

end