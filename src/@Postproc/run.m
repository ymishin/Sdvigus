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
for nfile = obj.first:obj.step:obj.last
    
    obj.nfile = nfile;
    fprintf('Processing %s, step %5d\n', obj.model_name, obj.nfile);
    
    % read output files from simulation
    obj.read_data();
    
    % generate grid
    obj.grids.generate();
    
    % *** plot just grid ***
    if (obj.isprop('grid') && obj.grid.plot)
        obj.grids.plot_grid(obj);
    end
    
    % *** properties from grid ***
    fields = {'velocity_x', 'velocity_y', 'pressure'};
    for i = 1:length(fields)
        f = fields{i};
        if (obj.isprop(f) && obj.(f).plot)
            obj.stokes_sys.plot_field(f, obj);
        end
    end
    
    % *** properties from particles ***
    fields = {'material', 'viscosity', 'density', ...
              'strain_rate', 'strain_plast'};
    for i = 1:length(fields)
        f = fields{i};
        if (obj.isprop(f) && obj.(f).plot)
            obj.particles.plot_field(f, obj);
        end
    end
    
    % *** execute custom functions ***
    if (obj.isprop('custom_funcs'))
        custom_funcs = obj.custom_funcs;
        for i = 1:length(custom_funcs)
            custom_funcs{i}(obj);
        end
    end
    
end

fprintf('\n');

end