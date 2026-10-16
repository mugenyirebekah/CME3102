function [t, x] = generate_sensor_signal(p)
% Slowly varying sensor reading: baseline + sinusoid + sensor noise.
t = 0:1/p.analog_fs:p.duration-1/p.analog_fs;
x = p.baseline + p.amplitude*sin(2*pi*p.sensor_freq*t) ...
    + p.sensor_noise_std*randn(size(t));
end
