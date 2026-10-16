function [bits, num_invalid] = manchester_decode(corr, mode)
% MANCHESTER_DECODE  mode = 'hard' or 'soft'
%   hard: decide each chip first; pair [+1 -1]->0, [-1 +1]->1.
%         Invalid pairs ([+1 +1] or [-1 -1]) are DETECTED errors; the first
%         chip is used as a fallback (so effectively bit = first chip).
%   soft: decide on (c1 - c2) using BOTH correlator outputs (ML detection).
c1 = corr(1:2:end);
c2 = corr(2:2:end);
switch lower(mode)
    case 'soft'
        bits = double((c1 - c2) < 0);
        num_invalid = 0;
    case 'hard'
        h1 = (c1 < 0);              % true means chip = -1
        h2 = (c2 < 0);
        invalid = (h1 == h2);
        bits = double(h1);          % valid pairs: bit = (first chip == -1)
        num_invalid = sum(invalid);
    otherwise
        error('mode must be ''hard'' or ''soft''');
end
end
