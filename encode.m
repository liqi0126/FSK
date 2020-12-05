c = str2code('hello worldhello cckkkttlesdfworldhello worlo');

signals = encoder(c, [1 0 1 0 1 0 1 0]);
code = decode(signals, [1 0 1 0 1 0 1 0]);
code2str(code)

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

        temp_signal = my_FSK_mod(temp_code(1: pre_len+16+temp_len), fs, duration, f0, f1);
        window = ceil(fs * duration);
        
        %fortest = my_FSK_demod(temp_signal(24*window:length(temp_signal)), fs, duration, f0,f1);
        %fortest = my_FSK_demod(temp_signal, fs, duration, f0,f1);
        %length(fortest)
        %fortest(length(fortest)-8:length(fortest))
        
        signals = [signals, zeros(1, 200), temp_signal];
    end
    signals = [signals, zeros(1, 200)];
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