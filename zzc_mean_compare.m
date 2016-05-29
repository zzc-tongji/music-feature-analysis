function compare_result = zzc_mean_compare(data_1, data_2)
%COMPARE MEAN of EACH COLUMN of DATA
%
%   compare_result = zzc_mean_compare(data_1, data_2)
%
%   ----------
%
%   Parameter 'data_1' and 'data_2' must be two-dimensional matrixes.
%
%   ----------
%
%   Return value 'compare_result' is the difference of parameter 'data_1' and 'data_2'.
%       It's value is relative, because data ranges of parameters might be different.
%       Positive value shows that the front value (parameter 'data_1')
%       is bigger than the behind value (parameter 'data_2').
%
%   For example, 'compare_result(1) == 0.156' shows that
%       mean value of 'data_1(:, 1)' is 15.6% bigger than mean value of 'data_2(:, 1)'.

% check parameter
if length(size(data_1)) ~= 2 || length(size(data_2)) ~= 2
    error('Parameter 1 and parameter 2 must be two-dimensional matrixes.');
end

% calculate
m1_average = mean(data_1);
m2_average = mean(data_2);
compare_result = (m1_average - m2_average) ./ ((m1_average + m2_average) ./ 2);

end
