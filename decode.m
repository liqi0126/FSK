function code = decode(signal, preamble_code)
    % constants
    fs = 48000;
    f0 = 10500;
    f1 = 12500;
    duration = 10*pi/f0;
    bit_length = ceil(fs * duration);
    preamble_bit_num = length(preamble_code);
    header_bit_num = 16;
    pre_bit_num = preamble_bit_num + header_bit_num;
    pre_length = pre_bit_num * bit_length;

    % generate standard preamble
    preamble_standard = my_FSK_mod(preamble_code, fs, duration, f0, f1);
    preamble_length = length(preamble_standard);
    
    code = [];
    signal_length = length(signal);
    i = 1;
    while i < signal_length - preamble_length
        corr = corrcoef(preamble_standard, signal(i : i+preamble_length-1));
        if corr > 0.9
            %i
            payload_length = decode_header(signal(i: i+pre_length-1), fs, duration, f0, f1);
            %payload_length
            start_pos = i + pre_length;
            end_pos = start_pos - 1 + payload_length*bit_length;
            [payload_code, fft_diff, start, window] = my_FSK_demod(signal(i: end_pos), fs, duration, f0, f1);
            %size(payload_code)
            code = [code, payload_code(25:length(payload_code))];
            code(length(code)-8:length(code));
            i = end_pos;
        end
        i = i + 1;
    end
    %code
end

function payload_length = decode_header(signal, Fs, duration, f0, f1)
    [code, fft_diff, start, window] = my_FSK_demod(signal, Fs, duration, f0, f1);
    code = code(17:24);
    payload_length = 0;
    x = 1;
    for i = 1:8
        payload_length = payload_length + code(9-i)*x;
        x = x*2;
    end
end

function str = code2str(code)
    code_len = length(code);
    str_len = floor(code_len/8);
    unicode_values = zeros(1, str_len);
    for i = 1: str_len
        val = 0;
        x = 1;
        for j = i*8: -1 :i*8-7
            val = val + code(j)*x;
            x = x*2;
        end
        unicode_values(i) = val;
    end
    str = char(unicode_values);
end