% Shape functions and their derivatives utility class.
%
% $Id$

classdef ShapeFuncs < handle
    
    methods (Access = public, Static = true)
        
        % compute shape functions
        N = compute(inp_coord, num_node);
        
        % compute derivatives of shape functions
        dN = compute_der(inp_coord, num_node);
        
    end
    
end