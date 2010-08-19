function vcells = compute(obj, part_data)
% Perform Voronoi tessellation.
%
% $Id$

% domain dimensions
xmin = obj.dsize(1); xmax = obj.dsize(2);
ymin = obj.dsize(3); ymax = obj.dsize(4);

% grid resolution
num_elem_x = obj.res(1); num_elem_y = obj.res(2);
num_elem = num_elem_x * num_elem_y;

% elements' coordinates (bottom-up numbering)
xvec = linspace(xmin, xmax, num_elem_x+1); el_dx = xvec(2) - xvec(1);
yvec = linspace(ymin, ymax, num_elem_y+1); el_dy = yvec(2) - yvec(1);
[el_coord_x, el_coord_y] = meshgrid(xvec(1:end-1), yvec(1:end-1));
clear xvec yvec;

% number of disrete points to divide reference element
num_dp_x = obj.vres(1); num_dp_y = obj.vres(2);
num_dp = num_dp_x * num_dp_y;

% disrete points' coordinates (bottom-up numbering)
% reference element is [0 1 0 1]
xvec = linspace(0.0, 1.0, num_dp_x+1); dp_dx = xvec(2) - xvec(1);
yvec = linspace(0.0, 1.0, num_dp_y+1); dp_dy = yvec(2) - yvec(1);
[dp_coord_x, dp_coord_y] = meshgrid(xvec(1:end-1), yvec(1:end-1));
clear xvec yvec;
dp_coord_x = reshape(dp_coord_x + 0.5 * dp_dx, num_dp, 1);
dp_coord_y = reshape(dp_coord_y + 0.5 * dp_dy, num_dp, 1);

% place bounding particles on interfaces between empty and occupied elements ?
add_bpart = true;
% local coordinates of bounding particles
bpart_coord = [0.1; 0.3; 0.5; 0.7; 0.9];
% pre-compute distances between discrete points and bounding particles
n = length(bpart_coord);
left = zeros(num_dp, n); right = zeros(num_dp, n);
bottom = zeros(num_dp, n); top = zeros(num_dp, n);
for ip = 1:n
    left(:,ip) = (dp_coord_x - 0).^2 + (dp_coord_y - bpart_coord(ip)).^2;
    right(:,ip) = (dp_coord_x - 1).^2 + (dp_coord_y - bpart_coord(ip)).^2;
    bottom(:,ip) = (dp_coord_x - bpart_coord(ip)).^2 + (dp_coord_y - 0).^2;
    top(:,ip) = (dp_coord_x - bpart_coord(ip)).^2 + (dp_coord_y - 1).^2;
end
bpart_dp_dist_4 = cat(3, left, right, bottom, top);
clear left right bottom top;

% find empty elements
elem_empty = reshape(cellfun('isempty', part_data), num_elem_y, num_elem_x);
% find interfaces between empty and occupied elements
left = [zeros(num_elem_y,1), elem_empty(:,1:end-1)] & ~elem_empty;
right = [elem_empty(:,2:end), zeros(num_elem_y,1)] & ~elem_empty;
bottom = [zeros(1,num_elem_x,1); elem_empty(1:end-1,:)] & ~elem_empty;
top = [elem_empty(2:end,:); zeros(1,num_elem_x,1)] & ~elem_empty;
elem_iface = [reshape(left, 1, num_elem); reshape(right, 1, num_elem); ...
              reshape(bottom, 1, num_elem); reshape(top, 1, num_elem)];
clear left right bottom top elem_empty;

% preallocate
vcells = zeros(num_elem, num_dp);

% loop over elements
parfor iel = 1:num_elem
    
    % particles in current element
    ipart_data = part_data{iel};
    
    % is element empty ?
    if (isempty(ipart_data))
        continue;
    end
    
    % number of particles
    num_part = size(ipart_data, 1);
    
    % local particles coordinates (reference element is [0 1 0 1])
    part_coord_x = (ipart_data(:,1) - el_coord_x(iel)) ./ el_dx;
    part_coord_y = (ipart_data(:,2) - el_coord_y(iel)) ./ el_dy;
    
    % compute distances between all disrete points and all particles
    part_dp_dist = zeros(num_dp, num_part);
    for ip = 1:num_part
        part_dp_dist(:,ip) = (dp_coord_x - part_coord_x(ip)).^2 + ...
                             (dp_coord_y - part_coord_y(ip)).^2;
    end
    
    % put bounding particles on interface between empty and occupied elements
    bpart_dp_dist = [];
    if (add_bpart && any(elem_iface(:,iel)))
        bpart_dp_dist = ...
            reshape(bpart_dp_dist_4(:,:,elem_iface(:,iel)), num_dp, []);
    end
    
    % find nearest disrete points for each particle (Voronoi cells)
    [ignore, vcells(iel,:)] = min([part_dp_dist, bpart_dp_dist], [], 2);
    
end
vcells = uint8(vcells);

end