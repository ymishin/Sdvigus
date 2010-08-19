function assign2elemhl(obj)
% Assign particles to elements of regular quadraliteral grid of highest
% possible resolution (corresponds to highest grid level in case of 
% multilevel grid). Elements are numbered bottom-up starting from left 
% side of the domain. All particles outside domain are eliminated.
%
% $Id$

% domain dimensions
xmin = obj.domain.size(1); xmax = obj.domain.size(2);
ymin = obj.domain.size(3); ymax = obj.domain.size(4);

% grid resolution
num_elem_x = obj.grids.reshl(1); num_elem_y = obj.grids.reshl(2);
num_elem = num_elem_x * num_elem_y;

% element' size
dx = (xmax - xmin) / num_elem_x;
dy = (ymax - ymin) / num_elem_y;

% find particles inside domain
inside = obj.data(:,1) > xmin & obj.data(:,1) < xmax & ...
         obj.data(:,2) > ymin & obj.data(:,2) < ymax;
obj.data = obj.data(inside,:);
num_part = size(obj.data, 1);
clear inside;

% find elements where particles reside (bottom-up element numbering)
k = ceil((obj.data(:,1) - xmin) ./ dx);
l = ceil((obj.data(:,2) - ymin) ./ dy);
pel = (k - 1) .* num_elem_y + l;
clear k l;

% preallocate
elem_part = zeros(num_elem, 30, 'uint32');
elem_num_part = zeros(num_elem, 1);

% assign global particles' numbers to elements
for ip = 1:num_part
    iel = pel(ip);
    elem_num_part(iel) = elem_num_part(iel) + 1;
    elem_part(iel,elem_num_part(iel)) = ip;
end
clear pel;

% shrink
elem_part = elem_part(:,1:max(elem_num_part));

% assign particles' data to elements
data = obj.data;
data_new = cell(num_elem, 1);
for iel = 1:num_elem
    data_new{iel} = data(elem_part(iel,1:elem_num_part(iel)),:);
end
clear data;
obj.data = data_new;
clear data_new;

end