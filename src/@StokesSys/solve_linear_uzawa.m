function solve_linear_uzawa(obj)
% Solve Stokes system using Uzawa iterations.
% 
% Some ideas came from:
% M. Dabrowski et al., "MILAMIN: MATLAB-based finite element method 
% solver for large problems", Geochem.Geophys.Geosyst. 9(4), Q04030, 2008.
%
% $Id$

global verbose;
spval = 0;
if (verbose.level > 2), spval = 1; end;
if (verbose.level > 3), spval = 2; end;
t = tic;

% parameters
k = obj.solv_params.uzawa_k;
maxdiv = obj.solv_params.uzawa_maxdiv;
maxiter = obj.solv_params.uzawa_maxiter;

% all required data
bc    = obj.bc;
CV    = obj.CV;
Q     = obj.Q;
invM  = obj.invM;
A     = obj.A + k * Q * invM * Q';
obj.A = []; % clear
RHSv  = obj.RHS;

% ensure that A is symmetric
A = tril(A,0) + tril(A,-1)';

% equations corresponding to hanging nodes
hanging_veq = find(~spdiags(CV,0))';

% total numbers of velocity and pressure equations
[num_veq, num_peq] = size(Q);

% velocity and pressure vectors
v = zeros(num_veq, 1);
p = zeros(num_peq, 1);

% free velocity equations
free_veq = (1:num_veq);
free_veq(union(bc.eq,hanging_veq)) = [];

% impose BC
v(bc.eq) = bc.val;
RHSv = RHSv - A(:,bc.eq) * bc.val;

% leave only free equations in the system
A = A(free_veq,free_veq);
RHSv = RHSv(free_veq);

% reorder to reduce fill-in
perm = amd(A);
A = tril(A(perm,perm));
free_veq = free_veq(perm);
RHSv = RHSv(perm);
clear perm;

% perform Cholesky factorization
spparms('spumoni', spval);
A = chol(A, 'lower');
spparms('spumoni', 0);

% Uzawa loop
j = 0;
while (true)
    % compute velocity
    v(free_veq) = A' \ (A \ (RHSv - Q(free_veq,:) * p));
    % restore hanging nodes DOFs
    v = CV * v;
    % compute divergence
    div = invM * Q' * v;
    % update pressure
    p = p + k * div;
    % check convergence
    res = norm(div(:), Inf);
    j = j + 1;
    if (res < maxdiv || j >= maxiter)
        break;
    end
end

% store solution
obj.velocity = v(1:2:end-1);
obj.velocity(:,2) = v(2:2:end);
obj.pressure = p;

t = toc(t);
m = sprintf('Stokes solver (Uzawa: %d) ... %f', j, t);
verbose.disp(m, 2);

end