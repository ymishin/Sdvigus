function build_system_matrices(obj, elem_visc, elem_dens)
% Construct all system matrices for Stokes system.
%
% $Id$

global verbose;
t = tic;

% number of nodes
num_node = size(obj.grids.stokes.node_coord, 2);

% number of elements
elem2node = obj.grids.stokes.elem2node;
num_elem = size(elem2node, 2);

% element type
elem_type = obj.elem_type;
switch elem_type
    case 1
        % Q1P0
        num_inp = 4;                  % integration points
        num_vnode_el = 4;             % velocity nodes
        num_pnode_el = 1;             % pressure nodes
        elem2peq = (1:num_elem);      % element -> pressure equations
        num_peq = num_elem;           % total number of pressure equations
    case 2
        % Q1Q1
        num_inp = 4;                  % integration points
        num_vnode_el = 4;             % velocity nodes
        num_pnode_el = 4;             % pressure nodes
        elem2peq = elem2node;         % element -> pressure equations
        num_peq = num_node;           % total number of pressure equations
    case 3
        % Q2P-1
        num_inp = 9;                  % integration points
        num_vnode_el = 9;             % velocity nodes
        num_pnode_el = 3;             % pressure nodes
        elem2peq = reshape( ...
            1:3*num_elem,3,num_elem); % element -> pressure equations
        num_peq = 3*num_elem;         % total number of pressure equations
end

% pressure equations per element
num_peq_el = num_pnode_el;
% velocity equations per element
num_veq_el = 2 * num_vnode_el;
% total number of velocity equations
num_veq = 2 * num_node;
% element -> velocity equations
elem2veq = zeros(num_veq_el, num_elem);
elem2veq(1:2:end-1) = elem2node*2-1;   % x-velocity
elem2veq(2:2:end) = elem2node*2;       % y-velocity
clear elem2node;

% integration points
[inp_coord, inp_weight] = IntegrPoints.get_coord_weight(num_inp);

% velocity shape functions and their derivatives
Nv = ShapeFuncs.compute(inp_coord, num_vnode_el);
dNv = ShapeFuncs.compute_der(inp_coord, num_vnode_el);

% pressure shape functions
Np = ShapeFuncs.compute(inp_coord, num_pnode_el);

% D matrix
D = [ 2  0  0; ...
      0  2  0; ...
      0  0  1 ];
  
% D = [ 4/3 -2/3  0; ...
%      -2/3  4/3  0; ...
%         0    0  1 ];

% preallocate
B = zeros(3, num_veq_el);
elemA = zeros(num_veq_el, num_veq_el);
elemQ = zeros(num_veq_el, num_peq_el);
elemMC = zeros(num_peq_el, num_peq_el);
elemRHS = zeros(num_veq_el, 1);
n = ((num_veq_el + 1) * num_veq_el) / 2; % store only low triangle of A
A_i = zeros(n, num_elem);
A_j = zeros(n, num_elem);
A_s = zeros(n, num_elem);
n = num_veq_el * num_peq_el;
Q_i = zeros(n, num_elem);
Q_j = zeros(n, num_elem);
Q_s = zeros(n, num_elem);
n = num_peq_el * num_peq_el;
MC_i = zeros(n, num_elem);
MC_j = zeros(n, num_elem);
MC_s = zeros(n, num_elem);
RHS = zeros(num_veq, 1);

% auxiliary arrays for construction of matrices
[A_j_ind, A_i_ind] = meshgrid(1:num_veq_el, 1:num_veq_el);
A_j_ind = A_j_ind(:); A_i_ind = A_i_ind(:);
[Q_j_ind, Q_i_ind] = meshgrid(1:num_peq_el, 1:num_veq_el);
Q_j_ind = Q_j_ind(:); Q_i_ind = Q_i_ind(:);
[MC_j_ind, MC_i_ind] = meshgrid(1:num_peq_el, 1:num_peq_el);
MC_j_ind = MC_j_ind(:); MC_i_ind = MC_i_ind(:);

% Jacobian for abstract element at finest level
dx = obj.grids.stokes.elemhl(1);
dy = obj.grids.stokes.elemhl(2);
invJ = [ 2/dx 0; 0 2/dy ];
detJ = dx*dy/4;

% perform numerical integration and construct element matrices 
% for reference element at finest level
for i = 1:num_inp
        % shape functions at current integration point
        Nvi  = Nv(i,:);
        dNvi = dNv(2*i-1:2*i,:);
        Npi  = Np(i,:);
        % derivatives wrt global coordinates
        dNvi = invJ * dNvi;
        % weight and detJ
        wdetJ = detJ * inp_weight(i);
        % matrix A
        B(1,1:2:end-1) = dNvi(1,:);
        B(2,2:2:end)   = dNvi(2,:);
        B(3,1:2:end-1) = dNvi(2,:);
        B(3,2:2:end)   = dNvi(1,:);
        elemA = elemA + wdetJ * B' * D * B;
        % matrix Q
        BQ = dNvi(:);
        elemQ = elemQ - wdetJ * BQ * Npi;
        if (elem_type == 2)
            % matrix C (Q1Q1)
            elemMC = elemMC + wdetJ * (Npi - 0.25)' * (Npi - 0.25);
        else
            % matrix M (Q1P0, Q2P-1)
            elemMC = elemMC + wdetJ * Npi' * Npi;
        end
        % RHS
        r = obj.Fext * Nvi;
        elemRHS = elemRHS + wdetJ * r(:);
end

% store element matrix A for reference element
obj.elemA = elemA;

% scaling factor for invJ and detJ
if (obj.grids.stokes.jmax > 1)
    % multilevel grid
    % detJ should be scaled by sf^2
    % invJ should be scaled by 1/sf
    sf = 2.^(obj.grids.stokes.jmax - double(obj.grids.stokes.elem_level));
else
    % equidistant grid
    sf = ones(num_elem, 1);
end

% compute matrices for actual elements and store them in vector-format
for iel = 1:num_elem

    % velocity and pressure equations
    veq_el = double(elem2veq(:,iel));
    peq_el = double(elem2peq(:,iel));
    
    % matrix A (symmetric => store only low triangle)
    m = (veq_el(A_i_ind) >= veq_el(A_j_ind));
    A_i(:,iel) = veq_el(A_i_ind(m));
    A_j(:,iel) = veq_el(A_j_ind(m)); 
    A_s(:,iel) = elem_visc(iel) * elemA(m); % (1/sf) * (1/sf) * sf^2 == 1
    
    % matrix Q
    Q_i(:,iel) = veq_el(Q_i_ind);
    Q_j(:,iel) = peq_el(Q_j_ind);
    Q_s(:,iel) = sf(iel) * elemQ(:); % (1/sf) * sf^2 == sf
    
    % matrices M and C
    MC_i(:,iel) = peq_el(MC_i_ind);
    MC_j(:,iel) = peq_el(MC_j_ind);
    if (elem_type == 2)
        % matrix C (Q1Q1)
        MC_s(:,iel)  = (1/elem_visc(iel)) * sf(iel)^2 * elemMC(:);           
    else
        % matrix M (Q1P0, Q2P-1)
        MC_s(:,iel)  = sf(iel)^2 * elemMC(:);
    end
    
    % RHS
    RHS(veq_el) = RHS(veq_el) + elem_dens(iel) * sf(iel)^2 * elemRHS;
    
end

% use sparse2 if available
if (exist('sparse2','file'))
    sparsef = @sparse2;
else
    sparsef = @sparse;
end

% create matrices from vectors
% A
A = sparsef(A_i(:), A_j(:), A_s(:), num_veq, num_veq); % lower triangular
obj.A = A + tril(A,-1)';
clear A A_i A_j A_s;
% Q
obj.Q = sparsef(Q_i(:), Q_j(:), Q_s(:), num_veq, num_peq);
clear Q_i Q_j Q_s;
% invM and C
MC = sparsef(MC_i(:), MC_j(:), MC_s(:), num_peq, num_peq);
if (elem_type == 2)
    % matrix C (Q1Q1)
    obj.C = MC;
else
    % matrix invM (Q1P0, Q2P-1)
    obj.invM = inv(diag(diag(MC)));
end
clear MC_i MC_j MC_s MC;
% RHS
obj.RHS = RHS;
clear RHS;

t = toc(t);
verbose.disp(['System matrices construction ... ', num2str(t)], 2);

end