function cfunc(postproc)
% custom function to tune a plot

% some useful variables
model = postproc.model_name;
time = postproc.current_time;
nstep = postproc.nstep;
size = postproc.domain.size;
size0 = postproc.domain.size0;

end