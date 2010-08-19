function fmat = fwd_transform_2d(fmat, jmax, jmin, mask)
% Forward linear wavelet transform is performed on 2D field given by
% values 'fmat'. Only values at positions marked by 'mask' are considered,
% if 'mask' equals -1 then all values are considered. Number of values
% of 'fmat' has to be Mx*2^(jmax-1)+1 and My*2^(jmax-1)+1 in x- and
% y-directions respectively (Mx and My are arbitrary). Transform is
% performed from level 'jmax' to level 'jmin'.
%
% $Id$

[ny nx] = size(fmat);

% check mask
if (mask == -1)
    mask = true(ny,nx); % mark all values
end

% loop over levels
for j = jmax:-1:(jmin+1)
    
    % step
    s = 2^(jmax-j);
    
    % perform transform to lower level on X-slices
    for iy = 1:s:ny
        fmat(iy,:) = Wavelets.fwd_transform_step(fmat(iy,:), s, mask(iy,:));
    end
    
    % perform transform to lower level on Y-slices
    for ix = 1:s:nx
        fmat(:,ix) = Wavelets.fwd_transform_step(fmat(:,ix), s, mask(:,ix));
    end
    
end

end