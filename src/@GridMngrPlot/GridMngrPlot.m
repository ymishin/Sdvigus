% Grid manager to use at postprocessing stage.
%
% $Id$

classdef GridMngrPlot < GridMngr
    
    methods (Access = public)
        
        % plotting routines
        plot_grid(obj, postproc);
        plot_grid_cf(obj);
        
    end
    
end