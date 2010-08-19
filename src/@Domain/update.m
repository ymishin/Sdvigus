function update(obj, dt)
% Update size of the domain if necessary.
%
% $Id$

% change size of the domain according to normal componenets of velocity bc
if (obj.change_size)
    % check if x-velocities are prescribed
    if (~obj.stokes_bc.free(1,1))
        % left (xmin)
        obj.size(1) = obj.size(1) + dt * obj.stokes_bc.val(1,1);
    end
    if (~obj.stokes_bc.free(1,2))
        % right (xmax)
        obj.size(2) = obj.size(2) + dt * obj.stokes_bc.val(1,2);
    end
    % check if y-velocities are prescribed
    if (~obj.stokes_bc.free(2,3))
        % bottom (ymin)
        obj.size(3) = obj.size(3) + dt * obj.stokes_bc.val(2,3);
    end
    if (~obj.stokes_bc.free(2,4))
        % top (ymax)
        obj.size(4) = obj.size(4) + dt * obj.stokes_bc.val(2,4);
    end
end

end