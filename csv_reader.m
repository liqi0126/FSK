[signal, Fs] = audioread('res.wav');
size(signal)
signal = signal(:,1).';
%用定义好的带通滤波器对data进行滤波
hd = design(fdesign.bandpass('N,F3dB1,F3dB2',6, f0-500, f1+500, fs),'butter');
signal = filter(hd,signal);

filename = "content.csv";
onsets = csvread(filename, 5, 0);
onsets = onsets(:, 4);

% constants
fs = 48000;
f0 = 4000;
f1 = 6000;
duration = 0.025;
bit_length = ceil(fs * duration);
prelen = 28*bit_length;

f = fopen('decoded_res.csv', 'w');
packet_num = length(onsets);
for i = 1 : packet_num
    onset = onsets(i);
    payload_length = decode_header(signal(onset: onset+prelen-1), fs, duration, f0, f1, 20);
    payload_length
    start_pos = onset;
    end_pos = onset + (28 + payload_length) * bit_length - 1;
    payload_code = my_kFSK_demod(signal(start_pos: end_pos), fs, duration, [f0 f1]);
    temp_code = payload_code(29:length(payload_code));
    for j = 1 : payload_length
        if j == payload_length
             fprintf(f,'%d\n', temp_code(j));%如果是最后一个，就换行
        else
             fprintf(f,'%d,', temp_code(j));%如果不是最后一个，就,
        end
    end
end
fclose(f);


function payload_length = decode_header(signal, Fs, duration, f0, f1, preamble_bit_num)
    code = my_kFSK_demod(signal, Fs, duration, [f0 f1]);
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