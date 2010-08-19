function mask = adapt_mask_2d(fmat, jmax, jmin, balanced, eps)
% Grid adaptation is performed for 2D field given by values 'fmat', which was
% previously linearly transformed from level 'jmax' to level 'jmin'.
% The new adapted grid is returned via 'mask' and contains: significant
% nodes (as prescribed by 'eps'), adjacent to significant nodes, nodes at
% all levels which are necessary to compute these significant and adjacent
% nodes (reconstruction check criterion), and all nodes at lowest (coarsest)
% level (c-coefficients). If 'balanced' is true the grid also will include
% nodes to balance it, i.e. there will be no boundaries between levels which
% differ by more than 1.
%
% For details see:
% O.V.Vasilyev and C.Bowman, "Second Generation Wavelet Collocation Method for
% the Solution of Partial Differential Equations",J.Comp.Phys.,165,660-693,2000.
%
% $Id$

[ny nx] = size(fmat);

% ********** MARK SIGNIFICANT NODES **********
% coefficients at all levels with values above eps
mask = abs(fmat) > eps;

% ********** MARK ADJACENT NODES **********
% mark nodes adjacent to significant nodes
mask_adj = mask;
for j = jmax:-1:(jmin+1)
    
    % step
    s = 2^(jmax-j);
    s2 = 2 * s;
    % step at one level higher
    s_hi = ceil(0.5 * s);
    
    % loop over d-coefficients on X-slices
    for iy = 1:s:ny
        % coefficients' indices
        ind = (1+s:s2:nx-s);
        % leave only marked by mask
        ind = ind(mask(iy,ind));
        % mark adjacent nodes at current level
        mask_adj([max(1,iy-s) iy min(iy+s,ny)], ...
            [ind-s ind ind+s]) = true;
        % mark adjacent nodes at one level higher
        mask_adj([max(1,iy-s_hi) iy min(iy+s_hi,ny)], ...
            [ind-s_hi ind ind+s_hi]) = true;
    end
    
    % loop over d-coefficients on Y-slices
    % (only nodes on edges are considered as nodes at centers were already
    % considered in previous loop => so higher step is used here)
    for ix = 1:s2:nx
        % coefficients' indices
        ind = (1+s:s2:ny-s);
        % leave only marked by mask
        ind = ind(mask(ind,ix));
        % mark adjacent nodes at current level
        mask_adj([ind-s ind ind+s], ...
            [max(1,ix-s) ix min(ix+s,nx)]) = true;
        % mark adjacent nodes at one level higher
        mask_adj([ind-s_hi ind ind+s_hi], ...
            [max(1,ix-s_hi) ix min(ix+s_hi,nx)]) = true;
    end
    
end
mask = mask_adj;

% ********** RECONSTRUCTION CHECK **********
% mark nodes at all levels which are
% necessary to compute significant and adjacent nodes
for j = jmax:-1:(jmin+1)
    
    % step
    s = 2^(jmax-j);
    s2 = 2 * s;
    s4 = 2 * s2;
        
    % (TODO: introduce true/false parameter to activate this piece)
%     % *** d-coefficients at cells' centers ***
%     for ix = (1+s2):s4:(nx-s2)
%         % coefficients' indices
%         ind = (1+s2:s4:ny-s2);
%         ind = ind(mask(ind-s,ix-s) | mask(ind-s,ix+s) | ...
%             mask(ind+s,ix-s) | mask(ind+s,ix+s));
%         mask(ind-s,ix-s) = true;
%         mask(ind-s,ix+s) = true;
%         mask(ind+s,ix-s) = true;
%         mask(ind+s,ix+s) = true;
%     end
    
    % *** d-coefficients at cells' centers ***
    for ix = (1+s):s2:(nx-s)
        % coefficients' indices
        ind = (1+s:s2:ny-s);
        % leave only marked by mask
        ind = ind(mask(ind,ix));
        % mark necessary nodes
        mask([ind-s ind+s],ix) = true;
        mask(ind,[ix-s ix+s]) = true;
    end    
    
    % *** d-coefficients at cells' edges ***
    % X-slices    
    for iy = 1:s2:ny
        % coefficients' indices
        ind = (1+s:s2:nx-s);
        % leave only marked by mask
        ind = ind(mask(iy,ind));
        % mark necessary nodes
        mask(iy,[ind-s ind+s]) = true;
        % mark nodes at lower level to balance the grid
        if (balanced && (iy > 1) && (iy < ny))
            mask([iy-s2 iy+s2],[ind-s ind+s]) = true;
        end
    end    
    % Y-slices
    for ix = 1:s2:nx
        % coefficients' indices
        ind = (1+s:s2:ny-s);
        % leave only marked by mask
        ind = ind(mask(ind,ix));
        % mark necessary nodes
        mask([ind-s ind+s],ix) = true;
        % mark nodes at lower level to balance the grid
        if (balanced && (ix > 1) && (ix < nx))
            mask([ind-s ind+s],[ix-s2 ix+s2]) = true;
        end
    end
    
end

% mark c-coefficients from lowest level
mask(1:2*s:ny,1:2*s:nx) = true;

end
