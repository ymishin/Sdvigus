function cfunc2(postproc)
% custom function to perform some additional analysis

% some useful variables
model = postproc.model_name;
time = postproc.current_time;
nstep = postproc.nstep;
size = postproc.domain.size;
size0 = postproc.domain.size0;

end