% Contains everything concerning particles.
%
% $Id$

classdef Particles < handle
    
    properties (SetAccess = protected)
        
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
        
        % rheologies
        yielding_flag;
        powerlaw_flag;
        
        % references to main entities
        domain;
        grids;
        stokes_sys;
        
    end
    
    methods (Access = public)
        
        % init and output
        init(obj, df, mf, cf, domain, grids, stokes_sys);
        init_voronoi(obj, cf);
        output(obj, of);
        
        % time integratation (advection, etc.)
        time_integr(obj, dt);
        
        % reorder particles in the domain
        reorder(obj);
        
        % interpolate properties to nodes
        node_data = interp2node(obj, mask, elem_order, prop);
        
        % average properties inside elements
        [elem_visc, elem_dens] = average_visc_dens(obj);
        elem_visc = update_visceff(obj, pressure);
        
        % compute strain rate invariant
        %compute_strain_rate(obj);
        
    end
    
    methods (Access = protected)
        
        % change state of the data array
        reshape_data(obj, mode);
        
        % assign particles to elements at highest grid level
        assign2elemhl(obj);
        
        % assign particles to actual elements in case of multilevel grid
        assign2elem(obj, elem2elemhl);
        
        % sub-functions for particles->nodes interpolation
        node_data = interp2node_1(obj, mask, iprop);
        node_data = interp2node_2(obj, mask, iprop);
        
    end
    
end