function power_result = audio_power(wav_file, frame_s, non_overlap_s, method)
%CACULATE POWER of AUDIO WAVE
%
%   power_result = audio_power(wav_file, frame_s, non_overlap_s)
%       Use 'linear' as the default interpolation method in tne end.
%       Return value 'power result' is a matrix with 2 line:
%           1st line - power
%           2nd line - time (s)
%
%   power_result = audio_power(wav_file, frame_s, non_overlap_s, method)
%       Parameter 'method' indicates interpolation method in the end,
%       it must be one of them:
%          'nearest'  - nearest neighbor interpolation
%          'linear'   - linear interpolation
%          'spline'   - piecewise cubic spline interpolation (SPLINE)
%          'pchip'    - shape-preserving piecewise cubic interpolation
%          'cubic'    - same as 'pchip'
%          'v5cubic'  - the cubic interpolation from MATLAB 5, which does not
%                       extrapolate and uses 'spline' if X is not equally spaced.

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
if (nargin == 3)
elseif (nargin == 4)
    if ~ischar(method) || (~ strcmp(method, 'nearest') && ~ strcmp(method, 'linear') && ~ strcmp(method, 'spline') && ~ strcmp(method, 'pchip') && ~ strcmp(method, 'cubic') && ~ strcmp(method, 'v5cubic'))
        error('Parameter 4 must be a string which must be one of them: ''linear'', ''''spline, ''pchip'', ''cubic'' or ''v5cubic''.');
    end
else
    error('There are too much parameters.');
end

% read .wav file
[wave, sample_rate, ~] = wavread(wav_file);

% transform from second to point
frame_point = fix(sample_rate * frame_s);
non_overlap_point = fix(sample_rate * non_overlap_s);

% calculate power
loop_end_index = fix((length(wave) - frame_point) / non_overlap_point) + 1;
power = zeros(loop_end_index, 2);
for index = 1 : loop_end_index
    select_begin = (index - 1) * non_overlap_point + 1;
    select_end = select_begin + frame_point - 1;
    % This is the core formula.
    power(index, 1) = sum(wave(select_begin : select_end).^ 2) /...
        (frame_point / sample_rate);
end

% interpolate
for index = 1 : loop_end_index
    power(index, 2) = fix(frame_point / 2) + (index - 1) * non_overlap_point;
end
power_result = zeros(length(wave), 2);
for index = 1 : length(wave)
    power_result(index, 2) = index;
end
if(nargin == 3)
    power_result(:, 1) = interp1(power(:, 2), power(:, 1), power_result(:, 2));
else
    power_result(:, 1) = interp1(power(:, 2), power(:, 1), power_result(:, 2), method);
end
for index = 1 : loop_end_index
    if power_result(index, 1) < 0
        power_result(index, 1) = 0;
    end
end

% set time
power_result(:, 2) = power_result(:, 2) / sample_rate;
