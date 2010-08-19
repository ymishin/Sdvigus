function part_data = compute(obj, part_data)
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

% perform splitting / destruction of Voronoi cells ?
min_area = obj.min_area; max_area = obj.max_area;
splitdest_vcells = ~isempty(min_area) || ~isempty(max_area);

% check for fixed types ?
fixed_types = obj.fixed_types;
check_fixed_types = ~isempty(fixed_types);

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

% % preallocate
% part_area = cell(num_elem, 1);

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
    num_bpart = 0;
    bpart_dp_dist = [];
    if (add_bpart && any(elem_iface(:,iel)))
        bpart_dp_dist = ...
            reshape(bpart_dp_dist_4(:,:,elem_iface(:,iel)), num_dp, []);
        num_bpart = size(bpart_dp_dist, 2);
    end
    
    % find nearest disrete points for each particle (Voronoi cells)
    [ignore, vcells] = min([part_dp_dist, bpart_dp_dist], [], 2);
    
    % compute areas of Voronoi cells
    ipart_area = zeros(num_part + num_bpart, 1);
    for idp = 1:num_dp
        ip = vcells(idp);
        ipart_area(ip) = ipart_area(ip) + 1;
    end
    ipart_area = ipart_area(1:num_part) ./ num_dp; % normalize
    
    % splitting / destruction of Voronoi cells
    if (splitdest_vcells)
        
        % Voronoi cells with areas above maximum - candidates for splitting
        to_split = find(ipart_area > max_area);
        num_split = length(to_split);
        
        % prevent splitting of cells of fixed types
        if (check_fixed_types && num_split)
            to_split(ismember(ipart_data(to_split,3), fixed_types)) = [];
            num_split = length(to_split);
        end
        
        % split Voronoi cells (add particles to cell centroids)
        if (num_split)
            vcells = reshape(vcells, num_dp_y, num_dp_x);
            for ip = num_split:-1:1
                % local coordinates of cell centroid
                [dp_i, dp_j] = find(vcells == to_split(ip));
                cent_x = (mean(dp_j) - 0.5) * dp_dx;
                cent_y = (mean(dp_i) - 0.5) * dp_dy;
                % add new particle to cell centroid
                ipart_data(num_part+ip,:) = [ ...
                    cent_x * el_dx + el_coord_x(iel), ... % global x-coord
                    cent_y * el_dy + el_coord_y(iel), ... % global y-coord
                    ipart_data(to_split(ip),3:end)];      % clone all data
                % update distances to discrete points
                part_dp_dist(:,num_part+ip) = ...
                    (dp_coord_x - cent_x).^2 + (dp_coord_y - cent_y).^2;
            end
        end
        
        % Voronoi cells with areas below minimum - candidates for destruction
        to_destroy = find(ipart_area < min_area);
        num_destroy = length(to_destroy);
        
        % leave at least one particle with maximum area
        % (TODO: splitting and destruction should be done in a loop with
        % recalculation of areas, then this workaround is not needed here)
        if (num_destroy == num_part)
            [ignore, ip] = max(ipart_area);
            to_destroy(ip) = [];
            num_destroy = num_destroy - 1;
        end
        
        % prevent destruction of cells of fixed types
        if (check_fixed_types && num_destroy)
            to_destroy(ismember(ipart_data(to_destroy,3), fixed_types)) = [];
            num_destroy = length(to_destroy);
        end
        
        % destroy Voronoi cells (eliminate corresponding particles)
        if (num_destroy)
            % eliminate particles
            ipart_data(to_destroy,:) = [];
            % update distances to discrete points
            part_dp_dist(:,to_destroy) = [];
        end
        
        % are there splitted / destroyed cells ?
        if (num_split || num_destroy)
            
            % update global particles' data
            part_data{iel} = ipart_data;
            
            % rebuild Voronoi cells and recompute areas
            % new number of particles
            num_part = size(ipart_data, 1);
            % find nearest disrete points for each particle (Voronoi cells)
            [ignore, vcells] = min([part_dp_dist, bpart_dp_dist], [], 2);
            % compute areas of Voronoi cells
            ipart_area = zeros(num_part + num_bpart, 1);
            for idp = 1:num_dp
                ip = vcells(idp);
                ipart_area(ip) = ipart_area(ip) + 1;
            end
            ipart_area = ipart_area(1:num_part) ./ num_dp; % normalize
            
        end
        
    end
    
%     % store areas
%     part_area{iel} = ipart_area;
    
%     figure;
%     vcells1 = reshape(vcells,num_dp_y,num_dp_x);
%     vcells1 = [vcells1;vcells1(end,:)];
%     vcells1 = [vcells1,vcells1(:,end)];
%     [X,Y] = meshgrid(linspace(0,1,num_dp_x+1),linspace(0,1,num_dp_y+1));
%     pcolor(X,Y,vcells1);
%     shading flat;
%     hold on;
%     part_coord_x = (ipart_data(:,1)-el_coord_x(iel))./el_dx;
%     part_coord_y = (ipart_data(:,2)-el_coord_y(iel))./el_dy;
%     scatter(part_coord_x,part_coord_y,100,'k','filled');
%     hold off;
%     waitforbuttonpress;
        
end

end
