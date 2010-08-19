function output(obj, of)
% Perform output.
%
% $Id$

w = 'writemode'; a = 'append';
% element type
hdf5write(of, '/grids/elem_type', obj.elem_type, w, a);
% velocity and pressure
hdf5write(of, '/grids/velocity', obj.velocity, w, a);
hdf5write(of, '/grids/pressure', obj.pressure, w, a);

end