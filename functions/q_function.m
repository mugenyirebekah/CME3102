function y = q_function(x)
% Gaussian tail probability Q(x) (no toolbox needed).
y = 0.5*erfc(x/sqrt(2));
end
