function [elem_visc, elem_dens] = average_visc_dens(obj)
% Compute average properties inside elements from particles' properties.
%
% $Id$

global verbose;
t = tic;

% assign particles to elements of Stokes grid
obj.reshape_data('cell_stokes');

% preallocate
num_elem = size(obj.data, 1);
elem_visc = zeros(num_elem, 1);
elem_dens = zeros(num_elem, 1);

% properties
ivisc = obj.iprop.VISC;
idens = obj.iprop.DENS;
visc0 = obj.mtrl_lib.visc0;
dens0 = obj.mtrl_lib.dens0;

% loop over elements
data = obj.data;
parfor iel = 1:num_elem
    
    if (isempty(data{iel}))
        % empty element
        elem_visc(iel) = visc0;
        elem_dens(iel) = dens0;
    else
        % arithmetic mean
        elem_visc(iel) = mean(data{iel}(:,ivisc));
        elem_dens(iel) = mean(data{iel}(:,idens));
        % harmonic mean
        %elem_visc(iel) = 1.0 / mean(1.0 ./ data{iel}(:,ivisc));
        %elem_dens(iel) = 1.0 / mean(1.0 ./ data{iel}(:,idens));
    end
    
end
clear data;

t = toc(t);
if (verbose > 1)
    fprintf('Compute average properties ... %f\n', t);
end

end