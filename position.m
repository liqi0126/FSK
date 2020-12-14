function start_pos = position(signal, preamble_signal, preamble_length)
%     % constants
%     fs = 48000;
%     bit_length = ceil(fs * duration);
%     preamble_bit_num = length(preamble_code);
%     header_bit_num = 16;
%     pre_bit_num = preamble_bit_num + header_bit_num;
%     pre_length = pre_bit_num * bit_length;
%     
%     % generate standard preamble
%     preamble_standard = my_2FSK_mod(preamble_code, fs, duration, f0, f1);
%     preamble_length = length(preamble_standard);
    
    signal_length = length(signal);
    i = 1;
    start_pos = -1;
    corrs  = [];
    while i < signal_length - preamble_length
        corr = corrcoef(preamble_signal, signal(i : i+preamble_length-1));
        corr = abs(corr(1,2));
        corrs = [corrs corr];
        if corr > 0.25
            max_corr = corr;
            start_pos = i;
            end_pos = min(i+240, signal_length - preamble_length);
            for j = i: end_pos
                corr = corrcoef(preamble_signal, signal(j : j+preamble_length-1));
                if corr > max_corr
                    max_corr = corr;
                    start_pos = j;
                end
            end
            plot(corrs);
            return
        end
        i = i + 1;
    end
    plot(corrs);
end