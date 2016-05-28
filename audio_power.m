function power = audio_power(wav_file, frame_s, non_overlap_s)
%CACULATE POWER of AUDIO WAVE
%
%   power_result = audio_power(wav_file, frame_s, non_overlap_s)
%       Use 'linear' as the default interpolation method in tne end.
%       Return value 'power' is a matrix with 2 columns:
%           1st column - power
%           2nd column - time (s)

% check parameter
if ~ischar(wav_file) || strcmp(wav_file, '')
	error('Parameter 1 must be a non-empty string.');
end
if ~isfloat(frame_s)
    error('Parameter 2 must be a double.');
end
if ~isfloat(non_overlap_s)
    error('Parameter 3 must be a double.');
end
if frame_s < non_overlap_s
    error('Parameter 2 should be no less than parameter 3.');
end

% read .wav file
[wave, sample_rate, ~] = wavread(wav_file);

% transform from second to point
temp = sample_rate * frame_s;
frame_point = floor(temp);
if frame_point ~= temp
    error('Number of sampling points in a frame is not an integer.');
end
temp = sample_rate * non_overlap_s;
non_overlap_point = floor(temp);
if non_overlap_point ~= temp
    error('Number of sampling points in non-overlaping part of a frame is not an integer.');
end

frame_number = floor((length(wave) - (frame_point - non_overlap_point)) / non_overlap_point);

% calculate power
power = zeros(frame_number, 2);
for index = 1 : 1 : frame_number
    select_end = index * non_overlap_point + (frame_point - non_overlap_point);
    select_begin = select_end - frame_point + 1;
    % This is the core formula.
    power(index, 1) = sum(wave(select_begin : select_end).^ 2) / frame_s;
end

% set time
for index = 1 : frame_number
    power(index, 2) = frame_s / 2 + (index - 1) * non_overlap_s;
end

end
