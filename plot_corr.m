function start_pos = plot_corr(signal, preamble_signal, preamble_length, t1, t2, f0, f1)
    %用定义好的带通滤波器对data进行滤波
    hd = design(fdesign.bandpass('N,F3dB1,F3dB2',6, f0-500, f1+500, 48000),'butter');
    signal = filter(hd, signal);
    
    signal_length = length(signal);
    i = 1;
    start_pos = -1;
    corrs  = [];
    while i < signal_length - preamble_length
        corr = corrcoef(preamble_signal, signal(i : i+preamble_length-1));
        corr = abs(corr(1,2));
        corrs = [corrs corr];
        i = i + 1;
    end
    figure;
    plot(corrs);
    hold on;
    xline(t1);
    xline(t2);
    hold off;
end