function generate(obj)
% Generate grid.
%
% $Id$

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
        obj.stokes_update = false;
    else
        % equidistant grid
        obj.stokes.generate_simple();
        obj.stokes_update = false;
    end
end

end