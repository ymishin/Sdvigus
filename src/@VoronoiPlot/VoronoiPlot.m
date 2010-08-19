% Voronoi tessellation.
%
% $Id: Voronoi.m 38 2010-06-14 10:22:39Z ymishin $

classdef VoronoiPlot < Voronoi
    
    methods (Access = public)
        
        % perform Voronoi tessellation
        vcells = compute(obj, part_data);
        
    end
    
end