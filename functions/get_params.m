function p = get_params()
% GET_PARAMS  All simulation parameters in one place.

p.seed = 7;                         % random seed (repeatable results)

% ---- Source / sampling ----
p.duration    = 10;                 % s
p.analog_fs   = 1000;               % Hz, dense grid standing in for "analog"
p.fs          = 100;                % Hz, real sensor sampling rate
p.decim       = p.analog_fs/p.fs;   % keep every 10th analog point
p.sensor_freq = 0.2;                % Hz, slow sensor variation
p.baseline    = 50;                 % sensor baseline (e.g. degC)
p.amplitude   = 40;                 % uses most of the quantizer range
p.sensor_noise_std = 1.5;

% ---- PCM ----
p.n_bits     = 8;
p.v_min      = 0;
p.v_max      = 100;
p.num_levels = 2^p.n_bits;
p.delta      = (p.v_max-p.v_min)/(p.num_levels-1);   % quantizer step

% ---- Rates ----
p.bit_rate  = p.fs*p.n_bits;        % 800 bit/s
p.chip_rate = 2*p.bit_rate;         % Manchester: 2 chips per bit = 1600 chip/s

% ---- BPSK waveform ----
p.sps = 20;                         % waveform samples per chip
p.wave_fs = p.chip_rate*p.sps;      % 32 kHz
p.cycles_per_chip = 2;              % INTEGER number of carrier cycles per chip
p.fc = p.cycles_per_chip*p.chip_rate;   % 3200 Hz carrier
n = 0:p.sps-1;
p.carrier_chip = cos(2*pi*p.fc*n/p.wave_fs);   % one chip of carrier
p.chip_energy  = sum(p.carrier_chip.^2);       % = sps/2 = 10

% ---- Bandwidth for the Shannon discussion ----
% Null-to-null bandwidth of BPSK with rectangular chips = 2 x chip rate.
p.bandwidth = 2*p.chip_rate;        % 3200 Hz

% ---- Channel experiments ----
p.demo_EbN0_dB  = 6;                % Eb/N0 (per BIT) for the stage plots
p.sweep_EbN0_dB = -4:2:14;
p.num_trials    = 30;
end
