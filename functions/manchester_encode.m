function chips = manchester_encode(bits)
% Bit 0 -> [+1 -1],  Bit 1 -> [-1 +1]   (two chips per bit)
chips = zeros(1, 2*numel(bits));
chips(1:2:end) =  (1 - 2*bits);
chips(2:2:end) = -(1 - 2*bits);
end
