function sound_intensity = audio_sound_intensity(wav_file, method)
%CACULATE SOUND INTENSITY of AUDIO WAVE
%
%   sound_intensity = audio_sound_intensity(wav_file)
%       Use 'linear' as the default interpolation method in tne end.
%       Return value 'sound_intensity' is a matrix with 2 line:
%           1st line - sound intensity
%           2nd line - time (s)
%
%   sound_intensity = audio_sound_intensity(wav_file, method)
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
if (nargin == 1)
elseif (nargin == 2)
    if ~ischar(method) || (~ strcmp(method, 'nearest') && ~ strcmp(method, 'linear') && ~ strcmp(method, 'spline') && ~ strcmp(method, 'pchip') && ~ strcmp(method, 'cubic') && ~ strcmp(method, 'v5cubic'))
        error('Parameter 2 must be a string which must be one of them: ''linear'', ''''spline, ''pchip'', ''cubic'' or ''v5cubic''.');
    end
else
    error('There are too much parameters.');
end

% read .wav file
[wave, sample_rate, ~] = wavread(wav_file);

% Sound intensity, in my opinion, is the linking route of all max-extremum point.

% difference
loop_end_index = length(wave);
difference = zeros(loop_end_index, 1);
difference(1) = 0;
for index = 2 : loop_end_index
    difference(index) = wave(index) - wave(index - 1);
end

% get all all max-extremum point
max_extremum = zeros(loop_end_index, 1);
max_extremum_length = 0;
for index = 1 : loop_end_index - 1
    if difference(index) > 0 && difference(index + 1) < 0 && wave(index) > 0
        max_extremum_length = max_extremum_length + 1;
        max_extremum(max_extremum_length, 1) = wave(index);
        max_extremum(max_extremum_length, 2) = index;
    end
end
max_extremum = max_extremum(1 : max_extremum_length, :); % intercept

% interpolate
sound_intensity = zeros(length(wave), 2);
for index = 1 : loop_end_index - 1
    sound_intensity(index, 2) = index;
end
if(nargin == 1)
    sound_intensity(:, 1) = interp1(max_extremum(:, 2), max_extremum(:, 1), sound_intensity(:, 2));
else
    sound_intensity(:, 1) = interp1(max_extremum(:, 2), max_extremum(:, 1), sound_intensity(:, 2), method);
end

% check value
for index = 1 : loop_end_index
    if isnan(sound_intensity(index, 1)) == 1 || sound_intensity(index, 1) < 0
        sound_intensity(index, 1) = 0;
    end
end

% set time
sound_intensity(:, 2) = sound_intensity(:, 2) / sample_rate;

end
