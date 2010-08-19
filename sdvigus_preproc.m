function sdvigus_preproc(model_dir, vrb, do_exit)
% Sdvigus preprocessor.
%
% $Id: sdvig_preproc.m 47 2010-06-24 11:20:56Z ymishin $

% verbosity level
global verbose;
if (~exist('vrb','var') || isempty(vrb))
    vrb = 0;
end
verbose = vrb;

% exit Matlab after execution ?
if (~exist('do_exit','var') || isempty(do_exit))
    do_exit = false;
end

% model description script
desc = 'model_desc';

% code
addpath([pwd, filesep, 'src']);

% save current dir and change to model dir
old_dir = pwd;
cd(model_dir);

% name of the model
if (ispc)
    dlm = '\\';
else
    dlm = '/';
end
model_name = textscan(pwd, '%s', 'Delimiter', dlm);
model_name = model_name{1}{end};

% run preprocessor
preproc(model_name, desc);

% go back
cd(old_dir);

% exit matlab
if (do_exit)
    exit;
end

end