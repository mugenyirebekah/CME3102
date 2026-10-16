function [rx, sigma2] = awgn_channel(tx, EbN0_dB, p)
% AWGN channel with noise set from Eb/N0 PER INFORMATION BIT.
%   Chip energy Ec = sum(carrier_chip^2) = 10.  Eb = 2*Ec (2 chips/bit).
%   Per-sample noise variance sigma2 = N0/2  ->  Eb/N0 = 2*Ec/(2*sigma2)
%   => sigma2 = Ec / (Eb/N0).
EbN0 = 10^(EbN0_dB/10);
sigma2 = p.chip_energy / EbN0;
rx = tx + sqrt(sigma2)*randn(size(tx));
end
