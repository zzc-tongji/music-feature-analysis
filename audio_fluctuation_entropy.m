function fluctuation_entropy = audio_fluctuation_entropy(d_fluc)
%CACULATE FLUCTUATION ENTROPY of A FRAME
%
% This function is written originally by Wang Deqing <deqing.wang@foxmail.com>.
% Some modifications have been added.

d_fluc_abs = abs(d_fluc);
summat = repmat(sum(d_fluc_abs) + repmat(eps, ...
    [1 size(d_fluc_abs, 2) size(d_fluc_abs, 3) size(d_fluc_abs, 4)]), ...
    [size(d_fluc_abs, 1) 1 1 1]);
d_fluc_abs = d_fluc_abs ./ summat;
fluctuation_entropy = - sum(d_fluc_abs .* log(d_fluc_abs + eps)) ./ log(size(d_fluc_abs, 1));

end
