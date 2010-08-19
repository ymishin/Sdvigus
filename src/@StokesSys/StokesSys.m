% All functionality concerning Stokes system of equations.
%
% $Id$

classdef StokesSys < handle
    
    properties (SetAccess = private)
        
        % velocity and pressure
        velocity;
        pressure;
        
        % element type
        elem_type;
        
        % external force field
        Fext;

        % boundary conditions
        stokes_bc;
        
        % references to main entities
        domain;
        grids;
        particles;
        
    end
    
    methods (Access = public)
        
        % build and solve the system
        solve(obj);
        
        % compute time step
        dt = compute_dt(obj, courant);
        
        % init and output
        init(obj, df, cf, domain, grids, particles);
        output(obj, of);
        
    end
    
    methods (Access = private)
        
        % build all system matrices
        stokes = build_system_matrices(obj, elem_visc, elem_dens);
        
        %
        bc = construct_bc(obj);
        
        % get solution
        [v, p] = solve_linear(obj, stokes, bc)
        
    end
    
end