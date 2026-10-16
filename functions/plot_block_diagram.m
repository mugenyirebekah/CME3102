function fig = plot_block_diagram()
% Draws the complete system block diagram.
fig = figure('Color','w','Position',[50 50 1300 480]);
ax = axes('Position',[0 0 1 1]); axis(ax,[0 100 0 52]); axis off; hold on;

tx_names = {'Sensor\newline(analog)','Sampler\newline100 Hz','PCM encoder\newline8-bit','Manchester\newlineencoder','BPSK\newlinemodulator'};
rx_names = {'AWGN\newlinechannel','BPSK\newlinedemodulator','Manchester\newlinedecoder','PCM decoder\newline8-bit','Reconstructed\newlinesignal'};
xc = [10 30 50 70 90];  w = 15;  h = 10;
y1 = 33;  y2 = 8;

for k = 1:5
    rectangle('Position',[xc(k)-w/2 y1 w h],'Curvature',0.2,'FaceColor',[0.80 0.90 1.00],'EdgeColor','k','LineWidth',1.2);
    text(xc(k), y1+h/2, tx_names{k}, 'HorizontalAlignment','center','FontSize',11);
    if k == 1, col = [1.00 0.85 0.85]; elseif k == 5, col = [0.80 0.95 0.80]; else, col = [0.85 0.95 0.85]; end
    rectangle('Position',[xc(k)-w/2 y2 w h],'Curvature',0.2,'FaceColor',col,'EdgeColor','k','LineWidth',1.2);
    text(xc(k), y2+h/2, rx_names{k}, 'HorizontalAlignment','center','FontSize',11);
end
for k = 1:4
    quiver(xc(k)+w/2, y1+h/2, 20-w-0.5, 0, 0, 'k','LineWidth',1.5,'MaxHeadSize',1.5);
    quiver(xc(k)+w/2, y2+h/2, 20-w-0.5, 0, 0, 'k','LineWidth',1.5,'MaxHeadSize',1.5);
end
% connection from modulator (top right) to channel (bottom left)
plot([90 90],[y1 25],'k-','LineWidth',1.5);
plot([90 10],[25 25],'k-','LineWidth',1.5);
quiver(10, 25, 0, y2+h-25-0.3, 0, 'k','LineWidth',1.5,'MaxHeadSize',2);

text(2, 48, 'TRANSMITTER','FontWeight','bold','FontSize',12);
text(2, 4,  'RECEIVER','FontWeight','bold','FontSize',12);
text(50, 49.5, 'Industrial Sensor Telemetry: End-to-End Chain','HorizontalAlignment','center','FontWeight','bold','FontSize',13);
text(50, 27, 'transmitted BPSK waveform','HorizontalAlignment','center','FontSize',10,'BackgroundColor','w');
end
