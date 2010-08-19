function output(obj, of)
% Perform output.
%
% $Id$

% grids data
w = 'writemode'; a = 'append';
hdf5write(of, '/grids/reshl', obj.reshl, w, a);
if (obj.stokes.jmax > 1)
    mask = obj.stokes.mask;
else
    mask = 0;
end
hdf5write(of, '/grids/mask', uint8(mask), w, a);

end