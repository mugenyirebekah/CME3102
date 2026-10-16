
%% LAB8 - Industrial Sensor Telemetry Simulator
% Sensor -> Sampling -> 8-bit PCM -> Manchester -> BPSK -> AWGN
% -> BPSK demodulation -> Manchester decoding -> PCM -> Reconstruction
%
% Uses standard MATLAB functions only.
% No de2bi, bi2de, or awgn required.

clear; clc; close all;
rng(7);  % Repeatable results

%% 1. Simulation Configuration
fs = 100;                       % Sensor sampling frequency (Hz)
duration = 10;                  % Signal duration (s)
t = 0:1/fs:duration-1/fs;
num_samples = numel(t);

sensor_freq = 0.2;              % Slow sensor variation (Hz)
baseline = 50;                  % Illustrative baseline
amplitude = 25;                 % Sensor variation amplitude
sensor_noise_std = 1.5;         % Sensor noise

analog_signal = baseline + amplitude*sin(2*pi*sensor_freq*t) ...
                + sensor_noise_std*randn(size(t));

%% 2. Sampling and 8-bit PCM Quantization
% Use a fixed range for fair comparison across SNR values.
n_bits = 8;
min_val = 0;
max_val = 100;
num_levels = 2^n_bits;

clipped_signal = min(max(analog_signal, min_val), max_val);

quantized_levels = round((clipped_signal-min_val) ...
                  /(max_val-min_val)*(num_levels-1));

quantized_levels = max(0, min(num_levels-1, quantized_levels));

% Convert quantization levels to binary, most significant bit first.
binary_matrix = zeros(num_samples, n_bits);

for k = 1:n_bits
    binary_matrix(:,k) = bitget(uint16(quantized_levels), n_bits-k+1);
end

% Serialize the binary words into one bitstream.
bits_stream = reshape(binary_matrix.', 1, []);

%% 3. Manchester Line Coding
% Convention:
% Bit 0 -> [+1 -1]
% Bit 1 -> [-1 +1]

manchester_pairs = zeros(numel(bits_stream), 2);

manchester_pairs(bits_stream == 0,:) = ...
    repmat([1 -1], sum(bits_stream == 0), 1);

manchester_pairs(bits_stream == 1,:) = ...
    repmat([-1 1], sum(bits_stream == 1), 1);

manchester_chips = reshape(manchester_pairs.', 1, []);

%% 4. BPSK Modulation
% Each Manchester chip is transmitted using BPSK.
% Chip +1 multiplies the carrier by +1.
% Chip -1 multiplies the carrier by -1.

samples_per_chip = 20;
chip_rate = 1000;               % Chips per second
wave_fs = chip_rate*samples_per_chip;
fc = 100;                       % Carrier frequency (Hz)

sample_index = 0:samples_per_chip-1;

carrier_one_chip = cos(2*pi*fc*sample_index/wave_fs);

chip_waveform = repelem(manchester_chips, samples_per_chip);

carrier = repmat(carrier_one_chip, 1, numel(manchester_chips));

tx_signal = chip_waveform .* carrier;

%% 5. AWGN Channel
% Eb/N0 is specified per Manchester chip.
% The carrier has approximately 0.5 average power.
% This noise variance gives the corresponding coherent detector SNR.

EbNo_dB = 5;
EbNo_linear = 10^(EbNo_dB/10);

noise_variance = (samples_per_chip/4)/EbNo_linear;

rx_signal = tx_signal + ...
            sqrt(noise_variance)*randn(size(tx_signal));

%% 6. Coherent BPSK Demodulation
% Correlate each received chip interval with the carrier.
% Positive correlation means chip +1.
% Negative correlation means chip -1.

rx_blocks = reshape(rx_signal, samples_per_chip, []);

correlations = (carrier_one_chip * rx_blocks)';

rx_bipolar_chips = ones(size(correlations));
rx_bipolar_chips(correlations < 0) = -1;

%% 7. Manchester Decoding
% [+1 -1] -> bit 0
% [-1 +1] -> bit 1

rx_bipolar_pairs = reshape(rx_bipolar_chips, 2, []).';

rx_bits = zeros(size(bits_stream));

valid_zero = rx_bipolar_pairs(:,1) > 0 & ...
             rx_bipolar_pairs(:,2) < 0;

valid_one = rx_bipolar_pairs(:,1) < 0 & ...
            rx_bipolar_pairs(:,2) > 0;

rx_bits(valid_one) = 1;

% If a noise-corrupted pair is invalid, use the first chip
% as a fallback decision.
invalid_pairs = ~(valid_zero | valid_one);

rx_bits(invalid_pairs) = ...
    rx_bipolar_pairs(invalid_pairs,1) < 0;

%% 8. PCM Decoding and Reconstruction
% Convert the recovered serial bits into 8-bit words.

rx_binary_matrix = reshape(rx_bits, n_bits, []).';

rx_quantized_levels = zeros(size(rx_binary_matrix,1), 1);

for k = 1:n_bits
    rx_quantized_levels = rx_quantized_levels ...
        + double(rx_binary_matrix(:,k))*2^(n_bits-k);
end

% Convert quantization levels back to sensor values.
reconstructed_signal = ...
    (rx_quantized_levels.'/(num_levels-1)) ...
    *(max_val-min_val) + min_val;

%% 9. Error Analysis
num_bit_errors = sum(bits_stream ~= rx_bits);
ber = num_bit_errors/numel(bits_stream);

mse = mean((clipped_signal-reconstructed_signal).^2);

signal_power = mean(clipped_signal.^2);

if mse > 0
    reconstruction_snr_db = 10*log10(signal_power/mse);
else
    reconstruction_snr_db = Inf;
end

fprintf('\n--- Industrial Sensor Telemetry Results ---\n');
fprintf('Sensor samples: %d\n', num_samples);
fprintf('PCM bits transmitted: %d\n', numel(bits_stream));
fprintf('Manchester chips transmitted: %d\n', numel(manchester_chips));
fprintf('Eb/N0: %.1f dB\n', EbNo_dB);
fprintf('Bit errors after Manchester decoding: %d\n', num_bit_errors);
fprintf('BER: %.6f\n', ber);
fprintf('Reconstruction MSE: %.6f\n', mse);
fprintf('Reconstruction SNR: %.2f dB\n', reconstruction_snr_db);

%% 10. SNR Versus Reconstruction MSE
% Keep the same sensor signal and quantization range for every SNR.
% Average results over multiple independent noise trials.

EbNo_values = 0:5:20;
num_trials = 10;

mse_vs_snr = zeros(size(EbNo_values));
ber_vs_snr = zeros(size(EbNo_values));

for s = 1:numel(EbNo_values)

    current_EbNo = EbNo_values(s);
    current_linear = 10^(current_EbNo/10);

    current_noise_variance = ...
        (samples_per_chip/4)/current_linear;

    mse_trials = zeros(1, num_trials);
    ber_trials = zeros(1, num_trials);

    for trial = 1:num_trials

        % Transmit through an independent noise realization.
        trial_rx = tx_signal + ...
            sqrt(current_noise_variance)*randn(size(tx_signal));

        % Coherent BPSK detection.
        trial_blocks = reshape(trial_rx, samples_per_chip, []);

        trial_corr = (carrier_one_chip * trial_blocks)';

        trial_chip_signs = ones(size(trial_corr));
        trial_chip_signs(trial_corr < 0) = -1;

        % Manchester decoding.
        trial_pairs = reshape(trial_chip_signs, 2, []).';

        trial_bits = zeros(size(bits_stream));

        trial_zero = trial_pairs(:,1) > 0 & ...
                     trial_pairs(:,2) < 0;

        trial_one = trial_pairs(:,1) < 0 & ...
                    trial_pairs(:,2) > 0;

        trial_bits(trial_one) = 1;

        trial_invalid = ~(trial_zero | trial_one);

        trial_bits(trial_invalid) = ...
            trial_pairs(trial_invalid,1) < 0;

        % PCM decoding.
        trial_binary = reshape(trial_bits, n_bits, []).';

        trial_levels = zeros(size(trial_binary,1), 1);

        for k = 1:n_bits
            trial_levels = trial_levels ...
                + double(trial_binary(:,k))*2^(n_bits-k);
        end

        % Reconstruct the sensor measurements.
        trial_reconstruction = ...
            (trial_levels.'/(num_levels-1)) ...
            *(max_val-min_val) + min_val;

        % Calculate performance.
        mse_trials(trial) = ...
            mean((clipped_signal-trial_reconstruction).^2);

        ber_trials(trial) = mean(bits_stream ~= trial_bits);

    end

    mse_vs_snr(s) = mean(mse_trials);
    ber_vs_snr(s) = mean(ber_trials);

end

fprintf('\n--- SNR Sweep: Average of %d Trials ---\n', num_trials);
fprintf(' Eb/N0 (dB)       BER            MSE\n');

for s = 1:numel(EbNo_values)
    fprintf(' %6.1f        %.6f      %.6f\n', ...
        EbNo_values(s), ber_vs_snr(s), mse_vs_snr(s));
end

%% 11. Visualization
figure('Name','Industrial Sensor Telemetry Simulator', ...
       'Position',[80 60 1250 900]);

% Plot 1: Original and sampled signal.
subplot(4,2,1);

plot(t, analog_signal, 'b-', 'LineWidth', 1);
hold on;

stem(t(1:10:end), analog_signal(1:10:end), ...
    'r.', 'MarkerSize', 8);

grid on;
title('Original Sensor Signal and Example Samples');
xlabel('Time (s)');
ylabel('Sensor value');

legend('Sensor signal','Every 10th sample','Location','best');

% Plot 2: Quantized signal.
subplot(4,2,2);

stairs(t, quantized_levels, 'LineWidth', 1);

grid on;
title('8-bit PCM Quantization Levels');
xlabel('Time (s)');
ylabel('Level (0 to 255)');

% Plot 3: PCM bitstream.
subplot(4,2,3);

num_bits_plot = min(20, numel(bits_stream));

stairs(0:num_bits_plot-1, bits_stream(1:num_bits_plot), ...
    'LineWidth', 1.3);

grid on;
ylim([-0.2 1.2]);

title('PCM Serial Bitstream (First 20 Bits)');
xlabel('Bit index');
ylabel('Bit');

% Plot 4: Manchester-coded data.
subplot(4,2,4);

num_chips_plot = min(40, numel(manchester_chips));

stairs(0:num_chips_plot-1, manchester_chips(1:num_chips_plot), ...
    'LineWidth', 1.2);

grid on;
ylim([-1.4 1.4]);

title('Manchester-Coded Chips (First 40 Chips)');
xlabel('Chip index');
ylabel('Amplitude');

% Plot 5: Transmitted BPSK waveform.
subplot(4,2,5);

num_wave_plot = min(800, numel(tx_signal));

tx_time_plot = (0:num_wave_plot-1)/wave_fs;

plot(tx_time_plot, tx_signal(1:num_wave_plot), 'b');

grid on;
title('Transmitted BPSK Waveform (Zoomed)');
xlabel('Time (s)');
ylabel('Amplitude');

% Plot 6: Received noisy waveform.
subplot(4,2,6);

plot(tx_time_plot, rx_signal(1:num_wave_plot), 'm');

grid on;
title(sprintf('Received BPSK + AWGN (Eb/N0 = %.1f dB)', EbNo_dB));
xlabel('Time (s)');
ylabel('Amplitude');

% Plot 7: Original versus reconstructed signal.
subplot(4,2,7);

plot(t, clipped_signal, 'b-', 'LineWidth', 1);
hold on;

plot(t, reconstructed_signal, 'r--', 'LineWidth', 1);

grid on;
title(sprintf('Original vs Reconstructed (BER %.4g, MSE %.4g)', ...
    ber, mse));

xlabel('Time (s)');
ylabel('Sensor value');

legend('Original clipped signal','Reconstructed','Location','best');

% Plot 8: SNR versus reconstruction MSE.
subplot(4,2,8);

semilogy(EbNo_values, max(mse_vs_snr, eps), ...
    'o-', 'LineWidth', 1.5);

grid on;
title('Channel Eb/N0 vs Reconstruction MSE');
xlabel('Eb/N0 (dB)');
ylabel('Mean squared error');

% Separate BER graph.
figure('Name','BER versus Eb/N0');

semilogy(EbNo_values, max(ber_vs_snr, eps), ...
    's-', 'LineWidth', 1.5);

grid on;
title('BER versus Eb/N0');
xlabel('Eb/N0 (dB)');
ylabel('Bit error rate');

%% 12. Save Figures for the Report
if ~exist('figures','dir')
    mkdir('figures');
end

figHandles = findall(0, 'Type', 'figure');

for k = 1:numel(figHandles)
    figure(figHandles(k));

    saveas(figHandles(k), ...
        fullfile('figures', sprintf('figure_%02d.png', k)));
end

fprintf('\nFigures saved in the figures/ folder.\n');
