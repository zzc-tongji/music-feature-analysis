function result = sps_rebuild(data, frame_length_s, non_overlap_s)
%REBUILD of SOUND INTENSITY, POWER and SHARPNESS by MEAN
%
%   result = sps_reconstruct(data, frame_length_s, non_overlap_s)
%       Parameter 'data' must be the result of function 'audio_sound_intensity',
%           function 'audio_power' or function 'audio_sharpness'.
%       Return value 'result' is a column vector, no longer include time information.

% check parameter
if ~ismatrix(data)
    error('Parameter 1 must be a matrix');
end
if ~isfloat(frame_length_s)
    error('Parameter 2 must be a double.');
end
if ~isfloat(non_overlap_s)
    error('Parameter 3 must be a double.');
end
if frame_length_s < non_overlap_s
    error('Parameter 2 should be no less than parameter 3.');
end

% rebuild
next_time = frame_length_s;
selected_begin = 1;
result = zeros(ceil((ceil(data(end, 2)) - (frame_length_s - non_overlap_s)) / non_overlap_s), 1);
index_1 = 1;
for index_2 = 1 : 1 : size(data, 1)
    if data(index_2, 2) > next_time
        % locate
        selected_end = index_2 - 1;
        % caculate mean
        result(index_1) = mean(data(selected_begin : selected_end, 1));
        index_1 = index_1 + 1;
        % locate
        selected_begin = index_2;
        next_time = next_time + non_overlap_s;
        % no data left
        if index_2 == size(data, 1)
            break;
        end
    end
    % the rest of data
    if index_2 == size(data, 1)
        selected_end = index_2;
        result(index_1) = mean(data(selected_begin : selected_end, 1));
    end
end
result = result(1 : index_1);

end
