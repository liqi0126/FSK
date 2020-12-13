function signals = encode(str, preamble_code)
    % constants
    fs = 48000;
    f0 = 4000;
    f1 = 6000;
    duration = 0.01;
    window = ceil(fs * duration);
    
    % seperate & encode
    code = str2code(str);
    signals = [];
    len = length(code);
    pre_len = length(preamble_code);
    temp_code = zeros(1, pre_len + 8 + 255);
    header_len = pre_len + 8;
    while len > 0
        % each package size <= 255
        if len > 255
            temp_code(header_len+1:header_len+255) = code(1: 255);
            temp_len = 255;
            code = code(256:len);
            len = len - 255;
        else
            temp_code(header_len+1:header_len+len) = code;
            temp_len = len;
            len = 0;
        end
        
        temp_code(1: pre_len) = preamble_code;
        %temp_code(pre_len+1: pre_len+16) = [zeros(1, 8), uint8tobinary(temp_len)];
        temp_code(pre_len+1: header_len) = uint8tobinary(temp_len);
        temp_signal = my_2FSK_mod(temp_code(1: header_len+temp_len), fs, duration, f0, f1);
        
        signals = [signals, zeros(1, 10*window), temp_signal];
    end
    signals = [zeros(1, 1*window), signals, zeros(1, 10*window)];
end

function binary_code = uint8tobinary(num)
    binary_code = zeros(1, 8);
    for i = 1 : 8
        binary_code(9-i) = bitand(num, 1);
        num = bitshift(num, -1);
    end
end

function str_code = str2code(string)
    unicode_values = double(string);
    str_len = length(unicode_values);
    str_code = zeros(1, str_len * 8);
    for i = 1: str_len
        str_code(i*8-7: i*8) = uint8tobinary(unicode_values(i));
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