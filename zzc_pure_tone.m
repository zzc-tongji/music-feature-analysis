function [wave, sample_rate] = zzc_pure_tone(frequency, time, sample_rate)
%GENERATE WAVE of PURE TONE
%
%   [wave, sample_rate] = zzc_pure_tone(frequency, time, sample_rate)
%
%   ----------
%
%   Parameter 'frequency' indicates the frequency of the sound.
%       If it is not positive, a period of silent time will be generated.
%       If it is undefined, the default value is 44100.
%
%   Parameter 'time' indicates the time of the sound.
%
%   Parameter 'sample_rate' indicates the sampling rate of the sound.
%
%   All parameters must be doubles.
%
%   ----------
%
%   Return value 'wave' is the wave of the sound, which has the sampling rate
%       indicated by return value 'sample_rate'.
%
%   ----------
%
%   After executing this function, you can use this instruction to generate the sound:
%       wavwrite(wave, sample_rate, 'sound.wav');

% check parameter
if nargin == 2
    if ~isfloat(frequency)
        error('Parameter 1 must be a double.');
    end
    if ~isfloat(time)
        error('Parameter 2 must be a double.');
    end
    sample_rate = 44100;
elseif nargin == 3
    if ~isfloat(frequency)
        error('Parameter 1 must be a double.');
    end
    if ~isfloat(time)
        error('Parameter 2 must be a double.');
    end
     if ~isfloat(sample_rate)
        error('Parameter 3 must be a double.');
    end
end

% generate
if frequency > 0
    wave = 0.5 * sin(2 * pi * frequency * time * linspace(0, 1, sample_rate * time));
else
    wave = 0 * linspace(0, 1, sample_rate * time);
end

end
