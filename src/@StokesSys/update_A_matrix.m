function update_A_matrix(obj, elem_visc)
% Update matrix A for Stokes system.
%
% $Id$

global verbose;
t = tic;

% number of nodes
num_node = size(obj.grids.stokes.node_coord, 2);

% number of elements
elem2node = obj.grids.stokes.elem2node;
num_elem = size(elem2node, 2);

% number of velocity nodes per element
switch obj.elem_type
    case 1, num_vnode_el = 4; % Q1P0
    case 2, num_vnode_el = 4; % Q1Q1
    case 3, num_vnode_el = 9; % Q2P-1
end

% velocity equations per element
num_veq_el = 2 * num_vnode_el;
% total number of velocity equations
num_veq = 2 * num_node;
% element -> velocity equations
elem2veq = zeros(num_veq_el, num_elem);
elem2veq(1:2:end-1) = elem2node*2-1;   % x-velocity
elem2veq(2:2:end) = elem2node*2;       % y-velocity
clear elem2node;

% preallocate
n = ((num_veq_el + 1) * num_veq_el) / 2; % store only low triangle of A
A_i = zeros(n, num_elem);
A_j = zeros(n, num_elem);
A_s = zeros(n, num_elem);

% auxiliary arrays for construction of matrices
[A_j_ind, A_i_ind] = meshgrid(1:num_veq_el, 1:num_veq_el);
A_j_ind = A_j_ind(:); A_i_ind = A_i_ind(:);

% element matrix A for reference element
elemA = obj.elemA;

% compute matrices for actual elements and store them in vector-format
for iel = 1:num_elem

    % velocity and pressure equations
    veq_el = double(elem2veq(:,iel));
    
    % matrix A (symmetric => store only low triangle)
    m = (veq_el(A_i_ind) >= veq_el(A_j_ind));
    A_i(:,iel) = veq_el(A_i_ind(m));
    A_j(:,iel) = veq_el(A_j_ind(m));
    A_s(:,iel) = elem_visc(iel) * elemA(m); % (1/sf) * (1/sf) * sf^2 == 1
    
end

% create matrix A from vectors
A = sparse(A_i(:), A_j(:), A_s(:), num_veq, num_veq); % lower triangular
obj.A = A + tril(A,-1)';
clear A A_i A_j A_s;

t = toc(t);
if (verbose > 1)
    fprintf('Update matrix A for Stokes system ... %f\n', t);
end

end