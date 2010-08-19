function r = isprop(obj, prop)
% Returns true if object has property 'prop'.
%
% $Id$

try
    tmp = obj.(prop);
    r = true;
catch
    r = false;
end