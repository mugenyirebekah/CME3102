function tx = bpsk_modulate(chips, p)
% BPSK: each chip (+1/-1) multiplies one chip-length of carrier.
chip_wave = repelem(chips, p.sps);
carrier   = repmat(p.carrier_chip, 1, numel(chips));
tx = chip_wave .* carrier;
end
