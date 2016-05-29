function [features, sound_intensity, power, sharpness, title] = zzc_music(wav_file, frame_length_s, non_overlap_length_s)
%CACULATE MUSIC FEATURES of WAV FILE
%
%   [features, sound_intensity, power, sharpness, title]
%      = zzc_music(wav_file, frame_length_s, non_overlap_length_s)
%
%   Environment
%      1. Matlab R2012a
%      2. MIRtoolbox 1.6

% check parameter
if nargin == 1
    if ~ischar(wav_file) || strcmp(wav_file, '')
        error('Parameter must be a non-empty string.');
    end
    frame_length_s = 3;
    non_overlap_length_s = 1;
elseif nargin == 3
    if ~ischar(wav_file) || strcmp(wav_file, '')
        error('Parameter 1 must be a non-empty string.');
    end
    if ~isfloat(frame_length_s)
        error('Parameter 2 must be a double.');
    end
    if ~isfloat(non_overlap_length_s)
        error('Parameter 3 must be a double.');
    end
    if frame_length_s < non_overlap_length_s
        error('Parameter 2 should be no less than parameter 3.');
    end
else
    error('There must be 1 or 3 parameters.');
end

% Sound Intensity
sound_intensity = audio_sound_intensity(wav_file);
data_sound_intensity = sps_rebuild(sound_intensity, frame_length_s, non_overlap_length_s);

% Power
%
% ... segmenting the audio signal into 50% overlapping time frames of 50 ms width
% and then calculating the average power of each window ...
%
% by:
% Multi-Variate EEG Analysis as a Novel Tool to Examine Brain Responses to Naturalistic Music
%
% A little modify is included: overlapping time is 20 ms.
power = audio_power(wav_file, 0.05, 0.02);
data_power = sps_rebuild(power, frame_length_s, non_overlap_length_s);

% Sharpness
sharpness = audio_sharpness(power);
data_sharpness = sps_rebuild(sharpness, frame_length_s, non_overlap_length_s);

% frame
map_audio = miraudio(wav_file);
map_frame = mirframe(map_audio, 'Length', frame_length_s, 's', 'Hop', non_overlap_length_s, 's');
data_frame = mirgetdata(map_frame);
data_frame_number = size(data_frame, 2);

% Spectral Centroid
map_spectral_centroid = mircentroid(map_frame);
data_spectral_centroid = mirgetdata(map_spectral_centroid)';

% Spectral Entropy
map_spectral_entropy = mirentropy(map_frame);
data_spectral_entropy = mirgetdata(map_spectral_entropy)';

% Spectral Flux
map_spectral_flux = mirflux(map_frame);
data_spectral_flux = mirgetdata(map_spectral_flux)';

% Key Clarity
[~, map_key_clarity, ~] = mirkey(map_frame);
data_key_clarity = mirgetdata(map_key_clarity)';

% Mode
map_mode = mirmode(map_frame);
data_mode = mirgetdata(map_mode)';

% Fluctuation Centroid & Fluctuation Entropy
%
% This part is written originally by Wang Deqing <deqing.wang@foxmail.com>.
% Some modifications have been added.
data_fluctuation_centroid = zeros(data_frame_number ,1);
data_fluctuation_entropy = zeros(data_frame_number ,1);
for index = 0 : data_frame_number - 1
    segment = miraudio(map_audio, 'Extract', index, index + 3);
    fluc = mirfluctuation(segment,'summary');
    d_fluc = mirgetdata(fluc);
    data_fluctuation_centroid(index + 1) = audio_fluctuation_centroid(d_fluc);
    data_fluctuation_entropy(index + 1) = audio_fluctuation_entropy(d_fluc);
end

% Pulse Clarity
map_pulse_clarity = mirpulseclarity(map_audio, 'Frame', frame_length_s, 's', non_overlap_length_s, 's');
data_pulse_clarity = mirgetdata(map_pulse_clarity)';

% features
features = zeros(data_frame_number, 11);
for index = 1 : length(data_spectral_centroid)
    features(index, 1) = data_spectral_centroid(index);
end
for index = 1 : length(data_spectral_entropy)
    features(index, 2) = data_spectral_entropy(index);
end
for index = 1 : length(data_spectral_flux)
    features(index, 3) = data_spectral_flux(index);
end
for index = 1 : length(data_key_clarity)
    features(index, 4) = data_key_clarity(index);
end
for index = 1 : length(data_mode)
    features(index, 5) = data_mode(index);
end
for index = 1 : length(data_fluctuation_centroid)
    features(index, 6) = data_fluctuation_centroid(index);
end
for index = 1 : length(data_fluctuation_entropy)
    features(index, 7) = data_fluctuation_entropy(index);
end
for index = 1 : length(data_pulse_clarity)
    features(index, 8) = data_pulse_clarity(index);
end
for index = 1 : size(features, 1)
    features(index, 9) = data_sound_intensity(index);
end
for index = 1 : size(features, 1)
    features(index, 10) = data_power(index);
end
for index = 1 : size(features, 1)
    features(index, 11) = data_sharpness(index);
end
title = {'spectral_centroid', 'spectral_entropy', 'spectral_flux', ...
    'key_clarity', 'mode', 'fluctuation_centroid', ...
    'fluctuation_entropy', 'pulse_clarity', ...
    'sound_intensity', 'power', 'sharpness'};

% output
disp 'All Finished.'

end

function [sound_intensity, sample_rate] = audio_sound_intensity(wav_file, method)
%CACULATE SOUND INTENSITY of AUDIO WAVE
%
%   [sound_intensity, sample_rate] = audio_sound_intensity(wav_file)
%       Use 'linear' as the default interpolation method in tne end.
%       Return value 'sound_intensity' is a matrix with 2 columns:
%           1st column - sound intensity
%           2nd column - time (s)
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
        error('Parameter 2 must be a string which must be one of them: ''linear'', ''spline'', ''pchip'', ''cubic'' or ''v5cubic''.');
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
for index = 1 : loop_end_index
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

function sharpness = audio_sharpness(power)
%CACULATE SHARPNESS of AUDIO WAVE
%
%   sharpness = audio_sharpness(power)
%       Parameter 'power' must be the result of function 'audio_power'.
%       Return value 'sharpness' is a matrix with 2 columns:
%           1st column - sharpness
%           2nd column - time (s)

% check parameter
if length(size(power)) ~= 2
    error('Parameter must be a two-dimensional matrix.');
end

% calculate sharpness
loop_end_index = length(power);
sharpness = zeros(loop_end_index, 2);
for index = 2 : loop_end_index
    % Sharpness, defined as the mean positive first derivative of the waveform power.
    % Because of the descrete data and the short time interval,
    % interative differential method is used here to replace the derivation.
    sharpness(index, 1) = (power(index, 1) - power(index - 1, 1)) / ...
                            (power(index, 2) - power(index - 1, 2));
end
sharpness(1, 1) = sharpness(2, 1);
sharpness(:, 2) = power(:, 2);

end

function result = sps_rebuild(data, frame_length_s, non_overlap_length_s)
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
if ~isfloat(non_overlap_length_s)
    error('Parameter 3 must be a double.');
end
if frame_length_s < non_overlap_length_s
    error('Parameter 2 should be no less than parameter 3.');
end

% rebuild
next_time = frame_length_s;
selected_begin = 1;
result = zeros(ceil((ceil(data(end, 2)) - (frame_length_s - non_overlap_length_s)) / non_overlap_length_s), 1);
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
        next_time = next_time + non_overlap_length_s;
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
