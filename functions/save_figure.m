function save_figure(fig, figdir, name)
% Save a figure as PNG (200 dpi) in figdir.
print(fig, fullfile(figdir, [name '.png']), '-dpng', '-r200');
end
