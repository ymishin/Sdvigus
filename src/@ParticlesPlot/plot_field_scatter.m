function plot_field_scatter(obj, ind, desc)
% Plot actual particles colored according to data field.
%
% $Id$

% flat array
obj.reshape_data('array');

% particles' coordinates and data
coord = obj.data(:,1:2);
data = obj.data(:,ind);

% modify for log-plot
if (isfield(desc,'log') && ~isempty(desc.log) && desc.log)
    data = log10(data);
end

% plot particles
if (isfield(desc,'partsize') && ~isempty(desc.partsize))
    partsize = desc.partsize;
else
    partsize = 1.0;
end
if (isfield(desc,'partfilled') && ~isempty(desc.partfilled) && desc.partfilled)
    scatter(coord(:,1), coord(:,2), partsize, data, 'filled');
else
    scatter(coord(:,1), coord(:,2), partsize, data);
end

clear coord data;

end