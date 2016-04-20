function power_result = audio_power(wav_file, frame_s, non_overlap_s)
%CACULATE POWER of AUDIO WAVE
%
%   power_result = audio_power(wav_file, frame_s, non_overlap_s)
%       Use 'linear' as the default interpolation method in tne end.
%       Return value 'power result' is a matrix with 2 line:
%           1st line - power
%           2nd line - time (s)

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

% read .wav file
[wave, sample_rate, ~] = wavread(wav_file);

% transform from second to point
frame_point = fix(sample_rate * frame_s);
non_overlap_point = fix(sample_rate * non_overlap_s);

% calculate power
loop_end_index = fix((length(wave) - frame_point) / non_overlap_point) + 1;
power_result = zeros(loop_end_index, 2);
for index = 1 : loop_end_index
    select_begin = (index - 1) * non_overlap_point + 1;
    select_end = select_begin + frame_point - 1;
    % This is the core formula.
    power_result(index, 1) = sum(wave(select_begin : select_end).^ 2) /...
        (frame_point / sample_rate);
end

% set time
for index = 1 : loop_end_index
    power_result(index, 2) = fix(frame_s / 2) + (index - 1) * non_overlap_s;
end

end
