function m = compute_metrics(xc, xr, bits, bits_hat)
% BER, MSE and reconstruction SNR (signal power = variance, i.e. DC removed).
m.num_errors = sum(bits ~= bits_hat);
m.ber = m.num_errors/numel(bits);
m.mse = mean((xc - xr).^2);
m.snr_db = 10*log10(var(xc)/m.mse);
end
