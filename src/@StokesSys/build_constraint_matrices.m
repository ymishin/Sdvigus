function build_constraint_matrices(obj)
% Construct and apply constraint matrices for Stokes system.
%
% $Id$

global verbose;
t = tic;

% local vars
mask = obj.grids.stokes.mask;
jmax = obj.grids.stokes.jmax;
elem_type = obj.elem_type;

% number of nodes at finest level
[num_node_y, num_node_x] = size(mask);

% nodes' bottom-up numbering
node_no = zeros(num_node_y, num_node_x);
node_no(mask) = 1:nnz(mask);

% velocity equations' numbering
vxeq_no = node_no * 2 - 1;
vyeq_no = node_no * 2;

% total number of velocity equations
num_veq = 2 * nnz(mask);

% velocity constraint matrix
CV_i = zeros(num_veq * 2, 1);
CV_j = zeros(num_veq * 2, 1);
CV_s = zeros(num_veq * 2, 1);
k = 1;

% in case of Q1Q1 pressure is continuous and has to be constrained
if (elem_type == 2)
    % pressure equations' numbering
    peq_no = node_no;
    % total number of pressure equations
    num_peq = nnz(mask);
    % pressure constraint matrix
    CP_i = zeros(num_peq * 2, 1);
    CP_j = zeros(num_peq * 2, 1);
    CP_s = zeros(num_peq * 2, 1);
    l = 1;
end

% construct constraint matrices in vector-format
switch elem_type
    
    % Q1P0, Q1Q1
    case {1,2}
    
    % loop over grid levels
    for j = jmax:-1:2
        
        % step
        s = 2^(jmax-j);
        s2 = 2*s;
        
        % look for hangning nodes on horizontal edges
        for inx = (1+s):s2:(num_node_x-s)
            for iny = (1+s2):s2:(num_node_y-s2)
                
                % check if the node exists
                if (~mask(iny,inx))
                    continue;
                end
                
                % check if the node has both neighbours in a vertical
                % direction, if it does have both => it's not a hanging node
                if (mask(iny+s,inx) && mask(iny-s,inx))
                    continue;
                end
                
                % put constraint on velocity eqs. of hanging node
                CV_i(k:k+5) = [ ...
                    vxeq_no(iny,inx) vxeq_no(iny,inx) vxeq_no(iny,inx) ...
                    vyeq_no(iny,inx) vyeq_no(iny,inx) vyeq_no(iny,inx)];
                CV_j(k:k+5) = [ ...
                    vxeq_no(iny,inx) vxeq_no(iny,inx-s) vxeq_no(iny,inx+s) ...
                    vyeq_no(iny,inx) vyeq_no(iny,inx-s) vyeq_no(iny,inx+s)];
                CV_s(k:k+5) = [-1.0 0.5 0.5 -1.0 0.5 0.5];
                k = k + 6;

                % put constraint on pressure eqs. of hanging node (Q1Q1)
                if (elem_type == 2)
                    CP_i(l:l+2) = [ ...
                        peq_no(iny,inx) peq_no(iny,inx) peq_no(iny,inx)];
                    CP_j(l:l+2) = [ ...
                        peq_no(iny,inx) peq_no(iny,inx-s) peq_no(iny,inx+s)];
                    CP_s(l:l+2) = [-1.0 0.5 0.5];
                    l = l + 3;
                end
                
            end
        end
        
        % look for hangning nodes on vertical edges
        for inx = (1+s2):s2:(num_node_x-s2)
            for iny = (1+s):s2:(num_node_y-s)
                
                % check if the node exists
                if (~mask(iny,inx))
                    continue;
                end
                
                % check if the node has both neighbours in a horizontal 
                % direction, if it does have both => it's not a hanging node
                if (mask(iny,inx+s) && mask(iny,inx-s))
                    continue;
                end
                
                % put constraint on velocity eqs. of hanging node
                CV_i(k:k+5) = [ ...
                    vxeq_no(iny,inx) vxeq_no(iny,inx) vxeq_no(iny,inx) ...
                    vyeq_no(iny,inx) vyeq_no(iny,inx) vyeq_no(iny,inx)];
                CV_j(k:k+5) = [ ...
                    vxeq_no(iny,inx) vxeq_no(iny-s,inx) vxeq_no(iny+s,inx) ...
                    vyeq_no(iny,inx) vyeq_no(iny-s,inx) vyeq_no(iny+s,inx)];
                CV_s(k:k+5) = [-1.0 0.5 0.5 -1.0 0.5 0.5];
                k = k + 6;
                
                % put constraint on pressure eqs. of hanging node (Q1Q1)                
                if (elem_type == 2)
                    CP_i(l:l+2) = [ ...
                        peq_no(iny,inx) peq_no(iny,inx) peq_no(iny,inx)];
                    CP_j(l:l+2) = [ ...
                        peq_no(iny,inx) peq_no(iny-s,inx) peq_no(iny+s,inx)];
                    CP_s(l:l+2) = [-1.0 0.5 0.5];
                    l = l + 3;
                end
                
            end
        end
        
    end
    
    % Q2P-1
    case 3
    
    for j = jmax:-1:2
        
        % step
        s = 2^(jmax-j);
        s2 = 2*s;
        s3 = 3*s;
        s4 = 4*s;
        
        % look for hangning nodes on horizontal edges
        for inx = (1+s):s4:(num_node_x-s3)
            for iny = (1+s4):s4:(num_node_y-s4)
                
                % check if the node exists
                if (~mask(iny,inx))
                    continue;
                end
                
                % check if the node has both neighbours in a vertical
                % direction, if it does have both => it's not a hanging node
                if (mask(iny+s,inx) && mask(iny-s,inx))
                    continue;
                end
                
                % put constraint on velocity eqs. of hanging node
                CV_i(k:k+7) = [ ...
                    vxeq_no(iny,inx) vxeq_no(iny,inx) ...
                    vxeq_no(iny,inx) vxeq_no(iny,inx) ...
                    vyeq_no(iny,inx) vyeq_no(iny,inx) ...
                    vyeq_no(iny,inx) vyeq_no(iny,inx)];
                CV_j(k:k+7) = [ ...
                    vxeq_no(iny,inx) vxeq_no(iny,inx-s) ...
                    vxeq_no(iny,inx+s) vxeq_no(iny,inx+s3) ...
                    vyeq_no(iny,inx) vyeq_no(iny,inx-s) ...
                    vyeq_no(iny,inx+s) vyeq_no(iny,inx+s3)];
                CV_s(k:k+7) = [-1.0 0.375 0.750 -0.125 ...
                               -1.0 0.375 0.750 -0.125];
                k = k + 8;
                
                % put constraint on velocity eqs. of hanging node
                inx2 = inx + s2;
                CV_i(k:k+7) = [ ...
                    vxeq_no(iny,inx2) vxeq_no(iny,inx2) ...
                    vxeq_no(iny,inx2) vxeq_no(iny,inx2) ...
                    vyeq_no(iny,inx2) vyeq_no(iny,inx2) ...
                    vyeq_no(iny,inx2) vyeq_no(iny,inx2)];
                CV_j(k:k+7) = [ ...
                    vxeq_no(iny,inx2) vxeq_no(iny,inx+s3) ...
                    vxeq_no(iny,inx+s) vxeq_no(iny,inx-s) ...
                    vyeq_no(iny,inx2) vyeq_no(iny,inx+s3) ...
                    vyeq_no(iny,inx+s) vyeq_no(iny,inx-s)];
                CV_s(k:k+7) = [-1.0 0.375 0.750 -0.125 ...
                               -1.0 0.375 0.750 -0.125];
                k = k + 8;
                
            end
        end
        
        % look for hangning nodes on vertical edges
        for inx = (1+s4):s4:(num_node_x-s4)
            for iny = (1+s):s4:(num_node_y-s3)
                
                % check if the node exists
                if (~mask(iny,inx))
                    continue;
                end
                
                % check if the node has both neighbours in a horizontal 
                % direction, if it does have both => it's not a hanging node
                if (mask(iny,inx+s) && mask(iny,inx-s))
                    continue;
                end
                
                % put constraint on velocity eqs. of hanging node
                CV_i(k:k+7) = [ ...
                    vxeq_no(iny,inx) vxeq_no(iny,inx) ...
                    vxeq_no(iny,inx) vxeq_no(iny,inx) ...
                    vyeq_no(iny,inx) vyeq_no(iny,inx) ...
                    vyeq_no(iny,inx) vyeq_no(iny,inx)];
                CV_j(k:k+7) = [ ...
                    vxeq_no(iny,inx) vxeq_no(iny-s,inx) ...
                    vxeq_no(iny+s,inx) vxeq_no(iny+s3,inx) ...
                    vyeq_no(iny,inx) vyeq_no(iny-s,inx) ...
                    vyeq_no(iny+s,inx) vyeq_no(iny+s3,inx)];
                CV_s(k:k+7) = [-1.0 0.375 0.750 -0.125 ...
                               -1.0 0.375 0.750 -0.125];
                k = k + 8;
                
                % put constraint on velocity eqs. of hanging node
                iny2 = iny + s2;
                CV_i(k:k+7) = [ ...
                    vxeq_no(iny2,inx) vxeq_no(iny2,inx) ...
                    vxeq_no(iny2,inx) vxeq_no(iny2,inx) ...
                    vyeq_no(iny2,inx) vyeq_no(iny2,inx) ...
                    vyeq_no(iny2,inx) vyeq_no(iny2,inx)];
                CV_j(k:k+7) = [ ...
                    vxeq_no(iny2,inx) vxeq_no(iny+s3,inx) ...
                    vxeq_no(iny+s,inx) vxeq_no(iny-s,inx) ...
                    vyeq_no(iny2,inx) vyeq_no(iny+s3,inx) ...
                    vyeq_no(iny+s,inx) vyeq_no(iny-s,inx)];
                CV_s(k:k+7) = [-1.0 0.375 0.750 -0.125 ...
                               -1.0 0.375 0.750 -0.125];
                k = k + 8;
                
            end
        end
        
    end
    
end

% use sparse2 if available
if (exist('sparse2','file'))
    sparsef = @sparse2;
else
    sparsef = @sparse;
end

% create velocity constraint matrix from vectors
CV_i(k:end) = [];
CV_j(k:end) = [];
CV_s(k:end) = [];
CV = speye(num_veq) + sparsef(CV_i(:), CV_j(:), CV_s(:), num_veq, num_veq);
obj.CV = CV;

% impose constraint on velocities
obj.A = CV' * obj.A * CV;
obj.Q = CV' * obj.Q;
obj.RHS = CV' * obj.RHS;

% create pressure constraint matrix from vectors (Q1Q1)
if (elem_type == 2)
    CP_i(l:end) = [];
    CP_j(l:end) = [];
    CP_s(l:end) = [];
    CP = speye(num_peq) + sparsef(CP_i(:), CP_j(:), CP_s(:), num_peq, num_peq);
    obj.CP = CP;

    % impose constraint on pressures
    obj.Q = obj.Q * CP;
    obj.C = CP' * obj.C * CP;
end

t = toc(t);
verbose.disp(['Constraint matrices construction ... ', num2str(t)], 2);

end