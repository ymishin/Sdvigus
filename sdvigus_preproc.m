function sdvigus_preproc(model_dir, vrbl, do_exit)
% Sdvigus preprocessor.
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

% exit Matlab after execution ?
if (~exist('do_exit','var') || isempty(do_exit))
    do_exit = false;
end

% model description script
desc = 'model_desc';

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
preproc = Preproc(model_name, desc);
preproc.run();
delete(preproc);

% go back
cd(old_dir);

% exit matlab
if (do_exit)
    exit;
end

end