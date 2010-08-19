% Wavelets transform and adaptation utility class.
%
% $Id$

classdef Wavelets < handle
    
    methods (Access = public, Static = true)
        
        update_mask();
        
    end    
    
    methods (Access = private, Static = true)
        
        % returns mask which corresponds to new adapted grid
        mask = adapt_mask_2d(this, fmat, jmax, jmin, balanced, eps);
        
        % forward linear wavelet transform in 2D
        fmat = fwd_transform_2d(this, fmat, jmax, jmin, mask);
        
        % forward linear wavelet transform
        fvec = fwd_transform_step(this, fvec, s, mask)
        
    end
    
end