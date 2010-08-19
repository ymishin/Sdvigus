function output(obj)
% Perform output.
%
% $Id$

% step number
obj.nstep = obj.nstep + 1;

% perform output ?
if (~obj.output_enabled)
    return;
end

% name of the data file
of = [obj.model_name, '_', num2str(obj.nstep, '%05d'), '.h5'];

% current time
hdf5write(of, '/time/dt', obj.dt);
hdf5write(of, '/time/current_time', obj.current_time, 'writemode', 'append');

% perform output
obj.domain.output(of);
obj.particles.output(of);
obj.grids.output(of);
obj.stokes_sys.output(of);

% save number to restart from
csvwrite('start_from', obj.nstep);

end