function [ber_hard, ber_soft, mse_hard, mse_soft] = theory(EbN0_dB, p)
% THEORY  Predicted BER and MSE versus Eb/N0 (per bit).
%   Soft Manchester+BPSK = ideal BPSK:  Pb = Q(sqrt(2 Eb/N0))
%   Hard (first-chip) decision:         Pb = Q(sqrt(Eb/N0))   (3 dB worse)
%   MSE ~ delta^2/12 (quantization) + Pb * delta^2 * (4^n - 1)/3
%   (a flipped bit j has weight delta*2^j; assumes independent bit errors)
EbN0 = 10.^(EbN0_dB/10);
ber_soft = q_function(sqrt(2*EbN0));
ber_hard = q_function(sqrt(EbN0));
floor_q = p.delta^2/12;
k = p.delta^2*(4^p.n_bits - 1)/3;
mse_soft = floor_q + k*ber_soft;
mse_hard = floor_q + k*ber_hard;
end
