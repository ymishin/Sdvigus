function [inp_coord, inp_weight] = get_coord_weight(num_inp)
% Function returns local coordinates `inp_coord` and corresponding 
% weights `inp_weight` of integration points to perform numerical
% integration for the quadraliteral reference element [-1 +1 -1 +1].
% Number of integration points is specified by `num_inp`.
%
% $Id$

switch num_inp
    
    case 4
      
        % 4 integration points
        % ---------
        % | 4   3 |
        % |       |
        % | 1   2 |
        % ---------
               
        % local coordinates
        lc1 = -sqrt(1 / 3);
        lc2 =  sqrt(1 / 3);
        inp_coord = [lc1, lc2, lc2, lc1; ... % xi
                     lc1, lc1, lc2, lc2];    % eta
        
        % weights
        w = 1.0;
        inp_weight = [w, w, w, w];
        
    case 9

        % 9 integration points
        % ---------
        % | 4 7 3 |
        % | 8 9 6 |
        % | 1 5 2 |
        % ---------

        % local coordinates
        lc1 = -sqrt(3 / 5);
        lc2 =  sqrt(3 / 5);
        inp_coord = [lc1, lc2, lc2, lc1, 0.0, lc2, 0.0, lc1, 0.0; ... % xi
                     lc1, lc1, lc2, lc2, lc1, 0.0, lc2, 0.0, 0.0];    % eta
        
        % weights
        w1 = 5 / 9;
        w2 = 8 / 9;
        w11 = w1 * w1;
        w12 = w1 * w2;
        w22 = w2 * w2;
        inp_weight = [w11, w11, w11, w11, w12, w12, w12, w12, w22];
        
end

end