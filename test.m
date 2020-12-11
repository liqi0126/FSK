[signal, Fs] = audioread('res.wav');
size(signal)
signal = signal(:,1).';

code = decoder(signal, [0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1]);
%code = decoder(signal, [0 1]);
%code

fs = 48000;
f0 = 4000;
f1 = 6000;
duration = 0.025;

% preamble_standard = my_2FSK_mod([0 1], fs, duration, f0, f1);
% preamble_length = length(preamble_standard);
% preamble_length
% corrcoef(preamble_standard, signal(159601 : 159600+preamble_length))

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
    preamble_standard = my_2FSK_mod(preamble_code, fs, duration, f0, f1);
    preamble_length = length(preamble_standard);
    
    % generate standard preamble prefix
    preamble_prefix = my_2FSK_mod(preamble_code(1:2), fs, duration, f0, f1);
    preamble_prefix_length = length(preamble_prefix);
    
    code = [];
    signal_length = length(signal);
    available_len = signal_length - preamble_length;
    i = 1;
    packet_pos = [];
    while i < available_len
        corr = corrcoef(preamble_standard, signal(i : i+preamble_length-1));
        %corr = corrcoef(preamble_prefix, signal(i : i+preamble_prefix_length-1));
        corr = corr(1,2);
        is_match = 0;
        if corr > -0.2
            start_i = max(1, i-301);
            end_i = min(i+301, available_len);
            max_i = i;
            max_corr = corr;
            original_i = i;
%             original_i
            for i = start_i : end_i
                %corr = corrcoef(preamble_standard, signal(i : i+preamble_length-1));
                corr = corrcoef(preamble_prefix, signal(i : i+preamble_prefix_length-1));
                corr = corr(1,2);
                if corr > max_corr
                    max_corr = corr;
                    max_i = i;
                end
            end
            i = original_i;
            if max_corr > 0.7
                whole_corr = corrcoef(preamble_standard, signal(max_i : max_i+preamble_length-1));
                whole_corr = whole_corr(1,2);
                if whole_corr > 0.7
                    is_match = 1;
                    i = max_i;
                    packet_pos = [packet_pos i];
                end
            end
        end
        if is_match == 1
            payload_length = decode_header(signal(i: i+pre_length-1), fs, duration, f0, f1, preamble_bit_num);
            if payload_length > 0
                start_pos = i + pre_length;
                end_pos = start_pos - 1 + payload_length*bit_length;
                [payload_code, fft_diff, start, window] = my_2FSK_demod(signal(i: end_pos), fs, duration, f0, f1);
                %size(payload_code)
                temp_code = payload_code(pre_bit_num+1:length(payload_code));
                i
                max_corr
                payload_length
                temp_code
                code = [code, temp_code];
                i = end_pos;
                is_match = 0;
            end
        end
        i = i + 600;
    end
    packet_pos
end

function payload_length = decode_header(signal, Fs, duration, f0, f1, preamble_bit_num)
    [code, fft_diff, start, window] = my_2FSK_demod(signal, Fs, duration, f0, f1);
    code = code(preamble_bit_num+1:length(code));
    payload_length = 0;
    x = 1;
    if length(code) < 8
        payload_length = -1;
        return
    end
    for i = 1:8
        if x == -1
            payload_length = -1;
            return
        end
        payload_length = payload_length + code(9-i)*x;
        x = x*2;
    end
end