function [wave, sampling_rate] = pure_tone(frequency, time)
%GENERATE WAVE of PURE TONE
%
%   [wave, sampling_rate] = pure_tone(frequency, time)
%       All parameter must be doubles.
%       A silent wave will be generate if 'frequency' is not positive.

% check parameter
if ~isfloat(frequency)
    error('Parameter 1 must be a double.');
end
if ~isfloat(time)
    error('Parameter 2 must be a double.');
end

% generate
sampling_rate = 44100;
if frequency > 0
    wave = 0.5 * sin(2 * pi * frequency * time * linspace(0, 1, sampling_rate * time));
else
    wave = 0 * linspace(0, 1, sampling_rate * time);
end

end
