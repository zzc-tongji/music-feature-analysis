function result = average_compare(m1, m2)
%COMPARE MEAN of DATA
%
%   result = average_compare(m1, m2)
%       Parameter 'm1' and 'm2' must be must be two-dimensional matrixes.
%       If m1 is bigger than m2, the return value is positive.
%       The return value is relative, because data ranges of each feature are different.
%       For example, 0.156 means m1 is 15.6% bigger than m2.

% check parameter
s1 = size(m1);
s2 = size(m2);
if length(s1) ~= 2 || length(s2) ~= 2
    error('Parameter ''m1'' and ''m2'' must be must be two-dimensional matrixes.');
end

% calculate
m1_average = mean(m1);
m2_average = mean(m2);
result = (m1_average - m2_average) ./ ((m1_average + m2_average) ./ 2);

end
