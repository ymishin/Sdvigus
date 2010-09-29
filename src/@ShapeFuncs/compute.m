function N = compute(inp_coord, num_node)
% Compute shape functions 'N' at local integration points 'inp_coord' for
% element with 'num_node' number of nodes.
%
% $Id$

% number of points
num_inp = size(inp_coord, 2);

% local coordinates
xi  = inp_coord(1,:)';
eta = inp_coord(2,:)';

switch num_node
    
    case 1
        % shape functions
        N = ones(num_inp, 1);
        
    case 3
        % shape functions
        N = [ones(num_inp,1) xi eta];
        
    case 4
        % 1D polynomials
        p10 = 0.5 * (1.0 - xi);
        p11 = 0.5 * (1.0 + xi);
        p20 = 0.5 * (1.0 - eta);
        p21 = 0.5 * (1.0 + eta);
        % shape functions
        N = [ ...
            p10 .* p20 ...
            p11 .* p20 ...
            p11 .* p21 ...
            p10 .* p21];
        
    case 9
        % 1D polynomials
        p10 = 0.5 * xi .* (xi - 1.0);
        p11 = -(xi + 1.0) .* (xi - 1.0);
        p12 = 0.5 * xi .* (xi + 1.0);
        p20 = 0.5 * eta .* (eta - 1.0);
        p21 = -(eta + 1.0) .* (eta - 1.0);
        p22 = 0.5 * eta .* (eta + 1.0);
        % shape functions
        N = [ ...
            p10 .* p20 ...
            p12 .* p20 ...
            p12 .* p22 ...
            p10 .* p22 ...
            p11 .* p20 ...
            p12 .* p21 ...
            p11 .* p22 ...
            p10 .* p21 ...
            p11 .* p21];
        
end

end