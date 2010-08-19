function sdvigus_simulator(model_dir, vrb, ncpu, do_exit)
% Sdvigus simulator.
%
% $Id: sdvig_simulator.m 47 2010-06-24 11:20:56Z ymishin $

% verbosity level
global verbose;
if (~exist('vrb','var') || isempty(vrb))
    vrb = 0;
end
verbose = vrb;

% parallel execution ?
if (~exist('ncpu','var') || isempty(ncpu))
    ncpu = 0;
end

% exit Matlab after execution ?
if (~exist('do_exit','var') || isempty(do_exit))
    do_exit = false;
end

% code
addpath([pwd, filesep, 'src']);

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

% name of the model
if (ispc)
    dlm = '\\';
else
    dlm = '/';
end
model_name = textscan(pwd, '%s', 'Delimiter', dlm);
model_name = model_name{1}{end};

% run simulation
simulator(model_name);

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