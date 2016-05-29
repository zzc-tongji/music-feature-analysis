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
