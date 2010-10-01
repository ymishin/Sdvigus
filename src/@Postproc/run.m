function run(obj)
% Perform postprocessing.
%
% $Id$

global version;
fprintf('\n***** SDVIGUS v%4.2f - POST-PROCESSOR *****\n\n', version);

% read description file
obj.read_desc();

% create folder for postprocessing results
obj.outdir = 'postproc_output';
[ignore, ignore, ignore] = mkdir(obj.outdir);

% loop over output steps
for nstep = obj.nsteps
    
    obj.nstep = nstep;
    fprintf('Processing %s, step %5d\n', obj.model_name, obj.nstep);
    
    % read output files from simulation
    obj.read_data();
    
    % generate grid
    obj.grids.generate();
    
    % plot just grid
    obj.grids.plot_grid(obj);
    
    % plot properties from grid
    obj.stokes_sys.plot_field(obj);
    
    % plot properties from particles
    obj.particles.plot_field(obj);
    
    % execute custom functions
    if (obj.isprop('custom_funcs'))
        custom_funcs = obj.custom_funcs;
        for i = 1:length(custom_funcs)
            custom_funcs{i}(obj);
        end
    end
    
end

fprintf('\n');

end