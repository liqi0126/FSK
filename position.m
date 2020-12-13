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
    while i < signal_length - preamble_length
        corr = corrcoef(preamble_signal, signal(i : i+preamble_length-1));
        corr = abs(corr(1,2));
        if corr > 0.8
            start_pos = i;
            return
        end
        i = i + 1;
    end
end