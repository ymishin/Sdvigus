% Preprocessor - reads model description and 
% creates all necessary files to start simulation.
%
% $Id$

classdef Preproc < handle
    
    properties (Access = private)
        
        % name of the model
        model_name;
        
        % description file
        desc;
        
    end
    
    methods (Access = public)
        
        % constructor
        function obj = Preproc(model_name, desc)
            obj.model_name = model_name;
            obj.desc = desc;
        end
        
        % run preprocessor
        run(obj);
        
    end
    
end
