function generate(obj)
% Generate grid.
%
% $Id$

global verbose;
t = tic;

% check if domain size was changed
if (any(obj.stokes.dsize ~= obj.domain.size))
    obj.stokes.dsize = obj.domain.size;
    obj.stokes_update = true;
end

% re-generate grid if necessary
if (obj.stokes_update)
    if (obj.stokes.jmax > 1)
        % multilevel grid
        obj.stokes.generate_multilevel();
    else
        % equidistant grid
        obj.stokes.generate_simple();
    end
    obj.stokes_update = false;
end

num_elem = size(obj.stokes.elem2node, 2);
verbose.disp(['Number of elements: ', num2str(num_elem)], 1);

t = toc(t);
verbose.disp(['Grid generation ... ', num2str(t)], 2);

end