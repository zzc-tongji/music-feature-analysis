function [features, sound_intensity, power, sharpness, title] = zzc_music(wav_file)
%CACULATE MUSIC FEATURES of WAV FILE
%
%   [features, sound_intensity, power, sharpness, title]
%      = zzc_music(wav_file)
%
%   Environment
%      1. Matlab R2012a
%      2. MIRtoolbox 1.6

% check parameter
if ~ischar(wav_file) || strcmp(wav_file, '')
    clear input_wav_file
    error('Parameter ''input_wav_file'' must be a non-empty string.');
end

% set frame information
frame_length_s = 3;
frame_non_overlap_s = 1;

% Sound Intensity
sound_intensity = audio_sound_intensity(wav_file);

% Power
%
% ... segmenting the audio signal into 50% overlapping time frames of 50 ms width
% and then calculating the average power of each window ...
%
% by:
% Multi-Variate EEG Analysis as a Novel Tool to Examine Brain Responses to Naturalistic Music
power = audio_power(wav_file, 0.05, 0.025);

% Sharpness
sharpness = audio_sharpness(power);

% frame
map_audio = miraudio(wav_file);
map_frame = mirframe(map_audio, 'Length', frame_length_s, 's', 'Hop', frame_non_overlap_s, 's');
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
map_pulse_clarity = mirpulseclarity(map_audio, 'Frame', frame_length_s, 's', frame_non_overlap_s, 's');
data_pulse_clarity = mirgetdata(map_pulse_clarity)';

% features
features = zeros(data_frame_number, 8);
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
title = {'spectral_centroid', 'spectral_entropy', 'spectral_flux', ...
    'key_clarity', 'mode', 'fluctuation_centroid', ...
    'fluctuation_entropy', 'pulse_clarity'};

% output
disp 'All Finished.'

end
