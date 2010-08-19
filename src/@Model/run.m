function run(obj)
% Simulation loop.
%
% $Id$

if (obj.prec_output && obj.nstep > 0)
    % generate grid
    obj.grids.generate();
end

while (obj.current_time < obj.total_time)
    
    fprintf('Current time ... %f\n', obj.current_time);

    % update domain and advect particles
    if (obj.prec_output && obj.nstep > 0)
        obj.particles.advect(obj.dt);
        obj.domain.update(obj.dt);
    end
    
    % update particles distribution
    obj.particles.reorder();
    
    % adapt grid
    obj.grids.adapt();
    
    % generate grid
    obj.grids.generate();
    
    % solve Stokes system
    obj.stokes_sys.solve();
    
    % calculate time step
    obj.compute_dt();
    obj.current_time = obj.current_time + obj.dt;
    
    % update domain and advect particles
    if (~obj.prec_output)
        obj.particles.advect(obj.dt);
        obj.domain.update(obj.dt);
    end
    
    % perform output
    obj.output();
    
    fprintf('\n');
    
end

end