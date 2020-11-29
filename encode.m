c = str2code('hello worldhello worldhello world');
%size(c)
signals = encoder(c, [1 0 1 0 1 0 1 0]);
%size(signals)
code = decode(signals, [1 0 1 0 1 0 1 0]);
function signals = encoder(code, preamble_code)
    % constants
    fs = 48000;
    f0 = 10500;
    f1 = 12500;
    duration = 10*pi/f0;
    
    % seperate & encode
    signals = [];
    len = length(code);
    pre_len = length(preamble_code);
    temp_code = zeros(1, pre_len + 16 + 255);
    while len > 0
        % each package size <= 255
        if len > 255
            temp_code(25:279) = code(1: 255);
            temp_len = 255;
            code = code(256:len);
            len = len - 255;
        else
            temp_code(25:24+len) = code;
            temp_len = len;
            len = 0;
        end
        
        temp_code(1: pre_len) = preamble_code;
        temp_code(pre_len+1: pre_len+16) = [zeros(1, 8), uint8tobinary(temp_len)];
        %temp_len
        %temp_code(pre_len+1: pre_len+16)

        temp_signal = my_FSK_mod(temp_code(1: pre_len+16+temp_len), fs, duration, f0, f1);
        signals = [signals, zeros(1, 200), temp_signal];
    end
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
