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
data_power = audio_power(input_wav_file, input_frame_length, input_frame_non_overlap, 'cubic');

% Sharpness
data_sharpness = audio_sharpness(data_power);

% frame & envelope
map_audio = miraudio(input_wav_file);
map_frame = mirframe(map_audio, 'Length', input_frame_length, 's', 'Hop', input_frame_non_overlap, 's');

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

% envelope & cheat
map_envelope = mirenvelope(map_audio, 'Tau', 0.02);
envelop_temp = mirgetdata(map_envelope);
wavwrite(envelop_temp, sample_rate / 16, 'temp.wav');
audio_temp = miraudio('temp.wav');
frame_temp = mirframe(audio_temp, 'Length', input_frame_length, 's', 'Hop', input_frame_non_overlap, 's');

% Fluctuation Centroid
map_fluctuation_centroid = mircentroid(frame_temp);
data_fluctuation_centroid = mirgetdata(map_fluctuation_centroid);

% Fluctuation Entropy
map_fluctuation_entropy = mirentropy(frame_temp);
data_fluctuation_entropy = mirgetdata(map_fluctuation_entropy);

% Pulse Clarity
map_pulse_clarity = mirpulseclarity(map_audio, 'Frame', input_frame_length, 's', input_frame_non_overlap, 's');
data_pulse_clarity = mirgetdata(map_pulse_clarity);

% clear
clear sample_rate audio_temp frame_temp envelop_temp
delete('temp.wav');

% output
disp 'All Finished.'
