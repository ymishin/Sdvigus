function assign2elem(obj, elem2elemhl)
% Assign particles to actual elements in case of multilevel
% grid, in accordance with 'elem2elemhl' structure.
%
% $Id$

% number of elements
num_elem = size(elem2elemhl, 1);

% preallocate
data_new = cell(num_elem, 1);

% loop over levels
data = obj.data;
for j = 1:size(elem2elemhl,1)
    
    % actual elements ...
    no_elem = elem2elemhl(j).no_elem;
    % ... include elements from finest level
    no_elemhl = elem2elemhl(j).no_elemhl;
    
    % loop over elements
    for i = 1:length(no_elem)
        data_new{no_elem(i)} = vertcat(data{no_elemhl(:,i)});
    end
    
end
clear data;
obj.data = data_new;
clear data_new;

end