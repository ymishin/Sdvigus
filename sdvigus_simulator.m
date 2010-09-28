function sdvigus_simulator(model_dir, vrbl, ncpu, do_exit)
% Sdvigus simulator.
%
% $Id$

% sdvigus home
shome = regexprep(mfilename('fullpath'), mfilename, '');

% code
addpath([shome, 'src']);

% version
global version;
version = csvread([shome, '.ver']);

% verbosity level
global verbose;
if (~exist('vrbl','var') || isempty(vrbl))
    vrbl = 0;
end
verbose = Verbose(vrbl);

% parallel execution ?
if (~exist('ncpu','var') || isempty(ncpu))
    ncpu = 0;
end

% exit Matlab after execution ?
if (~exist('do_exit','var') || isempty(do_exit))
    do_exit = false;
end

% save current dir and change to model dir
old_dir = pwd;
cd(model_dir);

% run local scheduler
if (ncpu > 0)
    sched = findResource('scheduler', 'type', 'local');
    pardir = './partmp';
    [ignore, ignore, ignore] = mkdir(pardir);
    sched.DataLocation = pardir;
    ncpu_cur = matlabpool('size');
    if (ncpu_cur == 0)
        matlabpool(ncpu);
    elseif (ncpu_cur ~= ncpu)
        matlabpool('close');
        matlabpool(ncpu);
    end
end

% set maximum number of computational threads
if (ncpu > 0)
    num_threads = ncpu;
else
    num_threads = 1;
end
maxNumCompThreads(num_threads);
fprintf('maxNumCompThreads: %d\n', num_threads);

% name of the model
if (ispc)
    dlm = '\\';
else
    dlm = '/';
end
model_name = textscan(pwd, '%s', 'Delimiter', dlm);
model_name = model_name{1}{end};

% run simulation
model = Model(model_name);
model.run();
delete(model);

% go back
cd(old_dir);

% exit matlab
if (do_exit)
    if (ncpu > 0)
        matlabpool('close');
    end
    exit;
end

end