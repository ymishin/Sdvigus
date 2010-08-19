% Domain.
%
% $Id$

classdef Domain < handle
    
    properties (SetAccess = private)
        
        % initial and current sizes of the domain
        size0;
        size;
        
        % boundary conditions
        stokes_bc;
        
        % change domain size ?
        change_size;
        
    end
    
    methods (Access = public)
        
        % init and output
        init(obj, df, cf);
        output(obj, of);
        
        % update size of the domain
        update(obj, dt);
        
    end
    
end