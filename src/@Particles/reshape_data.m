function reshape_data(obj, mode)
% Change state of the data array according to 'mode'.
%
% $Id$

% global verbose;
% t = tic;

switch mode
    
    case 'array'
        % convert into flat array
        if (obj.data_state ~= 1)
            obj.data = cell2mat(obj.data);
            obj.data_state = 1;
            % update number
            obj.num_part = size(obj.data, 1);
        end
        
    case 'cell_hl'
        % assign particles to elements of finest grid
        if (obj.data_state ~= 2)
            obj.reshape_data('cell_hl_forced');
        end
        
    case 'cell_hl_forced'
        % re-assign particles to elements of finest grid
        % even if they are assigned already
        obj.reshape_data('array');
        obj.assign2elemhl();
        obj.data_state = 2;
        
    case 'cell_stokes'
        
        % assign particles to actual elements of
        % Stokes grid in case of multilevel grid
        if (obj.data_state ~= 3)
            obj.reshape_data('cell_hl');
            if (~isempty(obj.grids.stokes.elem2elemhl))
                % multilevel grid
                obj.assign2elem(obj.grids.stokes.elem2elemhl);
                obj.data_state = 3;
            end
        end
        
end

% t = toc(t); verbose.disp(['Change state of the data to ''', ...
%                          mode, ''' ... ', num2str(t)], 2);

end