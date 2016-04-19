% MAIN PROGRAM
%
% Running
%   zzc_music
%
% Environment
%   1. Matlab R2012a
%   2. MIRtoolbox

% input
input_wav_file = input('input_wav_file (non-empty filename) = ', 's');
input_frame_length = input('input_frame_length (double) = ');
input_frame_non_overlap = input('input_frame_non_overlap (double) = ');

% check parameter
if ~ischar(input_wav_file) || strcmp(input_wav_file, '')
    clear input_wav_file
    error('Parameter ''input_wav_file'' must be a non-empty string.');
end
if ~isfloat(input_frame_length)
    clear input_wav_file input_frame_length
    error('Parameter ''input_frame_length'' must be a double.');
end
if ~isfloat(input_frame_non_overlap)
    clear input_wav_file input_frame_length input_frame_non_overlap
    error('Parameter ''input_frame_non_overlap'' must be a double.');
end

% sample rate
[~, sample_rate, ~] = wavread(input_wav_file);

% Sound Intensity
data_sound_intensity = audio_sound_intensity(input_wav_file);

% Power
%
% ... segmenting the audio signal into 50% overlapping time frames of 50 ms width
% and then calculating the average power of each window ...
%
% by:
% Multi-Variate EEG Analysis as a Novel Tool to Examine Brain Responses to Naturalistic Music
data_power = audio_power(input_wav_file, 0.05, 0.025, 'cubic');

% Sharpness
data_sharpness = audio_sharpness(data_power);

% frame & envelope
map_audio = miraudio(input_wav_file);
map_frame = mirframe(map_audio, 'Length', input_frame_length, 's', 'Hop', input_frame_non_overlap, 's');
data_frame = mirgetdata(map_frame);
data_frame_number = size(data_frame, 2);

% Spectral Centroid
map_spectral_centroid = mircentroid(map_frame);
data_spectral_centroid = mirgetdata(map_spectral_centroid);

% Spectral Entropy
map_spectral_entropy = mirentropy(map_frame);
data_spectral_entropy = mirgetdata(map_spectral_entropy);

% Spectral Flux
map_spectral_flux = mirflux(map_frame);
data_spectral_flux = mirgetdata(map_spectral_flux);

% Key Clarity
[~, map_key_clarity, ~] = mirkey(map_frame);
data_key_clarity = mirgetdata(map_key_clarity);

% Mode
map_mode = mirmode(map_frame);
data_mode = mirgetdata(map_mode);

% Fluctuation Centroid & Fluctuation Entropy
%
% This part is written originally by Wang Deqing <deqing.wang@foxmail.com>.
% Some modifications have been added.
data_fluctuation_centroid = zeros(data_frame_number ,1);
data_fluctuation_entropy = zeros(data_frame_number ,1);
for index = 0 : data_frame_number - 1
    excerpt_0 = miraudio(input_wav_file, 'Extract', index, index + 3);
    excerpt = mirframe(excerpt_0, 'Length', 3, 's', 'Hop', 1/3,'/1');
    fluc = mirfluctuation(excerpt,'summary');
    d_fluc = mirgetdata(fluc);
    data_fluctuation_centroid(index + 1) = audio_fluctuation_centroid(d_fluc);
    data_fluctuation_entropy(index + 1) = audio_fluctuation_entropy(d_fluc);
end

% clear
clear sample_rate data_frame map_audio map_frame excerpt_0 excerpt index fluc d_fluc

% output
disp 'All Finished.'
