function output(obj, of)
% Perform output.
%
% $Id$

% flat array
obj.reshape_data('array');

% particles data
w = 'writemode'; a = 'append';
hdf5write(of, '/particles/coord', obj.data(:,obj.iprop.COORD), w, a);
hdf5write(of, '/particles/type', uint8(obj.data(:,obj.iprop.TYPE)), w, a);
hdf5write(of, '/particles/visc', obj.data(:,obj.iprop.VISC), w, a);
hdf5write(of, '/particles/dens', obj.data(:,obj.iprop.DENS), w, a);

end