% Voronoi tessellation.
%
% $Id$

classdef VoronoiPlot < Voronoi
    
    methods (Access = public)
        
        % perform Voronoi tessellation
        vcells = compute(obj, part_data);
        
    end
    
end