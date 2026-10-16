function [xr, levels] = pcm_decode(bits, p)
% Serial bits -> n_bits words -> levels -> sensor values.
M = reshape(bits, p.n_bits, []).';
weights = 2.^(p.n_bits-1:-1:0).';
levels = (M*weights).';
xr = levels/(p.num_levels-1)*(p.v_max-p.v_min) + p.v_min;
end
