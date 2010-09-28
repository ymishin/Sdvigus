function run(obj)
% Simulation loop.
%
% $Id$

global version;
fprintf('\n***** SDVIGUS v%4.2f - SIMULATOR *****\n\n', version);

% is simulation restarted ?
if (obj.nstep > -1)
    
    % continue simulation ?
    if (obj.current_time >= obj.total_time || obj.nstep >= obj.max_nstep - 1)
        return;
    end
    
    fprintf('Restart from time: %f\n', obj.current_time);
    
    % time integration
    obj.grids.generate();
    obj.particles.time_integr(obj.dt);
    obj.domain.time_integr(obj.dt);
    
    fprintf('\n');
    
end

% enter the simulation loop
while (true)
    
    obj.nstep = obj.nstep + 1;
    obj.current_time = obj.current_time + obj.dt;
    fprintf('Step: %d, time: %f\n', obj.nstep, obj.current_time);
    
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
    
    % perform output
    obj.output();
    
    % continue simulation ?
    if (obj.current_time >= obj.total_time || obj.nstep >= obj.max_nstep - 1)
        fprintf('\n');
        break;
    end
    
    % time integration
    obj.particles.time_integr(obj.dt);
    obj.domain.time_integr(obj.dt);
    
    fprintf('\n');
    
end

end