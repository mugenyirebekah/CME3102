function r = run_channel_and_decode(tx, bits, xc, EbN0_dB, p)
% One pass: AWGN -> BPSK demod -> Manchester decode (hard AND soft) -> PCM decode.
[rx, sigma2] = awgn_channel(tx, EbN0_dB, p);
[corr, chips_hat] = bpsk_demodulate(rx, p);

[bits_h, ninv] = manchester_decode(corr, 'hard');
[bits_s, ~]    = manchester_decode(corr, 'soft');

xr_h = pcm_decode(bits_h, p);
xr_s = pcm_decode(bits_s, p);

r.hard = compute_metrics(xc, xr_h, bits, bits_h);
r.soft = compute_metrics(xc, xr_s, bits, bits_s);
r.hard.bits = bits_h;  r.hard.xr = xr_h;
r.soft.bits = bits_s;  r.soft.xr = xr_s;

r.rx = rx;  r.corr = corr;  r.chips_hat = chips_hat;
r.sigma2 = sigma2;  r.num_invalid = ninv;
end
