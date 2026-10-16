function [ts, xs] = sample_signal(t, x, p)
% Ideal sampling at p.fs by keeping every p.decim-th point.
idx = 1:p.decim:numel(x);
ts = t(idx);
xs = x(idx);
end
