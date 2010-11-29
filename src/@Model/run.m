function run(obj)
% Simulation loop.
%
% $Id$

global verbose;
global version;

m = sprintf('\n***** SDVIGUS v%4.2f - SIMULATOR *****\n', version);
verbose.disp(m, 0);

% is simulation restarted ?
if (obj.nstep > -1)
    
    % continue simulation ?
    if (obj.current_time >= obj.total_time || obj.nstep >= obj.max_nstep - 1)
        return;
    end
    
    m = sprintf('Restart from time: %f', obj.current_time);
    verbose.disp(m, 0);
    
    % time integration
    obj.grids.generate();
    obj.particles.time_integr(obj.dt);
    obj.domain.time_integr(obj.dt);
    
    verbose.disp('', 0);
    
end

% enter the simulation loop
while (true)
    
    obj.nstep = obj.nstep + 1;
    obj.current_time = obj.current_time + obj.dt;
    
    m = sprintf('Step: %d, time: %f', obj.nstep, obj.current_time);
    verbose.disp(m, 0);
    
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
        verbose.disp('', 0);
        break;
    end
    
    % time integration
    obj.particles.time_integr(obj.dt);
    obj.domain.time_integr(obj.dt);
    
    verbose.disp('', 0);
    
end

end