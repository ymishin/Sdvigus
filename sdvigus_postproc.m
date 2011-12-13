function sdvigus_postproc(model_dir, vrbl, ncpu, do_exit)
% Sdvigus postprocessor.
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
    vrbl = 1;
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

% description script for postprocessing
desc = 'postproc_desc';

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

% run postprocessor
postproc = Postproc(model_name, desc);
postproc.run();
delete(postproc);

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