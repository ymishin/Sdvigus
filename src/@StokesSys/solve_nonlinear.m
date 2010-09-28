function solve_nonlinear(obj)
% Solve non-linear Stokes system of equations.
%
% $Id$

global verbose;
t = tic;

% parameters
norm_p = obj.solv_params.nonlinear_norm;
tolerance = obj.solv_params.nonlinear_tol;
maxiter = obj.solv_params.nonlinear_maxiter;

% number of elements
elem2node = obj.grids.stokes.elem2node;
num_elem = size(elem2node, 2);

% solve the system
j = 0;
obj.solve_linear();
v = obj.velocity;
verbose.disp('Non-linear iteration   0 (initial)', 2);

while (true)
    
    % update effective viscosities
    switch obj.elem_type
        case 1, p = obj.pressure;                     % Q1P0
        case 2, p = obj.pressure(elem2node);          % Q1Q1
        case 3, p = reshape(obj.pressure,3,num_elem); % Q2P-1
    end
    visc = obj.particles.update_visceff(p);
    
    % update Stokes system
    obj.update_A_matrix(visc);
    
    % solve the system
    v_prev = v;
    obj.solve_linear();
    v = obj.velocity;
    
    % check convergence
    res = norm(v(:) - v_prev(:), norm_p) / norm(v(:), norm_p);
    j = j + 1;
    m = sprintf('Non-linear iteration %3d, res: %9.7f', j, res);
    verbose.disp(m, 2);
    if (res < tolerance || j >= maxiter)
        break;
    end
    
end

t = toc(t);
if (res < tolerance), c = 'converged'; else c = 'didn''t converge'; end;
verbose.disp(['Non-linear iterations - ', c, ' ... ', num2str(t)], 2);

end