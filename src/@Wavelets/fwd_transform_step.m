function fvec = fwd_transform_step(fvec, s, mask)
% Forward linear wavelet transform is performed on 1D field given
% by values 'fvec'. Only values at positions indicated by step 's'
% and marked by 'mask' are considered.
%
% $Id$

nx = length(fvec);

s2 = 2 * s;

% *************** PREDICT ***************

% indices of values to predict
ind = (1+s:s2:nx-s);
% leave only marked by mask
ind = ind(mask(ind));
% predict and compute d-coefficients
fvec(ind) = 0.5 * (fvec(ind) - 0.5 * (fvec(ind-s) + fvec(ind+s)));
% number of d-coefficients
no_dc = length(ind);

% *************** UPDATE ***************

% indices of values to update (except boundaries)
ind = (1+s2:s2:nx-s2);
% leave only marked by mask
ind = ind(mask(ind));
% compute c-coefficients
fvec(ind) = fvec(ind) + 0.5 * (fvec(ind-s) + fvec(ind+s));
% compute c-coefficients at boundaries
if (no_dc > 1)
    % preserve order
    fvec(1) = fvec(1) + 0.5 * (3 * fvec(1+s) - fvec(1+s+s2));
    fvec(nx) = fvec(nx) + 0.5 * (3 * fvec(nx-s) - fvec(nx-s-s2));
else
    % only one d-coefficient => just take its value
    fvec(1) = fvec(1) + fvec(1+s);
    fvec(nx) = fvec(nx) + fvec(nx-s);
end

end
