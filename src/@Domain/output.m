function output(obj, of)
% Perform output.
%
% $Id$

% size of the domain
w = 'writemode'; a = 'append';
hdf5write(of, '/domain/size0', obj.size0, w, a);
hdf5write(of, '/domain/size', obj.size, w, a);

end