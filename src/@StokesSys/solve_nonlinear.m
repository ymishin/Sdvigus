function solve_nonlinear(obj)
% Solve non-linear Stokes system of equations.
%
% $Id$

global verbose;

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
if (verbose > 0)
    fprintf('Non-linear iteration %3d (initial)\n', j);
end

while (true)
    
    % update effective viscosities
    switch obj.elem_type
        case 1, p = obj.pressure;                     % Q1P0
        case 2, p = obj.pressure(elem2node);          % Q1Q1
        case 3, p = reshape(obj.pressure,3,num_elem); % Q2P-1
    end
    visc = obj.particles.update_visceff(p);
  
    % build new stiffness matrix and apply constraints
    obj.update_A_matrix(visc);
    obj.A = obj.CV' * obj.A * obj.CV;
    
    % solve the system
    v_prev = v;    
    obj.solve_linear();
    v = obj.velocity;
    
    % check convergence
    res = norm(v(:) - v_prev(:), norm_p) / norm(v(:), norm_p);
    j = j + 1;
    if (verbose > 0)
        fprintf('Non-linear iteration %3d, res %9.7f\n', j, res);
    end
    if (res < tolerance || j >= maxiter)
        break;
    end
    
end

end