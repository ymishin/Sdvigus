function run(obj)
% Perform postprocessing.
%
% $Id$

% read description file
obj.read_desc();

% create folder for postprocessing results
obj.outdir = 'postproc_output';
[ignore, ignore, ignore] = mkdir(obj.outdir);

% loop over output steps
for nfile = obj.first:obj.step:obj.last
    
    obj.nfile = nfile;
    fprintf('Processing %s ...\n', ...
        [obj.model_name, '_', num2str(obj.nfile, '%05d'), '.h5']);
    
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
    
end

end