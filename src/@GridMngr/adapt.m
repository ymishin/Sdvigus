function adapt(obj)
% Perform wavelet-based grid adaptation.
%
% $Id$

if (~obj.adapt_grid)
    return;
end

global verbose;
t = tic;

% number of nodes
mask = obj.stokes.mask;
[num_node_y, num_node_x] = size(mask);

elem_order = obj.stokes.elem_order;
if (elem_order == 1)
    refine_fully = false; % 1st order
else
    refine_fully = true; % 2nd order
end

% preallocate
field = [];
eps = [];
n = 0;

% Viscosity field (interpolate from particles)
e = obj.adapt_criteria.viscosity;
if (e > 0)
    n = n + 1;
    interp_prop = 'VISC';
    field{n} = obj.particles.interp2node(mask, elem_order, interp_prop);
    eps(n) = e * abs(max(field{n}(:)) - min(field{n}(:))); % normalize
end

% Density field (interpolate from particles)
e = obj.adapt_criteria.density;
if (e > 0)
    n = n + 1;
    interp_prop = 'DENS';
    field{n} = obj.particles.interp2node(mask, elem_order, interp_prop);
    eps(n) = e * abs(max(field{n}(:)) - min(field{n}(:))); % normalize
end

% X-Velocity
e = obj.adapt_criteria.velocity_x;
if (e > 0)
    n = n + 1;
    field{n} = zeros(num_node_y, num_node_x);
    vel_x = obj.stokes_sys.velocity(:,1);
    field{n}(mask) = vel_x;
    eps(n) = e * abs(max(vel_x(:)) - min(vel_x(:))); % normalize
end

% Y-Velocity
e = obj.adapt_criteria.velocity_y;
if (e > 0)
    n = n + 1;
    field{n} = zeros(num_node_y, num_node_x);
    vel_y = obj.stokes_sys.velocity(:,2);
    field{n}(mask) = vel_y;
    eps(n) = e * abs(max(vel_y(:)) - min(vel_y(:))); % normalize
end

% update mask for each field
new_mask = Wavelets.update_mask(field, mask, obj.stokes.jmax, ...
                                true, refine_fully, eps);
clear field;

% combine masks
new_mask = any(reshape(cell2mat(new_mask), num_node_y, num_node_x, n), 3);

% has mask been changed ?
if (any(any(new_mask ~= mask)))
    obj.stokes.mask = new_mask;
    obj.stokes_update = true;
end

t = toc(t);
verbose.disp(['Grid adaptation ... ', num2str(t)], 2);

end