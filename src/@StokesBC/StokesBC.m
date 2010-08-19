% Boundary conditions for Stokes system.
%
% $Id$

classdef StokesBC < handle
    
    properties (SetAccess = private)
        
        % values of velocities at boundaries
        val;
        
        % flags indicating un-constrained velocities
        free;
        
    end
    
    methods (Access = public)
        
        % init
        init(obj, df, cf);
        
    end
    
end