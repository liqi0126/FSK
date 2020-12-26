function start_pos = position(signal, preamble_signal, preamble_length, f0, f1)
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
        if corr > 0.4
            max_corr = corr;
            start_pos = i;
            end_pos = min(i+2400, signal_length - preamble_length);
            for j = i: end_pos
                corr = corrcoef(preamble_signal, signal(j : j+preamble_length-1));
                corr = abs(corr(1,2));
                corrs = [corrs corr];
                if corr > max_corr
                    max_corr = corr;
                    start_pos = j;
                end
            end
%             plot(corrs);
            return
        end
        i = i + 1;
    end
%     plot(corrs);
end