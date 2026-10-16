function [corr, chips_hat] = bpsk_demodulate(rx, p)
% Coherent correlator: multiply each chip interval by the carrier and sum.
%   corr      : 1 x Nchips soft values (about +/-Ec plus noise)
%   chips_hat : hard decisions (+1/-1)
blocks = reshape(rx, p.sps, []);
corr = p.carrier_chip * blocks;
chips_hat = ones(size(corr));
chips_hat(corr < 0) = -1;
end
