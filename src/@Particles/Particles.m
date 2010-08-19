% Contains everything concerning particles.
%
% $Id$

classdef Particles < handle
    
    properties (SetAccess = private)
        
        % all particles' properties
        data;
        data_state;
        
        % number of particles
        num_part;
        
        % properties indices
        iprop;
        
        % Voronoi tessellation
        voronoi;
        voronoi_enabled;
        
        % material library
        mtrl_lib;
        
        % references to main entities
        domain;
        grids;
        stokes_sys;
        
    end
    
    methods (Access = public)        
        
        % init and output
        init(obj, df, mf, cf, domain, grids, stokes_sys);
        output(obj, of);
        
        % advection of particles
        advect(obj, dt);
        
        % reorder particles in the domain
        reorder(obj);
        
        % compute properties inside elements
        [elem_visc, elem_dens] = interp2elem(obj);
        
        %interp2node(obj);
        %update_eff_visc(obj);
        
    end
    
    methods (Access = private)
        
        % change state of the data array
        reshape_data(obj, mode);
        
        % assign particles to elements at highest grid level
        assign2elemhl(obj);
        
        % assign particles to actual elements in case of multilevel grid
        assign2elem(obj, elem2elemhl);
        
    end
    
end