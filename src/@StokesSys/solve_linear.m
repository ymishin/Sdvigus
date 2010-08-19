function [v, p] = solve_linear(obj, stokes, bc)
% Solve Stokes system of equations.
%
% $Id$

global verbose;
t = tic;

% ensure that C is symmetric
stokes.C = tril(stokes.C,0) + tril(stokes.C,-1)';

% total numbers of velocity and pressure equations
[num_veq, num_peq] = size(stokes.Q);

% velocity and pressure vectors
v = zeros(num_veq, 1);
p = zeros(num_peq, 1);

% free velocity equations
free_veq = (1:num_veq);
free_veq(bc.eq) = [];
num_free_veq = length(free_veq);

% % impose BC on velocity vector
% v(bc.eq) = bc.val;

% impose BC on momentum equation
v(bc.eq) = bc.val;
RHSv = stokes.RHS - stokes.A(:,bc.eq) * bc.val;
RHSv = RHSv(free_veq);
A = stokes.A(free_veq,free_veq);

% impose BC on continuity equation
RHSp = - stokes.Q(bc.eq,:)' * bc.val;
Q = stokes.Q(free_veq,:);

% TODO: clean-up
if (verbose > 1)
    spparms('spumoni', 2);
else
    spparms('spumoni', 0);
end

% solve
x = [A, Q; Q', -stokes.C] \ [RHSv; RHSp];

% extract velocity and pressure
v(free_veq) = x(1:num_free_veq);
p(:) = x(num_free_veq+1:end);

t = toc(t);
if (verbose > 0)
    fprintf('Solve Stokes system ... %f\n', t);
end

end