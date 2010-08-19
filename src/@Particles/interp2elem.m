function [elem_visc, elem_dens] = interp2elem(obj)
% Compute average properties inside elements from particles' properties.
% TODO: implement other averaging schemes
%
% $Id$

global verbose;
t = tic;

% assign particles to elements of Stokes grid
obj.reshape_data('cell_stokes');

% preallocate
data = obj.data;
num_elem = size(data, 1);
elem_visc = zeros(num_elem, 1);
elem_dens = zeros(num_elem, 1);
ivisc = obj.iprop.VISC;
idens = obj.iprop.DENS;
visc0 = obj.mtrl_lib.visc0;
dens0 = obj.mtrl_lib.dens0;

% loop over elements
parfor iel = 1:num_elem
    
    if (isempty(data{iel}))
        % empty element
        elem_visc(iel) = visc0;
        elem_dens(iel) = dens0;
    else
        % arithmetic averaging
        elem_visc(iel) = mean(data{iel}(:,ivisc));
        elem_dens(iel) = mean(data{iel}(:,idens));
    end
    
end

clear data;

t = toc(t);
if (verbose > 0)
    fprintf('Perform particles->grid interpolation ... %f\n', t);
end

end