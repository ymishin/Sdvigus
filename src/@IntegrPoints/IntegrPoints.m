% Integration points for numerical integration utility class.
%
% $Id$

classdef IntegrPoints < handle
    
    methods (Access = public, Static = true)
        
        % get coordinates and weights for 'num_inp' integration points
        [inp_coord, inp_weight] = get_coord_weight(num_inp);
        
    end
    
end