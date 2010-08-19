function run(obj)
% Simulation loop.
%
% $Id$

% generate grid
if (obj.prec_output && obj.nstep > 0)
    obj.grids.generate();
end

while (obj.current_time < obj.total_time)
    
    fprintf('Current time ... %f\n', obj.current_time);
    
    % time integration
    if (obj.prec_output && obj.nstep > 0)
        obj.particles.time_integr(obj.dt);
        obj.domain.time_integr(obj.dt);
    end
    
    % update particles distribution
    obj.particles.reorder();
    
    % adapt grid
    if (obj.nstep > 0)
        obj.grids.adapt();
    end
    
    % generate grid
    obj.grids.generate();
    
    % solve Stokes system
    obj.stokes_sys.solve();
    
    % calculate time step
    obj.compute_dt();
    obj.current_time = obj.current_time + obj.dt;
    
    % time integration
    if (~obj.prec_output)
        obj.particles.time_integr(obj.dt);
        obj.domain.time_integr(obj.dt);
    end
    
    % perform output
    obj.output();
    
    fprintf('\n');
    
end

end