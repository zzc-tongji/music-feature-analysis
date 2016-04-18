function fluctuation_centroid = audio_fluctuation_centroid(d_fluc)
%CACULATE FLUCTUATION CENTROID of A FRAME
%
% This function is written originally by Wang Deqing <deqing.wang@foxmail.com>.
% Some modifications have been added.

fram_num = size(d_fluc, 2);
window_length = size(d_fluc, 1);
fluctuation_centroid = zeros(1, fram_num);
m = ((10 / (window_length - 1)) * (0 : window_length - 1))';
for index = 1 : fram_num
    fram = d_fluc(:, index);
    fluctuation_centroid(index) = sum(m .* fram) / (sum(fram) + eps);
end

end
