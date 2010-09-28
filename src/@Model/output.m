function output(obj)
% Perform output.
%
% $Id$

% perform output ?
if (~obj.output_enabled || mod(obj.nstep - obj.nstep1, obj.output_freq))
    return;
end

global verbose;
t = tic;

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

% attach version number
global version;
attr = struct('Name', 'version', 'AttachedTo', '/', 'AttachType', 'group');
hdf5write(of, attr, version, 'writemode', 'append');

% step to restart from
csvwrite('start_from', obj.nstep);

t = toc(t);
verbose.disp(['Data output ... ', num2str(t)], 2);

end