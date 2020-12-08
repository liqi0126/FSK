[signal, Fs] = audioread('res.wav');
signal = signal(:,1).';
code = decoder(signal, [0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1]);
code

function code = decoder(signal, preamble_code)
    % constants
    fs = 48000;
    f0 = 4000;
    f1 = 6000;
    duration = 0.025;
    bit_length = ceil(fs * duration);
    preamble_bit_num = length(preamble_code);
    header_bit_num = 8;
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
        if corr > 0.5
            i
            payload_length = decode_header(signal(i: i+pre_length-1), fs, duration, f0, f1);
            %payload_length
            start_pos = i + pre_length;
            end_pos = start_pos - 1 + payload_length*bit_length;
            [payload_code, fft_diff, start, window] = my_FSK_demod(signal(i: end_pos), fs, duration, f0, f1);
            %size(payload_code)
            code = [code, payload_code(pre_bit_num+1:length(payload_code))];
            %code(length(code)-8:length(code));
            i = end_pos;
        end
        i = i + bit_length;
    end
    %code
end

function payload_length = decode_header(signal, Fs, duration, f0, f1, preamble_bit_num)
    [code, fft_diff, start, window] = my_FSK_demod(signal, Fs, duration, f0, f1);
    code = code(preamble_bit_num:length(code));
    payload_length = 0;
    x = 1;
    for i = 1:8
        payload_length = payload_length + code(9-i)*x;
        x = x*2;
    end
end