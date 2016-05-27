function result = zzc_mean_compare(m1, m2)
%COMPARE MEAN of DATA
%
%   result = zzc_mean_compare(m1, m2)
%       Parameter 'm1' and 'm2' must be two-dimensional matrixes.
%       If 'm1' is bigger than 'm2', the return value is positive.
%       The return value is relative, because data ranges might be different.
%       For example, 0.156 means 'm1' is 15.6% bigger than 'm2'.

% check parameter
if length(size(m1)) ~= 2 || length(size(m2)) ~= 2
    error('Parameter 1 and parameter 2 must be two-dimensional matrixes.');
end

% calculate
m1_average = mean(m1);
m2_average = mean(m2);
result = (m1_average - m2_average) ./ ((m1_average + m2_average) ./ 2);

end
