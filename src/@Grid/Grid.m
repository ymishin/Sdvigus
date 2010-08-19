% The class contains all data structures and corresponding 
% functionality for equidistant or multilevel grid.
%
% Elements at one level are numbered bottom-up and starting from the left.
% Internal nodes' numbering is:
% element of 1st order      element of 2nd order
%      4-------3                 4---7---3
%      |       |                 |       |
%      |       |                 8   9   6
%      |       |                 |       |
%      1-------2                 1---5---2
%
% $Id$

classdef Grid < handle
    
    properties (Access = public)
        
        % domain dimensions
        dsize;
        
        % order of elements to be created, can be 1 or 2
        elem_order;
        
        % grid resolution
        res;
        
        % number of grid levels, equals 1 for equidistant grid
        jmax;
        
        % logical mask which has to mark nodes to be included in
        % the grid, mask is assumed to be consistent (multilevel grid)
        mask;
        
    end
    
    properties (SetAccess = private)
        
        % global coordinates of all nodes
        node_coord;
        
        % assignment of nodes to elements
        elem2node;
        
        % numbers of boundary nodes
        node_bnd;
        
        % dimensions of an element at finest level
        elemhl;
        
        % number of level for each element (multilevel grid)
        elem_level;
        
        % assignment of elements from finest level to 
        % inclusive elements from coarser levels (multilevel grid)
        elem2elemhl;
    
    end
    
    methods (Access = public)
        
        % generate equidistant FE grid
        generate_simple(obj);
        
        % generate multilevel FE grid
        generate_multilevel(obj);
        
    end
    
end
