% Postprocessor.
%
% $Id$

classdef Postproc < dynamicprops
    
    properties (SetAccess = private)
        
        % name of the model
        model_name;
        
        % description file
        desc;
        
        % time stepping parameters
        nstep;
        current_time;
        
        % folder for results
        outdir;
        
        % main entities which constitute model
        domain;
        particles;
        grids;
        stokes_sys;
        
    end
    
    methods (Access = public)
        
        % constructor
        function obj = Postproc(model_name, desc)
            obj.model_name = model_name;
            obj.desc = desc;
        end
        
        % run postprocessor
        run(obj);
        
        % tune and save the plot
        save_plot(obj, name, desc);
        
        % check if property exists
        r = isprop(obj, prop);
        
    end
    
    methods (Access = private)
        
        % read description file
        desc_struct = read_desc(obj);
        
        % read all data
        read_data(obj);
        
    end
    
end