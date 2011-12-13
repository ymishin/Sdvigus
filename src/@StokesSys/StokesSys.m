% All functionality concerning Stokes system of equations.
%
% $Id$

classdef StokesSys < handle
    
    properties (SetAccess = protected)
        
        % solve the system ?
        stokes_enabled;
        
        % velocity and pressure
        velocity;
        pressure;
        
        % element type
        elem_type;
        
        % external force field
        Fext;
        
        % boundary conditions
        stokes_bc;
        bc_exits;
        
        % linear / non-linear flag
        linear_flag;
        
        % parameters for solvers
        solv_params;
        
        % all matrices and vectors required for solution
        A; Q; invM; C; elemA; RHS; bc;
        CV = 1; CP = 1;
        
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
    
    methods (Access = protected)
        
        % build BC vectors
        build_bc(obj);
        
        % build system and constraint matrices
        build_system_matrices(obj, elem_visc, elem_dens);
        build_constraint_matrices(obj);
        update_A_matrix(obj, elem_visc);
        
        % solvers' sub-routines
        solve_nonlinear(obj);
        solve_linear(obj);
        solve_linear_coupled(obj);
        solve_linear_uzawa(obj);
        
    end
    
end