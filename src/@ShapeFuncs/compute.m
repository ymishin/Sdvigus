function [N] = compute(inp_coord, num_node)
% Compute shape functions 'N' at local integration points 'inp_coord' for
% element with 'num_node' number of nodes.
% TODO: vectorize main loop
%
% $Id$

% number of points
num_inp = size(inp_coord,2);

% preallocate
N = zeros(num_inp,num_node);

% loop over integration points
for i = 1:num_inp
    
    % local coordinates
    xi  = inp_coord(1,i);
    eta = inp_coord(2,i);
    
    switch num_node
        case 1
            % shape functions
            N(i,:) = [1.0];
            
        case 3
            % shape functions
            N(i,:) = [1.0 xi eta];
            
        case 4
            % 1D polynomials
            p10 = 0.5 * (1.0 - xi);
            p11 = 0.5 * (1.0 + xi);
            p20 = 0.5 * (1.0 - eta);
            p21 = 0.5 * (1.0 + eta);
            
            % shape functions
            N(i,:) = [
                p10 * p20 ...
                p11 * p20 ...
                p11 * p21 ...
                p10 * p21];
            
        case 9
            % 1D polynomials
            p10 = 0.5 * xi * (xi - 1.0);
            p11 = -(xi + 1.0) * (xi - 1.0);
            p12 = 0.5 * xi * (xi + 1.0);
            p20 = 0.5 * eta * (eta - 1.0);
            p21 = -(eta + 1.0) * (eta - 1.0);
            p22 = 0.5 * eta * (eta + 1.0);
            
            % shape functions
            N(i,:) = [
                p10 * p20 ...
                p12 * p20 ...
                p12 * p22 ...
                p10 * p22 ...
                p11 * p20 ...
                p12 * p21 ...
                p11 * p22 ...
                p10 * p21 ...
                p11 * p21];
            
    end
    
end