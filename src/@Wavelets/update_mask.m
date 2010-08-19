function new_mask = update_mask(fmat, mask, jmax, balance_grid, ...
                                refine_fully, eps)
% Perform wavelet transform and build new adapted 
% mask for each field from 'fmat' cell array.
%
% $Id$

% number of fields
num_fmat = size(fmat, 2);

% preallocate
new_mask = cell(1, num_fmat);

parfor i = 1:num_fmat
    
    % perform forward transform
    f = Wavelets.fwd_transform_2d(fmat{i}, jmax, 1, mask);
    
    % build adapted mask
    new_mask{i} = Wavelets.adapt_mask_2d(f, jmax, 1, balance_grid, ...
                                         refine_fully, eps(i));
    
end

end