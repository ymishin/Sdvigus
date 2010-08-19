% Main entry point class.
%
% $Id$

classdef Model < handle
    
    properties (Access = private)
        
        % name of the model
        model_name;
        
        % main entities which constitute model
        domain;
        particles;
        grids;
        stokes_sys;
        
        % time stepping parameters
        nstep;
        current_time;
        dt;
        total_time;
        dt_default;
        courant;
        
        % output
        output_enabled;
        prec_output;
        
    end
    
    methods (Access = public)
        
        % constructor
        function obj = Model(model_name)
            obj.model_name = model_name;
            obj.init();
        end
        
        % run simulation
        run(obj);
        
    end
    
    methods (Access = private)
        
        % compute time step
        compute_dt(obj);
        
        % init and output
        init(obj);
        output(obj);
        
    end
    
end