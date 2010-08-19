function solve_linear(obj)
% Solve linear Stokes system of equations.
%
% $Id$

% choose appropriate solver depending on element type
switch obj.elem_type
    
    case {1,3}
        % Q1P0, Q2P-1
        obj.solve_linear_PH();
        
    case 2
        % Q1Q1
        obj.solve_linear_coupled();
        
end

end