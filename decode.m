function str = decode(signal, preamble_code)
    % constants
    fs = 48000;
    f0 = 4300;
    f1 = 6300;
    duration = 0.01;
    bit_length = ceil(fs * duration);
    preamble_bit_num = length(preamble_code);
    header_bit_num = 8;
    pre_bit_num = preamble_bit_num + header_bit_num;
    pre_length = pre_bit_num * bit_length;
    
    f = fopen('decoded_res.csv', 'w');
    
    %用定义好的带通滤波器对data进行滤波
    hd = design(fdesign.bandpass('N,F3dB1,F3dB2',6, f0-500, f1+500, fs),'butter');
    signal = filter(hd,signal);

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
    cnt=0;
    while i < available_len
        %strength = sum(abs(signal(i : i+preamble_prefix_length-1)))/preamble_prefix_length;
        %corr = corrcoef(preamble_standard, signal(i : i+preamble_length-1));
        %corr = corrcoef(preamble_prefix, signal(i : i+preamble_prefix_length-1));
        %corr = abs(corr(1,2));
        corr = center_corr(preamble_prefix, signal, preamble_prefix_length, i, available_len);
        is_match = 0;
        if corr > 0.65
            cnt = cnt+1;
            start_i = max(1, i-bit_length/2);
            end_i = min(i+bit_length/2, available_len);
            max_i = i;
            max_corr = 0;
            original_i = i;
%             original_i
            for i = start_i : end_i
                %corr = corrcoef(preamble_standard, signal(i : i+preamble_length-1));
                corr = corrcoef(preamble_prefix, signal(i : i+preamble_prefix_length-1));
                corr = abs(corr(1,2));
                if corr > max_corr
                    max_corr = corr;
                    max_i = i;
                end
            end
            i = original_i;
            if max_corr > 0.68
                whole_corr = corrcoef(preamble_standard, signal(max_i : max_i+preamble_length-1));
                whole_corr = abs(whole_corr(1,2));
                if whole_corr > 0.65
                    is_match = 1;
                    i = max_i;
                end
            end
        end
        if is_match == 1
            payload_length = decode_header(signal(i: i+pre_length-1), fs, duration, f0, f1, preamble_bit_num);
            if payload_length > 0
                start_pos = i + pre_length;
                end_pos = start_pos - 1 + payload_length*bit_length;
                if end_pos > length(signal)
                    break
                end
                payload_code = my_2FSK_demod(signal(i: end_pos), fs, duration, f0, f1);
                %size(payload_code)
                temp_code = payload_code(pre_bit_num+1:length(payload_code));
                temp_code_len = length(temp_code);
                if temp_code_len == payload_length
                    nonzero = 1;
                    for j = 1 : temp_code_len
                        if temp_code(j) == -1
                            nonzero = 0;
                            break;
                        end
                    end
                    if nonzero == 1
                        code = [code, temp_code];
                        packet_pos = [packet_pos i];
                        i
                        i = end_pos;
                        max_corr
                        payload_length
                        temp_code
                        for j = 1 : payload_length
                            if j == payload_length
                                fprintf(f,'%d\n', temp_code(j));%如果是最后一个，就换行
                            else
                                fprintf(f,'%d,', temp_code(j));%如果不是最后一个，就,
                            end
                        end
                    end
                end
            end
            is_match = 0;
        end
        i = i + bit_length;
    end
    packet_pos
    cnt
    fclose(f);
    str = code2str(code);
end


function code = decode_v0(signal, preamble_code)
    % constants
    fs = 48000;
    f0 = 4000;
    f1 = 6000;
    duration = 0.01;
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
    str = code2str(code);
end

function payload_length = decode_header_v0(signal, Fs, duration, f0, f1)
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

function payload_length = decode_header(signal, Fs, duration, f0, f1, preamble_bit_num)
    code = my_2FSK_demod(signal, Fs, duration, f0, f1);
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

function corr = center_corr(standard, signal, standard_len, pos, available_len)
    start_pos = max(1, pos-10);
    end_pos = min(pos+10, available_len);
    corr = 0;
    
    for i = start_pos:end_pos
        temp = corrcoef(standard, signal(i:i-1+standard_len));
        temp = abs(temp(1,2));
        if temp > corr
            corr = temp;
        end
    end
end