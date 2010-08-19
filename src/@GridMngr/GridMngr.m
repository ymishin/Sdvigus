% Grid manager. Provides all functionality concerning grid(s).
%
% $Id$

classdef GridMngr < handle
    
    properties (SetAccess = protected)
        
        % Stokes grid
        stokes;
        stokes_update;
        
        % highest grid resolution
        reshl;
        
        % adaptive grid refinement
        adapt_grid;
        adapt_criteria;
        
        % references to main entities
        domain;
        particles;
        stokes_sys;
        
    end
    
    methods (Access = public)
        
        % init and output
        init(obj, df, cf, domain, particles, stokes_sys);
        output(obj, of);
        
        % grid adaptation
        adapt(obj);
        
        % grid generation
        generate(obj);
        
    end
    
end