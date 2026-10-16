function [bits, levels, xc] = pcm_encode(xs, p)
% PCM_ENCODE  Clip, uniformly quantize to n_bits, serialize MSB first.
%   bits   : 1 x (n_bits*N) serial bitstream
%   levels : 1 x N integer levels 0..2^n_bits-1
%   xc     : clipped input (what the quantizer actually sees)
xc = min(max(xs, p.v_min), p.v_max);
levels = round((xc-p.v_min)/(p.v_max-p.v_min)*(p.num_levels-1));

M = zeros(numel(levels), p.n_bits);
for k = 1:p.n_bits
    M(:,k) = bitget(uint16(levels(:)), p.n_bits-k+1);
end
bits = reshape(M.', 1, []);        % word 1 (MSB..LSB), word 2, ...
end
