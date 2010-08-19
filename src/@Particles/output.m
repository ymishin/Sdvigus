function output(obj, of)
% Perform output.
%
% $Id$

% flat array
%obj.reshape_data('array');
if (obj.data_state ~= 1)
    data = cell2mat(obj.data);
end

% indices
i = obj.iprop;

% particles data
w = 'writemode'; a = 'append';
hdf5write(of, '/particles/coord', data(:,i.COORD), w, a);
hdf5write(of, '/particles/type', uint8(data(:,i.TYPE)), w, a);
if (obj.yielding_flag || obj.powerlaw_flag)
    % efficient viscosities
    hdf5write(of, '/particles/visc', data(:,i.VISC), w, a);
    % 2nd strain rate invariant
    hdf5write(of, '/particles/strain_rate', data(:,i.STRAIN_RATE), w, a);
    if (obj.yielding_flag)
        % accumulated plastic strain
        hdf5write(of, '/particles/strain_plast', data(:,i.STRAIN_PLAST), w, a);
    end
end

clear data;

end