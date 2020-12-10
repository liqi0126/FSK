function signal = my_kFSK_mod(code, Fs, duration, f_seq)
% code: squence to encode
% Fs: sampling frequence
% duration: hold-on time
% f: a list of freqency for encoding

cLen = length(code);

window = ceil(Fs * duration);
t = (0:window-1)/Fs;

cNum = length(f_seq);
sig = zeros(cNum, window);
for i = 1:cNum
    sig(i, :) = sin(2*pi*f_seq(i)*t);
end

signal = zeros(1, window*cLen);
for i = 1:cLen
    signal((i-1)*window+(1:window)) = sig(code(i)+1, :);
end

end

